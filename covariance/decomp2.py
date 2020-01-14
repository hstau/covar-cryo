'''
.. Created 2015
.. codeauthor:: Hstau Y Liao <hstau.y.liao@gmail.com>
'''

import numpy as np

def decomp2(in1, p_dim):
    NX = p_dim[0]
    a = np.floor(in1/NX)
    a = in1 - a*NX
    b = (in1 - a)/NX
    return (a,b)    
