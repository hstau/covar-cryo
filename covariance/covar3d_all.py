from scipy.sparse.linalg import LinearOperator, eigsh, svds
import project
import a
import quaternion
import numpy as np
import myio
from subprocess import Popen
from scipy.sparse import lil_matrix, csr_matrix
from scipy.sparse.linalg import norm
from scipy.sparse.linalg import LinearOperator
import os
import mrcfile
import pandas
import star
import p
import matplotlib.pyplot as plt
import time

def mv(v):
    N = int(np.rint(v.shape[0]**(1/3.)))
    v = v.reshape((N,N,N))
    pr = np.array([])
    for PrD in range(len(a.CG)):
        PD = a.PDs[PrD]
        pr1 = project.op(v,PD)
        pr1 = pr1.flatten()
        pr = np.concatenate((pr, pr1))
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
    return v

def R_brute_force(N,PDs):
    #data = myio.fin1('matrixR')
    #R = data['R']
    #R = R.tocsr()
    #return R
    I = N*N
    J = N*N*N
    K = len(PDs) * I
    R = lil_matrix((K, J), dtype=np.float64)
    for k in range(len(PDs)):
        print 'k=',k
        for i in range(J):
            v = np.zeros(J)
            v[i] = 1
            v = np.reshape(v,(N,N,N))
            R[k * I: (k + 1) * I, i] = project.op(v, PDs[k]).flatten()[:,np.newaxis]
    myio.fout1('matrixR',['R'],[R])
    R = R.tocsr()
    return R

def compare_3d(N):
    m = 3  # number of states
    J = N*N*N
    b = np.zeros((m, J))
    for i in range(m):
        phan_file = 'phantom{}.mrc'.format(i)
        with mrcfile.open(phan_file) as mrc:
            a = mrc.data
        b[i, :] = a.flatten().astype(np.float64)
    Cx = csr_matrix(np.matmul(b.T,b))

    return Cx


def op(CG, q, N, op):
    import p
    p.init()
    #p.cov_file = 'temp1/cov_'

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
    k = 2

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
                ###################
                #fig = plt.figure()
                #ax1 = fig.add_subplot(1, 1, 1)
                #ax1.imshow(Cy_ind.todense(), cmap='gray')
                #fig_name = 'cov2d_{}{}.png'.format(prD1,prD2)
                #fig.savefig(fig_name)
                #plt.show()
                #plt.close()
                ###################
                #print 'K=',K
                #print 'prd2=', prD2
                #print 'prd1=', prD1
                #print 'shape Cy',Cy
                #print 'shape cy_ind', Cy_ind.shape
                Cy[prD1 * I: F1 * I, prD2 * I: F2 * I] = Cy_ind
                if prD1 != prD2:
                    Cy[prD2 * I: F2 * I, prD1 * I: F1 * I] = Cy_ind.T
        print 'done Cy as lil_mat'
        Cy = Cy.tocsr()
        print 'max cov_2d', np.max(np.max(Cy))
        print 'mean cov_2d', np.mean(np.mean(Cy))
        print 'entering eigen decomp0'


        if op == 1:  # empirical RRt
            R = LinearOperator((K,J),matvec=mv, rmatvec=hmv)
            R = R_brute_force(N,PDs)
            U, S, V = svds(R, k=60, which='LM', maxiter=300, tol=0)
            ix = np.argsort(S)[::-1]
            S = np.sort(S)[::-1]
            U = U[:, ix]
            print 'S=',S[:30]
            print 'entering eigen decomp1'
            k = 60
            RRt = np.dot(U[:, :k].dot(np.diag((S * S)[:k])), U.T[:k, :])
            k = 60
            RRt1 = np.dot(U[:, :k].dot(np.diag(1. / (S[:k] * S[:k]))), U.T[:k, :])
            for prD in range(len(CG)):
                ind1 = prD*I
                ind2 = ind1+I
                #####################
                #fig = plt.figure()
                #ax1 = fig.add_subplot(1, 1, 1)
                ##t = U[ind1:ind2,:k]
                ##print 'u=', t[:10,0]
                #ax1.imshow(U[ind1:ind2,:k].reshape(N,N), cmap='gray')
                #fig_name = 'U{}.png'.format(prD)
                #fig.savefig(fig_name)
                #plt.show()
                #plt.close()
        
        #elif op == 2:  leaving this for later
        #    minv = theo_R1()

        #else:
        #    exit()
        print 'entering eigen decomp2'
        vals, vecs = eigsh(Cy, k=10, M=RRt,  maxiter=300, tol=0, Minv=RRt1)
        vals = np.sort(vals)[::-1]
        ix = np.argsort(vals)[::-1]
        vecs = vecs[:, ix]
        print 'vals=', vals[:10]
        k=10
        for i in range(k):  # for each eigenv
            # plotting
            for prD in range(len(CG)):
                ind1 = prD * I
                ind2 = ind1 + I
                ########################
                #fig = plt.figure()
                #ax1 = fig.add_subplot(1, 1, 1)
                ##t = vecs[ind1:ind2, i:(i+1)]
                ##print 'vecs=',t[:10,0]
                #ax1.imshow(vecs[ind1:ind2, i:(i+1)].reshape(N, N), cmap='gray')
                #fig_name = 'vec{}_{}.png'.format(prD,i)
                #fig.savefig(fig_name)
                #plt.show()
                #plt.close()
            #
            result = hmv(vecs[:, i])
            result = result.astype(np.float32)
            result = result.reshape((N, N, N))
            print 'done eigendecomp'
            # output the reconstrcution
            if op == 1:
                out_file = 'reconst_empir_eig{}.mrc'.format(i)
                outN_file = 'reconst_empir_Neig{}.mrc'.format(i)
            elif op == 2:
                out_file = 'reconst_theo_eig{}.mrc'.format(i)
            else:
                exit()
            if os.path.exists(out_file):
                mrc = mrcfile.open(out_file, mode='r+')
            else:
                mrc = mrcfile.new(out_file)
            mrc.set_data(result)
            # negative
            result=-result
            if os.path.exists(outN_file):
                mrc = mrcfile.open(outN_file, mode='r+')
            else:
                mrc = mrcfile.new(outN_file)
            mrc.set_data(result)


    Cx = compare_3d(N)
    vals, vecs = eigsh(Cx, k=10, maxiter=300, tol=0)
    vals = np.sort(vals)[::-1]
    ix = np.argsort(vals)[::-1]
    vecs = vecs[:, ix]
    print 'vals=', vals[:10]
    k = 10
    for i in range(k):  # for each eigenv

        result = vecs[:, i]
        result = result.astype(np.float32)
        result = result.reshape((N, N, N))
        print 'done eigendecomp'
        # output the reconstrcution
        if op == 1:
            out_file = 'cov3d_empir_eig{}.mrc'.format(i)
            outN_file = 'cov3d_empir_Neig{}.mrc'.format(i)
        if os.path.exists(out_file):
            mrc = mrcfile.open(out_file, mode='r+')
        else:
            mrc = mrcfile.new(out_file)
        mrc.set_data(result)
        # negative
        result = -result
        if os.path.exists(outN_file):
            mrc = mrcfile.open(outN_file, mode='r+')
        else:
            mrc = mrcfile.new(outN_file)
        mrc.set_data(result)



if __name__ == '__main__':
    import p
    p.init()
    data = myio.fin1('temp1/selecGCs')
    CG = data['CG']
    q = data['q']
    N = 10
    op(CG, q, N, 1)

