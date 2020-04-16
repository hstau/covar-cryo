'''
.. Created 2015
.. codeauthor:: Hstau Y Liao <hstau.y.liao@gmail.com>
'''

import sys
import numpy as np
import math

def expa(lp,lv,cc,N,M):
    # from list to array
    cc = np.array(cc)
    lv = np.array(lv)
    lp = np.array(lp)
    # make them row vectors
    cc = cc.reshape(1,cc.shape[0])
    lv = lv.reshape(1,lv.shape[0])
    lp = lp.reshape(1,lp.shape[0])
    # find the weights
    w1 = np.dot(cc.T,cc)
    w1 = w1[np.nonzero(np.triu(w1))] # w1 is a 1D array
    # find the voxel labels
    lv = lv-1 # must start from 0
    ll = lv.shape[1]
    in2 = N*np.tile(lv,(ll,1)) + np.tile(lv.T,(1,ll))
    in2 = in2[np.nonzero(np.triu(in2))] # 1D array
    # find the pixel labels
    lb = lb-1 # must start from 0
    ll = lb.shape[1]
    ind = M*np.tile(lb,(ll,1)) + np.tile(lb.T,(1,ll))
    ind = ind[np.nonzero(np.triu(ind))] # 1D array
  
    return (ind,in2,w1)

def create_big_tot(amat,pref_tot):
    # amat is a list with sparse matrices  
    N = amat[0].shape[1]  # number of voxels
    N1 = N*N
    for i in range(len(amat)):
        cc = [] # list
        lab_pix = []
        lab_vox= []
        for j in range(amat[i].shape[0]):
            ray = amat[i][j,:].toarray() # sparse to full = 1D ndarray 
            ind = np.nonzero(ray)
            fray = ray(ind)
            if fray.shape[0] > 0:
                cc.append(fray)
                lab_vox.append(ind)
                lab_pix.append(j*np.ones(fray.shape))
         M = amat[i].shape[0]
         M1 = M*M
         row1,col1,w = expand(lab_pix,lab_vox,cc,N,M)
         # toti = csr_matrix((w,(row,col)),shape=(M1, N1)))  # sparse(row,col,w,M1,N1) 
         tot_file =  pref_tot + '%05d' % i
         np.savez(tot_file,data=w,row=row1, col=col1, shape=(M1,N1))
        
if __name__ == '__main__':
   amat = sys.argv[1]
   sel_ang_file = sys.argv[2]
   pref_tot_out = sys.argv[3]

   create_big_tot(amat,pref_tot)

                        



