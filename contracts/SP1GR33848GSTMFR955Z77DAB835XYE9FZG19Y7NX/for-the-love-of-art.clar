;; for-the-love-of-art
;; contractType: editions

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token for-the-love-of-art uint)

;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant COMM u1000)
(define-constant COMM-ADDR 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)

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
(define-constant ERR-CONTRACT-LOCKED u115)

;; Internal variables
(define-data-var mint-limit uint u32)
(define-data-var last-id uint u1)
(define-data-var total-price uint u25000000)
(define-data-var artist-address principal 'SP1GR33848GSTMFR955Z77DAB835XYE9FZG19Y7NX)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmYZ8ET9kyz7KNXNZFUH7bCZ8EDmDPh5aqWvUDqY5rHSkr/")
(define-data-var mint-paused bool true)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u0)
(define-data-var locked bool false)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

(define-public (lock-contract)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set locked true)
    (ok true)))

(define-public (claim) 
  (mint (list true)))

;; Default Minting
(define-private (mint (orders (list 25 bool)))
  (mint-many orders))

(define-private (mint-many (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (or (is-eq (var-get mint-limit) u0) (<= last-nft-id (var-get mint-limit))) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price) (- id-reached last-nft-id)))
      (total-commission (/ (* price COMM) u10000))
      (current-balance (get-balance tx-sender))
      (total-artist (- price total-commission))
      (capped (> (var-get mint-cap) u0))
      (user-mints (get-mints tx-sender))
    )
    (asserts! (or (is-eq false (var-get mint-paused)) (is-eq tx-sender DEPLOYER)) (err ERR-PAUSED))
    (asserts! (is-eq (var-get locked) false) (err ERR-CONTRACT-LOCKED))
    (asserts! (or (not capped) (is-eq tx-sender DEPLOYER) (is-eq tx-sender art-addr) (>= (var-get mint-cap) (+ (len orders) user-mints))) (err ERR-NO-MORE-MINTS))
    (map-set mints-per-user tx-sender (+ (len orders) user-mints))
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER) (is-eq (var-get total-price) u0000000))
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
      )
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
        (try! (stx-transfer? total-artist tx-sender (var-get artist-address)))
        (try! (stx-transfer? total-commission tx-sender COMM-ADDR))
      )    
    )
    (ok id-reached)))

(define-private (mint-many-iter (ignore bool) (next-id uint))
  (if (or (is-eq (var-get mint-limit) u0) (<= next-id (var-get mint-limit)))
    (begin
      (unwrap! (nft-mint? for-the-love-of-art next-id tx-sender) next-id)
      (+ next-id u1)    
    )
    next-id))

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

(define-public (burn (token-id uint))
  (begin 
    (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market token-id)) (err ERR-LISTING))
    (nft-burn? for-the-love-of-art token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? for-the-love-of-art token-id) false)))

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
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? for-the-love-of-art token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (var-get ipfs-root))))

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-price)
  (ok (var-get total-price)))

(define-read-only (get-artist-address)
  (ok (var-get artist-address)))

(define-read-only (get-locked)
  (ok (var-get locked)))

(define-read-only (get-mints (caller principal))
  (default-to u0 (map-get? mints-per-user caller)))

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/4")
(define-data-var license-name (string-ascii 40) "PERSONAL")

(define-read-only (get-license-uri)
  (ok (var-get license-uri)))
  
(define-read-only (get-license-name)
  (ok (var-get license-name)))
  
(define-public (set-license-uri (uri (string-ascii 80)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set license-uri uri))))
    
(define-public (set-license-name (name (string-ascii 40)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set license-name name))))

