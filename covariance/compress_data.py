import numpy as np

def op(fin, prj, PrD):
    finn = fin[PrD,:]
    ind = np.nonzero(finn)[0]
    I = len(ind)
    da = np.zeros(I)
    data = prj.flatten()
    da[finn] = data[ind]
    return da
    