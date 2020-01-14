'''
.. Created 2015
.. codeauthor:: Hstau Y Liao <hstau.y.liao@gmail.com>
'''

import numpy as np

def decomp3(in1, v_dim):
    NX = v_dim[0]
    NY = v_dim[1]
    a = np.floor(in1/NX)
    a = in1 - a*NX
    in1 = (in1 - a)/NX
    c = np.floor(in1/NY)
    b = in1 - c*NY
    return (a,b,c) 
