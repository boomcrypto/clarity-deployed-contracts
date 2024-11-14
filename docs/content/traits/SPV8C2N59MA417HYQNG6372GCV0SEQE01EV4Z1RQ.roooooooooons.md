---
title: "Trait roooooooooons"
draft: true
---
```
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This is a simple contract to collect taproot addresses for the roooooooooons project
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Data declarations  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants and other data
(define-constant DEPLOYER tx-sender )
(define-data-var collab-address principal 'SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D)

;; error codes
(define-constant ERR-NOT-AUTHORIZED u104)
(define-constant ERR-NOT-A-TAPROOT u106)

(define-data-var roo-whitelist-counter  uint u1)
(define-data-var collab-whitelist-counter  uint u1)
;; map to save taproot vs Stacks Addresses.
(define-map roo-whitelist-wallets
    {stacks-principal: principal} ;; SPXXX or SMXXX
    {bech32m-addy: (string-ascii 62)} ;; bc1pXXX
)

;; map to save taproot addys from collabs
(define-map collab-whitelist-wallets
    {counter: uint} ;; SPXXX or SMXXX
    {bech32m-addy: (string-ascii 62)} ;; bc1pXXX
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Core functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Logging function, Chainhook will listen to these and deal with the data
;;Capture $ROO whitelist
(define-public (confirm-taproot-address (bech32m-addy (string-ascii 62)))
  (let 
    (
      (taproot-start (default-to "000000" (slice? bech32m-addy u0 u4)))  
      (roo-counter (var-get roo-whitelist-counter) )
      (new-roo-counter (+ roo-counter u1))      
    )
   (asserts! (is-eq taproot-start "bc1p" ) (err ERR-NOT-A-TAPROOT))  ;; check NFT ownership
  (begin
    (print { notification: "taproot-confirmed", payload: { stacks: tx-sender, taproot: bech32m-addy }})
    (map-set roo-whitelist-wallets  { stacks-principal: tx-sender } { bech32m-addy: bech32m-addy  }) 
    (var-set roo-whitelist-counter new-roo-counter)
    (ok true))
)
)
;;Capture collab whitelist
(define-public (confirm-taproot-address-collab (bech32m-addy (string-ascii 62)))
  (let 
    (
      (taproot-start (default-to "000000" (slice? bech32m-addy u0 u4)))  
      (collab-counter (var-get collab-whitelist-counter) )
      (new-collab-counter (+ collab-counter u1))
    )
    (asserts! (or (is-eq tx-sender (var-get collab-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
   (asserts! (is-eq taproot-start "bc1p" ) (err ERR-NOT-A-TAPROOT))  ;; check NFT ownership
  (begin
    (print { notification: "collab-taproot-confirmed", payload: { stacks: tx-sender, taproot: bech32m-addy }})
    (map-set collab-whitelist-wallets  { counter: collab-counter } { bech32m-addy: bech32m-addy  }) 
    (var-set collab-whitelist-counter new-collab-counter)
    (ok true))
)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setting, getting and toggling functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-read-only (get-current-roo-counter) 
  (let (
      (counter-wl (var-get roo-whitelist-counter))
  )
  (ok counter-wl) 
)
)

(define-read-only (get-current-collab-counter) 
  (let (
      (counter-wl (var-get collab-whitelist-counter))
  )
  (ok counter-wl) 
)
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; End of Contract. Thanks for reading!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
```
