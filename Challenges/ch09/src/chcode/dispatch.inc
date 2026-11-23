;;==============================================================
;; Challenge 5 · A dónde salta cada ejercicio
;;   Cada rutina de un ejercicio salta aquí. Según `main.asm`, se usa tu código (ejNN.asm) o el del proyecto.
;;   ❌ No lo modifiques
;;==============================================================
SECTION "Dispatch", ROM0

go_ej01::
IF STRCMP("{TEST}", "game") == 0
   jp   ej01
ELSE
   IF STRCMP("{TEST}", "test_ej01") == 0
      jp   ej01
   ELSE
      jp   ref_ej01
   ENDC
ENDC

go_ej02::
IF STRCMP("{TEST}", "game") == 0
   jp   ej02
ELSE
   IF STRCMP("{TEST}", "test_ej02") == 0
      jp   ej02
   ELSE
      jp   ref_ej02
   ENDC
ENDC

go_ej03::
IF STRCMP("{TEST}", "game") == 0
   jp   ej03
ELSE
   IF STRCMP("{TEST}", "test_ej03") == 0
      jp   ej03
   ELSE
      jp   ref_ej03
   ENDC
ENDC

go_ej04::
IF STRCMP("{TEST}", "game") == 0
   jp   ej04
ELSE
   IF STRCMP("{TEST}", "test_ej04") == 0
      jp   ej04
   ELSE
      jp   ref_ej04
   ENDC
ENDC

go_ej05::
IF STRCMP("{TEST}", "game") == 0
   jp   ej05
ELSE
   IF STRCMP("{TEST}", "test_ej05") == 0
      jp   ej05
   ELSE
      jp   ref_ej05
   ENDC
ENDC

go_ej06::
IF STRCMP("{TEST}", "game") == 0
   jp   ej06
ELSE
   IF STRCMP("{TEST}", "test_ej06") == 0
      jp   ej06
   ELSE
      jp   ref_ej06
   ENDC
ENDC

go_ej07::
IF STRCMP("{TEST}", "game") == 0
   jp   ej07
ELSE
   IF STRCMP("{TEST}", "test_ej07") == 0
      jp   ej07
   ELSE
      jp   ref_ej07
   ENDC
ENDC

go_ej08::
IF STRCMP("{TEST}", "game") == 0
   jp   ej08
ELSE
   IF STRCMP("{TEST}", "test_ej08") == 0
      jp   ej08
   ELSE
      jp   ref_ej08
   ENDC
ENDC

go_ej09::
IF STRCMP("{TEST}", "game") == 0
   jp   ej09
ELSE
   IF STRCMP("{TEST}", "test_ej09") == 0
      jp   ej09
   ELSE
      jp   ref_ej09
   ENDC
ENDC

go_ej10::
IF STRCMP("{TEST}", "game") == 0
   jp   ej10
ELSE
   IF STRCMP("{TEST}", "test_ej10") == 0
      jp   ej10
   ELSE
      jp   ref_ej10
   ENDC
ENDC

go_ej11a::
IF STRCMP("{TEST}", "game") == 0
   jp   ej11a
ELSE
   IF STRCMP("{TEST}", "test_ej11") == 0
      jp   ej11a
   ELSE
      jp   ref_ej11a
   ENDC
ENDC

go_ej11b::
IF STRCMP("{TEST}", "game") == 0
   jp   ej11b
ELSE
   IF STRCMP("{TEST}", "test_ej11") == 0
      jp   ej11b
   ELSE
      jp   ref_ej11b
   ENDC
ENDC

go_ej12::
IF STRCMP("{TEST}", "game") == 0
   jp   ej12
ELSE
   IF STRCMP("{TEST}", "test_ej12") == 0
      jp   ej12
   ELSE
      jp   ref_ej12
   ENDC
ENDC

