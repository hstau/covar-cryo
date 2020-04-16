'''
.. Created 2015
.. codeauthor:: Hstau Y Liao <hstau.y.liao@gmail.com>
'''

import sys
import numpy as np
import math

def fillin2(coarse):
    M = 4*coarse.shape[0]
    NX = round(sqrt(M))
    NX2 = round(NX/2.0)
    coarse.reshape((NX2,NX2))
    fine = np.zeros((NX,NX))
    for i in range(2):
        for j in range(2):
            fine[i:2,j:2] = coarse
    fine.flatten(1)
    return fine
    
    
def expand_data(array, ind2, j, p_dim):
    # get coarse and fine info separately
    find2 = ind2[0]
    cind2 = ind2[1]
    find2 = find2[:,j]
    cind2 = cind2[:,j]
    # create array
    M = p_dim[0]*p_dim[1]
    result = np.zeros(M)
    result2 = np.zeros(M/4)
    # coarse grid
    I = np.nonzero(cind2)
    result2[I] = array[cind2[I]]
    result[I] = fillin2(result2)
    # fine grid
    I = np.nonzero(find2)
    result[I] = array[find2[I]]
    
    return result

if __name__ == '__main__':
   array = sys.argv[1]
   ind2 = sys.argv[2]
   j = sys.argv[3]
   p_dim = sys.argv[4]

   expand_data(array,ind2, j, p_dim)
   
