
    (impl-trait 'SP39EMTZG4P7D55FMEQXEB8ZEQEK0ECBHB1GD8GMT.nft-trait.nft-trait)
    (use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)
    
    (define-non-fungible-token wax____ uint)
    (define-constant contract-owner tx-sender)
    (define-constant COMM u10)
    (define-constant COMM-ADDR 'SP1KMJR4X9BHS7830AA64316SGKZGQY354JRP2TQ7)
    (define-constant COMM-ADDR-TWO 'SP28KZ784B7AA6FGANSCPHV9V5CW4J43XT79DFKHG)
    
    (define-constant err-no-more-nfts u0)
    (define-constant err-not-enough-passes u1)
    (define-constant err-public-sale-disabled u2)
    (define-constant err-no-more-mints u3)
    (define-constant err-not-authorized u4)
    (define-constant err-invalid-user u5)
    (define-constant err-listing u6)
    (define-constant err-wrong-commission u7)
    (define-constant err-not-found u8)
    (define-constant err-minting-restricted-temporarily u9)
    (define-constant err-max-supply u10)
    (define-constant err-metadata-frozen u11)
    
    (define-map mints-per-user principal uint)
    (define-map mint-passes principal uint)
    (define-map token-count principal uint)
    (define-map market uint {price: uint, commission: principal})
    
    (define-data-var max-supply uint u10)
    (define-data-var total-price uint u100000)
    (define-data-var artiste-address principal tx-sender)
    (define-data-var nonce uint u1)
    (define-data-var ipfs (string-ascii 80) "https://radio-vault.vercel.app/api/metadata/63dfa72f1e3a2c3fdf034f7e")
    (define-data-var can-mint bool false)
    (define-data-var metadata-frozen bool false)
    (define-data-var mint-cap uint u0)
    
    
    
    (define-read-only (get-owner (token-id uint))
        (ok (nft-get-owner? wax____ token-id)))
    
    (define-read-only (get-last-token-id)
        (ok (- (var-get nonce) u1)))
    
    (define-read-only (get-token-uri (token-id uint))
        (ok (some (var-get ipfs))))
    
    (define-read-only (get-price)
        (ok (var-get total-price)))
    
    (define-read-only (get-mints (caller principal))
        (default-to u0 (map-get? mints-per-user caller)))
    
    (define-read-only (get-max-supply)
        (ok (var-get max-supply)))
    
    (define-read-only (get-balance (account principal))
        (default-to u0
        (map-get? token-count account)))
    
    (define-read-only (get-mint-status)
        (ok (var-get can-mint)))
    
    
    (define-public (set-artiste-address (address principal))
        (begin
        (asserts! (or (is-eq tx-sender (var-get artiste-address)) (is-eq tx-sender contract-owner)) (err err-invalid-user))
        (ok (var-set artiste-address address))))
    
    (define-public (set-price (price uint))
        (begin
        (asserts! (or (is-eq tx-sender (var-get artiste-address)) (is-eq tx-sender contract-owner)) (err err-invalid-user))
        (ok (var-set total-price price))))
    
    (define-public (restrict-minting)
        (begin
        (asserts! (or (is-eq tx-sender (var-get artiste-address)) (is-eq tx-sender contract-owner)) (err err-invalid-user))
        (ok (var-set can-mint (not (var-get can-mint))))))
    
    (define-public (set-max-supply (limit uint))
        (begin
        (asserts! (or (is-eq tx-sender (var-get artiste-address)) (is-eq tx-sender contract-owner)) (err err-invalid-user))
        (asserts! (< limit (var-get max-supply)) (err err-max-supply))
        (ok (var-set max-supply limit))))
    
    (define-public (burn (token-id uint))
       (begin 
        (asserts! (is-owner token-id tx-sender) (err err-not-authorized))
        (nft-burn? wax____ token-id tx-sender)))
    
    (define-private (is-owner (token-id uint) (user principal))
        (is-eq user (unwrap! (nft-get-owner? wax____ token-id) false)))
    
    (define-public (set-base-uri (new-base-uri (string-ascii 80)))
        (begin
        (asserts! (or (is-eq tx-sender (var-get artiste-address)) (is-eq tx-sender contract-owner)) (err err-not-authorized))
        (asserts! (not (var-get metadata-frozen)) (err err-metadata-frozen))
        (var-set ipfs new-base-uri)
        (ok true)))
    
    (define-public (freeze-metadata)
        (begin
        (asserts! (or (is-eq tx-sender (var-get artiste-address)) (is-eq tx-sender contract-owner)) (err err-not-authorized))
        (var-set metadata-frozen true)
        (ok true)))
    
    
    (define-public (transfer (id uint) (sender principal) (recipient principal))
        (begin
        (asserts! (is-eq tx-sender sender) (err err-not-authorized))
        (asserts! (is-none (map-get? market id)) (err err-listing))
        (trnsfr id sender recipient)))
    
    
    (define-private (iterate-minting (not-to-be-used bool) (next-id uint))
        (if (<= next-id (var-get max-supply))
        (begin
            (unwrap! (nft-mint? wax____ next-id tx-sender) next-id)
            (+ next-id u1)    
        )
        next-id))
    
    (define-public (claim-one) 
        (mint (list true)))
    (define-public (claim-two) 
        (mint (list true true)))
    (define-public (claim-three) 
        (mint (list true true true)))
    (define-public (claim-four) 
        (mint (list true true true true)))
    (define-public (claim-five) 
        (mint (list true true true true true)))
    
    
    (define-private (mint (orders (list 25 bool )))  
        (let 
        (
            (last-nft-id (var-get nonce))
            (enabled (asserts! (<= last-nft-id (var-get max-supply)) (err err-no-more-nfts)))
            (art-addr (var-get artiste-address))
            (id-reached (fold iterate-minting orders last-nft-id))
            (price (* (var-get total-price) (- id-reached last-nft-id)))
            (total-commission (/ (* price COMM) u10000))
            (current-balance (get-balance tx-sender))
            (total-artist (- price total-commission))
            (capped (> (var-get mint-cap) u0))
            (user-mints (get-mints tx-sender))
        )
        (asserts! (or (is-eq false (var-get can-mint)) (is-eq tx-sender contract-owner)) (err err-minting-restricted-temporarily))
        (asserts! (or (not capped) (is-eq tx-sender contract-owner) (is-eq tx-sender art-addr) (>= (var-get mint-cap) (+ (len orders) user-mints))) (err err-no-more-mints))
        (map-set mints-per-user tx-sender (+ (len orders) user-mints))
        (if (or (is-eq tx-sender art-addr) (is-eq tx-sender contract-owner) (is-eq (var-get total-price) u0000000))
            (begin
            (var-set nonce id-reached)
            (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
            )
            (begin
            (var-set nonce id-reached)
            (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
            (try! (stx-transfer? total-artist tx-sender (var-get artiste-address)))
            (try! (stx-transfer? (/ total-commission u2) tx-sender COMM-ADDR))
            (try! (stx-transfer? (/ total-commission u2) tx-sender COMM-ADDR-TWO))
            )    
        )
        (ok id-reached)))
    
    (define-private (trnsfr (id uint) (sender principal) (recipient principal))
        (match (nft-transfer? wax____ id sender recipient)
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
        (let ((owner (unwrap! (nft-get-owner? wax____ id) false)))
        (or (is-eq tx-sender owner) (is-eq contract-caller owner))))
    
    (define-read-only (get-listing-in-ustx (id uint))
        (map-get? market id))
    
    (define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
        (let ((listing  {price: price, commission: (contract-of comm-trait)}))
        (asserts! (is-sender-owner id) (err err-not-authorized))
        (map-set market id listing)
        (print (merge listing {a: "list-in-ustx", id: id}))
        (ok true)))
    
    (define-public (unlist-in-ustx (id uint))
        (begin
        (asserts! (is-sender-owner id) (err err-not-authorized))
        (map-delete market id)
        (print {a: "unlist-in-ustx", id: id})
        (ok true)))
    
    (define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
        (let ((owner (unwrap! (nft-get-owner? wax____ id) (err err-not-found)))
            (listing (unwrap! (map-get? market id) (err err-listing)))
            (price (get price listing)))
        (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err err-wrong-commission))
        (try! (stx-transfer? price tx-sender owner))
        (try! (contract-call? comm-trait pay id price))
        (try! (trnsfr id owner tx-sender))
        (map-delete market id)
        (print {a: "buy-in-ustx", id: id})
        (ok true)))
    