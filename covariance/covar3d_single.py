from scipy.sparse.linalg import LinearOperator, eigsh, svds
import project
import a
import quaternion
import numpy as np
import myio
from subprocess import Popen
from scipy.sparse import lil_matrix
import os
import mrcfile
import pandas
import star
import get_cov
import compress_data
import p


def op(input_data, doSave, fin, N, q, op):
    dist_file = input_data[0]
    data = myio.fin1(dist_file)
    ind = [data['ind']]
    prD = [input_data[1]]
    cov_file = '{}prD_{}'.format(p.cov_file, prD[0])

    if op > 0:
        dist_file = input_data[2]
        data = myio.fin1(dist_file)
        ind.append(data['ind'])
        prD.append(input_data[3])
        cov_file = '{}prD_{}_{}'.format(p.cov_file, prD[0], input_data[3])
    else: # op == 0, append itself
        ind.append(data['ind'])
        prD.append(input_data[1])

    '''op = 0  one projection at a time, RRt is approximated by a block diagonal
       op = 1  empirical, RRt considers all the projections as given
       op = 2  theoretical RRt has closed form, assuming uniform distrib of projection angles
               over S^2
    '''
    k = 3

    # compute the 2D covariance for pairs of prDs
    Cy_ind = get_cov.op(N, fin, prD[0], prD[1])

    if op == 0: # Heuristic: Cy is block diagonal
        # In this case RRt is the identity matrix times a constant
        vals, vecs = eigsh(Cy_ind, k, which='LM', maxiter=50, tol=0)
        ix = np.argsort(vals)[::-1]
        vals = np.sort(vals)[::-1]
        vecs = vecs[:, ix]
        myio.fout1(cov_file, ['Cy_ind', 'vals', 'vecs'], [Cy_ind, vals, vecs])  # members of options
        #######################################################
        # create empty PD files after each Pickle dump to...
        # ...be used to resume (avoiding corrupt Pickle files):
        progress_fname = '{}{}'.format(p.cov_prog, prD[0])
        open(progress_fname, 'a').close()  # create empty file to signify non-corrupted Pickle dump
        #######################################################


    else:  # Taking the entire Cy matrix
        myio.fout1(cov_file, ['Cy_ind'], [Cy_ind])  # members of options

        #######################################################
        # create empty PD files after each Pickle dump to...
        # ...be used to resume (avoiding corrupt Pickle files):
        progress_fname = '{}{}_{}'.format(p.cov_prog, prD[0], prD[1])
        open(progress_fname, 'a').close()  # create empty file to signify non-corrupted Pickle dump
        #######################################################

