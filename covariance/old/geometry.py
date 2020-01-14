'''
.. Created 2015
.. codeauthor:: Hstau Y Liao <hstau.y.liao@gmail.com>
'''

import eulerangles as eu
import numpy as np
import utilities as ut

def proj_sphere(elev,azim,p):
     # compute the unit vector for elev and azim
     elev = elev*np.pi/180
     azim = azim*np.pi/180
     u_elev = np.array([elev])
     u_azim = np.array([azim])
     u = euler_to_vect_X(u_elev,u_azim) # u is 1x3
     print u_elev
     # extract data points in front view 
     d = np.dot(p,u.T)
     # keep the points that are in front view
     pp= np.nonzero(d>0)
     p = p[np.nonzero(d>0)[0],:]
     # Now get their 2D coordinates on the view plane
     # first, find the intersection between the view plane and the XY plane
     # and this is the horizontal axis of the 2D proj
     # print u.shape
     #v = np.array([[-u[0][1]],[u[0][0]],[0]])
     v = np.array([[-np.sin(azim)],[np.cos(azim)],[0]]) # v is 3x1
     v = v.T # v is 1x3
     # cross product to get the vertical axis of the 2D proj
     w = np.cross(u,v)
     # Finally, get the 2D coordinates
     py = np.dot(p,v.T) # px is a row vector
     px = np.dot(p,w.T)
     #print py.shape,px.shape
     pt = np.concatenate((px,py),axis=1)
     aa = p[:,0]
     p[:,0:2] = pt[:,0:2]
     #print aa.ndim
     #print pt.shape
     print p.shape
     return p
    
def euler_to_rot(psi, theta, phi):       
     M1 = eu.euler2mat(phi)
     M2 = eu.euler2mat(0, theta)
     M3 = eu.euler2mat(psi)     
     return np.dot(M3, np.dot(M2, M1))

def euler_to_vect(theta, phi):
     px = np.cos(theta)*np.sin(phi)
     py = np.sin(theta)*np.sin(phi)
     pz = np.cos(phi)
     p = np.hstack((ut.mcol(px),ut.mcol(py),ut.mcol(pz)))
     return p

# elev = pi/2 - theta
def euler_to_vect_X(elev, azim):
     theta = np.pi/2 - elev
     phi = azim
     p = euler_to_vect(theta,phi)
     return p

