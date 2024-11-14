(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token rooons-wl uint)

;; Constants
(define-constant DEPLOYER tx-sender )
;;deployer: 'SPV8C2N59MA417HYQNG6372GCV0SEQE01EV4Z1RQ)

(define-constant ERR-NO-MORE-NFTS u100)
(define-constant ERR-NOT-ENOUGH-PASSES u101)
(define-constant ERR-PUBLIC-SALE-DISABLED u102)
(define-constant ERR-CONTRACT-INITIALIZED u103)
(define-constant ERR-NOT-AUTHORIZED u104)
(define-constant ERR-INVALID-USER u105)
(define-constant ERR-LISTING u106)
(define-constant ERR-WRONG-COMMISSION u107)
(define-constant ERR-NOT-FOUND u108)
(define-constant ERR-PAUSED u109)
(define-constant ERR-MINT-LIMIT u110)
(define-constant ERR-METADATA-FROZEN u111)
(define-constant ERR-AIRDROP-CALLED u112)
(define-constant ERR-NO-MORE-MINTS u113)
(define-constant ERR-INVALID-PERCENTAGE u114)
(define-constant ERR-BLOCK-ALREADY-MINTED u115)


;; Internal variables
(define-data-var mint-limit uint u99999) ;; 
(define-data-var last-id uint u0)
(define-data-var total-price uint u1000000) ;;Either free or 1 STX
(define-data-var artist-address principal 'SP30MSY8NECE4SJJRQ5NVFZA58HF9Y93XX6E15WMG)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/temporaryURL/json/") 
;;(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmSFmPopzJwVuXfzLNqSnwjoKM5o8WgYtzyHpk7ocR6gon/json/")
(define-data-var mint-paused bool true)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u10) ;; Max 10 per wallet

(define-map generated-nft
    {token-id: uint}
    {stage-id: uint, miner: principal}
)


(define-public (mint-wl (destination principal))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (+ last-nft-id u1));; mint command
      (price (var-get total-price) )
     ;; (price (* (var-get total-price) (- id-reached last-nft-id)))
      (current_id (- id-reached u1))
    )
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
   ;; (asserts! (is-eq true (nft-mint? rooons-wl id-reached destination) ) (err ERR-NO-MORE-NFTS))
    (try!  (nft-mint? rooons-wl id-reached destination) )
    (map-set generated-nft { token-id: id-reached } { stage-id: u1 , miner: destination })
    (var-set last-id id-reached)
    (ok current_id)
    )
)

(define-public (transfer (id uint) (sender principal) (recipient principal))
    (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
        (asserts! (is-eq contract-caller sender) (err ERR-NOT-AUTHORIZED))
        (nft-transfer? rooons-wl id sender recipient)
    )
)

(define-public (update-stage (id uint) (new-stage uint))
    (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (map-set generated-nft { token-id: id } { stage-id: new-stage , miner: DEPLOYER })
    (ok "Post successful")
    )
)

(define-public (set-artist-address (address principal))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set artist-address address))))

(define-public (set-price (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price price))))

(define-public (toggle-pause)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set mint-paused (not (var-get mint-paused))))))

(define-public (set-mint-limit (limit uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (asserts! (< limit (var-get mint-limit)) (err ERR-MINT-LIMIT))
    (ok (var-set mint-limit limit))))

(define-public (burn (token-id uint) (sender principal))
  (begin 
    (asserts! (or (is-eq tx-sender DEPLOYER) (is-owner token-id tx-sender) ) (err ERR-NOT-AUTHORIZED))
    (nft-burn? rooons-wl token-id sender)
    )

)

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? rooons-wl token-id) false)))

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (print { notification: "token-metadata-update", payload: { token-class: "nft", contract-id: (as-contract tx-sender) }})
    (var-set ipfs-root new-base-uri)
    (ok true)))

(define-public (freeze-metadata)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set metadata-frozen true)
    (ok true)))

;; Non-custodial SIP-009 transfer function

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? rooons-wl token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))


(define-read-only (get-token-uri (token-id uint))
(let
  ( 
    (stage-id (int-to-ascii (default-to u100 (get stage-id (map-get? generated-nft  (tuple ( token-id token-id ))))))) 
  )
;; get token block, replace on the ID below
  (ok (some (concat (concat (var-get ipfs-root) stage-id) ".json")))
)
)

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-price)
  (ok (var-get total-price)))

(define-read-only (get-artist-address)
  (ok (var-get artist-address)))

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/5")
(define-data-var license-name (string-ascii 40) "PERSONAL-NO-HATE")

(define-read-only (get-license-uri)
  (ok (var-get license-uri)))
  
(define-read-only (get-license-name)
  (ok (var-get license-name)))

;; updating license details  
(define-public (set-license-uri (uri (string-ascii 80)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set license-uri uri))))
    
(define-public (set-license-name (name (string-ascii 40)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set license-name name))))

(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? rooons-wl id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))
