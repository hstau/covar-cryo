; normalize particles to have zero mean and variance one in the background
; ====== INPUT 

FR L
[sel]listparticles

FR L
[prj]part_flip/rprj{******x22}     ; rotated particles 

FR L
[maskn]mask_53n  ; create circular mask with SPIDER covering just the particle

; ======== OUTPUT

FR L
[nprj]part_flip/nprj{******x22}    ; normalized (from LIST: data_pref)

;=================

MD
SET MP
0
    
; normalize

UD N, x33
[sel]

DO LB1 x22 = 1,x33

    ; normalization
    FS M x81,x82,x83,x84 ; max,min,ave,std
    [prj]
    [maskn]

    AR 
    [prj]
    [nprj]
    (P1-x83)/x84

LB1

EN
