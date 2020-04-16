import logging, sys
import numpy as np
import myio
import util
import time,os
import quaternion
import mrcfile
import pandas
import star
from pyface.qt import QtGui, QtCore
os.environ['ETS_TOOLKIT'] = 'qt4'
import matplotlib.pyplot as plt
'''
Copyright (c) UWM, Ali Dashti 2016 (matlab version)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Copyright (c) Hstau Liao 2018 (python version)    
'''

def flip1(data):
    N,dim,dim = data.shape
    for i in range(N):
        img = data[i,:,:]
        data[i,:,:] = img.T
    return data

#_logger = logging.getLogger(__name__)
#_logger.setLevel(logging.DEBUG)

def op(trajTaus, posPsi1All, posPathAll, xSelect, tauAvg, *argv):
    import p
    i = 0
    imgss = [[]]*p.nClass
    phis = [[]]*p.nClass
    thetas = [[]] * p.nClass
    psis = [[]] * p.nClass
    # somehow this step is necessary
    for bin in range(p.nClass):
        imgss[bin]=[]
        thetas[bin]=[]
        phis[bin] = []
        psis[bin] = []
    for x in xSelect:
        #print 'x=',x
        i += 1
        EL_file = '{}prD_{}'.format(p.EL_file, x)
        File = '{}_{}_{}'.format(EL_file, p.trajName, 1)
        data = myio.fin1(File)

        IMGT = data['IMGT']

        posPath = posPathAll[x]
        psi1Path = posPsi1All[x]

        dist_file = '{}prD_{}'.format(p.dist_file, x)
        data = myio.fin1(dist_file)
        q = data['q']

        q = q[:, posPath[psi1Path]] # python
        nS = q.shape[1]

        conOrder = np.floor(float(nS)/p.conOrderRange).astype(int)
        copies = conOrder
        q = q[:,copies-1:nS-conOrder]

        IMGT = IMGT / conOrder
        IMGT = IMGT.T  #flip here IMGT is now num_images x dim^2

        tau = trajTaus[x]
        tauEq = util.hist_match(tau, tauAvg)
        pathw = p.width_1D
        IMG1 = np.zeros((p.nClass, IMGT.shape[1]))
        for bin in range(p.nClass - pathw + 1):
            # print 'bin is', bin
            if bin == p.nClass - pathw:
                tauBin = ((tauEq >= (bin / float(p.nClass))) & (tauEq <= (bin + pathw) / p.nClass)).nonzero()[0]
            else:
                tauBin = ((tauEq >= (bin / float(p.nClass))) & (tauEq < (bin + pathw) / p.nClass)).nonzero()[0]

            if len(tauBin) == 0:
                #print 'bad bin is',bin
                continue
            else:
                imgs = IMGT[tauBin,:].astype(np.float32)
                #ar2 = tauEq[tauBin]
                qs = q[:,tauBin]
                nT = len(tauBin)
                PDs = quaternion.calc_avg_pd(qs,nT)
                phi = np.empty(nT)
                theta = np.empty(nT)
                psi = np.empty(nT)

                for i in range(nT):
                    PD = PDs[:, i]
                    phi[i], theta[i], psi[i] = quaternion.psi_ang(PD)
                dim = int(np.sqrt(imgs.shape[1]))
                imgs = imgs.reshape(nT, dim, dim)  # flip here
                imgs = flip1(imgs)  # flip here

                imgss[bin].append(imgs)  # append here
                phis[bin].append(phi)
                thetas[bin].append(theta)
                psis[bin].append(psi)

    # loop through the nClass again and convert each list in the list to array
    for bin in range(p.nClass - pathw + 1):

        if len(imgss[bin]) == 0:
            # print 'bad bin is',bin
            continue

        # reuse var names
        imgs = np.concatenate(imgss[bin])
        phi  = np.concatenate(phis[bin])

        theta = np.concatenate(thetas[bin])
        psi = np.concatenate(psis[bin])
        # print out
        traj_file_rel = 'imgsRELION_{}_{}_of_{}.mrcs'.format(p.trajName, bin + 1, p.nClass)
        traj_file = '{}{}'.format(p.relion_dir, traj_file_rel)
        ang_file = '{}EulerAngles_{}_{}_of_{}.star'.format(p.relion_dir, p.trajName, bin + 1, p.nClass)

        if os.path.exists(traj_file):
            mrc = mrcfile.open(traj_file, mode='r+')
        else:
            mrc = mrcfile.new(traj_file)
            # mrc.set_data(data*-1) #*-1 inverts contrast
        mrc.set_data(imgs * -1)

        d = dict(phi=phi, theta=theta, psi=psi)
        df = pandas.DataFrame(data=d)
        star.write_star(ang_file, traj_file_rel, df)

    if argv:
        progress7 = argv[0]
        signal = int((bin / float(p.nClass)) * 100)
        if signal == 100:
            signal = 95
        progress7.emit(signal)
    res = 'ok'
    return res

