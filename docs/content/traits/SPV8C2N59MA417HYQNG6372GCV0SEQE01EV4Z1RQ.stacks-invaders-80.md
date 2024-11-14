---
title: "Trait stacks-invaders-80"
draft: true
---
```
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This is the contract for the Gold/Silver and Lotto phase of the Stacks Invaders Project
;; This is not a NFT or a fungible token, but a minting contract for special traits that will be integrated in the original asset
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Data declarations  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants and other data
(define-constant DEPLOYER tx-sender )
(define-data-var artist-address principal 'SM1SGQPHTZCK5PAY57ZAVP0FW4PQKKWY0JTAJJ9A0)

;; error codes
(define-constant ERR-NOT-AUTHORIZED u104)
(define-constant ERR-INVALID-USER u105)
(define-constant ERR-PAUSED u109)
(define-constant ERR-BLOCK-NOT-FOUND-FOR-TOKEN u404)
(define-constant ERR-PATTERN-ALREADY-MINTED u115)


;; Internal variables
(define-data-var total-price-lotto uint u3000000)   ;; 3 STX
(define-data-var mint-paused bool true)

(define-data-var lotto-counter  uint u1)
;; map to save the base model per number preferences.
(define-map base-model-special
    {model-id: uint}
    {model-hexa: (string-ascii 8024)}
)
;; maps to save generated token vs block. (access via token or block)

(define-map generated-dmt-lotto
    {lotto-id: uint}
    {token-id: uint, miner: principal, block-id: uint}
)
(define-map generated-dmt-lotto-by-token
    {token-id: uint}
    {lotto-id: uint, miner: principal, block-id: uint }
)
(define-map success-dmt-lotto-by-block
    {block-id: uint }
    {lotto-id: uint, model-id: uint}
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Core functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;LOTTO
(define-public (upgrade-lotto-trait (token-id uint))
  (let 
    (
      (price (var-get total-price-lotto))
      (lotto-counter-in (var-get lotto-counter))
      (lotto-counter-new (+ lotto-counter-in u1))
      (token-uri (default-to "NOT_FOUND" (unwrap! (contract-call? 'SPV8C2N59MA417HYQNG6372GCV0SEQE01EV4Z1RQ.stacks-invaders-v0 get-token-uri token-id) (err ERR-BLOCK-NOT-FOUND-FOR-TOKEN))))
      ;;(token-uri  "ipfs://ipfs/QmeLBGNTKeUYU6bxxVWh5A2BPxjvweVZddSCVEfR7jWBXr/153184.json")
      (uri_found (asserts! ( is-eq false (is-eq token-uri "NOT_FOUND")) (err ERR-BLOCK-NOT-FOUND-FOR-TOKEN)))
      (block-full    (default-to "000000" (slice? token-uri u59 u65)))  
      (block-full-int (default-to u99 (string-to-uint? block-full)))
    )
    (asserts! (or (is-eq false (var-get mint-paused)) (is-eq tx-sender DEPLOYER) (is-eq tx-sender (var-get artist-address))) (err ERR-PAUSED)) ;; check if mint is on/off
    (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))                               ;; check NFT ownership
    (asserts! (is-eq none (get lotto-id (map-get? generated-dmt-lotto-by-token  (tuple (token-id token-id ))))) (err ERR-PATTERN-ALREADY-MINTED)) ;; check if NFT is already in the pool
  ;; Change data from here on:
    (begin 
    (if (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER))
      (begin
        (map-set generated-dmt-lotto-by-token  { token-id: token-id } { lotto-id: lotto-counter-in , miner: tx-sender , block-id: block-full-int }) ;; save the minted token and the block to the array (lotto-map) - 
        (map-set generated-dmt-lotto { lotto-id: lotto-counter-in } { token-id: token-id, miner: tx-sender, block-id: block-full-int}) ;; save the minted token and the block to the array (lotto-map) - 
        (var-set lotto-counter lotto-counter-new) ;; increase the counter in 1 -
      )
      (begin       
        (try! (stx-transfer? price tx-sender (var-get artist-address))) ;; pay the minting fee
        (map-set generated-dmt-lotto-by-token  { token-id: token-id } { lotto-id: lotto-counter-in , miner: tx-sender , block-id: block-full-int }) ;; save the minted token and the block to the array (lotto-map) - 
        (map-set generated-dmt-lotto { lotto-id: lotto-counter-in } { token-id: token-id, miner: tx-sender , block-id: block-full-int }) ;; save the minted token and the block to the array (lotto-map) - 
        (var-set lotto-counter lotto-counter-new) ;; increase the counter in 1 -
      )    
    )    
    (ok token-id)
    )    
)
)
;; set winners
(define-public (set-lotto-winners (winner-ticket uint) (winner-model uint))
  (let 
    (
      (winner-block (default-to u99 (get block-id (map-get? generated-dmt-lotto  (tuple ( lotto-id winner-ticket )))))) 

    )
    (asserts! (or (is-eq tx-sender DEPLOYER) (is-eq tx-sender (var-get artist-address))) (err ERR-NOT-AUTHORIZED)) ;; check if mint is on/off
  ;; Change data from here on:
    (begin 
        (map-set success-dmt-lotto-by-block  { block-id: winner-block } { lotto-id: winner-ticket , model-id: winner-model })       
    (ok winner-block)
    )    
)
)

;;;
(define-read-only (get-80-special-design-by-block (block-id uint)) 
  (let 
    (
      ;; split block numbers
      (winner-ticket (default-to u99 (get model-id (map-get? success-dmt-lotto-by-block  (tuple ( block-id block-id )))))) 
      ;; unpack into colours and patterns
      (base-mod-special (default-to "none" (get model-hexa (map-get? base-model-special  (tuple ( model-id winner-ticket )))))) 
    )

  (ok base-mod-special) 
  )
)

(define-read-only (get-80-special-design (model-id uint)) 
  (let 
    (
      ;; unpack into colours and patterns
      (base-mod-special (default-to "none" (get model-hexa (map-get? base-model-special  (tuple ( model-id model-id )))))) 
    )
  (ok base-mod-special) 
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Support functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-read-only (is-wallet-cool) 
  (let (
  (artist-address-boolean (is-eq tx-sender (var-get artist-address)))
  (deployer-address-boolean (is-eq tx-sender DEPLOYER))
  (boolean-return (or artist-address-boolean deployer-address-boolean))  
  )
(ok boolean-return)
) 
)
(define-public (model-special-set (model-id-input uint) (model-hexa-input (string-ascii 8024)) )
  (let
  (
      (model-ascii (int-to-ascii model-id-input))
  )
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (map-set base-model-special { model-id: model-id-input } { model-hexa: model-hexa-input })
    (ok "Post successful")
  )
  )
)

(define-read-only (get-lotto-details-token (token-id uint)) 
  (let (
    (lotto-id  (default-to u0 (get lotto-id (map-get? generated-dmt-lotto-by-token  (tuple (token-id token-id ))))) 
    ;;(original-svg  (unwrap! (contract-call? 'SPV8C2N59MA417HYQNG6372GCV0SEQE01EV4Z1RQ.stacks-invaders-v0 get-token-svg token-id-int) (err ERR-BLOCK-NOT-FOUND-FOR-TOKEN)))
    )
  )
  (ok lotto-id) 
)
)

(define-read-only (get-lotto-details-ticket (lotto-id uint)) 
  (let (
    (token-id  (default-to u0 (get token-id (map-get? generated-dmt-lotto  (tuple (lotto-id lotto-id ))))) 
    ;;(original-svg  (unwrap! (contract-call? 'SPV8C2N59MA417HYQNG6372GCV0SEQE01EV4Z1RQ.stacks-invaders-v0 get-token-svg token-id-int) (err ERR-BLOCK-NOT-FOUND-FOR-TOKEN)))
    )
  )
  (ok token-id) 
)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setting, getting and toggling functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-read-only (get-current-lotto-counter) 
  (let (
      (lotto-counter-in (var-get lotto-counter))
  )
  (ok lotto-counter-in) 
)
)

(define-public (set-artist-address (address principal))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set artist-address address))))

(define-public (toggle-pause)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set mint-paused (not (var-get mint-paused))))))

(define-private (is-owner (token-id uint) (user principal))

    (is-eq user (default-to DEPLOYER (unwrap! (contract-call? 'SPV8C2N59MA417HYQNG6372GCV0SEQE01EV4Z1RQ.stacks-invaders-v0 get-owner token-id) false))))

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-artist-address)
  (ok (var-get artist-address)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; End of Contract. Thanks for reading!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
```
