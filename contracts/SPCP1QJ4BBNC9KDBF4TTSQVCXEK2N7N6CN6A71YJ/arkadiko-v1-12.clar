;; 
(define-constant owner tx-sender)
(define-constant ERR-NOT-OWNER u101)
(define-constant ERR-MIN u102)
(define-constant ERR-FAIL u103)








(define-public (swap-ststx-stx-bitflow (dx uint))
  (let ((r (try! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-y-for-x 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2 dx u10))))
  (ok r))
)




(define-public (swap-wstx-usda-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok r))
)