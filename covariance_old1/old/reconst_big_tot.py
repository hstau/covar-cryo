'''
.. Created 2015
.. codeauthor:: Hstau Y Liao <hstau.y.liao@gmail.com>
'''

import sys
import numpy as np
import math

from arachnid.core.image import ndimage_file
from arachnid.core.metadata import format

def reconst(lambda, ind3, pref_tot, sel_ang_file, prj_sel_file, data_file, out_file, ext, th):
    # get the number of unknowns and initialize the soluton array
    i = 1
    tot_file = pref_tot + '%05d' % i
    t = np.load(tot_file)
     # toti = csr_matrix((t['data'],t['row'],t['col']),shape=t['shape'])  # sparse(row,col,w,M1,N1)
    N1 = t.['shape'][1]
    sol = np.zeros((N1,1))
    # get the number of views
    sel_ang, header = format.read(sel_ang_file, ndarray=True)
    I = sel_ang.shape[0]
    # start to iterate
    for n in range(30): # for each cycle
        print n
        cost = 0
        J = np.random.permutation(I)
        for i in range(I):    # for each view
            j = J[i]
            l = sel_ang[j]
            file = prj_sel_file + '%05d' % l + ext
            sel, header = format.read(file, ndarray=True)
            if(sel.shape[0] > th): # if enough particles
                tot_file = pref_tot + '%05d' % j
                # load the system matrix
                t = np.load(tot_file)
                # load data
                file = data_file + '%05d' % l 
                dat = np.load(file)
                # one iteration
                diff = data - t.dot(sol)
                sol = sol + lambda * t.T.dot(diff)
                # compute cost
                cost = cost + np.linalg.norm(data - t.dot(sol))
        print cost
        # save solution so far
        file = out_file + '%05d' % n 
        save(file,sol)
        # save the variance map
        file = 'var'+ out_file + '%05d' % n 
        var = get_diag3(sol,ind3)
        save(file,var)

if __name__ == '__main__':
   lambda = sys.argv[1]
   ind3 = sys.argv[2]
   pref_tot = sys.argv[3]
   sel_ang_file = sys.argv[4]
   prj_sel_file = sys.argv[5]
   data_file = sys.argv[6]
   out_file = sys.argv[7]
   ext = sys.argv[8]
   th = sys.argv[9]
   
   reconst(lambda, ind3, pref_tot, sel_ang_file, prj_sel_file, data_file, out_file, ext, th)
   

                        



