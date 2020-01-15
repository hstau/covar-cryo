MD
SET MP
0

; ====== INPUT 

FR L
[ref]refangles                         ; angles

FR L
[sel_ang]sel_ang                         ; angles

FR L
[sel]selfiles/prj_sel_{*****x11}         ; selfile with the part

FR L
[list]listparticles                        ; angles

FR L   
[fprj]part_flip/fsar{******x22}  ; filt particle

FR L
[tfprj]part_flip/fsar******    ; template of filt particle

FR L   
[shfprj]part_flip/sh_fsar{******x22}  ; filt particle

FR L
[tshfprj]part_flip/sh_fsar******    ; template of filt particle


; ======== OUTPUT

FR L
[ave]stats/ave_{*****x11}           ; average

FR L
[tave]stats/ave_*****               ; template of average
 
FR L
[var]stats/var_{*****x11}           ; var

FR L
[tvar]stats/var_*****               ; template of var

FR L
[vol_ave]vol_ave

FR L
[vol_var]vol_var


;=================


; list of selected angles
UD N, x33
[sel_ang]


DO LB1 x10 = 1,x33

  UD IC x10, x11
  [sel_ang]

  AS S
  [tfprj]
  [sel]
  AV
  [ave]
  [var] ;

LB1

UD ICE
[sel_ang]


BP 3F
[tave]   
[sel_ang]
[ref]
*
[vol_ave]

BP 3F
[tvar]   
[sel_ang]
[ref]
*
[vol_var]


EN
