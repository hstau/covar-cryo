import myio
from contextlib import contextmanager
import logging, sys, os
import set_params
import p
import multiprocessing
from functools import partial
from subprocess import Popen
import covar3d_single
import create_map_mask2D

'''
Copyright (c) UWM, Ali Dashti 2016 (original matlab version)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Copyright (c) Columbia University Hstau Liao 2018 (python version)
Copyright (c) Columbia University Sonya Hanson 2018 (python version)
'''

import time
from pyface.qt import QtGui, QtCore
os.environ['ETS_TOOLKIT'] = 'qt4'

#_logger = logging.getLogger(__name__)
#_logger.setLevel(logging.DEBUG)


@contextmanager

def poolcontext(*args, **kwargs):
    pool = multiprocessing.Pool(*args, **kwargs)
    yield pool
    pool.terminate()
    pool.close()

def fileCheck(op):
    fin_PDs = []  # collect list of previously finished PDs from diff_maps/progress/
    for root, dirs, files in os.walk(p.cov_prog):
        for file in sorted(files):
            if not file.startswith('.'):  # ignore hidden file
                if op == 0:
                    fin_PDs.append(int(file))
                else:
                    ll = list(file)
                    temp = (ll[0],ll[2])
                    print 'pair=',temp
                    fin_PDs.append((ll[0],ll[2]))
    return fin_PDs

def count(N,op):
    c = N - len(fileCheck(op))
    return c

def divide(N, op):
    ll=[]
    fin_PDs = fileCheck(op)
    if op == 0:
        for prD in range(N):
            dist_file = '{}prD_{}'.format(p.dist_file, prD)
            if prD not in fin_PDs:
                ll.append([dist_file, prD])
    else:
        for prD in range(N):
            for prD1 in range(prD,N):
                dist_file = '{}prD_{}'.format(p.dist_file, prD)
                dist_file1 = '{}prD_{}'.format(p.dist_file, prD1)
                if (prD,prD1) not in fin_PDs:
                    ll.append([dist_file, prD, dist_file1, prD1])
    return ll

def op(*argv):
    '''op = 0  one projection at a time, RRt is approximated by a block diagonal
       op = 1  empirical, RRt considers all the projections as given
       op = 2  theoretical RRt has closed form, assuming uniform distrib of projection angles
               over S^2
    '''
    time.sleep(5)
    set_params.op(1)
    data = myio.fin1(p.tess_file)
    CG = data['CG']
    q = data['q']
    # create 2D masks from a 3D mask
    # fin is the vector of indeces with 2D mask pixels
    fin = create_map_mask2D.op(CG, q, p.msk3, p.nPix)

    if p.machinefile:
        op = 0
        print 'using MPI with {} processes'.format(p.ncpu)
        Popen(["mpirun", "-n", str(p.ncpu), "-machinefile", str(p.machinefile),
            "python", "modules/covar3d_mpi.py",str(p.proj_name)],close_fds=True)
        for i in range(p.numberofJobs):
            subdir = p.out_dir + '/topos/PrD_{}'.format(i + 1)
            Popen(["mkdir", "-p", subdir])
        if argv:
            progress2 = argv[0]
            offset = 0
            while offset < p.numberofJobs:
                offset = p.numberofJobs - count(p.numberofJobs,op)
                progress2.emit(int((offset / float(p.numberofJobs)) * 100))
                time.sleep(5)
    
    else:
        print "Computing the eigenvectors of the 3D covariance"
        doSave = dict(outputFile='', Is=True)
        # INPUT Parameters
        op = 1
        # Finding the covariances
        input_data = divide(p.numberofJobs, op)
        if argv:
            progress2 = argv[0]
            if op == 0:
                totalJobs = p.numberofJobs
            else:
                totalJobs = (p.numberofJobs * (p.numberofJobs + 1 )) / 2
            offset = totalJobs - len(input_data)
            progress2.emit(int((offset / float(p.numberofJobs)) * 100))

        print "Processing {} projection directions.".format(len(input_data))
        for i in range(p.numberofJobs):
            subdir = p.out_dir+'/topos/PrD_{}'.format(i+1)
            Popen(["mkdir", "-p", subdir])

        if p.ncpu == 1: #avoids the multiprocessing package
            for i in range(len(input_data)):
                covar3d_single.op(input_data[i], doSave, fin, p.nPix, q, op)
                if argv:
                    offset += 1
                    progress2.emit(int((offset / float(totalJobs)) * 100))
        else:
            with poolcontext(processes=p.ncpu,maxtasksperchild=1) as pool:
                for i, _ in enumerate(pool.imap_unordered(partial(covar3d_single.op,
                                   doSave=doSave, fin = fin, N = p.nPix, q=q, op=op), input_data), 1):
                    if argv:
                        offset += 1
                        progress2.emit(int((offset / float(totalJobs)) * 100))
                    time.sleep(0.05)
                pool.close()
                pool.join()

    print 'done with distributed covar calculation'
    set_params.op(0)
    progress2.emit(100)

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
