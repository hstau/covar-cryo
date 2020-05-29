import mrcfile
import os
import numpy as np
import project
import myio
import quaternion
import matplotlib.pyplot as plt
from pylab import imshow
import star
import q2Spider
import pandas

N = 10
N2 = 5
m = 3   # number of states
t = 3  # starting point
#a[5,5,2:7] = 1.
###############################
#phantom creation
#################################
b = np.zeros((m,N, N, N))
for i in range(m):
    a = np.zeros((N, N, N))
    phan_file = 'phantom{}.mrc'.format(i)
    '''
    if os.path.exists(phan_file):
        mrc = mrcfile.open(phan_file, mode='r')
    else:
        mrc = mrcfile.new(phan_file)
    '''
    mrc = mrcfile.new(phan_file)
    a[N2-1:N2+1, N2-1:N2+1,t+i-1:t+i+1] = 1.
    b[i,:,:,:] = a
    a = a.astype(np.float32)
    mrc.set_data(a)

phan_file = 'phantom_ave.mrc'
mrc = mrcfile.new(phan_file)
a=np.mean(b,axis=0)
a = a.astype(np.float32)
mrc.set_data(a)

#########################
#data creation
#########################

data = myio.fin1('selecGCs')
CG = data['CG']
q = data['q']
PDs = quaternion.cal_avg_pd_all(q, CG)

data = np.zeros((len(CG)*m,N,N))
print 'lenPD=',len(PDs)
print 'lenCG=',len(CG)

k=0
for PD in PDs:
    for i in range(m):
        ind = k*m + i
        a = b[i,:,:,:]
        prj = project.op(a,PD)
        data[ind,:,:] = prj
        #imshow(prj,cmap='gray')
        #plt.show()
    k+=1
data = data.astype(np.float32)
data_file = 'phantom.mrcs'
'''
if os.path.exists(data_file):
    mrc = mrcfile.open(data_file, mode='w')
else:
    mrc = mrcfile.new(data_file)
'''
mrc = mrcfile.new(data_file)
mrc.set_data(data)
#############################
# star file creation
#############################
ang_file = 'phantom.star'
phi = np.empty(len(CG))
theta = np.empty(len(CG))
psi = np.empty(len(CG))
for k in range(len(CG)):
    PD = PDs[k]
    lPD = sum(PD ** 2)
    Qr = np.array([1 + PD[2], PD[1], -PD[0], 0])
    # print i, j, Qr,GCs
    Qr = Qr / np.sqrt(np.sum(Qr ** 2))
    # Qr = np.array([0.6807, -0.7263, .0951, 0])
    phi[k], theta[k], psi[k] = q2Spider.op(Qr)

phi = np.mod(phi, 2 * np.pi) * (180 / np.pi)
theta = np.mod(theta, 2 * np.pi) * (180 / np.pi)
psi[:] = 0.0  # np.mod(psi,2*np.pi)*(180/np.pi) already done in getDistance

phi1 = np.tile(phi[np.newaxis].T,(1,m)).flatten()
theta1 = np.tile(theta[np.newaxis].T,(1,m)).flatten()
psi1 = np.tile(psi[np.newaxis].T,(1,m)).flatten()

d = dict(phi=phi1, theta=theta1, psi=psi1)
df = pandas.DataFrame(data=d)
star.write_star(ang_file, data_file, df)

