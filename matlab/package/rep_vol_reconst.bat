; Reconstruct 3D volume from the normalized projections. Its projections which will be subtracted from the normalized data. 
MD
SET MP
0

; ====== INPUT 

FR L
[ref]psi_adju_angles     ; angles (from LIST: psi_adj)

FR L
[sel_ang]listparticles                        ; angles

FR L
[tprj]part_flip/nprj******      ; normalized (from LIST: data_pref)

; ======== OUTPUT

FR L
[vol_ave]vol_all

;=================
    

BP 3F
[tprj]   
[sel_ang]
[ref]
*
[vol_ave]


;BP CG
;[tprj]
;[sel_ang]
;(63.)     ;radius
;[ref]
;F
;[vol_ave]
;(1.0E-5, 0.0)
;(20,1)
;(2000)


EN
