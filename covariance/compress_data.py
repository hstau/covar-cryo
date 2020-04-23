import numpy as np

def op(fin, prj, PrD):
    finn = fin[PrD,:]
    ind = np.nonzero(finn)
    I = len(ind)
    da = np.zeros(I)
    data = prj.flatten()
    print 'finn=',finn
    print 'ind=',ind
    da[finn] = data[ind]
    return da
    