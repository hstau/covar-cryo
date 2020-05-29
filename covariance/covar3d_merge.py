import myio
import logging, sys, os
import set_params
import p
import covar3d_all

'''
Copyright (c) Columbia University Hstau Liao 2018 (python version)
'''

import time
from pyface.qt import QtGui, QtCore
os.environ['ETS_TOOLKIT'] = 'qt4'

def op(*argv):
    '''op = 0  one projection at a time, RRt is approximated by a block diagonal
       op = 1  empirical, RRt considers all the projections as given
       op = 2  theoretical RRt has closed form, assuming uniform distrib of projection angles
               over S^2
    '''
    time.sleep(5)
    set_params.op(1)

    print 'starting merging covar calculation'

    data = myio.fin1(p.tess_file)
    CG = data['CG']
    q = data['q']

    if argv:
        progress3 = argv[0]
    op = 1
    # merge results
    covar3d_all.op(CG, q, p.nPix, op)

    set_params.op(0)

    print 'done with merging covar calculation'
    progress3.emit(100)
    return

if __name__ == '__main__':
    import p, os
    p.init()
    p.user_dir = '../'
    p.out_dir = os.path.join(p.user_dir, 'data_output/')
    p.tess_file = '{}/selecGCs'.format(p.out_dir)
    p.nowTime_file = os.path.join(p.user_dir, 'data_output/nowTime')
    p.create_dir()
    op()
