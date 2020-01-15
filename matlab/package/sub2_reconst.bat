; subtracting the "mean" from the normalized data
MD
SET MP
0

; ====== INPUT 

FR L
[ref]refangles                         ; angles (from LIST: ref_ang)

FR L
[sel_ang]sel_ang                         ; angles (from LIST: sel_ang)
 
FR L
[sel]selfiles/prj_sel_{*****x11}         ; (from LIST: sel_prj_pref)

FR L
[list]listparticles                        ; angles

FR L
[tprj]part_flip/nprj******      ; particles

FR L
[prj]part_flip/nprj{******x22}     ; particles

FR L
[trprj]part_flip/repprj******      ; particles

FR L
[rprj]part_flip/repprj{******x22}      ; particles

FR L
[maskn]mask_53n

FR L
[shifts]shifts

;X12 = 0.2                        ; filter
;X13 = X12 + 0.1

; ======== OUTPUT

FR L
[list1]goodparticles  (from LIST: good_part)


FR L
[tsprj]part_flip/sprj******  ; subtracted particles

FR L
[sprj]part_flip/sprj{******x22} 

FR L   
[fprj]part_flip/fsar{******x22}  ; filtered particle

FR L
[tfprj]part_flip/fsar******    ; template of filt particle

FR L   
[shfprj]part_flip/sh_fsar{******x22}  ; filtered shifted particle

FR L
[tshfprj]part_flip/sh_fsar******    ; template of filtered shifted particle


;=================


SUB 2   
[tprj]
[list]
[trprj]  
[list]
[tsprj]  
[list]

    
; list of selected angles
UD N, x33
[sel_ang]

x99 = 1

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
         
    CP ; just copy, no filtering
    [sprj]
    [fprj]

    SD x99, x22
    [list1]
    x99 = x99 + 1
  LB2

  UD ICE
  [sel]


LB1

SD E
[list1]

UD ICE
[sel_ang]

; SHIFT 1/2 window

SH
[tfprj]
[list1]
[tshfprj]
[shifts]
(1,2)

 
EN
