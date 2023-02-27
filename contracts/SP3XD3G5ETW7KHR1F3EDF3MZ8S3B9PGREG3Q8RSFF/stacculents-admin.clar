;; Stacculents - Buds Admin Premint
;; For the Stacculents Admin Team
;; Written by StrataLabs

;;;;;;;;;;;;;;;;;;;;;;;
;;;; Minting Logic ;;;;
;;;;;;;;;;;;;;;;;;;;;;;

;; Constant list of 20 u0s
(define-constant empty-list-twenty (list
  u0 u0 u0 u0 u0 u0 u0 u0 u0 u0
  u0 u0 u0 u0 u0 u0 u0 u0 u0 u0
))

;; Constant list of 200 u0s
(define-constant empty-list-two-hundred (list
  u0 u0 u0 u0 u0 u0 u0 u0 u0 u0
  u0 u0 u0 u0 u0 u0 u0 u0 u0 u0
  u0 u0 u0 u0 u0 u0 u0 u0 u0 u0
  u0 u0 u0 u0 u0 u0 u0 u0 u0 u0
  u0 u0 u0 u0 u0 u0 u0 u0 u0 u0
  u0 u0 u0 u0 u0 u0 u0 u0 u0 u0
  u0 u0 u0 u0 u0 u0 u0 u0 u0 u0
  u0 u0 u0 u0 u0 u0 u0 u0 u0 u0
  u0 u0 u0 u0 u0 u0 u0 u0 u0 u0
  u0 u0 u0 u0 u0 u0 u0 u0 u0 u0
  u0 u0 u0 u0 u0 u0 u0 u0 u0 u0
  u0 u0 u0 u0 u0 u0 u0 u0 u0 u0
  u0 u0 u0 u0 u0 u0 u0 u0 u0 u0
  u0 u0 u0 u0 u0 u0 u0 u0 u0 u0
  u0 u0 u0 u0 u0 u0 u0 u0 u0 u0
  u0 u0 u0 u0 u0 u0 u0 u0 u0 u0
  u0 u0 u0 u0 u0 u0 u0 u0 u0 u0
  u0 u0 u0 u0 u0 u0 u0 u0 u0 u0
  u0 u0 u0 u0 u0 u0 u0 u0 u0 u0
  u0 u0 u0 u0 u0 u0 u0 u0 u0 u0
))


;; This is the claim-1000 function
;; Claim 200 list * 5 claim = 1000 mints
(define-public (claim-one-thousand)
    (ok (map mint empty-list-two-hundred))
)

;; Claim 20 list * 5 claim = 100 mints
(define-public (claim-one-hundred)
    (ok (map mint empty-list-twenty))
)

;; Private function to map through list & mint from stacculents contract
(define-private (mint (item uint))
    (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.stacculents claim-five)
)


;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Transfer Logic ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; Recipient address var
(define-data-var recipient-helper principal tx-sender)

;; Mass-Transfer
;; @desc - This function will transfer a list of up to 250 Stacculents to a single address
;; @param - Items (uint), list of 250 Stacculents - Recipient (principal), address to send Stacculents to
(define-public (mass-transfer (items (list 250 uint)) (recipient principal))
    (begin
        ;; Var-set recipient
        (var-set recipient-helper recipient)
        ;; Map through list & transfer
        (ok (map mass-transfer-helper items))
    )
)

;; Private function to map through list & transfer from tx-sender to recipient
(define-private (mass-transfer-helper (item uint))
    (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.stacculents transfer item tx-sender (var-get recipient-helper))
)