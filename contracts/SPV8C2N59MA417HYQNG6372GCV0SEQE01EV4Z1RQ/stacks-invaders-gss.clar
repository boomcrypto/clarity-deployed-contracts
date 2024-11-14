;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This is the contract for the Gold/Silver and Lotto phase of the Stacks Invaders Project
;; This is not a NFT or a fungible token, but a minting contract for special traits that will be integrated in the original asset
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Data declarations  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants and other data
(define-constant DEPLOYER tx-sender )
(define-data-var artist-address principal 'SP30MSY8NECE4SJJRQ5NVFZA58HF9Y93XX6E15WMG)

;; error codes
(define-constant ERR-NOT-AUTHORIZED u104)
(define-constant ERR-INVALID-USER u105)
(define-constant ERR-PAUSED u109)
(define-constant ERR-NO-MORE-SILVER u139)
(define-constant ERR-NO-MORE-GOLD   u140)
(define-constant ERR-BLOCK-NOT-FOUND-FOR-TOKEN u404)
(define-constant ERR-PATTERN-ALREADY-MINTED u115)


;; Internal variables
(define-data-var total-price-silver uint u10000000) ;;Starts at 10 STX, increase 1 STX per mint
(define-data-var total-price-gold uint u20000000)   ;;Starts at 20 STX, increase 1 STX per mint
(define-data-var total-price-lotto uint u2000000)   ;; 2 STX
(define-data-var mint-paused bool true)

(define-data-var gold-counter   uint u1)
(define-data-var silver-counter uint u1)
(define-data-var lotto-counter  uint u1)
;; map to save the colour per number preferences.
(define-map colour-code
    {colour-id:  (string-ascii 40)}
    {colour-hexa: (string-ascii 7)}
)
;; map to save the base model per number preferences.
(define-map base-model
    {model-id: (string-ascii 70)}
    {model-hexa: (string-ascii 1024), model-hexa-2: (string-ascii 1024), model-hexa-3: (string-ascii 1024)}
)
;; maps to save generated token vs block. (access via token or block)
(define-map generated-dmt-gold
    {gold-id: uint}
    {token-id: uint, block-id: (string-ascii 70), miner: principal}
)
(define-map generated-dmt-gold-patterns
    {gold-pattern: (string-ascii 70)}
    {token-id: uint, gold-id: uint}
)
(define-map generated-dmt-silver
    {silver-id: uint}
    {token-id: uint, block-id: (string-ascii 70), miner: principal}
)
(define-map generated-dmt-silver-patterns
    {silver-pattern: (string-ascii 70)}
    {token-id: uint, silver-id: uint}
)
(define-map generated-dmt-lotto
    {lotto-id: uint}
    {token-id: uint, miner: principal}
)
(define-map generated-dmt-lotto-by-token
    {token-id: uint}
    {lotto-id: uint, miner: principal}
)
;; (define-map generated-dmt
;;     {token-id: uint}
;;     {block-id: uint, miner: principal}
;; )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Core functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GOLD
(define-public (upgrade-gold-trait (token-id uint))

  (let 
    (
      (price (var-get total-price-gold))
      (price-new (+ price u1000000))
      (gold-counter-in (var-get gold-counter))
      (gold-counter-new (+ gold-counter-in u1))
      ;; swap line for deployment
      ;; (token-uri (default-to "NOT_FOUND" (unwrap! (contract-call? 'SPV8C2N59MA417HYQNG6372GCV0SEQE01EV4Z1RQ.stacks-invaders-v0 get-token-uri token-id) (err ERR-BLOCK-NOT-FOUND-FOR-TOKEN))))
      (token-uri  "ipfs://ipfs/QmeLBGNTKeUYU6bxxVWh5A2BPxjvweVZddSCVEfR7jWBXr/153184.json")
      (uri_found (asserts! ( is-eq false (is-eq token-uri "NOT_FOUND")) (err ERR-BLOCK-NOT-FOUND-FOR-TOKEN)))
      (block-pattern (default-to "00" (slice? token-uri u61 u63)))
      (block-full    (default-to "000000" (slice? token-uri u59 u65)))

    )
    (asserts! (or (is-eq false (var-get mint-paused)) (is-eq tx-sender DEPLOYER)) (err ERR-PAUSED)) ;; check if mint is on/off
    (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))                               ;; check NFT ownership
    (asserts! (<= gold-counter-in u50) (err ERR-NO-MORE-GOLD))
    (asserts! (is-eq none (get token-id (map-get? generated-dmt-gold-patterns  (tuple ( gold-pattern block-pattern ))))) (err ERR-PATTERN-ALREADY-MINTED)) ;; check if model was minted
  ;; Change data from here on:
    (begin       
    (try! (stx-transfer? price tx-sender (var-get artist-address))) ;; pay the minting fee
    (map-set generated-dmt-gold-patterns  { gold-pattern: block-pattern } { token-id: token-id, gold-id: gold-counter-in }) ;; save the minted token and the block to the array (gold-map) - 
    (map-set generated-dmt-gold { gold-id: gold-counter-in } { token-id: token-id, block-id: block-full , miner: tx-sender }) ;; save the minted token and the block to the array (gold-map) - 
    (var-set total-price-gold price-new)    ;; increase the price in 1 STX (u1000000) -     
    (var-set gold-counter gold-counter-new) ;; increase the counter in 1 -
    (ok block-full)
    )    
)
)

(define-read-only (get-gold-details (counter-id uint)) 
  (let (
    (token-id-int  (default-to u99999 (get token-id (map-get? generated-dmt-gold (tuple ( gold-id counter-id )))))) 
    (block-id-int  (default-to "999999" (get block-id (map-get? generated-dmt-gold (tuple ( gold-id counter-id )))))) 
    (original-svg  (get-block-height-design-gold block-id-int))
    ;;(original-svg  (unwrap! (contract-call? 'SPV8C2N59MA417HYQNG6372GCV0SEQE01EV4Z1RQ.stacks-invaders-v0 get-token-svg token-id-int) (err ERR-BLOCK-NOT-FOUND-FOR-TOKEN)))
    )
  (print { notification: "golden-invader", payload: { token-id: token-id-int, block-id: block-id-int, svg: original-svg }})
  (ok u1) 
)
)

(define-read-only (get-gold-details-all ) ;; not my proudest moment, but couldn't figure out a best way to loop
 (let
  (
    (return-var-1 (get-gold-details u1) )
    (return-var-2 (get-gold-details u2) )
    (return-var-3 (get-gold-details u3))
    (return-var-4 (get-gold-details u4))
    (return-var-5 (get-gold-details u5))
    (return-var-6 (get-gold-details u6))
    (return-var-7 (get-gold-details u7))
    (return-var-8 (get-gold-details u8))
    (return-var-9 (get-gold-details u9))
    (return-var-10 (get-gold-details u10))
    (return-var-11 (get-gold-details u11))
    (return-var-12 (get-gold-details u12))
    (return-var-13 (get-gold-details u13))
    (return-var-14 (get-gold-details u14))
    (return-var-15 (get-gold-details u15))
    (return-var-16 (get-gold-details u16))
    (return-var-17 (get-gold-details u17))
    (return-var-18 (get-gold-details u18))
    (return-var-19 (get-gold-details u19))
    (return-var-20 (get-gold-details u20))
    (return-var-21 (get-gold-details u21))
    (return-var-22 (get-gold-details u22))
    (return-var-23 (get-gold-details u23))
    (return-var-24 (get-gold-details u24))
    (return-var-25 (get-gold-details u25))
    (return-var-26 (get-gold-details u26))
    (return-var-27 (get-gold-details u27))
    (return-var-28 (get-gold-details u28))
    (return-var-29 (get-gold-details u29))
    (return-var-30 (get-gold-details u30))
    (return-var-31 (get-gold-details u31))
    (return-var-32 (get-gold-details u32))
    (return-var-33 (get-gold-details u33))
    (return-var-34 (get-gold-details u34))
    (return-var-35 (get-gold-details u35))
    (return-var-36 (get-gold-details u36))
    (return-var-37 (get-gold-details u37))
    (return-var-38 (get-gold-details u38))
    (return-var-39 (get-gold-details u39))
    (return-var-40 (get-gold-details u40))
    (return-var-41 (get-gold-details u41))
    (return-var-42 (get-gold-details u42))
    (return-var-43 (get-gold-details u43))
    (return-var-44 (get-gold-details u44))
    (return-var-45 (get-gold-details u45))
    (return-var-46 (get-gold-details u46))
    (return-var-47 (get-gold-details u47))
    (return-var-48 (get-gold-details u48))
    (return-var-49 (get-gold-details u49))
    (return-var-50 (get-gold-details u50))
  ) 
  (ok return-var-1)   
)
)

;;SILVER
(define-public (upgrade-silver-trait (token-id uint))

  (let 
    (
      (price (var-get total-price-silver))
      (price-new (+ price u1000000))
      (silver-counter-in (var-get silver-counter))
      (silver-counter-new (+ silver-counter-in u1))
      ;; swap line for deployment
      ;; (token-uri (default-to "NOT_FOUND" (unwrap! (contract-call? 'SPV8C2N59MA417HYQNG6372GCV0SEQE01EV4Z1RQ.stacks-invaders-v0 get-token-uri token-id) (err ERR-BLOCK-NOT-FOUND-FOR-TOKEN))))
      (token-uri  "ipfs://ipfs/QmeLBGNTKeUYU6bxxVWh5A2BPxjvweVZddSCVEfR7jWBXr/153184.json")
      (uri_found (asserts! ( is-eq false (is-eq token-uri "NOT_FOUND")) (err ERR-BLOCK-NOT-FOUND-FOR-TOKEN)))
      (block-pattern (default-to "00" (slice? token-uri u61 u63)))
      (block-full    (default-to "000000" (slice? token-uri u59 u65)))

    )
    (asserts! (or (is-eq false (var-get mint-paused)) (is-eq tx-sender DEPLOYER)) (err ERR-PAUSED)) ;; check if mint is on/off
    (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))                               ;; check NFT ownership
    (asserts! (<= silver-counter-in u50) (err ERR-NO-MORE-SILVER))
    (asserts! (is-eq none (get token-id (map-get? generated-dmt-silver-patterns  (tuple ( silver-pattern block-pattern ))))) (err ERR-PATTERN-ALREADY-MINTED)) ;; check if model was minted
  ;; Change data from here on:
    (begin       
    (try! (stx-transfer? price tx-sender (var-get artist-address))) ;; pay the minting fee
    (map-set generated-dmt-silver-patterns  { silver-pattern: block-pattern } { token-id: token-id, silver-id: silver-counter-in }) ;; save the minted token and the block to the array (silver-map) - 
    (map-set generated-dmt-silver { silver-id: silver-counter-in } { token-id: token-id, block-id: block-full , miner: tx-sender }) ;; save the minted token and the block to the array (silver-map) - 
    (var-set total-price-silver price-new)    ;; increase the price in 1 STX (u1000000) -     
    (var-set silver-counter silver-counter-new) ;; increase the counter in 1 -
    (ok block-full)
    )    
)
)

(define-read-only (get-silver-details (counter-id uint)) 
  (let (
    (token-id-int  (default-to u99999 (get token-id (map-get? generated-dmt-silver (tuple ( silver-id counter-id )))))) 
    (block-id-int  (default-to "999999" (get block-id (map-get? generated-dmt-silver (tuple ( silver-id counter-id )))))) 
    (original-svg  (get-block-height-design-silver block-id-int))
    ;;(original-svg  (unwrap! (contract-call? 'SPV8C2N59MA417HYQNG6372GCV0SEQE01EV4Z1RQ.stacks-invaders-v0 get-token-svg token-id-int) (err ERR-BLOCK-NOT-FOUND-FOR-TOKEN)))
    )
  (print { notification: "silveren-invader", payload: { token-id: token-id-int, block-id: block-id-int, svg: original-svg }})
  (ok u1) 
)
)

(define-read-only (get-silver-details-all ) ;; not my proudest moment, but couldn't figure out a best way to loop
 (let
  (
    (return-var-1 (get-silver-details u1) )
    (return-var-2 (get-silver-details u2) )
    (return-var-3 (get-silver-details u3))
    (return-var-4 (get-silver-details u4))
    (return-var-5 (get-silver-details u5))
    (return-var-6 (get-silver-details u6))
    (return-var-7 (get-silver-details u7))
    (return-var-8 (get-silver-details u8))
    (return-var-9 (get-silver-details u9))
    (return-var-10 (get-silver-details u10))
    (return-var-11 (get-silver-details u11))
    (return-var-12 (get-silver-details u12))
    (return-var-13 (get-silver-details u13))
    (return-var-14 (get-silver-details u14))
    (return-var-15 (get-silver-details u15))
    (return-var-16 (get-silver-details u16))
    (return-var-17 (get-silver-details u17))
    (return-var-18 (get-silver-details u18))
    (return-var-19 (get-silver-details u19))
    (return-var-20 (get-silver-details u20))
    (return-var-21 (get-silver-details u21))
    (return-var-22 (get-silver-details u22))
    (return-var-23 (get-silver-details u23))
    (return-var-24 (get-silver-details u24))
    (return-var-25 (get-silver-details u25))
    (return-var-26 (get-silver-details u26))
    (return-var-27 (get-silver-details u27))
    (return-var-28 (get-silver-details u28))
    (return-var-29 (get-silver-details u29))
    (return-var-30 (get-silver-details u30))
    (return-var-31 (get-silver-details u31))
    (return-var-32 (get-silver-details u32))
    (return-var-33 (get-silver-details u33))
    (return-var-34 (get-silver-details u34))
    (return-var-35 (get-silver-details u35))
    (return-var-36 (get-silver-details u36))
    (return-var-37 (get-silver-details u37))
    (return-var-38 (get-silver-details u38))
    (return-var-39 (get-silver-details u39))
    (return-var-40 (get-silver-details u40))
    (return-var-41 (get-silver-details u41))
    (return-var-42 (get-silver-details u42))
    (return-var-43 (get-silver-details u43))
    (return-var-44 (get-silver-details u44))
    (return-var-45 (get-silver-details u45))
    (return-var-46 (get-silver-details u46))
    (return-var-47 (get-silver-details u47))
    (return-var-48 (get-silver-details u48))
    (return-var-49 (get-silver-details u49))
    (return-var-50 (get-silver-details u50))
  ) 
  (ok return-var-1)   
)
)

;;LOTTO
(define-public (upgrade-lotto-trait (token-id uint))
  (let 
    (
      (price (var-get total-price-lotto))
      (lotto-counter-in (var-get lotto-counter))
      (lotto-counter-new (+ lotto-counter-in u1))
      ;; swap line for deployment
      ;;(token-uri (default-to "NOT_FOUND" (unwrap! (contract-call? 'SPV8C2N59MA417HYQNG6372GCV0SEQE01EV4Z1RQ.stacks-invaders-v0 get-token-uri token-id) (err ERR-BLOCK-NOT-FOUND-FOR-TOKEN))))
      ;;(token-uri  "ipfs://ipfs/QmeLBGNTKeUYU6bxxVWh5A2BPxjvweVZddSCVEfR7jWBXr/153184.json")
      ;;(uri_found (asserts! ( is-eq false (is-eq token-uri "NOT_FOUND")) (err ERR-BLOCK-NOT-FOUND-FOR-TOKEN)))
      ;;(block-pattern (default-to "00" (slice? token-uri u61 u63)))
      ;;(block-full    (default-to "000000" (slice? token-uri u59 u65)))

    )
    (asserts! (or (is-eq false (var-get mint-paused)) (is-eq tx-sender DEPLOYER)) (err ERR-PAUSED)) ;; check if mint is on/off
    (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))                               ;; check NFT ownership
    (asserts! (is-eq none (get lotto-id (map-get? generated-dmt-lotto-by-token  (tuple (token-id token-id ))))) (err ERR-PATTERN-ALREADY-MINTED)) ;; check if NFT is already in the pool
  ;; Change data from here on:
    (begin       
    (try! (stx-transfer? price tx-sender (var-get artist-address))) ;; pay the minting fee
    (map-set generated-dmt-lotto-by-token  { token-id: token-id } { lotto-id: lotto-counter-in , miner: tx-sender }) ;; save the minted token and the block to the array (lotto-map) - 
    (map-set generated-dmt-lotto { lotto-id: lotto-counter-in } { token-id: token-id, miner: tx-sender }) ;; save the minted token and the block to the array (lotto-map) - 
    (var-set lotto-counter lotto-counter-new) ;; increase the counter in 1 -
    (ok token-id)
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
;; Support functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-read-only (get-block-height-design-gold ( block-id (string-ascii 70)))
  (let 
    (
      ;; split block numbers
      ;;(block-ascii (int-to-ascii block-id))
      (block-digit-1 (default-to "0" (slice? block-id u5 u6)))
      (block-digit-2 (default-to "0" (slice? block-id u4 u5)))
      (block-digit-3 (default-to "0" (slice? block-id u2 u4)))
      ;; unpack into colours and patterns
      ;; gold colours:
      (colour-1 "#FFDF00") 
      (colour-2 "#D4AF37") 
      (base-mod (default-to "<div>" (get model-hexa (map-get? base-model  (tuple ( model-id block-digit-3 )))))) 
      (base-mod-2 (default-to "<div>" (get model-hexa-2 (map-get? base-model  (tuple ( model-id block-digit-3 )))))) 
      (base-mod-3 (default-to "<div>" (get model-hexa-3 (map-get? base-model  (tuple ( model-id block-digit-3 )))))) 
      (conc-return (concat block-digit-1 (concat colour-1 (concat block-digit-2 (concat colour-2 (concat block-digit-3 base-mod))))))
    )
  (ok conc-return) 
  )
)
(define-read-only (get-block-height-design-silver ( block-id (string-ascii 70)))
  (let 
    (
      ;; split block numbers
      ;;(block-ascii (int-to-ascii block-id))
      (block-digit-1 (default-to "0" (slice? block-id u5 u6)))
      (block-digit-2 (default-to "0" (slice? block-id u4 u5)))
      (block-digit-3 (default-to "0" (slice? block-id u2 u4)))
      ;; unpack into colours and patterns
      ;; gold colours:
      (colour-1 "#C0C0C0") 
      (colour-2 "#D3D3D3") 
      (base-mod (default-to "<div>" (get model-hexa (map-get? base-model  (tuple ( model-id block-digit-3 )))))) 
      (base-mod-2 (default-to "<div>" (get model-hexa-2 (map-get? base-model  (tuple ( model-id block-digit-3 )))))) 
      (base-mod-3 (default-to "<div>" (get model-hexa-3 (map-get? base-model  (tuple ( model-id block-digit-3 )))))) 
      (conc-return (concat block-digit-1 (concat colour-1 (concat block-digit-2 (concat colour-2 (concat block-digit-3 base-mod))))))
    )
  (ok conc-return) 
  )
)
;; public function to return token SVG per token ID:
;; (define-read-only (get-token-svg (token-id uint))
;;   (let
;;   (
;;     (block-id (default-to u100 (get block-id (map-get? generated-dmt  (tuple ( token-id token-id ))))))
;;     (block-design (get-block-height-design block-id))
;;   )
;;   (ok block-design)
;;   )
;; )

;; Model set
(define-public (model-set (model-id-input uint) (model-hexa-input (string-ascii 1024)) (model-hexa-input-2 (string-ascii 1024)) (model-hexa-input-3 (string-ascii 1024)) )
  (let
  (
      (model-ascii (int-to-ascii model-id-input))
  )
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (map-set base-model { model-id: model-ascii } { model-hexa: model-hexa-input , model-hexa-2: model-hexa-input-2 , model-hexa-3: model-hexa-input-3 })
    (ok "Post successful")
  )
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

(define-read-only (get-current-silver-counter) 
  (let (
      (silver-counter-in (var-get silver-counter))
  )
  (ok silver-counter-in) 
)
)

(define-read-only (get-current-gold-counter) 
  (let (
      (gold-counter-in (var-get gold-counter))
  )
  (ok gold-counter-in) 
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

(define-public (set-price-gold (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price-gold price))))

(define-public (set-price-silver (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price-silver price))))

(define-read-only (get-price-gold)
  (ok (var-get total-price-gold)))

(define-read-only (get-price-silver)
  (ok (var-get total-price-silver)))  

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-artist-address)
  (ok (var-get artist-address)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; End of Contract. Thanks for reading!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;