import numpy as np
import myio
import compress_data
import p
from scipy.sparse import lil_matrix

def cov(fin, imgs1,imgs2,PrD1,PrD2):

    K = min(imgs1.shape[0], imgs2.shape[0]) # K is the number of images
    im1 = np.zeros((K, max(fin[PrD1, :])))
    im2 = np.zeros((K, max(fin[PrD2, :])))
    #im1 = np.zeros((K, imgs1.shape[1] * imgs1.shape[2]))
    #im2 = np.zeros((K, imgs2.shape[1] * imgs2.shape[2]))

    for k in range(K):
        prj1 = imgs1[k,:,:]
        im1[k,:],ind1 = compress_data.op(fin, prj1, PrD1)
        prj2 = imgs2[k,:,:]
        im2[k,:],ind2 = compress_data.op(fin, prj2, PrD2)

    ave1 = np.mean(im1,0)
    ave2 = np.mean(im2,0)

    im1 = im1 - np.tile(ave1,(K,1))
    im2 = im2 - np.tile(ave2,(K,1))

    cov_2d = np.matmul(im1.T, im2) / K

    return (cov_2d,ind1,ind2)

def op(N, fin, PrD1, PrD2):
    # read prj images
    dist_file = '{}prD_{}'.format(p.dist_file, PrD1)
    data = myio.fin1(dist_file)
    imgs1 = data['imgAll']
    dist_file = '{}prD_{}'.format(p.dist_file, PrD2)
    data = myio.fin1(dist_file)
    imgs2 = data['imgAll']
    # original image part
    cov_2d,ind1,ind2 = cov(fin,imgs1,imgs2,PrD1,PrD2)

    # noise part (shift by half length first)
    N2 = int(np.rint(imgs1.shape[1]/2.))
    noise1 = np.roll(imgs1, [N2, N2], axis=(0, 1))
    noise2 = np.roll(imgs2, [N2, N2], axis=(0, 1))
    cov_noise,ind1,ind2 = cov(fin, noise1, noise2, PrD1, PrD2)

    cov_2d = cov_2d - cov_noise

    # create a sparse matrix to hold cov_2d
    Cy = lil_matrix((N*N, N*N), dtype=np.float64)
    x, y = np.meshgrid(ind1, ind2)
    Cy[x,y] = cov_2d
    #Cy = lil_matrix(cov_2d)
    return Cy