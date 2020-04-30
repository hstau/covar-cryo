from scipy.sparse.linalg import LinearOperator, eigsh, svds
import project
import a
import quaternion
import numpy as np
import myio
from subprocess import Popen
from scipy.sparse import lil_matrix
from scipy.sparse.linalg import norm
from scipy.sparse.linalg import LinearOperator
import os
import mrcfile
import pandas
import star
import p

def mv(v):
    N = int(np.rint(v.shape[0]**(1/3.)))
    v = v.reshape((N,N,N))
    pr = np.array([])
    for PrD in range(len(a.CG)):
        PD = a.PDs[PrD]
        pr1 = project.op(v,PD).flatten()
        pr = np.concatenate((pr, pr1))
        #print 'shape pr=',pr.shape
    return pr

def hmv(y):
    N = int(np.sqrt(y.shape[0] / len(a.CG)))
    v = np.zeros((N,N,N))
    for PrD in range(len(a.CG)):
        PD = a.PDs[PrD]
        v = project.back(v, PD, y[PrD])
    v = v.flatten()
    return v


def op(CG, q, N, op):

    a.init()
    a.CG = CG
    # preparing angles to write on a star file
    PDs = quaternion.cal_avg_pd_all(q, CG)
    a.PDs = PDs
    phi, theta, psi = quaternion.psi_ang_all(PDs)
    ang_file = 'ave_angles.star'
    d = dict(phi=phi, theta=theta, psi=psi)
    df = pandas.DataFrame(data=d)
    I = N*N
    J = N*N*N
    k = 3

    if op == 0: # heuristics method
        # reconstruction
        for i in range(k): # for each eigenv
            imgs = np.zeros((len(CG), N, N))
            for prD in range(len(CG)):
                cov_file = '{}prD_{}'.format(p.cov_file, prD)
                data = myio.fin1(cov_file)
                vals = data['vals']
                vecs = data['vecs']
                imgs[prD, :, :] = vecs[:, i].reshape(N, N)
            # write image stack to mrcs file
            stack_file = 'heu_eig{}.mrcs'.format(i)
            if os.path.exists(stack_file):
                mrc = mrcfile.open(stack_file, mode='r+')
            else:
                mrc = mrcfile.new(stack_file)
            imgs = imgs.astype(np.float32)
            mrc.set_data(imgs)
            star.write_star(ang_file, stack_file, df)

            # output reconstrcution
            out_file = 'reconst_heu_eig{}.mrc'.format(i)
            Popen(["relion_reconstruct", "--i", ang_file, "--o", out_file], close_fds=True)

    else:
        K = len(CG) * I
        Cy = lil_matrix((K, K), dtype=np.float64)
        for prD1 in range(len(CG)):
            F1 = prD1 + 1
            for prD2 in range(prD1,len(CG)):
                F2 = prD2 + 1
                cov_file = '{}prD_{}_{}'.format(p.cov_file, prD1, prD2)
                data = myio.fin1(cov_file)
                Cy_ind = data['Cy_ind']
                Cy[prD1 * I: F1 * I, prD2 * I: F2 * I] = Cy_ind
                if prD1 != prD2:
                    Cy[prD2 * I: F2 * I, prD1 * I: F1 * I] = Cy_ind.T
        print 'done Cy as lil_mat'
        Cy = Cy.tocsr()
        print 'entering eigen decomp0'

        if op == 1:  # empirical RRt
            R = LinearOperator((K,J),matvec=mv, rmatvec=hmv)
            U, S, V = svds(R, k=6, which='LM', maxiter=100, tol=0)
            print 'entering eigen decomp1'
            k = 3
            RRt = np.dot(U[:, :k].dot(np.diag((S * S)[:k])), U.T[:k, :])
            k = 1
            RRt1 = np.dot(U[:, :k].dot(np.diag((1. / (S * S))[:k])), U.T[:k, :])

        #elif op == 2:  leaving this for later
        #    minv = theo_R1()

        #else:
        #    exit()
        print 'entering eigen decomp2'
        vals, vecs = eigsh(Cy, k=3, M=RRt,  maxiter=50, tol=0, Minv=RRt1)
        for i in range(k):  # for each eigenv
            result = hmv(vecs[:, i])
            result = result.astype(np.float32)
            result = result.reshape((N, N, N))
            print 'done eigendecomp'
            # output the reconstrcution
            if op == 1:
                out_file = 'reconst_empir_eig{}.mrc'.format(i)
            elif op == 2:
                out_file = 'reconst_theo_eig{}.mrc'.format(i)
            else:
                exit()
            if os.path.exists(out_file):
                mrc = mrcfile.open(out_file, mode='r+')
            else:
                mrc = mrcfile.new(out_file)
            mrc.set_data(result)
