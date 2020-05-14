import numpy as np
import math
import logging,sys
import rotatefill
from scipy.fftpack import ifftshift
from scipy.fftpack import fft2
from scipy.fftpack import ifft2
import matplotlib.pyplot as plt
import ctemh_cryoFrank
import myio
import p
import annularMask
import multiprocessing
from functools import partial
from contextlib import contextmanager
from scipy.ndimage.interpolation import shift
import mrcfile
import gc
import warnings
import time
import os
import q2Spider
from pylab import imshow
import time

warnings.simplefilter(action='ignore',category=FutureWarning)
'''
Copyright (c) UWM, Ali Dashti 2016 (original matlab version)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Copyright (c) Columbia University Hstau Liao 2018 (python version)    
Copyright (c) Columbia University Sonya Hanson 2018 (python version)    
Copyright (c) UWM, Peter Schwander 2019 (python version)    
'''

_logger = logging.getLogger(__name__)
_logger.setLevel(logging.DEBUG)


@contextmanager

def poolcontext(*args, **kwargs):
    pool = multiprocessing.Pool(*args, **kwargs)
    yield pool
    pool.terminate()

def num_proc(n):
    k = 0
    while k**2 < n:
        k+=1
    return k

def divide(k,inc):
    l = []
    for i in range(k):
        for j in range(i,k):  # for each block
            for p in [0, 1]:
                if (j - i > 0 or p == 0):
                    l.append([i, j, p, inc])
    return l

def conquer(ll,fy,CTF,d,M):
    inc = ll[3]
    p = ll[2]
    ic = ll[0]*inc
    jc = ll[1]*inc
    kc = jc - ic

    for x in range(ic,ic+inc):
        x1 = x - ic
        fy0 = fy[x, :, :]
        CTF0 = CTF[x, :, :]
        for y in range(jc,jc+inc):
            y1 = y-jc
            if (x < M and y < M):
                if (x != y) and ((p == 0 and y - x >= kc) or (p == 1 and y - x < kc)):
                    d[x1, y1] = np.linalg.norm(CTF0 * fy[y, :, :] - CTF[y, :, :] * fy0) ** 2
    return d

def fillin(ll,D,d,M):
    inc = ll[3]
    p = ll[2]
    ic = ll[0]*inc
    jc = ll[1]*inc
    kc = jc - ic

    for x in range(ic,ic+inc):
        x1 = x - ic
        for y in range(jc,jc+inc):
            if (x < M and y < M):
                if (x!=y) and ((p == 0 and y - x >= kc) or (p == 1 and y - x < kc)):
                    y1 = y-jc
                    D[x,y] = d[x1,y1]
    return D
def create_grid(N,N2):
    try:
        assert(N > 0)
    except AssertionError:
        _logger.error('non-positive image size')
        _logger.exception('non-positive image size')
        raise
        sys.exit(1)
    if N%2 == 1: 
        a = np.arange(-(N-1)/2,(N-1)/2+1)
    else:        
        a = np.arange(-N2,N/2)
    X, Y = np.meshgrid(a,a)

    Q = (1./(N/2.))*np.sqrt(X**2+Y**2)
    return Q

def create_filter(filter_type,NN,Qc,Q):
    
    if filter_type == 'Gauss':
        G = np.exp(-(np.log(2)/2.)*(Q/Qc)**2)
    elif filter_type == 'Butter':
        G = np.sqrt(1./(1+(Q/Qc)**(2*NN)))
    else:
        _logger.error('%s filter is unsupported'%(filter_type))
        _logger.exception('%s filter is unsupported'%(filter_type))
        raise
        sys.exit(1)  
    return G

def calc_avg_pd(q,nS):
    try:
        assert(q.shape[0] > 3)
    except AssertionError:
        _logger.error('quaternion has wrong dimensions')
        _logger.exception('quaternion has wrong dimensions')
        raise
        sys.exit(1)   
    # Calculate average projection directions (from matlab code)
    """PDs = 2*[q(2,:).*q(4,:) - q(1,:).*q(3,:);...
    q(1,:).*q(2,:) + q(3,:).*q(4,:); ...
    q(1,:).^2 + q(4,:).^2 - ones(1,nS)/2 ];
    """
    PDs = 2*np.vstack((q[1,:]*q[3,:]-q[0,:]*q[2,:],
                 q[0,:]*q[1,:] + q[2,:]*q[3,:],
		 q[0,:]**2 + q[3,:]**2 - np.ones((1,nS))/2.0))
    return PDs

