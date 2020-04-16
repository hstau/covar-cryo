import project
import a
import quaternion
import numpy as np

def decomp2(in1, p_dim):
    NX = p_dim[0]
    a = np.floor(in1/NX)
    a = in1 - a*NX
    b = (in1 - a)/NX
    return (a,b)

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

def circ_mask(N):
    N2 = np.rint(N/2.)
    r2 = N2*N2
    # default circular mask
    mask = np.zeros((N,N))
    for i in range(N):
        x = i-N2 + 1
        for j in range(N):
            y = j-N2 + 1
            if x*x + y*y < r2:
                mask[i,j] = 1
    return mask

def mv(v):
    N = np.rint(v.shape[0]**(1./3.))
    v = v.reshape((N,N,N))
    pr = np.array([])
    for PrD in range(len(a.CG)):
        PD = a.PDs[PrD]
        pr1 = project.op(v,PD).flatten()
        pr = np.concatenate((pr, pr1))
    return pr

def op(CG, q, msk3, N):
    a.init()
    a.q = q
    a.PDs = cal_avg_pd(a.q,a.CG)
    if msk3 != 0:
        pr = mv(msk3)
    fin = np.zeros((N*N,len(CG)))
    for PrD in range(len(CG)):
        if msk3 != 0:
            im = pr[PrD].reshape(N,N)
        else:
            im = circ_mask(N)
        msk2 = (im > 0).astype(int).flatten()
        k = 0
        for i in range(len(msk2)):
            a,b = decomp2()
            if msk2(i) == 1:
                fin[i,PrD] = k
                k+=1
    return fin

