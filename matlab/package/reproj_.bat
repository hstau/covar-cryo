; reproject the reconstructed volume to get the "mean projections" which are subtracted from the normalized data.
MD
SET MP
0
; ----------- Registers ------------------------

x41=65 ; radius?

; ----------- Input files --------------
FR L
<ref1>vol_all  ; 

FR L
<ang>align_dala; (from LIST: align)

FR L
<ang1>psi_adju_angles   ; (from LIST: psi_adj)

FR L
<sel1>listparticles

; ----------- Output files --------------

FR L
[repprj]part_flip/repprj{******x11}

FR L
[trepprj]part_flip/repprj******

; -------------- END BATCH HEADER --------------------------


; project at original angle

pj 3q
<ref1>
x41   
<sel1> ; counter
<ang>
[trepprj]

; mirror reflection if necessary

UD N, x33
[sel1]

DO LB1 x10 = 1,x33

   UD IC x10, x11
   [sel1]
   
   UD IC x11,x61,x62,x63
   [ang]

   IF (x62 .GT. 180) THEN
     MR
     [repprj]
     _1
     Y 

     CP
     _1
     [repprj]

   ENDIF
UD ICE
[sel1]

; now rotate using the corrected psi angle

RT SQ
  [treprj]
  [sel1]
  1,0,0,0
  [ang1]
  [treprj]
EN d
;