def get_psi(q,PD,iS):
    try:
        assert(q.shape[0] > 3)
    except AssertionError:
        _logger.error('quaternion has wrong dimensions')
        _logger.exception('quaternion has wrong dimensions')
        raise
        sys.exit(1)   
    # Quaternion approach
    #s = -(1+PD(3))*q(4,iS) - PD(1)*q(2,iS) - PD(2)*q(3,iS);
    #c =  (1+PD(3))*q(1,iS) + PD(2)*q(2,iS) - PD(1)*q(3,iS);
    s = -(1+PD[2])*q[3,iS] - PD[0]*q[1,iS] - PD[1]*q[2,iS]
    c =  (1+PD[2])*q[0,iS] + PD[1]*q[1,iS] - PD[0]*q[2,iS]
    Psi = 2*np.arctan(s/c)  # note that the Psi are in the interval [-pi,pi]

    return (Psi,s,c)

def psi_ang(PD):
    lPD = sum(PD**2)
    Qr = np.array([1 + PD[2], PD[1], -PD[0], 0])
    Qr = Qr / np.sqrt(np.sum(Qr**2))
    phi,theta,psi = q2Spider.op(Qr)

    psi = np.mod(psi,2*np.pi)*(180/np.pi)
    return psi


def op(input_data,filterPar, imgFileName, sh, nStot, options):

    ind = input_data[0]
    q = input_data[1]
    df = input_data[2]
    outFile = input_data[3]
    prD = input_data[4]
    nS = ind.shape[0]   # size of bin; ind are the indexes of particles in that bin
    # auxiliary variables
    N = p.nPix #emPar['nPix']
    N2 = N/2.
    # initialize arrays
    Psis = np.nan*np.ones((nS,1)) # psi angles
    Nom = np.nan*np.ones((nS,1))
    Dnom = np.nan*np.ones((nS,1))
    # different types of averages of aligned particles of the same view
    #imgAvg = np.zeros((N,N)) # simple average
    #imgAvgFlip = np.zeros((N,N))  # average of phase-flipped particles
    #imgAllFlip = np.zeros((nS,N,N)) # all the averages of phase-flipped particles
    imgAll = np.zeros((nS,N,N)) #

    y = np.zeros((N**2, nS)) # each row is a flatten image
    fy = np.complex(0)*np.ones((nS,N,N)) # each (i,:,:) is a Fourier image
    CTF = np.zeros((nS,N,N))  # each (i,:,:) is the CTF
    D = np.zeros((nS,nS))   # distances among the particles in the bin
    msk = annularMask.op(0,N2,N,N)
    # read images with conjugates
    imgLabels = np.zeros(nS,dtype=int)
    for iS in xrange(nS):
        if ind[iS] < nStot/2: # first half data set; i.e., before augmentation
            indiS = ind[iS]
            imgLabels[iS] = 1
        else: # second half data set; i.e., the conjugates
            indiS = ind[iS]-nStot/2
            imgLabels[iS] = -1
            # matlab version: y[:,iS] = m.Data(ind(iS)).y
        start = N**2*indiS*4
        if not options['relion_data']: # spider data
            tmp = np.memmap(imgFileName, dtype='float32', offset=start, mode='r', shape=(N,N))
            # store each flatted image in y
            tmp = tmp.T  # numpy mapping is diff from matlab's
        else: # relion data
            tmp = mrcfile.mmap(imgFileName,'r')
            tmp.is_image_stack()
            tmp = tmp.data[indiS]
            #shi = (sh[1][indiS]-0.5, sh[0][indiS]-0.5)
            #tmp = shift(tmp, shi, order=3, mode='wrap')
        if ind[iS] >= nStot/2: # second half data set
            tmp = np.flipud(tmp)
        # normalizing
        #backg = tmp*(1-msk)
        #try:
        #    tmp = (tmp - backg.mean())/backg.std()
        #except:
        #    pass
        # store each flatted image in y
        y[:,iS] = tmp.flatten('F')

    # create grid for filter G and CTF
    Q = create_grid(N,N2)
    '''
    G = create_filter(filterPar['type'],filterPar['N'],filterPar['Qc'],Q)
    G = ifftshift(G)
    # filter each image in the bin
    for iS in xrange(nS):
        img = y[:,iS].reshape(-1,N).transpose()
        img = ifft2(fft2(img)*G).real
        y[:,iS] = img.real.flatten('F')
    '''
    print "entered single processing"
    # Calculate average projection directions
    PDs = calc_avg_pd(q,nS)
    # reference PR is the average
    PD = np.sum(PDs,1)
    # make it a unit vector
    PD = PD/np.linalg.norm(PD)
    psi_p = psi_ang(PD)
    # looping for all the images in the bin
    for iS in xrange(nS):
        # Get the psi angle
        Psi,s,c = get_psi(q,PD,iS)
        
        if np.isnan(Psi): # this happens only for a rotation of pi about an axis perpendicular to the projection direction
            Psi = 0
        Psis[iS] = Psi  # save image rotations
        Dnom[iS] = c  # save denominator
        Nom[iS] = s   # save nominator

        # inplane align the images
        img = y[:,iS].reshape(-1,N).transpose()*msk # convert to matlab convention prior to rotation

        img = rotatefill.op(img, -(180 / math.pi) * Psi, visual=False)

        img = rotatefill.op(img, -psi_p, visual=False)

        """img = imrotate(img,-(180/pi)*Psi,'bilinear','crop'); # the negative sign is due to Spider convention"""
        #imgAvg = imgAvg + img # plain 2d average
        # CTF info
        if abs(df[iS]) < 1e-20:
            tmp = ctemh_cryoFrank.op(Q / (2 * p.pix_size), [p.Cs, df[iS], p.EkV, p.gaussEnv,p.AmpContrast])
            CTF[iS,:,:] = ifftshift(tmp) # tmp should be in matlab convention
        else:
            CTF[iS, :, :] = 1.
        """CTF(:,:,iS) = ifftshift(ctemh_cryoFrank(Q,[emPar.Cs,df(iS),emPar.EkV,emPar.gaussEnv])); % ifftshift is correct!"""
        CTFtemp = CTF[iS,:,:]
        fy[iS,:,:] = fft2(img)  # Fourier transformed
        #imgFlip = ifft2(np.sign(CTFtemp)*fy[iS,:,:]) # phase-flipped
        #imgAllFlip[iS,:,:] = imgFlip.real            # taking all the phase-flipped images
        #imgAvgFlip = imgAvgFlip + imgFlip.real       # average of all phase-flipped images
        imgAll[iS,:,:] = img
        #print 'img=',img
        #fig = plt.figure()
        #ax1 = fig.add_subplot(1, 1, 1)
        #ax1.imshow(img, cmap='gray')
        #ticks = int(time.time()*100)
        #fig_name = 'img{}.png'.format(ticks)
        #fig.savefig(fig_name)
        #plt.show()
        #plt.close()
    del y

    # use wiener filter
    imgAvg = 0
    wiener_dom = -get_wiener1(CTF)
    for iS in xrange(nS):
        img =  imgAll[iS,:,:]
        img_f = fft2(img)#.reshape(dim, dim)) T only for matlab
        CTF_i = CTF[iS,:,:]
        #wiener_dom_i = wiener_dom[:, i].reshape(dim, dim)
        img_f_wiener = img_f*(CTF_i/wiener_dom)
        imgAvg = imgAvg + ifft2(img_f_wiener).real

    # plain and phase-flipped averages
    imgAvg = imgAvg/nS
    #imgAvgFlip = imgAvgFlip.real/nS


    myio.fout1(outFile,['ind','q','df','CTF','imgAll','PD','PDs','Psis','imgAvg','options'],
               [ind, q, df, CTF, imgAll, PD, PDs, Psis, imgAvg, options]) # members of options


    #######################################################
    # create empty PD files after each Pickle dump to...
    # ...be used to resume (avoiding corrupt Pickle files):
    progress_fname = os.path.join(p.dist_prog, '%s' % (prD))
    open(progress_fname, 'a').close() #create empty file to signify non-corrupted Pickle dump
    #######################################################

def get_wiener1(CTF1):
    SNR = 5
    wiener_dom = 0.
    for i in xrange(CTF1.shape[0]):
        wiener_dom = wiener_dom + CTF1[i, :, :] ** 2

    wiener_dom = wiener_dom + 1. / SNR

    return (wiener_dom)

