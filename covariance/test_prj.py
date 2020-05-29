from scipy.sparse.linalg import LinearOperator, eigsh, svds
import project
import a
import quaternion
import numpy as np
import myio
from subprocess import Popen
from scipy.sparse import lil_matrix
from numpy.linalg import norm
from scipy.sparse.linalg import LinearOperator
import os
import mrcfile
import pandas
import star
import p
import matplotlib.pyplot as plt
import time


def mv(v,op):
    N = int(np.rint(v.shape[0]**(1/3.)))
    v = v.reshape((N,N,N))
    pr = np.array([])
    for PrD in range(len(a.CG)):
        PD = a.PDs[PrD]
        if op == 0:
            pr1 = project.op(v,PD)
        else:
            pr1 = project.op1(v,PD)

        fig = plt.figure()
        ax1 = fig.add_subplot(1, 1, 1)
        ax1.imshow(pr1, cmap='gray')
        fig_name = 'pr{}_{}.png'.format(PrD,op)
        fig.savefig(fig_name)
        plt.show()
        plt.close()
	
        pr1 = pr1.flatten()
        pr = np.concatenate((pr, pr1))
    #print 'pr=',pr.shape
    return pr

def hmv(y):
    N = int(np.sqrt(y.shape[0] / len(a.CG)))
    I = N*N
    v = np.zeros((N,N,N))
    for PrD in range(len(a.CG)):
        F = PrD + 1
        PD = a.PDs[PrD]
        v = project.back(v, PD, y[PrD*I:F*I].reshape(N,N))
    v = v.flatten()
    #print 'v=', v.shape
    return v

def op(CG,q,N,op):
    a.init()
    a.CG = [CG[0]]
    # preparing angles to write on a star file
    PDs = quaternion.cal_avg_pd_all(q, CG)
    a.PDs = [PDs[0]]

    with mrcfile.open('phantom4.mrc') as mrc:
         v = mrc.data

    v = v.flatten()
    nn = np.nonzero(v)
    print 'V=',nn
    pr = mv(v,1)
    ne = np.nonzero(v)
    print 'v after', ne
    v = hmv(pr)
    pr1 = mv(v,1)

    b = np.array(range(64))
    b = b.reshape((4,4,4))
    # forward
    b1=np.swapaxes(b,2,0)
    sym = [0.5,0.3,0]
    br = project.rotateVolumeEuler(b1,sym,0,0)  
    pr = np.sum(br,axis=2)/4 #
    #pr = pr.T #	
    # backward
    #b2 = np.zeros((4,4,4)) #
    #b2 = np.swapaxes(b2,2,0) #
    #br2 = project.rotateVolumeEuler(b2, sym, 0, 0)#
    br2 = np.tile(pr/br.shape[2],(br.shape[2],1,1)) #
    br2 = np.swapaxes(br2,2,0)# 
    br2 = project.rotateVolumeEuler(br2,sym,0,1) #
    br2 = np.swapaxes(br2,2,0)# 
    # forward
    b3=np.swapaxes(br2,2,0)
    b3r = project.rotateVolumeEuler(b3,sym,0,0)  
    p3r = np.sum(b3r,axis=2)
    p3r = p3r.T #	
    #
    brr = project.rotateVolumeEuler(br,sym,0,1)
    brr = np.swapaxes(brr,0,2)
    #
    print b
    print brr
    print 'diff3=',norm(pr-p3r)			
    print 'diff=',norm(b-brr)			
    #print 'equal', pr == pr1

    return 
     
    '''
    ##### test mv and hmv
        with mrcfile.open('phantom0.mrc') as mrc:
            v = mrc.data
            v = v.flatten()
        pr = mv(v,1)
        v = hmv(pr)
        #pr = mv(v,1)
        with mrcfile.new('phantom0_test.mrc') as mrc:
            v = v.astype(np.float32)
            mrc.set_data(v.reshape((N,N,N)))
        exit(1)
        #############

   '''

if __name__ == '__main__':
    import p
    p.init()
    data = myio.fin1('temp1/selecGCs')
    CG = data['CG']
    q = data['q']
    N = 22
    op(CG, q, N, 1)