;; Non-custodial marketplace extras
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalty: uint})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? for-the-love-of-art id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? for-the-love-of-art id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait), royalty: (var-get royalty-percent)}))
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
  (let ((owner (unwrap! (nft-get-owner? for-the-love-of-art id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing))
      (royalty (get royalty listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (pay-royalty price royalty))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))
    
(define-data-var royalty-percent uint u500)

(define-read-only (get-royalty-percent)
  (ok (var-get royalty-percent)))

(define-public (set-royalty-percent (royalty uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (asserts! (and (>= royalty u0) (<= royalty u1000)) (err ERR-INVALID-PERCENTAGE))
    (ok (var-set royalty-percent royalty))))

(define-private (pay-royalty (price uint) (royalty uint))
  (let (
    (royalty-amount (/ (* price royalty) u10000))
  )
  (if (and (> royalty-amount u0) (not (is-eq tx-sender (var-get artist-address))))
    (try! (stx-transfer? royalty-amount tx-sender (var-get artist-address)))
    (print false)
  )
  (ok true)))
  

;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u0) 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7))
      (map-set token-count 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7 (+ (get-balance 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u1) 'SP23DZ9XYT3YNF70MHAV9Y3622H8B3DX10WMWT2T9))
      (map-set token-count 'SP23DZ9XYT3YNF70MHAV9Y3622H8B3DX10WMWT2T9 (+ (get-balance 'SP23DZ9XYT3YNF70MHAV9Y3622H8B3DX10WMWT2T9) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u2) 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0))
      (map-set token-count 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0 (+ (get-balance 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u3) 'SP1WGFPEVNTK7N41JKAMEKEY9HK14MJP99BZ016N9))
      (map-set token-count 'SP1WGFPEVNTK7N41JKAMEKEY9HK14MJP99BZ016N9 (+ (get-balance 'SP1WGFPEVNTK7N41JKAMEKEY9HK14MJP99BZ016N9) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u4) 'SP30HDQ1WGZRD1YTBRPPPYZHKQJ7E8CVYZCTHXKVX))
      (map-set token-count 'SP30HDQ1WGZRD1YTBRPPPYZHKQJ7E8CVYZCTHXKVX (+ (get-balance 'SP30HDQ1WGZRD1YTBRPPPYZHKQJ7E8CVYZCTHXKVX) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u5) 'SP2E03GHWY145XMFDTHX4Z913EADP4RMZ0P0DCTE9))
      (map-set token-count 'SP2E03GHWY145XMFDTHX4Z913EADP4RMZ0P0DCTE9 (+ (get-balance 'SP2E03GHWY145XMFDTHX4Z913EADP4RMZ0P0DCTE9) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u6) 'SP3GNAE8V8KZ24T31JC10TT184F6NQ4YDYHGVFZ10))
      (map-set token-count 'SP3GNAE8V8KZ24T31JC10TT184F6NQ4YDYHGVFZ10 (+ (get-balance 'SP3GNAE8V8KZ24T31JC10TT184F6NQ4YDYHGVFZ10) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u7) 'SP2KKB6Y650VECRSAEEHRWZHPWKTMP2STA9YVA3KC))
      (map-set token-count 'SP2KKB6Y650VECRSAEEHRWZHPWKTMP2STA9YVA3KC (+ (get-balance 'SP2KKB6Y650VECRSAEEHRWZHPWKTMP2STA9YVA3KC) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u8) 'SPKCN7FXPWGKN6NSBHYA2EJG8PHF451B5BMRXGP1))
      (map-set token-count 'SPKCN7FXPWGKN6NSBHYA2EJG8PHF451B5BMRXGP1 (+ (get-balance 'SPKCN7FXPWGKN6NSBHYA2EJG8PHF451B5BMRXGP1) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u9) 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6))
      (map-set token-count 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6 (+ (get-balance 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u10) 'SP2XZ7YVJFPM1Q4Z67BHS7Z6X0F6BACEAXZHGC5DC))
      (map-set token-count 'SP2XZ7YVJFPM1Q4Z67BHS7Z6X0F6BACEAXZHGC5DC (+ (get-balance 'SP2XZ7YVJFPM1Q4Z67BHS7Z6X0F6BACEAXZHGC5DC) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u11) 'SP1DMVH9E81418WZS0QNPRHBNA8QZ8BEV0WJ017V2))
      (map-set token-count 'SP1DMVH9E81418WZS0QNPRHBNA8QZ8BEV0WJ017V2 (+ (get-balance 'SP1DMVH9E81418WZS0QNPRHBNA8QZ8BEV0WJ017V2) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u12) 'SP84C5YVBTBSXZ8KS39R97QDKX1YNSXXR8814ET7))
      (map-set token-count 'SP84C5YVBTBSXZ8KS39R97QDKX1YNSXXR8814ET7 (+ (get-balance 'SP84C5YVBTBSXZ8KS39R97QDKX1YNSXXR8814ET7) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u13) 'SP3EZ3H7H49CEE49X8HE9W6QX0Y29W8R5T1MMY7AJ))
      (map-set token-count 'SP3EZ3H7H49CEE49X8HE9W6QX0Y29W8R5T1MMY7AJ (+ (get-balance 'SP3EZ3H7H49CEE49X8HE9W6QX0Y29W8R5T1MMY7AJ) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u14) 'SP3KXV3J6MRHAH4H89MDS390X1KS0GQN4DWQ5RFVB))
      (map-set token-count 'SP3KXV3J6MRHAH4H89MDS390X1KS0GQN4DWQ5RFVB (+ (get-balance 'SP3KXV3J6MRHAH4H89MDS390X1KS0GQN4DWQ5RFVB) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u15) 'SP24X692XB6CZB0Z70ZGWRNCY22PZ5FED3P9KBGS8))
      (map-set token-count 'SP24X692XB6CZB0Z70ZGWRNCY22PZ5FED3P9KBGS8 (+ (get-balance 'SP24X692XB6CZB0Z70ZGWRNCY22PZ5FED3P9KBGS8) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u16) 'SP10MR7XS69Z0T5FEZ9M1NXQE3J38WVZEC1WW9M41))
      (map-set token-count 'SP10MR7XS69Z0T5FEZ9M1NXQE3J38WVZEC1WW9M41 (+ (get-balance 'SP10MR7XS69Z0T5FEZ9M1NXQE3J38WVZEC1WW9M41) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u17) 'SPJT8G4DA24ZDF35WMY5FZEQ9YJNK38DBN2D48QH))
      (map-set token-count 'SPJT8G4DA24ZDF35WMY5FZEQ9YJNK38DBN2D48QH (+ (get-balance 'SPJT8G4DA24ZDF35WMY5FZEQ9YJNK38DBN2D48QH) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u18) 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX))
      (map-set token-count 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX (+ (get-balance 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u19) 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ))
      (map-set token-count 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ (+ (get-balance 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u20) 'SP2MS5KKM4CFTC6C6H2QAB7BKYBSNXWZKVCCXBMQG))
      (map-set token-count 'SP2MS5KKM4CFTC6C6H2QAB7BKYBSNXWZKVCCXBMQG (+ (get-balance 'SP2MS5KKM4CFTC6C6H2QAB7BKYBSNXWZKVCCXBMQG) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u21) 'SP2MS5KKM4CFTC6C6H2QAB7BKYBSNXWZKVCCXBMQG))
      (map-set token-count 'SP2MS5KKM4CFTC6C6H2QAB7BKYBSNXWZKVCCXBMQG (+ (get-balance 'SP2MS5KKM4CFTC6C6H2QAB7BKYBSNXWZKVCCXBMQG) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u22) 'SP2JWXVBMB0DW53KC1PJ80VC7T6N2ZQDBGCDJDMNR))
      (map-set token-count 'SP2JWXVBMB0DW53KC1PJ80VC7T6N2ZQDBGCDJDMNR (+ (get-balance 'SP2JWXVBMB0DW53KC1PJ80VC7T6N2ZQDBGCDJDMNR) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u23) 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9))
      (map-set token-count 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9 (+ (get-balance 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u24) 'SP2BVBCF72JQZH9EHWX99WWEB726QS8WN4MT87CY2))
      (map-set token-count 'SP2BVBCF72JQZH9EHWX99WWEB726QS8WN4MT87CY2 (+ (get-balance 'SP2BVBCF72JQZH9EHWX99WWEB726QS8WN4MT87CY2) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u25) 'SP352FR22PRMWG4EYV0EJE0JXGCS3GWTZMB6HD6S7))
      (map-set token-count 'SP352FR22PRMWG4EYV0EJE0JXGCS3GWTZMB6HD6S7 (+ (get-balance 'SP352FR22PRMWG4EYV0EJE0JXGCS3GWTZMB6HD6S7) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u26) 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV))
      (map-set token-count 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV (+ (get-balance 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u27) 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ))
      (map-set token-count 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ (+ (get-balance 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u28) 'SP3JPR7XNR60AMBBEZAGF1YHRSFY1JCKE14HBKGTY))
      (map-set token-count 'SP3JPR7XNR60AMBBEZAGF1YHRSFY1JCKE14HBKGTY (+ (get-balance 'SP3JPR7XNR60AMBBEZAGF1YHRSFY1JCKE14HBKGTY) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u29) 'SP2JQKHDV4N3FH86S52G4DH8HRG93DE1X39YHNSN))
      (map-set token-count 'SP2JQKHDV4N3FH86S52G4DH8HRG93DE1X39YHNSN (+ (get-balance 'SP2JQKHDV4N3FH86S52G4DH8HRG93DE1X39YHNSN) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u30) 'SP14DXQ7A1PVVGPBQCJQVP0T4CH6FTZZ312FSE724))
      (map-set token-count 'SP14DXQ7A1PVVGPBQCJQVP0T4CH6FTZZ312FSE724 (+ (get-balance 'SP14DXQ7A1PVVGPBQCJQVP0T4CH6FTZZ312FSE724) u1))
      (try! (nft-mint? for-the-love-of-art (+ last-nft-id u31) 'SP1AV1T403Y7ZB5V7XCZK460G8515PVK6NGJFR7KD))
      (map-set token-count 'SP1AV1T403Y7ZB5V7XCZK460G8515PVK6NGJFR7KD (+ (get-balance 'SP1AV1T403Y7ZB5V7XCZK460G8515PVK6NGJFR7KD) u1))

      (var-set last-id (+ last-nft-id u32))
      (var-set airdrop-called true)
      (ok true))))