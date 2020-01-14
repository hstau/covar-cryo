'''
.. Created 2015
.. codeauthor:: Hstau Y Liao <hstau.y.liao@gmail.com>
'''

import sys
import spider
import numpy as np, logging
import math

from arachnid.core.image import ndimage_file
from arachnid.core.metadata import format

def create_amat(ind2,ind3,sel_ang_file,refang_file,good_part_file,pref_image_in):
    sel_ang, header = format.read(sel_ang_file, ndarray=True)
    refang, header =  format.read(refang_file, ndarray=True)
    good_part =  format.read(good_part_file, ndarray=True)
    # get the image dimensions from one image (volume)
    index = sel_ang[0, 0].astype(np.int)
    iter_single_images = ndimage_file.iter_images(pref_image_in, index)
    for i, img in enumerate(iter_single_images):
        v_dim = np.array([img.shape[0],img.shape[1],img.shape[2]])
        p_dim = v_dim[0:2]
    # ray tracing
    amat = ray_tracing(refang, v_dim, p_dim, mask,ind2,ind3)
 

if __name__ == '__main__':
   ind2 = sys.argv[1]
   ind3 = sys.argv[2]
   sel_ang_file = sys.argv[3]
   refang_file = sys.argv[4]
   good_part_file = sys.argv[5]
   pref_image_in = sys.argv[6]

   create_amat(ind2,ind3,sel_ang_file,refang_file,good_part_file,pref_image_in)

                        



