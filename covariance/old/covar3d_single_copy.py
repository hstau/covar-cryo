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
import create_map_mask2D
import compress_data
import p

def cal_avg_pd(q,CG):
    Ps = []
    for PrD in range(len(CG)):
        nS = CG[PrD].shape[0]
        # Calculate average projection directions
        PDs = quaternion.calc_avg_pd(q, nS)
        # reference PR is the average
        PD = np.sum(PDs, 1)
        # make it a unit vector
        PD = PD / np.linalg.norm(PD)
        Ps.append(PD)
    return Ps

def mv(v):
    N = np.rint(v.shape[0]**(1/3.))
    v = v.reshape((N,N,N))
    pr = np.array([])
    for PrD in range(len(a.CG)):
        PD = a.PDs[PrD]
        pr1 = project.op(v,PD).flatten()
        pr = np.concatenate((pr, pr1))
    return pr

def hmv(y):
    N = np.sqrt(y.shape[0] / len(a.CG))
    for PrD in range(len(a.CG)):
        PD = a.PDs[PrD]
        v = project.back(v, PD, y[PrD])
    v = v.flatten()
    return v

def Cv(CG, N, fin, PDs):
    Cy = []
    for PD in PDs:
        Cy.append(get_cov(CG, N, fin, PD,PD))
    return Cy

def Cv2(CG, N, fin, PDs,C):
    for PD1 in PDs:
        for PD2 in PDs:
            F1 = PD1 + 1
            F2 = PD2 + 1
            C[PD1*N: F1*N,PD2*N: F2*N] = get_cov(CG, N, fin, PD1, PD2)
    return C

def op(CG, q, N, y, msk3, op):
def op(input_data, filterPar, imgFileName, sh, nStot, options):

    ind = input_data[0]
    q = input_data[1]

    # create 2D masks from a 3D mask
    # fin is the vector of indeces with 2D mask pixels
    fin = create_map_mask2D.op(CG, q, msk3, N)

    '''op = 0  one projection at a time, RRt is approximated by a block diagonal
       op = 1  empirical, RRt considers all the projections as given
       op = 2  theoretical RRt has closed form, assuming uniform distrib of projection angles
               over S^2
    '''
    a.init()
    a.CG = CG
    a.q = q
    a.PDs = cal_avg_pd(a.q,a.CG)
    a.y = y
    I = N*N
    J = N*N*N
    k = 6
    which = 'LM'
    maxiter = 200
    tol = 0

    phi = np.empty(len(CG))
    theta = np.empty(len(CG))
    psi = np.empty(len(CG))
    phi, theta, psi = quaternion.psi_ang(a.PDs)

    # write angles to star file
    ang_file = 'heu_angles.star'
    d = dict(phi=phi, theta=theta, psi=psi)
    df = pandas.DataFrame(data=d)

    if op == 0: # Heuristic: Cy is block diagonal
        B = []
        for PrD in range(len(CG)):
            PD = [a.PDs[PrD]]
            Cy = Cv(CG, N, fin, PD)[0]
            # RRt is the identity matrix
            w, v = eigsh(Cy, k, which, maxiter,tol)
            B.append(v)
        # reconstruction theoretical
        for i in range(k): # for each eigenv
            imgs = np.zeros(len(CG), N, N)
            for PrD in range(len(CG)):
                imgs[PrD,:,:] = B[PrD].v[:,i].reshape(N,N)

            # write image stack to mrcs file
            stack_file = 'heu_eig{}.mrcs'.format(i)
            if os.path.exists(stack_file):
                mrc = mrcfile.open(stack_file, mode='r+')
            else:
                mrc = mrcfile.new(stack_file)
            mrc.set_data(imgs)
            star.write_star(ang_file, stack_file, df)

            # output reconstrcution
            out_file = 'reconst_heu_eig{}.mrc'.format(i)
            Popen(["relion_reconst", "--i", ang_file, "--o", out_file], close_fds=True)

        #######################################################
        # create empty PD files after each Pickle dump to...
        # ...be used to resume (avoiding corrupt Pickle files):
        progress_fname = os.path.join(p.cov_prog, '%s' % (prD))
        open(progress_fname, 'a').close()  # create empty file to signify non-corrupted Pickle dump
        #######################################################


    else:  # Taking the entire Cy matrix
        K = len(CG)*I
        Cy = lil_matrix((K,K),dtype=np.float64)
        Cy = Cv2(CG, N, fin, a.PDs,Cy)

        if op == 1: # empirical RRt
            k = 15
            U, S, V = svds(mv, k, which, maxiter, tol)
            RRt = np.dot(U[:, :k].dot(np.diag((S * S)[:k])), U.T[:k, :])
            k = 6
            RRt1 = np.dot(U[:,:k].dot(np.diag((1./(S*S))[:k])),U.T[:k,:])
            Minv = RRt1

        elif op == 2:
            Minv = theo_R1()

        else: exit()

        w,v = eigsh(Cy, k, RRt, which, maxiter, tol, Minv)
        for i in range(k):  # for each eigenv
            result = hmv(v[:,i])
            # output the reconstrcution
            if op == 1:
                out_file = 'reconst_empir_eig{}.mrc'.format(i)
            elif op == 2:
                out_file = 'reconst_theo_eig{}.mrc'.format(i)
            else: exit()
            if os.path.exists(out_file):
                mrc = mrcfile.open(out_file, mode='r+')
            else:
                mrc = mrcfile.new(out_file)
            mrc.set_data(result)

        #######################################################
        # create empty PD files after each Pickle dump to...
        # ...be used to resume (avoiding corrupt Pickle files):
        progress_fname = os.path.join(p.cov_prog, '%s' % (prD))
        open(progress_fname, 'a').close()  # create empty file to signify non-corrupted Pickle dump
        #######################################################
