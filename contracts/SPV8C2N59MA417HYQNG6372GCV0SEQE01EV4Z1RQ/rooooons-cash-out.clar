;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This contract allow Stacks Invaders holders to check ROOOONS and transfer them
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Data declarations  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
;;'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-ROONS
;; SP253J64EGMH59TV32CQXXTVKH5TQVGN108TA5TND.fair-bonding-curve
;; Constants and other data
(define-constant DEPLOYER tx-sender )
(define-data-var artist-address principal 'SP30MSY8NECE4SJJRQ5NVFZA58HF9Y93XX6E15WMG)
(define-data-var burn-address principal 'SP000000000000000000002Q6VF78)


;; error codes
(define-constant ERR-NOT-AUTHORIZED u104)
(define-constant ERR-INVALID-USER u105)
(define-constant ERR-PAUSED u109)
(define-constant ERR-BLOCK-NOT-FOUND-FOR-TOKEN u404)
(define-constant ERR-BURNT-TOKEN u403)
(define-constant ERR-TRANSFER-ERROR u500)
(define-constant ERR-DOUBLE-SPEND u009)


;; Internal variables

(define-data-var claim-paused bool true)
(define-map claimed-tokens
    {token-id: uint}
    {block-id: uint, miner: principal}
)

;; Functions
;;; low-level functions
(define-private
  (transfer-call
   (user  principal)
   (amt   uint))

  (let ((protocol (as-contract tx-sender)))
    (ok (if (> amt u0)
        (try!
         (as-contract
          (contract-call?
           'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-ROONS transfer amt protocol user none)))
        true)) )
)

;; fund the contract with ROOOONS
(define-public (fund-rooons (amt   uint))
    (begin       
        (try!
          (contract-call?
           'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-ROONS transfer amt tx-sender .rooooons-cash-out none))
      (ok true)
    )
)

;; Claim ROOOONS
(define-public (claim-rooons (token-id uint) )
  (let 
    (
      (token-uri (default-to "NOT_FOUND" (unwrap! (contract-call? 'SPV8C2N59MA417HYQNG6372GCV0SEQE01EV4Z1RQ.stacks-invaders-v0 get-token-uri token-id) (err ERR-BLOCK-NOT-FOUND-FOR-TOKEN))))
     ;; (token-uri  "ipfs://ipfs/QmeLBGNTKeUYU6bxxVWh5A2BPxjvweVZddSCVEfR7jWBXr/153184.json")
      (uri_found (asserts! ( is-eq false (is-eq token-uri "NOT_FOUND")) (err ERR-BLOCK-NOT-FOUND-FOR-TOKEN)))
      (owner-principal (default-to (var-get burn-address) (unwrap! (contract-call? 'SPV8C2N59MA417HYQNG6372GCV0SEQE01EV4Z1RQ.stacks-invaders-v0 get-owner token-id) (err ERR-BLOCK-NOT-FOUND-FOR-TOKEN))))
      (owner_found (asserts! ( is-eq false (is-eq owner-principal (var-get burn-address))) (err ERR-BURNT-TOKEN)))
      (block-id (default-to u100 (get block-id (map-get? claimed-tokens (tuple ( token-id token-id ))))))
      (token_claimed (asserts! ( is-eq true (is-eq block-id u100)) (err ERR-DOUBLE-SPEND)))
    )
    (asserts! (or (is-eq false (var-get claim-paused)) (is-eq tx-sender DEPLOYER) (is-eq tx-sender (var-get artist-address))) (err ERR-PAUSED)) ;; check if claim is on/off
    (asserts! (is-eq owner-principal tx-sender) (err ERR-NOT-AUTHORIZED))  ;; check NFT ownership
    (asserts! ( is-eq true (is-eq block-id u100)) (err ERR-DOUBLE-SPEND))  ;; check if token already claimed
  ;; Change data from here on:
    (begin       
    ;;(if (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER))  
    (try! (transfer-call owner-principal u1000000000)) ;;  (err ERR-TRANSFER-ERROR)
    (map-set claimed-tokens { token-id: token-id } { block-id: block-height , miner: tx-sender })   
    (print { notification: "rooons-claim-successful", payload: { token-id: token-id }})
    (ok true)
    )    
)
)


;; Claim ROOOONS 10 IDs
(define-public (claim-rooons-10 (token-id-01 uint) (token-id-02 uint) (token-id-03 uint) (token-id-04 uint) (token-id-05 uint) (token-id-06 uint) (token-id-07 uint) (token-id-08 uint) (token-id-09 uint) (token-id-10 uint) )
    (begin       
    (try! (claim-rooons token-id-01 )) 
    (try! (claim-rooons token-id-02 ))
    (try! (claim-rooons token-id-03 ))
    (try! (claim-rooons token-id-04 ))
    (try! (claim-rooons token-id-05 ))
    (try! (claim-rooons token-id-06 ))
    (try! (claim-rooons token-id-07 ))
    (try! (claim-rooons token-id-08 ))
    (try! (claim-rooons token-id-09 ))
    (try! (claim-rooons token-id-10 ))
    (ok true)
    )    
)

;; check ROOOONS balance
(define-read-only (check-rooons-balance (token-id uint))
    (let
        (
            (block-id (default-to u1000 (get block-id (map-get? claimed-tokens (tuple ( token-id token-id ))))))
            (roooons (if (is-eq block-id u1000) u1000 u0))   
        )
        (begin
            (ok roooons)
        )
    )
)
;; On/Off and other variable settings
;; Pause contract
(define-public (pause-contract)
  (begin
  (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
  (var-set claim-paused true)
  (ok true)
)
)
;; Unpause contract
(define-public (unpause-contract)
    (begin
  (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
  (var-set claim-paused false)
  (ok true)
)
)
(define-read-only (get-paused)
  (ok (var-get claim-paused)))