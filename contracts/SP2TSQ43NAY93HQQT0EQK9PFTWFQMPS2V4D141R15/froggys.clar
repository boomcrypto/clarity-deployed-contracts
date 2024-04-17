;; froggys

;; Who are Froggys? 

;; The fact that this is the first 10k sOrdinals collection is purely anecdotical. We will build something magical together. 

;; Inside every Degen there's a kid that wants to come out. 

;; Think "The Little Prince" meets "Crypto Degens"

;; Our community will be a blend of the daring and the dreamy, where risk-taking meets reflection, and innovation meets introspection. 
;; Let's embark on this journey together, with the wisdom of The Little Prince guiding our Degen spirits.

;; The 10k Froggys are 6x6 pixels, children of sOrdinal Inscription #2793
;; All Froggys were inscribed before 100k inscriptions existed in the sOrdinals Protocol - ranging from #10065 to #87643

;; Special thanks to Gamma devs and Cirrotoshi for proofing the first froggy inscription wrapper on Stacks. We appreciate Gamma, Stacks, and Bitcoin!
;; Special thanks to Mijoco.btc, aka @Radicleart, for promptly reviewing the hop and hop-back functions.
;; To go far, go together. Hop Hop!

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;; (impl-trait .nft-trait.nft-trait)

(define-non-fungible-token froggys uint)

;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant COMM u1000)
(define-constant COMM-ADDR 'SP2TSQ43NAY93HQQT0EQK9PFTWFQMPS2V4D141R15)

(define-constant ERR-NOT-AUTHORIZED u104)
(define-constant ERR-INVALID-USER u105)
(define-constant ERR-LISTING u106)
(define-constant ERR-WRONG-COMMISSION u107)
(define-constant ERR-NOT-FOUND u108)
(define-constant ERR-METADATA-FROZEN u111)

;; Internal variables
(define-data-var last-id uint u1)
(define-data-var artist-address principal 'SP3E8B51MF5E28BD82FM95VDSQ71VK4KFNZX7ZK2R)
(define-data-var ipfs-root (string-ascii 80) "ipfs://bafybeiggwtcx7xzd4g7l236xvd7xnv6t6flj4dp3lgq57ienaib2urs2vq/")
(define-data-var metadata-frozen bool false)

(define-data-var gas-for-froggy uint u1000001)
(define-data-var froggy-agent principal 'SP246BNY0D1H2J2WMXMXEZVHH5J8CBG10XA17YEMD)

;; A public function to update the froggy-agent variable
(define-public (set-froggy-agent (new-agent principal))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (var-set froggy-agent new-agent)
    (ok true)
  )
)

;; A public function to update the gas-for-froggy variable
(define-public (set-gas-for-froggy (new-gas uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (var-set gas-for-froggy new-gas)
    (ok true)
  )
)

(define-public (set-artist-address (address principal))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set artist-address address))))

(define-public (burn (token-id uint))
  (begin 
    (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))
    ;; token-id must not be listed in the market
    (try! (if (is-none (map-get? market token-id)) (ok true) (err ERR-LISTING)))
    (nft-burn? froggys token-id tx-sender)))

(define-public (hop (token-id uint) (recipient principal)) 
 ;; Before calling this function
 ;; Agent verifies that the inscription 1.000001 was sent to them (DEPLOYER) by the recipient (1 or lower gas fees to cover for callint this func)
  (let 
    (
      (froggy-owner (nft-get-owner? froggys token-id)) ;; Was the token-id ever minted?
      (recipient-balance (get-balance recipient))
    )
    ;; Only DEPLOYER or froggy-agent can wrap the inscription
    (asserts! (or (is-eq tx-sender DEPLOYER) (is-eq tx-sender (var-get froggy-agent))) (err ERR-NOT-AUTHORIZED))
  
    (if (is-none froggy-owner)
          (let ;; token-id never minted
              (
                (setting-balance 
                  (map-set token-count recipient (+ recipient-balance u1)))
              )
            (print {expr: "hop", token-id: token-id, recipient: recipient})  
            (nft-mint? froggys token-id recipient) ;; and mints the NFT to the recipient
          )
          (begin ;; token-id minted
          ;; token-id must be vaulted in this contract
          (asserts! (is-owner token-id (as-contract tx-sender)) (err ERR-NOT-AUTHORIZED))
          ;; token-id must not be listed in the market
          (try! (if (is-none (map-get? market token-id)) (ok true) (err ERR-LISTING)))
          (print {expr: "hop", token-id: token-id, recipient: recipient})  
          (as-contract (trnsfr token-id tx-sender recipient)) ;; and sends the NFT wrapper to the recipient
          )
    )
  )
)

(define-public (hop-back (token-id uint))
  (begin   
    (asserts! (is-owner token-id contract-caller) (err ERR-NOT-AUTHORIZED)) ;; Mike says contract-caller to include a contract owning it
    ;; Tx-sender must send froggy-agent 1.000001 STX to cover for the inscription transfer
    (try! (stx-transfer? (var-get gas-for-froggy) tx-sender (var-get froggy-agent)))
    ;; token-id must not be listed in the market
    (try! (if (is-none (map-get? market token-id)) (ok true) (err ERR-LISTING)))
    (try! (trnsfr token-id tx-sender (as-contract tx-sender))) ;; Mike says try! to keep nested errors
    (print {expr: "hop-back", token-id: token-id, recipient: tx-sender})
    (ok true)
    ;; Agent sends 1.000001 inscription token-id to tx-sender after this call is successful
  )
)

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? froggys token-id) false)))

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (var-set ipfs-root new-base-uri)
    (ok true)))

(define-public (freeze-metadata)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set metadata-frozen true)
    (ok true)))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-INVALID-USER))
    ;; (nft-transfer? froggys token-id sender recipient))) ;; this should be trnsfer instead because it messes up the token count
    ;; say I transfer out to Alice and I'm Froggy, my token count is still 1, and Alice's is still 0
    ;; token-id must not be listed in the market
    (try! (if (is-none (map-get? market token-id)) (ok true) (err ERR-LISTING)))
    (trnsfr token-id sender recipient))) ;; this means that every minted token should get a token count of 1

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? froggys token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))

(define-trait commission-trait
  ((pay (uint uint) (response bool uint))))

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? froggys id sender recipient)
    success
      (let
        ((sender-balance (get-balance sender))
        (recipient-balance (get-balance recipient)))
          (map-set token-count
            sender
            (- sender-balance u1))
          (map-set token-count
            recipient
            (+ recipient-balance u1))
          (ok success))
    error (err error)))

(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? froggys id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait)}))
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? froggys id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))

;; It's an honor to have you as a friend. You are a kind person. You are a role model of a human being. And you are the creator of Froggys.
;; Life was created so that we can hop, hop, auction $NOTHING, and hop back.