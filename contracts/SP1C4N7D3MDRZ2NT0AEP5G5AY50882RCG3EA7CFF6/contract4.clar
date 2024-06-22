;; (use-trait sip-010-trait 'STCGTZ0E65T7BCR61VHZAR4HXVK1W7K488DS2VWH.abc.sip-010-trait)
;; (impl-trait 'STCGTZ0E65T7BCR61VHZAR4HXVK1W7K488DS2VWH.sip-010-trait-ft-standard.sip-010-trait)
;; (use-trait sip-010-trait 'STCGTZ0E65T7BCR61VHZAR4HXVK1W7K488DS2VWH.sip-010-trait-ft-standard)



(use-trait sip-010-trait .sip-010-trait-ft-standard.sip-010-trait)

(define-public (claim-stx (amount uint)
  (sender principal)
  (recipient principal)
  (target <sip-010-trait>)
  (memo (optional (buff 34))))
  (let ((transfer-result (stx-transfer? amount tx-sender recipient)))
      (if (is-ok transfer-result)
        (ok (contract-call? target transfer amount tx-sender recipient memo))  
        (err (tuple (status "failure") (error transfer-result))
        )
      )
      
    )
  
    ;; (ok true)
)