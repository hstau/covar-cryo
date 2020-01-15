; correct for the psi angle
; ====== INPUT 

FR L
[psi_adj]psi_adju_angles    ; angles (from LIST: psi_adj)

FR L
[sel]listparticles

FR L
[tprj]part_flip/prj******     ; particles  (from LIST: mir_pref)

; ======== OUTPUT

FR L
[trprj]part_flip/rprj******    ; template of rotated particle

;=================
    
MD  
SET MP
0   

  
  RT SQ
  [tprj]
  [sel]
  1,0,0,0
  [psi_adj]
  [trprj]

EN
