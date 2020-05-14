import project
import quaternion
import numpy as np
import matplotlib.pyplot as plt
import myio
import p
import mrcfile
import time

def decomp2(in1, p_dim):
    NX = p_dim[0]
    a = np.floor(in1/NX)
    a = in1 - a*NX
    b = (in1 - a)/NX
    return (a,b)

def circ_mask(N):
    N2 = np.rint(N/2.) ###!!!
    r2 = N2*N2
    # default circular mask
    mask = np.zeros((N,N))
    for i in range(N):
        x = i-N2 - 1
        for j in range(N):
            y = j-N2 - 1
            if x*x + y*y < r2:
                mask[i,j] = 1.
    return mask

def mv(v):
    import a
    #N = int(np.rint(v.shape[0]**(1./3.))) # v is not flattened!
    #v = v.reshape((N,N,N))
    #pr = np.array([])
    pr = []
    for PrD in range(len(a.CG)):
        PD = a.PDs[PrD]
        #pr1 = project.op(v,PD)#.flatten()
        pr.append(project.op(v,PD)) #.flatten()) = np.concatenate((pr, pr1))
    return pr


def op(CG, q, msk3, N):
    import a
    a.init()
    a.q = q
    a.CG = CG
    a.PDs = quaternion.cal_avg_pd_all(q,CG)
    #if msk3 != 0:
    if p.mask_vol_file != '':
        with mrcfile.open(p.mask_vol_file) as mrc:
            vol = mrc.data
            pr = mv(vol)
            print 'using mask'
    fin = np.zeros((len(CG),N*N),dtype= np.int)
    for PrD in range(len(CG)):
        #if msk3 != 0:
        if p.mask_vol_file != '':
            im = pr[PrD]#.reshape(N,N)
        else:
            im = circ_mask(N)
        msk2 = (im > 1e-1).astype(int).flatten()
        fig = plt.figure()
        ax1 = fig.add_subplot(1, 1, 1)
        ax1.imshow(msk2.reshape(N,N).astype(np.float), cmap='gray')
        ticks = int(time.time() * 100)
        fig_name = 'mask{}.png'.format(PrD)
        fig.savefig(fig_name)
        plt.show()
        plt.close()
        k = 0
        for i in range(len(msk2)):
            if msk2[i] == 1:
                fin[PrD,i] = k
                k+=1
    return fin

