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
[list1]goodparticles

FR L
[shifts]shifts


FR L
[tsprj]part_flip/sprj******

FR L
[sprj]part_flip/sprj{******x22} 

FR L   
[fprj]part_flip/ffsar{******x22}  ; filt particle

FR L
[tfprj]part_flip/ffsar******    ; template of filt particle

; =   

FR L   
[shfprj]part_flip/sh_ffsar{******x22}  ; filt particle

FR L
[tshfprj]part_flip/sh_ffsar******    ; template of filt particle



;=================

; SHIFT 1/2

SH
[tfprj]
[list1]
[tshfprj]
[shifts]
(1,2)



EN
