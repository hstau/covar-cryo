MD
SET MP
0

; ====== INPUT 


FR L
[sel_ang]sel_ang                         ; angles

FR L
[sel]selfiles/prj_sel_{*****x11}         ; selfile with the part

FR L
[rprj]part_flip/rprj{******x22}

FR L
[sprj]part_flip/sprj{******x22}

FR L
[nprj]part_flip/nprj{******x22}

FR L
[repprj]part_flip/repprj{******x22}


;FR L   
;[fprj]part_flip/fsar{******x22}  ; filt particle


;=================
    
; list of selected angles
UD N, x33
[sel_ang]

DO LB1 x10 = 1,x33
    
  UD IC x10, x11
  [sel_ang]

  ; sel file with a list of particles in the same bin
  UD N, x44
  [sel]

  DO LB2 x20 = 1,x44

    ; read particle number
    UD IC x20, x22
    [sel]
             
    DE
    [rprj]

    DE
    [nprj]

    DE
    [sprj]

    DE
    [repprj]
  
    ;DE
    ;[fprj]


  LB2

  UD ICE
  [sel]

LB1

UD ICE
[sel_ang]

EN
