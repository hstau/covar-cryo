import sys


from arachnid.core.metadata import spider_utility 
from arachnid.core.image import ndimage_file
from arachnid.core.image import ndimage_interpolate


import glob

def decimate(input_files,output_file,bin_factor):

    input_files = glob.glob(input_files)
    print "processing %d files"%len(input_files)
    img = ndimage_file.read_image(input_files[0])
    nsize = img.shape[0]/2

    for input_file in input_files:
        print 'processing ', input_file
        output_file = spider_utility.spider_filename(output_file, input_file)
        for i, img in enumerate(ndimage_file.iter_images(input_file)):
            img = ndimage_interpolate.downsample(img, bin_factor)
            #img = ndimage_interpolate.interpolate_ft(img, (nsize,nsize))
            ndimage_file.write_image(output_file, img, i)

if __name__ == '__main__':
    
    input_files = sys.argv[1]
    output_file = sys.argv[2]
    bin_factor = int(sys.argv[3])
    
    decimate(input_files,output_file,bin_factor)
                        
                              
          
               
         

                   
