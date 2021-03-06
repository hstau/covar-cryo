'''
.. Created 2015
.. codeauthor:: Hstau Y Liao <hstau.y.liao@gmail.com>
'''

import sys
import numpy as np
import math

def get_diag3(array,ind3):
    # get the number of voxels in reduced index
    N1 = array.shape[0]
    N = round(math.sqrt(N1))
    # extract the diagonal elements
    array.reshape((N,N))
    var = np.diag(array)
    # get the number of voxels          
    find3 = ind3[0]
    NX = round((find3.shape[0])**0.333)          
    v_dim = [NX NX NX]
    var = expand_volume(var, ind3, v_dim)
    return var

if __name__ == '__main__':
   array = sys.argv[1]
   ind3 = sys.argv[2]
  
   get_diag3(array,ind3)
   

                        



