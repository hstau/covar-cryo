'''
.. Created 2015
.. codeauthor:: Hstau Y Liao <hstau.y.liao@gmail.com>
'''

import sys
import spider
import eulerangles as eu
import numpy as np, logging
import math
#import glob

from arachnid.core.image import ndimage_file
from arachnid.core.metadata import format

def get_unitv(phi, theta):

    u = np.cos(phi) * np.sin(theta)  # cos(phi).*sin(theta)
    v = np.sin(phi)* np.sin(theta)  # sin(phi).*sin(theta)  
    w = np.cos(theta)  # cos(theta)     
    
    return np.hstack((u,v,w))

def mcol(u):
    # u is an array
    u = np.reshape(u,(u.shape[0],1))
    return u

def adjust_psi(rpsi,rtheta,rphi,theta,phi):
   # number of increment steps for correcting psi angle
   N = 50
   # big initial dif
   dif = 1e10
   # rotation matrix for the reference Euler angles 
   rrot = euler_to_rot(rpsi,rtheta,rphi)
   # brute force search
   npsi = 0
   for i in range(N):
      psi = 2*math.pi*i/N
      # rotation matrix for particle Euler angles 
      rot = euler_to_rot(psi,theta,phi)   
      ndif = np.linalg.norm(rot-rrot)
      if (ndif < dif):
         npsi = psi
         dif = ndif
  
   return npsi   

def euler_to_rot(psi, theta, phi):       
     
     M1 = eu.euler2mat(phi)
     M2 = eu.euler2mat(0, theta)
     M3 = eu.euler2mat(psi)
     
     return np.dot(M3, np.dot(M2, M1))

def get_mirror(ima):
    
    ima= np.hstack((ima[:,0].reshape(-1,1),ima[:,-1:0:-1]))
    return ima
    
                            
def bin(align_param_file, ref_ang_file, pref_image_in, pref_image_out, pref_sel, pref_sel_all,thres):
   # read in the alignment parameters and the reference angles
   # 1st column is psi, 2nd is theta, and 3rd is phi
   align = spider.parse(align_param_file)
   #align,header = format.read_alignment(align_param_file, ndarray=True)
   print("Reconstructing %d particles"%len(align))
   #assert(header[0]=='id')
   # read in reference angles
   refang = spider.parse(ref_ang_file)
   index = align[:, 0].astype(np.int)
   #refang, header = format.read_alignment(ref_ang_file, ndarray=True)
   #assert(header[0]=='id')
   # from degree to radian from column 1
   align[:,1:4] = np.deg2rad(align[:,1:4])
   refang[:,1:4] = np.deg2rad(refang[:,1:4])
   # read in pref of images
   iter_single_images = ndimage_file.iter_images(pref_image_in, index)
   # form unit directional vectors
   rphi = mcol(refang[:,3])
   rtheta = mcol(refang[:,2]) 
   unit_v = get_unitv(rphi,rtheta)
   
   # 2-array to track indeces of particles in the same angle bin 
   # Max number of particles in the same angle bin 
   MAX = 5000
   index = np.zeros((refang.shape[0],MAX))
   # array to track the number of particles in each bin
   quant = np.zeros((refang.shape[0]))
   # binning: loop through particles 
   for i, img in enumerate(iter_single_images):
      # direction of one particle
      phi = align[i,3]
      theta = align[i,2] 
      uv = get_unitv(phi,theta)
      # read in image
      #print i
      #img = ndimage_file.read_image(img)
      if theta > math.pi:
         img = get_mirror(img)
      ndimage_file.write_image(pref_image_out, img, i)
      # multiply with all ref ang and store the largest       
      ip = np.dot(unit_v,uv.T)
      # store the largest in the right bin
      bin = ip.argmax()
      index[bin,quant[bin]] = align[i,0]
      quant[bin] += 1
      #print index
      # adjust the psi angle
      rpsi = refang[bin,1]
      rtheta = refang[bin,2]
      rphi = refang[bin,3]  
      psi = adjust_psi(rpsi,rtheta,rphi,theta,phi)
      align[i,1] = psi     
   # loop through the bins and keep only those with more than 'thres' particles
   S = [] # will hold the selected bin numbers
   count = 0
   for j in range(refang.shape[0]):
      sz =  len(np.nonzero(index[j,:])[0])
      if sz > thres:
         table = index[j,0:sz]
         #print table
         filename = pref_sel + '{:05d}'.format(j)
         spider.write(filename,table)
         S.append(j)
   #print S
   spider.write(pref_sel_all,S)                     


if __name__ == '__main__':
   align_param_file = sys.argv[1]
   ref_ang_file = sys.argv[2]
   pref_image_in = sys.argv[3]
   pref_image_out = sys.argv[4]
   pref_sel = sys.argv[5]
   pref_sel_all = sys.argv[6] 
   thres = int(sys.argv[7])

   bin(align_param_file, ref_ang_file, pref_image_in, pref_image_out, pref_sel, pref_sel_all,thres)               
                        
                              
          
               
