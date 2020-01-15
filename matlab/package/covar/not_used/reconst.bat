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
[ffprj]part_flip/ffsar{******x22}  ; filt particle

FR L
[tffprj]part_flip/ffsar******    ; template of filt particle


FR L   
[shfprj]part_flip/sh_fsar{******x22}  ; filt particle

FR L
[tshfprj]part_flip/sh_fsar******    ; template of filt particle

FR L
[shffprj]part_flip/sh_ffsar{******x22}  ; filt particle

FR L
[tshffprj]part_flip/sh_ffsar******    ; template of filt particle



;X12 = 0.1  ;0.05
;X13 = 0.12 ;0.06

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

  ; sel file with a list of particles in the same bin
  UD N, x44
  [sel]

  DO LB2 x20 = 1,x44

    ; read particle number
    UD IC x20, x22
    [sel]
         
    ;FQ
    ;[fprj]
    ;_1
    ;(7)
    ;(X12,X13)    

    ;FQ
    ;[shfprj]
    ;_2   
    ;(7)
    ;(X12,X13)

    IP FS
    [fprj];_1
    [ffprj]
    (32,32)

    IP FS
    [shfprj];_2   
    [shffprj]
    (32,32)
    
  LB2

  UD ICE
  [sel]
  
  AS S
  [tffprj]
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
