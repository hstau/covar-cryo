#run via: 'chimera 2_GenMovie.py'
session = 'view1' #name of session saved in Chimera (e.g., 'view1' for view1.py)

################################################################################
# GENERATE CHIMERA MOVIE #
################################################################################
import os
from chimera import runCommand as rc

pyDir = os.path.dirname(os.path.abspath(__file__)) #python file location
projDir = os.path.join(pyDir, '%s' % session)
outDir = os.path.join(pyDir, 'views/%s/%s' % (session, session)) #folder where files will be written
if not os.path.exists(os.path.join(pyDir, 'views')):
    os.mkdir(os.path.join(pyDir, 'views'))
if not os.path.exists(os.path.join(pyDir, 'views/%s' % session)):
    os.mkdir(os.path.join(pyDir, 'views/%s' % session))

wait_time=1
states=(1,51)

rc('open %s.py' % projDir)
rc('movie record')
for i in xrange(*states):
    rc('background solid black')
    rc('set projection orthographic')
    #rc('unset depthCue')
    if 0: #SURFACE REPRESENTATION
        rc('volume #%d show style surface step 1 level 0.008 color white' % (i-1))
    if 1: #SOLID REPRESENTATION
        rc('volume #%d show style solid step 1 color gray' % (i-1))
    rc('sop hideDust #%d size 90' % (i-1))
    rc('wait %d' % wait_time)
    rc('copy file ' + outDir + '_%s.png' % i)
    rc('volume #%d hide' % (i-1))
##rc('close all')

# create MOV:
rc('movie stop')
rc('movie encode output %s.mov' % outDir)
