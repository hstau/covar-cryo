import numpy as np

def op(fin, prj, PrD):
    finn = fin[PrD,:]
    ind = np.nonzero(finn)[0]
    data = prj.flatten()
    da = data[ind]
    return (da,ind)
    