; reproject the reconstructed volume to get the "mean projections" which are subtracted from the normalized data.
MD
SET MP
0
; ----------- Registers ------------------------

x41=65 ; radius?

; ----------- Input files --------------
FR L
<ref1>vol_all  ; input, reference volume 1

FR L
[prj]part_flip/nprj{******x11}     ; normalized (from LIST: data_pref)

FR L
<ang1>psi_adju_angles   ; output angular file  (from LIST: psi_adj)

FR L
<sel1>listparticles

FR L
[mask]mask_65
; ----------- Output files --------------

FR L
[repprj]part_flip/repprj{******x11}

FR L
[trepprj]part_flip/repprj******

; -------------- END BATCH HEADER --------------------------


; project first

pj 3q
<ref1>
x41   
<sel1> ; counter
<ang1>
[trepprj]

; now correct

; compute size of mask
AR
[mask]
_1
P1*0

CC C x99,x21,x22,x23,x24,x88 ; [ccc],[av1],[sd1],[av2],[sd2],[eud]
[mask]
_1
[mask]   ; within this mask

VM    
echo area mask = {%F20.10%x88} 

; correction

UD N, x33
[sel1]

UD N, x33
[ang1] 

x95 = 0

DO LB1 x10 = 1,x33

   UD IC x10, x11
   [sel1]
   
   UD IC x11,x61,x62,x63
   [ang1]

   IF (x62 .GT. 180) THEN
     MR
     [repprj]
     _1
     Y 

     CP
     _1
     [repprj]

   ENDIF
  
   ;CC C x99,x21,x22,x23,x24,x25 ; [ccc],[av1],[sd1],[av2],[sd2],[eud]
   ;[prj]
   ;[repprj]
   ;[mask]
  
   ;x91 = x21*x21+x22*x22  ; squared Euclidean norm of 1 averaged
   ;x92 = x23*x23+x24*x24  ; squared Euclidean norm of 2 averaged   
   ;x93 = 0.5* (x91 + x92 - x25 / x88) ; inner product averaged
   ;x94 = x93/x92 ; lambda
  
   ;VM    
   ;echo factor = {%F20.10%x94} 
   ;VM
   ;echo euc_before = {%F20.10%x25}  
  
   ;AR
   ;[repprj]
   ;_2
   ;P1*x94

   ;CC C x99,x21,x22,x23,x24,x25 ; [ccc],[av1],[sd1],[av2],[sd2],[eud]
   ;[prj]
   ;_2
   ;[mask]

   ;VM   
   ;echo euc_after = {%F20.10%x25} 
   
   ;CP 
   ;_2
   ;[repprj]

   x95 = x95 + x94
LB1

x95 =x95/x33

VM
echo factor = {%F20.10%x95}

;x95 = 1  ; if I do not do this,  particle 29094 will be nan

;DO LB2 x10 = 1,x33

   ;AR
   ;[repprj]
   ;_2
   ;P1*x95

   ;CP
   ;_2
   ;[repprj]
;LB2

UD ICE
[sel1]

UD ICE
[ang1]

EN d
;


