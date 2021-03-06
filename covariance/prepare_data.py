import numpy as np
import multiprocessing
import prepare_data_single
from functools import partial
from contextlib import contextmanager
from subprocess import Popen
import myio
import set_params
import os
import p

'''Copyright (c) Columbia University Hstau Liao 2019    
'''
import time

@contextmanager

def poolcontext(*args, **kwargs):
    pool = multiprocessing.Pool(*args, **kwargs)
    yield pool
    pool.terminate()

def fileCheck():
    fin_PDs = [] #collect list of previously finished PDs from distances/progress/
    for root, dirs, files in os.walk(p.dist_prog):
        for file in sorted(files):
            if not file.startswith('.'): #ignore hidden files
                fin_PDs.append(int(file))
    return fin_PDs

def divide(CG,q,df,N):
    ll = []
    fin_PDs = fileCheck()
    for prD in range(N):
        ind = CG[prD]
        q1 = q[:, ind]
        df1 = df[ind]
        dist_file = '{}prD_{}'.format(p.dist_file, prD)
        if prD not in fin_PDs:
            ll.append([ind, q1, df1, dist_file, prD])
    return ll

def count(N):
    c = N - len(fileCheck())
    return c

def op(*argv):
    time.sleep(5)
    set_params.op(1)

    data = myio.fin1(p.tess_file)
    CG = data['CG']
    #print 'ncpu in getdist=',p.ncpu
    if p.machinefile:
        print 'using MPI with {} processes'.format(p.ncpu)
        Popen(["mpirun", "-n", str(p.ncpu), "--machinefile", str(p.machinefile),
              "python", "prepare_data_single.py", str(p.proj_name)],close_fds=True)
        if argv:
            progress1 = argv[0]
            offset = 0
            while offset < p.numberofJobs:
                offset = p.numberofJobs - count(p.numberofJobs)
                progress1.emit(int((offset / float(p.numberofJobs)) * 100))
                time.sleep(5)
        # wait till all processes are done
        while count(p.numberofJobs) > 0:
            time.sleep(5)
        Popen(["relion_reconst", "-n", str(p.ncpu), "--machinefile", str(p.machinefile),
              "python", "kk.py", str(p.proj_name)],close_fds=True)
    else:
        print "preparing data"
        df = data['df']
        q = data['q']
        sh = data['sh']
        set_params.op(1)
        size = len(df)

        filterPar = dict(type='Butter',Qc=0.5,N=8)
        options = dict(verbose=False,avgOnly=False,visual=False,parallel=False,
                       relion_data=p.relion_data,thres=p.PDsizeThH)

        sigmaH = 0

        input_data = divide(CG, q, df, p.numberofJobs)
        if argv:
            progress1 = argv[0]
            offset = p.numberofJobs - len(input_data)
            progress1.emit(int((offset / float(p.numberofJobs)) * 100))

        print "Processing {} projection directions.".format(len(input_data))

        if p.ncpu == 1 or options['parallel'] == True: # avoids the multiprocessing package
            for i in range(len(input_data)):
                prepare_data_single.op(input_data[i],filterPar, p.img_stack_file,
                                                    sh, size, options)
                if argv:
                    offset += 1
                    progress1.emit(int((offset / float(p.numberofJobs)) * 100))
        else:
            with poolcontext(processes=p.ncpu,maxtasksperchild=1) as pool:
                for i, _ in enumerate(pool.imap_unordered(partial(prepare_data_single.op,
                                                               filterPar=filterPar, imgFileName=p.img_stack_file,
                                                              sh=sh,nStot=size, options=options), input_data), 1):
                    if argv:
                        offset += 1
                        progress1.emit(int((offset / float(p.numberofJobs)) * 100))

                    time.sleep(0.05)
                pool.close()
                pool.join()

        set_params.op(0)

    return


if __name__ == '__main__':
    import Data
    import p, os
    p.init()
    p.user_dir = '../'
    p.out_dir = os.path.join(p.user_dir, 'data_output/')
    p.nowTime_file = os.path.join(p.user_dir,'data_output/nowTime')
    p.align_param_file = os.path.join(p.user_dir, 'run_it300_data.star')
    p.img_stack_file = os.path.join(p.user_dir, '2_toy42_stack.mrcs')
    p.create_dir()
    Data.op(p.align_param_file)
    op()
