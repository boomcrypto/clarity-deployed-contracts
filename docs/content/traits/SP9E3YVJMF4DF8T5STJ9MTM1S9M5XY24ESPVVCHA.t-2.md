---
title: "Trait t-2"
draft: true
---
```
;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant CONTRACT-OWNER tx-sender)

;;(define-data-var holders (string-ascii 256) "hi")


;;;;;;;;;;;;;;

(define-read-only (get-vault-by-id (vault-id uint))
  (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vault-data-v1-1 get-vault-by-id vault-id)
)


(define-read-only (get-debt-for-vault (vault-id uint))
  (let ((vault (get-vault-by-id vault-id))) (ok (get debt vault)))
)

(print (get-vault-by-id u95))
(print (get-vault-by-id u96))
(print (get-vault-by-id u97))
(print (get-vault-by-id u98))
(print (get-vault-by-id u99))
(print (get-vault-by-id u100))
(print (get-vault-by-id u101))
(print (get-vault-by-id u102))
(print (get-vault-by-id u103))
(print (get-vault-by-id u104))
(print (get-vault-by-id u105))
(print (get-vault-by-id u106))
(print (get-vault-by-id u107))
(print (get-vault-by-id u108))
(print (get-vault-by-id u109))
(print (get-vault-by-id u110))
(print (get-vault-by-id u111))
(print (get-vault-by-id u112))
(print (get-vault-by-id u113))
(print (get-vault-by-id u114))
(print (get-vault-by-id u115))
(print (get-vault-by-id u116))
(print (get-vault-by-id u117))
(print (get-vault-by-id u118))
(print (get-vault-by-id u119))
(print (get-vault-by-id u120))
(print (get-vault-by-id u121))
(print (get-vault-by-id u122))
(print (get-vault-by-id u123))
(print (get-vault-by-id u124))
(print (get-vault-by-id u125))
(print (get-vault-by-id u126))
(print (get-vault-by-id u127))
(print (get-vault-by-id u128))
(print (get-vault-by-id u129))
(print (get-vault-by-id u130))
(print (get-vault-by-id u131))
(print (get-vault-by-id u132))
(print (get-vault-by-id u133))
(print (get-vault-by-id u134))
(print (get-vault-by-id u135))
(print (get-vault-by-id u136))
(print (get-vault-by-id u137))
(print (get-vault-by-id u138))
(print (get-vault-by-id u139))
(print (get-vault-by-id u140))
(print (get-vault-by-id u141))
(print (get-vault-by-id u142))
(print (get-vault-by-id u143))
(print (get-vault-by-id u144))
(print (get-vault-by-id u145))
(print (get-vault-by-id u146))
(print (get-vault-by-id u147))
(print (get-vault-by-id u148))
(print (get-vault-by-id u149))
(print (get-vault-by-id u150))
(print (get-vault-by-id u151))
(print (get-vault-by-id u152))
(print (get-vault-by-id u153))
(print (get-vault-by-id u154))
(print (get-vault-by-id u155))
(print (get-vault-by-id u156))
(print (get-vault-by-id u157))
(print (get-vault-by-id u158))
(print (get-vault-by-id u159))
(print (get-vault-by-id u160))
(print (get-vault-by-id u161))
(print (get-vault-by-id u162))
(print (get-vault-by-id u163))
(print (get-vault-by-id u164))
(print (get-vault-by-id u165))
(print (get-vault-by-id u166))
(print (get-vault-by-id u167))
(print (get-vault-by-id u168))
(print (get-vault-by-id u169))
(print (get-vault-by-id u170))
(print (get-vault-by-id u171))
(print (get-vault-by-id u172))
(print (get-vault-by-id u173))
(print (get-vault-by-id u174))
(print (get-vault-by-id u175))
(print (get-vault-by-id u176))
(print (get-vault-by-id u177))
(print (get-vault-by-id u178))
(print (get-vault-by-id u179))
(print (get-vault-by-id u180))
(print (get-vault-by-id u181))
(print (get-vault-by-id u182))
(print (get-vault-by-id u183))
(print (get-vault-by-id u184))
(print (get-vault-by-id u185))
(print (get-vault-by-id u186))
(print (get-vault-by-id u187))
(print (get-vault-by-id u188))
(print (get-vault-by-id u189))
(print (get-vault-by-id u190))
```