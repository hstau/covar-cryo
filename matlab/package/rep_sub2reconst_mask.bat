;random_projection.bat, hx
; generate random eular angular file  (0-0. 0-90. 0-360)

MD
SET MP
0

; ----------- Registers ------------------------

x41=16 ; radius?
 
; ----------- Input files --------------

FR L
<ref1>sfvol_var_perc100_mask  ; 3D mask (from LIST: maskfile)

FR L
<ref>refangles                         ; angles

FR L
<sel_ang>sel_ang                         ; angles

; ----------- Output files --------------

FR L
<trepsvar>stats/rep_mask*****           ; 2D mask (from LIST: mask_pref)

; -------------- END BATCH HEADER --------------------------

pj 3q
<ref1>
x41
<sel_ang> ; counter
<ref>
<trepsvar>

EN d
;


