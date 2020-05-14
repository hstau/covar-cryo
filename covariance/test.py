from scipy.sparse.linalg import LinearOperator,svds
import numpy as np

#M = np.array([[2,5,6],[7,9,8],[2,6,3]])
#T = M.T
#M = np.eye(3)
 
def mv(v):
	print 'v=',v
	M = np.array([[2,5,6],[7,9,8],[2,6,3]])
	M = np.eye(3)
	M[:,2]=0
	print 'M=',M
	return np.dot(M,v)


def hmv(v):
	print 'vt=',v
        T = np.array([[2,7,2],[5,9,6],[6,8,3]])
	T = np.eye(3)
	T[2,:]=0
	print 'T=',T
	return np.dot(T,v)

M=LinearOperator((3,3),matvec=mv,rmatvec=hmv)

U,S,V = svds(M, k=2, which='LM', tol=0, maxiter=300)

k=2
print 'U=',U
print 'V=',V
print 'S=',S

res = np.dot(np.dot(U[:,:2],np.diag(S[:2])),V[:,:k])

print 'res=', res

U,S,V = svds(np.eye(3), k=2, which='LM', tol=0, maxiter=300)

print 'U=',U
print 'V=',V
print 'S=',S

res = np.dot(np.dot(U[:,:2],np.diag(S[:2])),V[:,:k])

print 'res=', res

