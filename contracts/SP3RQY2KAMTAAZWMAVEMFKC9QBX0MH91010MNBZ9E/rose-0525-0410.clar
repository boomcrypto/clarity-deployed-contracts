;; test www
(use-trait sip-trait .sip-010-trait-ft-standard.sip-010-trait)
(define-constant owner tx-sender)





(define-public (transfer-usda (a0 uint))
  (let
    (
      (sender tx-sender)
      (transfer-usda (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer a0 tx-sender tx-sender none) (err "errtra")))
    )
    (ok u0)
  )

)