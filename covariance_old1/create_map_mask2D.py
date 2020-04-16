'''
.. Created 2015
.. codeauthor:: Hstau Y Liao <hstau.y.liao@gmail.com>
'''

import sys
import spider
import numpy as np
import math
import decomp2

from arachnid.core.image import ndimage_file
#from arachnid.core.metadata import format


def create_map2(sel_ang_file, pref_image_in):
    # read in sel of angles file
    selang =  spider.parse(sel_ang_file)
    print("Using %d bins"%len(selang))
    # read in one mask file to get the sizes
    index = selang[0, 0].astype(np.int)
    iter_single_images = ndimage_file.iter_images(pref_image_in, index)
    for i, img in enumerate(iter_single_images):
        NX = img.shape[0]
        NY = img.shape[1]
    NX2 = NX/2
    NY2 = NY/2
    # create array of the image sizes
    p_dim = np.array([NX, NY])
    #inda2 = np.array([1 NX2])
    # cicle image mask
    circ = circ_mask(p_dim)
    # create the index vectors
    find2 = np.zeros((NX*NY,selang[:,0].shape[0]))
    cind2 = np.zeros((NX*NY/4,selang[:,0].shape[0]))
    # read in mask files
    index = selang[:, 0].astype(np.int)
    iter_single_images = ndimage_file.iter_images(pref_image_in, index)
    for k, mask in enumerate(iter_single_images):
        # binarized and plus 1
        mask = (mask>0).astype(np.int) + 1
        mask = mask*circ
        mask = mask.flatten(1)
        for i in range(len(mask)):
            a,b = decomp2(i,p_dim)
            if mask[i] == 2:
                find2[i,k] = -i;
            elif mask[i] == 1:
                a = np.floor(a/2)
                b = np.floor(b/2)
                m = a + b*NX2
                cind2[m,k] = m
        # prunning: set find2 to zero to those in the coarse area
        for i in range(len(mask)):
            a,b = decomp2(i,p_dim)
            a = np.floor(a/2)
            b = np.floor(b/2)
            m = a + b*NX2
            if cind2[m,k] != 0:
                find2[i,k] = 0
        # reducing the size of indexes
        I = np.nonzero(cind2[:,k])
        cind2[I,k] = range(len(I[0]))
        offset = len(I[0])
        I = np.nonzero(find2[:,k])
        find2[I,k] = cind2[I,k] + offset

    # concatenate find2 and cind2 to create a cell
    ind2 = [find2,cind2]

    return ind2

if __name__ == '__main__':
   sel_ang_file = sys.argv[1]
   pref_image_in = sys.argv[2]

   create_map2(sel_ang_file, pref_image_in)

                        
