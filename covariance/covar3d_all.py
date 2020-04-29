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
import p

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


def op(CG, q, N, op):

    a.init()
    # preparing angles to write on a star file
    PDs = quaternion.cal_avg_pd_all(q, CG)
    phi, theta, psi = quaternion.psi_ang_all(PDs)
    ang_file = 'ave_angles.star'
    d = dict(phi=phi, theta=theta, psi=psi)
    df = pandas.DataFrame(data=d)
    I = N*N
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
            Popen(["relion_reconst", "--i", ang_file, "--o", out_file], close_fds=True)

    else:
        K = len(CG) * I
        Cy = lil_matrix((K, K), dtype=np.float64)
        for prD1 in range(len(CG)):
            F1 = prD1 + 1
            for prD2 in range(len(CG)):
                F2 = prD2 + 1
                cov_file = '{}prD_{}_{}'.format(p.cov_file, prD1, prD2)
                data = myio.fin1(cov_file)
                Cy_ind = data['Cy_ind']
                Cy[prD1 * N: F1 * N, prD2 * N: F2 * N] = Cy_ind

        if op == 1:  # empirical RRt
            k = 15
            U, S, V = svds(mv, k, which='LM', maxiter=100, tol=0)
            RRt = np.dot(U[:, :k].dot(np.diag((S * S)[:k])), U.T[:k, :])
            k = 6
            RRt1 = np.dot(U[:, :k].dot(np.diag((1. / (S * S))[:k])), U.T[:k, :])
            minv = RRt1

        #elif op == 2:  leaving this for later
        #    minv = theo_R1()

        else:
            exit()

        vals, vecs = eigsh(Cy, k, RRt, which='LM', maxiter=100, tol=0, Minv=minv)
        for i in range(k):  # for each eigenv
            result = hmv(vecs[:, i])
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
