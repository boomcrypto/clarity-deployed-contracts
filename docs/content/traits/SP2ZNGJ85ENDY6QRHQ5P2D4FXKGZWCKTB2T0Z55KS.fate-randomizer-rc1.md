---
title: "Trait fate-randomizer-rc1"
draft: true
---
```
;; Fate Randomizer Interaction Contract
;;
;; This contract provides a narrative interface for rolling classic D&D dice types
;; and flipping coins using the dungeon's VRF-based randomizer. Each roll generates 
;; a thematic message describing the result.
;;
;; Actions:
;; - CF: Flip a coin (heads/tails)
;; - D4: Roll a four-sided die
;; - D6: Roll a six-sided die
;; - D8: Roll an eight-sided die
;; - D10: Roll a ten-sided die
;; - D12: Roll a twelve-sided die
;; - D20: Roll a twenty-sided die
;; - D100: Roll percentile dice
;;
;; Integration with Charisma Ecosystem:
;; - Implements the interaction-trait for exploration system compatibility
;; - Uses the dungeon's VRF randomizer for fair and verifiable rolls
;; - Provides narrative feedback for each roll attempt

;; Implement the interaction-trait
(impl-trait .dao-traits-v7.interaction-trait)

;; Constants
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant CONTRACT_OWNER tx-sender)

;; Data Variables
(define-data-var contract-uri (optional (string-utf8 256)) 
  (some u"https://charisma.rocks/api/v0/interactions/fate-randomizer"))

;; Read-only functions

(define-read-only (get-interaction-uri)
  (ok (var-get contract-uri)))

;; Public functions

(define-public (execute (action (string-ascii 32)))
  (let ((sender tx-sender))
    (if (is-eq action "CF") (coin-flip-action sender)
    (if (is-eq action "D4") (roll-d4-action sender)
    (if (is-eq action "D6") (roll-d6-action sender)
    (if (is-eq action "D8") (roll-d8-action sender)
    (if (is-eq action "D10") (roll-d10-action sender)
    (if (is-eq action "D12") (roll-d12-action sender)
    (if (is-eq action "D20") (roll-d20-action sender)
    (if (is-eq action "D100") (roll-d100-action sender)
    (err "INVALID_ACTION")))))))))))

;; Random Actions

(define-private (coin-flip-action (sender principal))
  (let ((result (unwrap-panic (contract-call? .charisma-randomizer-rc1 roll-die u2))))
    (handle-coin-flip result)))

(define-private (roll-d4-action (sender principal))
  (let ((result (unwrap-panic (contract-call? .charisma-randomizer-rc1 roll-die u4))))
    (handle-d4-roll result)))

(define-private (roll-d6-action (sender principal))
  (let ((result (unwrap-panic (contract-call? .charisma-randomizer-rc1 roll-die u6))))
    (handle-d6-roll result)))

(define-private (roll-d8-action (sender principal))
  (let ((result (unwrap-panic (contract-call? .charisma-randomizer-rc1 roll-die u8))))
    (handle-d8-roll result)))

(define-private (roll-d10-action (sender principal))
  (let ((result (unwrap-panic (contract-call? .charisma-randomizer-rc1 roll-die u10))))
    (handle-d10-roll result)))

(define-private (roll-d12-action (sender principal))
  (let ((result (unwrap-panic (contract-call? .charisma-randomizer-rc1 roll-die u12))))
    (handle-d12-roll result)))

(define-private (roll-d20-action (sender principal))
  (let ((result (unwrap-panic (contract-call? .charisma-randomizer-rc1 roll-die u20))))
    (handle-d20-roll result)))

(define-private (roll-d100-action (sender principal))
  (let ((result (unwrap-panic (contract-call? .charisma-randomizer-rc1 roll-die u100))))
    (handle-d100-roll result)))

;; Response Handlers

(define-private (handle-coin-flip (result uint))
  (begin
    (print  (if (is-eq result u1) "The silver coin spins through the air and lands on heads."
            "The coin flips end over end, coming to rest on tails."))
    (ok (if (is-eq result u1) "HEADS" "TAILS"))))

(define-private (handle-d4-roll (result uint))
  (begin
    (print  (if (is-eq result u1) "The tiny pyramid tumbles to a stop, pointing to one."
            (if (is-eq result u2) "The four-sided die spins and settles on two."
            (if (is-eq result u3) "The tetrahedral die rolls to three."
            "The d4 comes to rest showing four."))))
    (ok (uint-to-ascii result))))

(define-private (handle-d6-roll (result uint))
  (begin
    (print  (if (>= result u5) "The cube bounces and shows a high number."
            "The six-sided die tumbles to a low number."))
    (ok (uint-to-ascii result))))

(define-private (handle-d8-roll (result uint))
  (begin
    (print  (if (>= result u5) "The octahedron spins to a high face."
            "The eight-sided die settles on a low number."))
    (ok (uint-to-ascii result))))

(define-private (handle-d10-roll (result uint))
  (begin
    (print  (if (>= result u6) "The ten-sided die lands on a high number."
            "The die lands revealing a low number."))
    (ok (uint-to-ascii result))))

(define-private (handle-d12-roll (result uint))
  (begin
    (print  (if (>= result u7) "The dodecahedron tumbles to a high number."
            "The twelve-sided die settles on a low face."))
    (ok (uint-to-ascii result))))

(define-private (handle-d20-roll (result uint))
  (begin
    (print  (if (is-eq result u20) "Natural 20! The die gleams with critical success!"
            (if (is-eq result u1) "Critical failure! The d20 shows its darkest face."
            (if (>= result u15) "The twenty-sided die shows a heroic number."
            (if (>= result u10) "The d20 settles on a modest result."
            "The twenty-sided die tumbles to a challenging number.")))))
    (ok (uint-to-ascii result))))

(define-private (handle-d100-roll (result uint))
  (begin
    (print  (if (is-eq result u100) "The percentile dice align perfectly - 100!"
            (if (is-eq result u1) "Snake eyes! The percentile dice show 01."
            (if (>= result u90) "The percentile dice settle on a remarkable number."
            (if (>= result u50) "The percentile dice tumble to an above average result."
            "The percentile dice reveal a low percentage.")))))
    (ok (uint-to-ascii result))))

(define-private (handle-roll-error)
  (begin
    (print "The die refuses to roll properly.")
    (ok "ROLL_FAILED")))

;; Utility functions

(define-read-only (uint-to-ascii (number uint))
  (unwrap-panic (element-at
    (list "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" 
          "11" "12" "13" "14" "15" "16" "17" "18" "19" "20"
          "21" "22" "23" "24" "25" "26" "27" "28" "29" "30"
          "31" "32" "33" "34" "35" "36" "37" "38" "39" "40"
          "41" "42" "43" "44" "45" "46" "47" "48" "49" "50"
          "51" "52" "53" "54" "55" "56" "57" "58" "59" "60"
          "61" "62" "63" "64" "65" "66" "67" "68" "69" "70"
          "71" "72" "73" "74" "75" "76" "77" "78" "79" "80"
          "81" "82" "83" "84" "85" "86" "87" "88" "89" "90"
          "91" "92" "93" "94" "95" "96" "97" "98" "99" "100")
    (- number u1))))

(define-read-only (ascii-to-uint (ascii-number (string-ascii 3)))
  (default-to u0 
    (index-of (list "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" 
          "11" "12" "13" "14" "15" "16" "17" "18" "19" "20"
          "21" "22" "23" "24" "25" "26" "27" "28" "29" "30"
          "31" "32" "33" "34" "35" "36" "37" "38" "39" "40"
          "41" "42" "43" "44" "45" "46" "47" "48" "49" "50"
          "51" "52" "53" "54" "55" "56" "57" "58" "59" "60"
          "61" "62" "63" "64" "65" "66" "67" "68" "69" "70"
          "71" "72" "73" "74" "75" "76" "77" "78" "79" "80"
          "81" "82" "83" "84" "85" "86" "87" "88" "89" "90"
          "91" "92" "93" "94" "95" "96" "97" "98" "99" "100")
      ascii-number)))

;; Admin functions

(define-public (set-contract-uri (new-uri (optional (string-utf8 256))))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (ok (var-set contract-uri new-uri))))
```
