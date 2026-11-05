
SECTION "Header", ROM0[$100]

   nop     

   jp main 

   
   db $CE, $ED, $66, $66, $CC, $0D, $00, $0B, $03, $73, $00, $83, $00, $0C, $00, $0D
   db $00, $08, $11, $1F, $88, $89, $00, $0E, $DC, $CC, $6E, $E6, $DD, $DD, $D9, $99
   db $BB, $BB, $67, $63, $6E, $0E, $EC, $CC, $DD, $DC, $99, $9F, $BB, $B9, $33, $3E

   db "PASTOR"          
   ds $013F - @, 0      

   db $EF, $AC, $AE, $AE   

   db $00   

   db $00, $00 

   db $00   

   db $03   
   db $00   

   db $02   

   db $01   

   db $00   

   db $00   

   db $00   

   db $00, $00 
