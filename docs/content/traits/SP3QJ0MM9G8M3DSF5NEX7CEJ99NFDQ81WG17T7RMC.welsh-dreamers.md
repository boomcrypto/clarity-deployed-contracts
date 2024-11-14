---
title: "Trait welsh-dreamers"
draft: true
---
```
;; welsh-dreamers
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token welsh-dreamers uint)

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

;; Internal variables
(define-data-var mint-limit uint u225)
(define-data-var last-id uint u1)
(define-data-var total-price uint u50000000)
(define-data-var artist-address principal 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmegZxq5UhHzRnZBRV8U313a79gZZS92DctJumx7EtjgWC/json/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u0)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

(define-public (claim) 
  (mint (list true)))

(define-public (claim-two) (mint (list true true)))

(define-public (claim-three) (mint (list true true true)))

(define-public (claim-four) (mint (list true true true true)))

(define-public (claim-five) (mint (list true true true true true)))

(define-public (claim-six) (mint (list true true true true true true)))

(define-public (claim-seven) (mint (list true true true true true true true)))

(define-public (claim-eight) (mint (list true true true true true true true true)))

(define-public (claim-nine) (mint (list true true true true true true true true true)))

(define-public (claim-ten) (mint (list true true true true true true true true true true)))

(define-public (claim-fifteen) (mint (list true true true true true true true true true true true true true true true)))

(define-public (claim-twenty) (mint (list true true true true true true true true true true true true true true true true true true true true)))

(define-public (claim-twentyfive) (mint (list true true true true true true true true true true true true true true true true true true true true true true true true true)))

;; Default Minting
(define-private (mint (orders (list 25 bool)))
  (mint-many orders))

(define-private (mint-many (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
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
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? welsh-dreamers next-id tx-sender) next-id)
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
    (nft-burn? welsh-dreamers token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? welsh-dreamers token-id) false)))

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
  (ok (nft-get-owner? welsh-dreamers token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-price)
  (ok (var-get total-price)))

(define-read-only (get-artist-address)
  (ok (var-get artist-address)))

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
  (match (nft-transfer? welsh-dreamers id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? welsh-dreamers id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? welsh-dreamers id) (err ERR-NOT-FOUND)))
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
  

;; Alt Minting Default
(define-data-var total-price-xbtc uint u158047)

(define-read-only (get-price-xbtc)
  (ok (var-get total-price-xbtc)))

(define-public (set-price-xbtc (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price-xbtc price))))

(define-public (claim-xbtc)
  (mint-xbtc (list true)))

(define-public (claim-two-xbtc) (mint-xbtc (list true true)))

(define-public (claim-three-xbtc) (mint-xbtc (list true true true)))

(define-public (claim-four-xbtc) (mint-xbtc (list true true true true)))

(define-public (claim-five-xbtc) (mint-xbtc (list true true true true true)))

(define-public (claim-six-xbtc) (mint-xbtc (list true true true true true true)))

(define-public (claim-seven-xbtc) (mint-xbtc (list true true true true true true true)))

(define-public (claim-eight-xbtc) (mint-xbtc (list true true true true true true true true)))

(define-public (claim-nine-xbtc) (mint-xbtc (list true true true true true true true true true)))

(define-public (claim-ten-xbtc) (mint-xbtc (list true true true true true true true true true true)))

(define-public (claim-fifteen-xbtc) (mint-xbtc (list true true true true true true true true true true true true true true true)))

(define-public (claim-twenty-xbtc) (mint-xbtc (list true true true true true true true true true true true true true true true true true true true true)))

(define-public (claim-twentyfive-xbtc) (mint-xbtc (list true true true true true true true true true true true true true true true true true true true true true true true true true)))


(define-private (mint-xbtc (orders (list 25 bool)))
  (mint-many-xbtc orders))

(define-private (mint-many-xbtc (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price-xbtc) (- id-reached last-nft-id)))
      (total-commission (/ (* price COMM) u10000))
      (current-balance (get-balance tx-sender))
      (total-artist (- price total-commission))
    )
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER))
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
      )
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
        (try! (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin transfer total-artist tx-sender (var-get artist-address) (some 0x00)))
        (try! (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin transfer total-commission tx-sender COMM-ADDR (some 0x00)))
      )    
    )
    (ok id-reached)))

;; Alt Minting Default
(define-data-var total-price-usda uint u111000000)

(define-read-only (get-price-usda)
  (ok (var-get total-price-usda)))

(define-public (set-price-usda (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price-usda price))))

(define-public (claim-usda)
  (mint-usda (list true)))

(define-public (claim-two-usda) (mint-usda (list true true)))

(define-public (claim-three-usda) (mint-usda (list true true true)))

(define-public (claim-four-usda) (mint-usda (list true true true true)))

(define-public (claim-five-usda) (mint-usda (list true true true true true)))

(define-public (claim-six-usda) (mint-usda (list true true true true true true)))

(define-public (claim-seven-usda) (mint-usda (list true true true true true true true)))

(define-public (claim-eight-usda) (mint-usda (list true true true true true true true true)))

(define-public (claim-nine-usda) (mint-usda (list true true true true true true true true true)))

(define-public (claim-ten-usda) (mint-usda (list true true true true true true true true true true)))

(define-public (claim-fifteen-usda) (mint-usda (list true true true true true true true true true true true true true true true)))

(define-public (claim-twenty-usda) (mint-usda (list true true true true true true true true true true true true true true true true true true true true)))

(define-public (claim-twentyfive-usda) (mint-usda (list true true true true true true true true true true true true true true true true true true true true true true true true true)))


(define-private (mint-usda (orders (list 25 bool)))
  (mint-many-usda orders))

(define-private (mint-many-usda (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price-usda) (- id-reached last-nft-id)))
      (total-commission (/ (* price COMM) u10000))
      (current-balance (get-balance tx-sender))
      (total-artist (- price total-commission))
    )
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER))
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
      )
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
        (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer total-artist tx-sender (var-get artist-address) (some 0x00)))
        (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer total-commission tx-sender COMM-ADDR (some 0x00)))
      )    
    )
    (ok id-reached)))

;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u0) 'SP13H6Y64BQM1SE17PVQAVGWWXRH4SBCSYM61JFG3))
      (map-set token-count 'SP13H6Y64BQM1SE17PVQAVGWWXRH4SBCSYM61JFG3 (+ (get-balance 'SP13H6Y64BQM1SE17PVQAVGWWXRH4SBCSYM61JFG3) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u1) 'SP177JV93RYPWWTX5F0MK9NVQ3YTXB4YQZGBPP6H4))
      (map-set token-count 'SP177JV93RYPWWTX5F0MK9NVQ3YTXB4YQZGBPP6H4 (+ (get-balance 'SP177JV93RYPWWTX5F0MK9NVQ3YTXB4YQZGBPP6H4) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u2) 'SP1CHWS7TDP36PPVWV8E4Q8QV7S8SZPYYWW9N0ZW8))
      (map-set token-count 'SP1CHWS7TDP36PPVWV8E4Q8QV7S8SZPYYWW9N0ZW8 (+ (get-balance 'SP1CHWS7TDP36PPVWV8E4Q8QV7S8SZPYYWW9N0ZW8) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u3) 'SP1EEPEQ35E36M76WNPHFQ0HPRA91MFSNFBC3HBJ4))
      (map-set token-count 'SP1EEPEQ35E36M76WNPHFQ0HPRA91MFSNFBC3HBJ4 (+ (get-balance 'SP1EEPEQ35E36M76WNPHFQ0HPRA91MFSNFBC3HBJ4) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u4) 'SP1P637C9NB6GSK9TY8AT8SN3QKH1WSV5ZVCZZSKS))
      (map-set token-count 'SP1P637C9NB6GSK9TY8AT8SN3QKH1WSV5ZVCZZSKS (+ (get-balance 'SP1P637C9NB6GSK9TY8AT8SN3QKH1WSV5ZVCZZSKS) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u5) 'SP1TRCNSSYS01EPH4AZ5QMQHQ5YAD49KFBN2788DV))
      (map-set token-count 'SP1TRCNSSYS01EPH4AZ5QMQHQ5YAD49KFBN2788DV (+ (get-balance 'SP1TRCNSSYS01EPH4AZ5QMQHQ5YAD49KFBN2788DV) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u6) 'SP20QT7A65T9J1RQM8BGD7CX0ZKBRMWQX4J72FF3Z))
      (map-set token-count 'SP20QT7A65T9J1RQM8BGD7CX0ZKBRMWQX4J72FF3Z (+ (get-balance 'SP20QT7A65T9J1RQM8BGD7CX0ZKBRMWQX4J72FF3Z) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u7) 'SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY))
      (map-set token-count 'SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY (+ (get-balance 'SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u8) 'SP2VP11195A8T6PCAP3NZHY7330EFWSGAQXSPCWK1))
      (map-set token-count 'SP2VP11195A8T6PCAP3NZHY7330EFWSGAQXSPCWK1 (+ (get-balance 'SP2VP11195A8T6PCAP3NZHY7330EFWSGAQXSPCWK1) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u9) 'SP30ZJR8FA4ENS8DP5E24PJ94ZZAZ1BP5C9KNC7WH))
      (map-set token-count 'SP30ZJR8FA4ENS8DP5E24PJ94ZZAZ1BP5C9KNC7WH (+ (get-balance 'SP30ZJR8FA4ENS8DP5E24PJ94ZZAZ1BP5C9KNC7WH) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u10) 'SP38PSGDVDQY04C4XSQ38EBCPKRWR5R1CK5FM0TEQ))
      (map-set token-count 'SP38PSGDVDQY04C4XSQ38EBCPKRWR5R1CK5FM0TEQ (+ (get-balance 'SP38PSGDVDQY04C4XSQ38EBCPKRWR5R1CK5FM0TEQ) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u11) 'SP3AF7X8FEM3C91YS3XDEPGP99B7GQQZD1KZSK3CQ))
      (map-set token-count 'SP3AF7X8FEM3C91YS3XDEPGP99B7GQQZD1KZSK3CQ (+ (get-balance 'SP3AF7X8FEM3C91YS3XDEPGP99B7GQQZD1KZSK3CQ) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u12) 'SP3ECM8VWFW6G7FVP78SG7EJGVXS6C7TGGFDEKS2R))
      (map-set token-count 'SP3ECM8VWFW6G7FVP78SG7EJGVXS6C7TGGFDEKS2R (+ (get-balance 'SP3ECM8VWFW6G7FVP78SG7EJGVXS6C7TGGFDEKS2R) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u13) 'SP3J7Y4C6XGJ5DAWMAKVDT4YTSH5FJP1THCZ2NYY4))
      (map-set token-count 'SP3J7Y4C6XGJ5DAWMAKVDT4YTSH5FJP1THCZ2NYY4 (+ (get-balance 'SP3J7Y4C6XGJ5DAWMAKVDT4YTSH5FJP1THCZ2NYY4) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u14) 'SP3JG1WY74GTDS9YVYJHZH75FSCZ2EPKE44FBTP8Y))
      (map-set token-count 'SP3JG1WY74GTDS9YVYJHZH75FSCZ2EPKE44FBTP8Y (+ (get-balance 'SP3JG1WY74GTDS9YVYJHZH75FSCZ2EPKE44FBTP8Y) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u15) 'SP3MYZ2T7JA4GYBYMSZ4ZJYEYTZ69JDD0M7W4BQ8V))
      (map-set token-count 'SP3MYZ2T7JA4GYBYMSZ4ZJYEYTZ69JDD0M7W4BQ8V (+ (get-balance 'SP3MYZ2T7JA4GYBYMSZ4ZJYEYTZ69JDD0M7W4BQ8V) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u16) 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC))
      (map-set token-count 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC (+ (get-balance 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u17) 'SP3WAAYXPC6WZNEC7SHGR36D32RJPZVXRR1BG0QSY))
      (map-set token-count 'SP3WAAYXPC6WZNEC7SHGR36D32RJPZVXRR1BG0QSY (+ (get-balance 'SP3WAAYXPC6WZNEC7SHGR36D32RJPZVXRR1BG0QSY) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u18) 'SPCD0ZWMQ75ZJ152PB0C2Q1S69P0GDFYBAS3Q315))
      (map-set token-count 'SPCD0ZWMQ75ZJ152PB0C2Q1S69P0GDFYBAS3Q315 (+ (get-balance 'SPCD0ZWMQ75ZJ152PB0C2Q1S69P0GDFYBAS3Q315) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u19) 'SPEHH120TRDJ49EV62K3GH8VGR2XWE53QMZ07HTB))
      (map-set token-count 'SPEHH120TRDJ49EV62K3GH8VGR2XWE53QMZ07HTB (+ (get-balance 'SPEHH120TRDJ49EV62K3GH8VGR2XWE53QMZ07HTB) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u20) 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE))
      (map-set token-count 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE (+ (get-balance 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u21) 'SPPR3B98653A21MBGFRZC2HPH4B3RM9KZEQ0AT8V))
      (map-set token-count 'SPPR3B98653A21MBGFRZC2HPH4B3RM9KZEQ0AT8V (+ (get-balance 'SPPR3B98653A21MBGFRZC2HPH4B3RM9KZEQ0AT8V) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u22) 'SPQDQG5AV16RVY4YRNZ5ZV9C9S9T94GXETQWGK8Z))
      (map-set token-count 'SPQDQG5AV16RVY4YRNZ5ZV9C9S9T94GXETQWGK8Z (+ (get-balance 'SPQDQG5AV16RVY4YRNZ5ZV9C9S9T94GXETQWGK8Z) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u23) 'SPSQ4W56BY5XKZR8YJMXYP1CKJ64TT4CQ04GFQT8))
      (map-set token-count 'SPSQ4W56BY5XKZR8YJMXYP1CKJ64TT4CQ04GFQT8 (+ (get-balance 'SPSQ4W56BY5XKZR8YJMXYP1CKJ64TT4CQ04GFQT8) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u24) 'SP4DAK740FESTGWSX4ME34N82F0BVHN3BS5DGG4K))
      (map-set token-count 'SP4DAK740FESTGWSX4ME34N82F0BVHN3BS5DGG4K (+ (get-balance 'SP4DAK740FESTGWSX4ME34N82F0BVHN3BS5DGG4K) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u25) 'SP27VK3EGRTFXKA0YBKDMHZD57AG3H4W56CMF0AWX))
      (map-set token-count 'SP27VK3EGRTFXKA0YBKDMHZD57AG3H4W56CMF0AWX (+ (get-balance 'SP27VK3EGRTFXKA0YBKDMHZD57AG3H4W56CMF0AWX) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u26) 'SP3WYV6HJC76F46RBSJGY72J2ZVA1NEKFEBQ01C6H))
      (map-set token-count 'SP3WYV6HJC76F46RBSJGY72J2ZVA1NEKFEBQ01C6H (+ (get-balance 'SP3WYV6HJC76F46RBSJGY72J2ZVA1NEKFEBQ01C6H) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u27) 'SP2C49ZARZ9S4HZQ9DJS8XH27K8SKRYAQ4JPJ6XE8))
      (map-set token-count 'SP2C49ZARZ9S4HZQ9DJS8XH27K8SKRYAQ4JPJ6XE8 (+ (get-balance 'SP2C49ZARZ9S4HZQ9DJS8XH27K8SKRYAQ4JPJ6XE8) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u28) 'SP13X1GXDCPXZWZGVBBPQEYY6A7NSXCB4XSYD8Z4B))
      (map-set token-count 'SP13X1GXDCPXZWZGVBBPQEYY6A7NSXCB4XSYD8Z4B (+ (get-balance 'SP13X1GXDCPXZWZGVBBPQEYY6A7NSXCB4XSYD8Z4B) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u29) 'SPXFQBMJEYNN4AE861EK9HAH95FZ8PJMT0ZYAW22))
      (map-set token-count 'SPXFQBMJEYNN4AE861EK9HAH95FZ8PJMT0ZYAW22 (+ (get-balance 'SPXFQBMJEYNN4AE861EK9HAH95FZ8PJMT0ZYAW22) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u30) 'SP137ERCZPW5T2D1YHHRFWJNQ9Z12RT8KD4EW4YA2))
      (map-set token-count 'SP137ERCZPW5T2D1YHHRFWJNQ9Z12RT8KD4EW4YA2 (+ (get-balance 'SP137ERCZPW5T2D1YHHRFWJNQ9Z12RT8KD4EW4YA2) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u31) 'SP3JY65HJ2NTR2AEY3CBTSZ9JX2G5W489V1DFZ1BF))
      (map-set token-count 'SP3JY65HJ2NTR2AEY3CBTSZ9JX2G5W489V1DFZ1BF (+ (get-balance 'SP3JY65HJ2NTR2AEY3CBTSZ9JX2G5W489V1DFZ1BF) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u32) 'SP2RNHHQDTHGHPEVX83291K4AQZVGWEJ7WCQQDA9R))
      (map-set token-count 'SP2RNHHQDTHGHPEVX83291K4AQZVGWEJ7WCQQDA9R (+ (get-balance 'SP2RNHHQDTHGHPEVX83291K4AQZVGWEJ7WCQQDA9R) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u33) 'SPBNZD0NMBJVRYJZ3SJ4MTRSZ3FEMGGTV2YM5MFV))
      (map-set token-count 'SPBNZD0NMBJVRYJZ3SJ4MTRSZ3FEMGGTV2YM5MFV (+ (get-balance 'SPBNZD0NMBJVRYJZ3SJ4MTRSZ3FEMGGTV2YM5MFV) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u34) 'SP2VTPR418ZMA20KNRKWVVK3VHD73WKW65ZX065Y8))
      (map-set token-count 'SP2VTPR418ZMA20KNRKWVVK3VHD73WKW65ZX065Y8 (+ (get-balance 'SP2VTPR418ZMA20KNRKWVVK3VHD73WKW65ZX065Y8) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u35) 'SP2Z2CBMGWB9MQZAF5Z8X56KS69XRV3SJF4WKJ7J9))
      (map-set token-count 'SP2Z2CBMGWB9MQZAF5Z8X56KS69XRV3SJF4WKJ7J9 (+ (get-balance 'SP2Z2CBMGWB9MQZAF5Z8X56KS69XRV3SJF4WKJ7J9) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u36) 'SP1QJ9RXZ396BTM57R3ZPQ1B98H81WB80SP7H4EXV))
      (map-set token-count 'SP1QJ9RXZ396BTM57R3ZPQ1B98H81WB80SP7H4EXV (+ (get-balance 'SP1QJ9RXZ396BTM57R3ZPQ1B98H81WB80SP7H4EXV) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u37) 'SP2V42A0NYSA3ZBT1KJ6GFV14F5A3WWNYP969HHVB))
      (map-set token-count 'SP2V42A0NYSA3ZBT1KJ6GFV14F5A3WWNYP969HHVB (+ (get-balance 'SP2V42A0NYSA3ZBT1KJ6GFV14F5A3WWNYP969HHVB) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u38) 'SPN8S712Z25ZS0KNNS0KKXRN6C5X4N6YZ85SAFBP))
      (map-set token-count 'SPN8S712Z25ZS0KNNS0KKXRN6C5X4N6YZ85SAFBP (+ (get-balance 'SPN8S712Z25ZS0KNNS0KKXRN6C5X4N6YZ85SAFBP) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u39) 'SP2ZE0FGQFZPJSP366H158Z5WB7XQ2T79KZSDRZP5))
      (map-set token-count 'SP2ZE0FGQFZPJSP366H158Z5WB7XQ2T79KZSDRZP5 (+ (get-balance 'SP2ZE0FGQFZPJSP366H158Z5WB7XQ2T79KZSDRZP5) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u40) 'SPHW2P7GW93HC8882X8NBM4FR53HJ7E3QXSVT7DE))
      (map-set token-count 'SPHW2P7GW93HC8882X8NBM4FR53HJ7E3QXSVT7DE (+ (get-balance 'SPHW2P7GW93HC8882X8NBM4FR53HJ7E3QXSVT7DE) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u41) 'SP97MKMVHW0H2JP01M04P50CY6NJ0MEMC9C2VYFR))
      (map-set token-count 'SP97MKMVHW0H2JP01M04P50CY6NJ0MEMC9C2VYFR (+ (get-balance 'SP97MKMVHW0H2JP01M04P50CY6NJ0MEMC9C2VYFR) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u42) 'SP17W459944DRA4FSRE1DYTHTVZ6620WS8F24NXR9))
      (map-set token-count 'SP17W459944DRA4FSRE1DYTHTVZ6620WS8F24NXR9 (+ (get-balance 'SP17W459944DRA4FSRE1DYTHTVZ6620WS8F24NXR9) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u43) 'SP1BGCKM7JW5S2592GN7X97DZGK3DTQKSXARJGXFF))
      (map-set token-count 'SP1BGCKM7JW5S2592GN7X97DZGK3DTQKSXARJGXFF (+ (get-balance 'SP1BGCKM7JW5S2592GN7X97DZGK3DTQKSXARJGXFF) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u44) 'SP24RHXCVB64KHQ7CVJARQEZ0JZ79854JKAG3QWFH))
      (map-set token-count 'SP24RHXCVB64KHQ7CVJARQEZ0JZ79854JKAG3QWFH (+ (get-balance 'SP24RHXCVB64KHQ7CVJARQEZ0JZ79854JKAG3QWFH) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u45) 'SPXHAWVM6NYG6W2H246P0YN5MEVFS02J32KPV24Y))
      (map-set token-count 'SPXHAWVM6NYG6W2H246P0YN5MEVFS02J32KPV24Y (+ (get-balance 'SPXHAWVM6NYG6W2H246P0YN5MEVFS02J32KPV24Y) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u46) 'SP1SGVJZNK1D9THF2668AMPK7Z5VQNZ1V639JNP1W))
      (map-set token-count 'SP1SGVJZNK1D9THF2668AMPK7Z5VQNZ1V639JNP1W (+ (get-balance 'SP1SGVJZNK1D9THF2668AMPK7Z5VQNZ1V639JNP1W) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u47) 'SP870RFTKDBMC8WJ9CE89ZKVEJBGF57ZAV3T87Z1))
      (map-set token-count 'SP870RFTKDBMC8WJ9CE89ZKVEJBGF57ZAV3T87Z1 (+ (get-balance 'SP870RFTKDBMC8WJ9CE89ZKVEJBGF57ZAV3T87Z1) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u48) 'SPJNGNX5RBR9RDWWANG1AJ6A5RJKXMY32M0YK4SD))
      (map-set token-count 'SPJNGNX5RBR9RDWWANG1AJ6A5RJKXMY32M0YK4SD (+ (get-balance 'SPJNGNX5RBR9RDWWANG1AJ6A5RJKXMY32M0YK4SD) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u49) 'SPHND7R13JQ4STHBM5E130T3JDM2BYE4FN0ZM2AR))
      (map-set token-count 'SPHND7R13JQ4STHBM5E130T3JDM2BYE4FN0ZM2AR (+ (get-balance 'SPHND7R13JQ4STHBM5E130T3JDM2BYE4FN0ZM2AR) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u50) 'SPRNF9Y34TMZ5CW7WZ8YR1RTV9QX0N9E4DSH9985))
      (map-set token-count 'SPRNF9Y34TMZ5CW7WZ8YR1RTV9QX0N9E4DSH9985 (+ (get-balance 'SPRNF9Y34TMZ5CW7WZ8YR1RTV9QX0N9E4DSH9985) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u51) 'SP3KAJC6X2X15C11J85C9HMBCF11D9GM43VKFM41V))
      (map-set token-count 'SP3KAJC6X2X15C11J85C9HMBCF11D9GM43VKFM41V (+ (get-balance 'SP3KAJC6X2X15C11J85C9HMBCF11D9GM43VKFM41V) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u52) 'SP3SYA6GERCVS6W1YT1W6YBTD8CT2B3VP1D3A3QXB))
      (map-set token-count 'SP3SYA6GERCVS6W1YT1W6YBTD8CT2B3VP1D3A3QXB (+ (get-balance 'SP3SYA6GERCVS6W1YT1W6YBTD8CT2B3VP1D3A3QXB) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u53) 'SP27VK3EGRTFXKA0YBKDMHZD57AG3H4W56CMF0AWX))
      (map-set token-count 'SP27VK3EGRTFXKA0YBKDMHZD57AG3H4W56CMF0AWX (+ (get-balance 'SP27VK3EGRTFXKA0YBKDMHZD57AG3H4W56CMF0AWX) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u54) 'SP34XQ0QR06W4QHSTTA83CM582CFACNPNRG1W44T5))
      (map-set token-count 'SP34XQ0QR06W4QHSTTA83CM582CFACNPNRG1W44T5 (+ (get-balance 'SP34XQ0QR06W4QHSTTA83CM582CFACNPNRG1W44T5) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u55) 'SP2TJVMD6794VGTYS68DSQ0XA6D4GHAR8G06D0JRZ))
      (map-set token-count 'SP2TJVMD6794VGTYS68DSQ0XA6D4GHAR8G06D0JRZ (+ (get-balance 'SP2TJVMD6794VGTYS68DSQ0XA6D4GHAR8G06D0JRZ) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u56) 'SP3QDR2JEAF8108MBV8Z1K09M3QZE0KCP3H93G9FB))
      (map-set token-count 'SP3QDR2JEAF8108MBV8Z1K09M3QZE0KCP3H93G9FB (+ (get-balance 'SP3QDR2JEAF8108MBV8Z1K09M3QZE0KCP3H93G9FB) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u57) 'SPXYRKWDFKBZN3GTS3W9A1MQ0PFTFAHZGGV9V1MJ))
      (map-set token-count 'SPXYRKWDFKBZN3GTS3W9A1MQ0PFTFAHZGGV9V1MJ (+ (get-balance 'SPXYRKWDFKBZN3GTS3W9A1MQ0PFTFAHZGGV9V1MJ) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u58) 'SPVGKXW1HAHMW29VYWAAS3MS6ZMVNWXQXS0HS5Z7))
      (map-set token-count 'SPVGKXW1HAHMW29VYWAAS3MS6ZMVNWXQXS0HS5Z7 (+ (get-balance 'SPVGKXW1HAHMW29VYWAAS3MS6ZMVNWXQXS0HS5Z7) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u59) 'SP3W3WTY4RP85Y9PX23MW85HNS3GVHHD2J1HPXPEY))
      (map-set token-count 'SP3W3WTY4RP85Y9PX23MW85HNS3GVHHD2J1HPXPEY (+ (get-balance 'SP3W3WTY4RP85Y9PX23MW85HNS3GVHHD2J1HPXPEY) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u60) 'SPJ8NVC2ZVQCKB68XW1QXM6P7YJF8EYGQ2TT5QT7))
      (map-set token-count 'SPJ8NVC2ZVQCKB68XW1QXM6P7YJF8EYGQ2TT5QT7 (+ (get-balance 'SPJ8NVC2ZVQCKB68XW1QXM6P7YJF8EYGQ2TT5QT7) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u61) 'SP2ZMHZE792DEC1196H5TQBKXEHP33BBJR2WC1Q0V))
      (map-set token-count 'SP2ZMHZE792DEC1196H5TQBKXEHP33BBJR2WC1Q0V (+ (get-balance 'SP2ZMHZE792DEC1196H5TQBKXEHP33BBJR2WC1Q0V) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u62) 'SP1XQ68T3E3569YG04H45136YWA2DCANQFJJ10QH5))
      (map-set token-count 'SP1XQ68T3E3569YG04H45136YWA2DCANQFJJ10QH5 (+ (get-balance 'SP1XQ68T3E3569YG04H45136YWA2DCANQFJJ10QH5) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u63) 'SP37Q9B72W3W3AE9WFK64S5RMJ9Y7H8R8HX23PHNY))
      (map-set token-count 'SP37Q9B72W3W3AE9WFK64S5RMJ9Y7H8R8HX23PHNY (+ (get-balance 'SP37Q9B72W3W3AE9WFK64S5RMJ9Y7H8R8HX23PHNY) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u64) 'SPN4WAQ8P684M6KE7ATS3H0XTN8QSM5MVP9GBJP3))
      (map-set token-count 'SPN4WAQ8P684M6KE7ATS3H0XTN8QSM5MVP9GBJP3 (+ (get-balance 'SPN4WAQ8P684M6KE7ATS3H0XTN8QSM5MVP9GBJP3) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u65) 'SPTYNEEZE1699FS9RG0N108NHNNA92RG2415MEZY))
      (map-set token-count 'SPTYNEEZE1699FS9RG0N108NHNNA92RG2415MEZY (+ (get-balance 'SPTYNEEZE1699FS9RG0N108NHNNA92RG2415MEZY) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u66) 'SPGYC88E6PS8TYJME3DQRSVTNA5Q91Z7BXGX5JR1))
      (map-set token-count 'SPGYC88E6PS8TYJME3DQRSVTNA5Q91Z7BXGX5JR1 (+ (get-balance 'SPGYC88E6PS8TYJME3DQRSVTNA5Q91Z7BXGX5JR1) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u67) 'SP2RFCP1G667JQFSC6CK2JBTJ0HN24MVVJVFNF8B))
      (map-set token-count 'SP2RFCP1G667JQFSC6CK2JBTJ0HN24MVVJVFNF8B (+ (get-balance 'SP2RFCP1G667JQFSC6CK2JBTJ0HN24MVVJVFNF8B) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u68) 'SP24SBJMZYS9FWKQZVVDZGM595EYGRT6368ND7MEA))
      (map-set token-count 'SP24SBJMZYS9FWKQZVVDZGM595EYGRT6368ND7MEA (+ (get-balance 'SP24SBJMZYS9FWKQZVVDZGM595EYGRT6368ND7MEA) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u69) 'SP2C9HTHKWTH890N742J6EQ1ZKM9WW2CHHQYGRR10))
      (map-set token-count 'SP2C9HTHKWTH890N742J6EQ1ZKM9WW2CHHQYGRR10 (+ (get-balance 'SP2C9HTHKWTH890N742J6EQ1ZKM9WW2CHHQYGRR10) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u70) 'SP2NARFZ0DB3X5R3VW6BYSJ2MMXDSVMESCYSXS132))
      (map-set token-count 'SP2NARFZ0DB3X5R3VW6BYSJ2MMXDSVMESCYSXS132 (+ (get-balance 'SP2NARFZ0DB3X5R3VW6BYSJ2MMXDSVMESCYSXS132) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u71) 'SP1B46TPZD8Y3ETHGZYJAPHD9GHJK81K08WRB127X))
      (map-set token-count 'SP1B46TPZD8Y3ETHGZYJAPHD9GHJK81K08WRB127X (+ (get-balance 'SP1B46TPZD8Y3ETHGZYJAPHD9GHJK81K08WRB127X) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u72) 'SPG9ERDCQ5Y42WCY66M40T3F8ADV3T9XJ6EH25M0))
      (map-set token-count 'SPG9ERDCQ5Y42WCY66M40T3F8ADV3T9XJ6EH25M0 (+ (get-balance 'SPG9ERDCQ5Y42WCY66M40T3F8ADV3T9XJ6EH25M0) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u73) 'SP30037F6V96K7NKT5HJ0EGEYQR8MJS39GZBKC6A9))
      (map-set token-count 'SP30037F6V96K7NKT5HJ0EGEYQR8MJS39GZBKC6A9 (+ (get-balance 'SP30037F6V96K7NKT5HJ0EGEYQR8MJS39GZBKC6A9) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u74) 'SP147CKES3RJS6B6XCFP1A4KK8MB34ND6Y60GZW3K))
      (map-set token-count 'SP147CKES3RJS6B6XCFP1A4KK8MB34ND6Y60GZW3K (+ (get-balance 'SP147CKES3RJS6B6XCFP1A4KK8MB34ND6Y60GZW3K) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u75) 'SP3V5MXVFRZNDMSF3AS3NT8A3KWF6A9S5J2Z8BN51))
      (map-set token-count 'SP3V5MXVFRZNDMSF3AS3NT8A3KWF6A9S5J2Z8BN51 (+ (get-balance 'SP3V5MXVFRZNDMSF3AS3NT8A3KWF6A9S5J2Z8BN51) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u76) 'SPE02H03WE8QC89BA741P8B5VR9Y7Y1FE6074G33))
      (map-set token-count 'SPE02H03WE8QC89BA741P8B5VR9Y7Y1FE6074G33 (+ (get-balance 'SPE02H03WE8QC89BA741P8B5VR9Y7Y1FE6074G33) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u77) 'SP2KY7F21EWVRKJ2BQSMJTP68DDFCQ7BGKXJ50RGW))
      (map-set token-count 'SP2KY7F21EWVRKJ2BQSMJTP68DDFCQ7BGKXJ50RGW (+ (get-balance 'SP2KY7F21EWVRKJ2BQSMJTP68DDFCQ7BGKXJ50RGW) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u78) 'SP3520HMJ2B5BBKM0ZPSR1ZR2AA0490S1YF6CV8NE))
      (map-set token-count 'SP3520HMJ2B5BBKM0ZPSR1ZR2AA0490S1YF6CV8NE (+ (get-balance 'SP3520HMJ2B5BBKM0ZPSR1ZR2AA0490S1YF6CV8NE) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u79) 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC))
      (map-set token-count 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC (+ (get-balance 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u80) 'SPBWF76FHRNA9C1A6ZZ896B3XRRK5TGGW7X9A55A))
      (map-set token-count 'SPBWF76FHRNA9C1A6ZZ896B3XRRK5TGGW7X9A55A (+ (get-balance 'SPBWF76FHRNA9C1A6ZZ896B3XRRK5TGGW7X9A55A) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u81) 'SP1ERZZ0G7KERNCXQDJF4GTHCF8DGZB8001YCNPQG))
      (map-set token-count 'SP1ERZZ0G7KERNCXQDJF4GTHCF8DGZB8001YCNPQG (+ (get-balance 'SP1ERZZ0G7KERNCXQDJF4GTHCF8DGZB8001YCNPQG) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u82) 'SPGCGE542GF02V9XZHW6F5F4NMVX7TKH2GYYBV0H))
      (map-set token-count 'SPGCGE542GF02V9XZHW6F5F4NMVX7TKH2GYYBV0H (+ (get-balance 'SPGCGE542GF02V9XZHW6F5F4NMVX7TKH2GYYBV0H) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u83) 'SP1J0HBZT8V3H6JA31C36YKRV50V3B715QXQV5KMY))
      (map-set token-count 'SP1J0HBZT8V3H6JA31C36YKRV50V3B715QXQV5KMY (+ (get-balance 'SP1J0HBZT8V3H6JA31C36YKRV50V3B715QXQV5KMY) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u84) 'SP2EK6MPWJYXM0JE3K19AWCDT0041DFPMJERAPP9Y))
      (map-set token-count 'SP2EK6MPWJYXM0JE3K19AWCDT0041DFPMJERAPP9Y (+ (get-balance 'SP2EK6MPWJYXM0JE3K19AWCDT0041DFPMJERAPP9Y) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u85) 'SP9P9T6JQE5VMKP7Y42E0XKET3V15CBXQ7JRYKX3))
      (map-set token-count 'SP9P9T6JQE5VMKP7Y42E0XKET3V15CBXQ7JRYKX3 (+ (get-balance 'SP9P9T6JQE5VMKP7Y42E0XKET3V15CBXQ7JRYKX3) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u86) 'SP1WTYJ55A644A73EQ88NMKSV1QVD9GSR35KKK9XW))
      (map-set token-count 'SP1WTYJ55A644A73EQ88NMKSV1QVD9GSR35KKK9XW (+ (get-balance 'SP1WTYJ55A644A73EQ88NMKSV1QVD9GSR35KKK9XW) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u87) 'SP28C5CG7188BSY496MM096Y80HQ9R94EDK0DMNKS))
      (map-set token-count 'SP28C5CG7188BSY496MM096Y80HQ9R94EDK0DMNKS (+ (get-balance 'SP28C5CG7188BSY496MM096Y80HQ9R94EDK0DMNKS) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u88) 'SPZHEKHK7FYP9J4Q8V2QFS0J5YJXH070K6Q5RGBP))
      (map-set token-count 'SPZHEKHK7FYP9J4Q8V2QFS0J5YJXH070K6Q5RGBP (+ (get-balance 'SPZHEKHK7FYP9J4Q8V2QFS0J5YJXH070K6Q5RGBP) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u89) 'SP3AR9RYFBGAWB9WSFZ2EF9J9K8F7MNHS1N6A0B3V))
      (map-set token-count 'SP3AR9RYFBGAWB9WSFZ2EF9J9K8F7MNHS1N6A0B3V (+ (get-balance 'SP3AR9RYFBGAWB9WSFZ2EF9J9K8F7MNHS1N6A0B3V) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u90) 'SP38JXDVKPJPV7GCDR1K9MCQYAWKJTQ7YF0S3F3F5))
      (map-set token-count 'SP38JXDVKPJPV7GCDR1K9MCQYAWKJTQ7YF0S3F3F5 (+ (get-balance 'SP38JXDVKPJPV7GCDR1K9MCQYAWKJTQ7YF0S3F3F5) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u91) 'SP2NTZ5ABMMMX1KYEHK3KYK5ZV6FKWV01CXRNYT44))
      (map-set token-count 'SP2NTZ5ABMMMX1KYEHK3KYK5ZV6FKWV01CXRNYT44 (+ (get-balance 'SP2NTZ5ABMMMX1KYEHK3KYK5ZV6FKWV01CXRNYT44) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u92) 'SP178EJKN4PTZ5P4HERE7ZWHWKZ36ZFQ9AVG48WA1))
      (map-set token-count 'SP178EJKN4PTZ5P4HERE7ZWHWKZ36ZFQ9AVG48WA1 (+ (get-balance 'SP178EJKN4PTZ5P4HERE7ZWHWKZ36ZFQ9AVG48WA1) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u93) 'SP2PZYA27E8MRBQHQXE0JQH5CHM9JJNM00YEMC4QJ))
      (map-set token-count 'SP2PZYA27E8MRBQHQXE0JQH5CHM9JJNM00YEMC4QJ (+ (get-balance 'SP2PZYA27E8MRBQHQXE0JQH5CHM9JJNM00YEMC4QJ) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u94) 'SP29RT33FYJRARYVYC9Y8DRP5545JFBQR1RG3R8MP))
      (map-set token-count 'SP29RT33FYJRARYVYC9Y8DRP5545JFBQR1RG3R8MP (+ (get-balance 'SP29RT33FYJRARYVYC9Y8DRP5545JFBQR1RG3R8MP) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u95) 'SPPB155Z73HHGF2EDE1FPZDEM0NY65PTMQK17W75))
      (map-set token-count 'SPPB155Z73HHGF2EDE1FPZDEM0NY65PTMQK17W75 (+ (get-balance 'SPPB155Z73HHGF2EDE1FPZDEM0NY65PTMQK17W75) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u96) 'SPG11NZEC2ZP77YWZPWP87C5VCDH1QW1XQDDXEEA))
      (map-set token-count 'SPG11NZEC2ZP77YWZPWP87C5VCDH1QW1XQDDXEEA (+ (get-balance 'SPG11NZEC2ZP77YWZPWP87C5VCDH1QW1XQDDXEEA) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u97) 'SP3RMH088VYVSV7J9NHMT94RFZPJQ248ZA6JT39QN))
      (map-set token-count 'SP3RMH088VYVSV7J9NHMT94RFZPJQ248ZA6JT39QN (+ (get-balance 'SP3RMH088VYVSV7J9NHMT94RFZPJQ248ZA6JT39QN) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u98) 'SP17XZYZC68K0HBS0FCQG01TTYNFE6TKZKTFN0NYF))
      (map-set token-count 'SP17XZYZC68K0HBS0FCQG01TTYNFE6TKZKTFN0NYF (+ (get-balance 'SP17XZYZC68K0HBS0FCQG01TTYNFE6TKZKTFN0NYF) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u99) 'SP158ZQV0JCYJCRGDMJ67ZG8N80DHCMHW4HD7BZT8))
      (map-set token-count 'SP158ZQV0JCYJCRGDMJ67ZG8N80DHCMHW4HD7BZT8 (+ (get-balance 'SP158ZQV0JCYJCRGDMJ67ZG8N80DHCMHW4HD7BZT8) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u100) 'SPJKX159HMEBKNS46Q58YG8M67SBRT99JRS34J3W))
      (map-set token-count 'SPJKX159HMEBKNS46Q58YG8M67SBRT99JRS34J3W (+ (get-balance 'SPJKX159HMEBKNS46Q58YG8M67SBRT99JRS34J3W) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u101) 'SP2W4453M1WRZ8YKEM70VSRQW7WNTT3ZG476ZF3J7))
      (map-set token-count 'SP2W4453M1WRZ8YKEM70VSRQW7WNTT3ZG476ZF3J7 (+ (get-balance 'SP2W4453M1WRZ8YKEM70VSRQW7WNTT3ZG476ZF3J7) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u102) 'SP2HRHR8HN94TMHGK7N10WTY90B1C4FPNDTDDWGB8))
      (map-set token-count 'SP2HRHR8HN94TMHGK7N10WTY90B1C4FPNDTDDWGB8 (+ (get-balance 'SP2HRHR8HN94TMHGK7N10WTY90B1C4FPNDTDDWGB8) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u103) 'SPFAZB03031PQZ49BTB0RDF3HFNGNKBKEDNZTRHF))
      (map-set token-count 'SPFAZB03031PQZ49BTB0RDF3HFNGNKBKEDNZTRHF (+ (get-balance 'SPFAZB03031PQZ49BTB0RDF3HFNGNKBKEDNZTRHF) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u104) 'SP2T5FAE7M1Q4H0DJQ2E7DH1BWH2FG4XDMYSD25KB))
      (map-set token-count 'SP2T5FAE7M1Q4H0DJQ2E7DH1BWH2FG4XDMYSD25KB (+ (get-balance 'SP2T5FAE7M1Q4H0DJQ2E7DH1BWH2FG4XDMYSD25KB) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u105) 'SPQAATW0PRFYJF7FHJDQ0RPGSMJZYP93VZPBA7NF))
      (map-set token-count 'SPQAATW0PRFYJF7FHJDQ0RPGSMJZYP93VZPBA7NF (+ (get-balance 'SPQAATW0PRFYJF7FHJDQ0RPGSMJZYP93VZPBA7NF) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u106) 'SPR9DNZPFNKN05FH9XAZW8N5HQA1ECQX89W7K5T6))
      (map-set token-count 'SPR9DNZPFNKN05FH9XAZW8N5HQA1ECQX89W7K5T6 (+ (get-balance 'SPR9DNZPFNKN05FH9XAZW8N5HQA1ECQX89W7K5T6) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u107) 'SP2XHY6EECE1BGY1R9JRW5E7RY2A8GT7Q5F3MH2DB))
      (map-set token-count 'SP2XHY6EECE1BGY1R9JRW5E7RY2A8GT7Q5F3MH2DB (+ (get-balance 'SP2XHY6EECE1BGY1R9JRW5E7RY2A8GT7Q5F3MH2DB) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u108) 'SP4ZN7DDDCH8317T2X1XFVN69VW07QEBFQYSV1CG))
      (map-set token-count 'SP4ZN7DDDCH8317T2X1XFVN69VW07QEBFQYSV1CG (+ (get-balance 'SP4ZN7DDDCH8317T2X1XFVN69VW07QEBFQYSV1CG) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u109) 'SP17A8R1JVAMC9HXDT2WKFPT5029782SSZ9BWD7ZN))
      (map-set token-count 'SP17A8R1JVAMC9HXDT2WKFPT5029782SSZ9BWD7ZN (+ (get-balance 'SP17A8R1JVAMC9HXDT2WKFPT5029782SSZ9BWD7ZN) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u110) 'SP3RCHWAEVHVRFJ9P6TR9A8EA22DD25C5F3P6N00Y))
      (map-set token-count 'SP3RCHWAEVHVRFJ9P6TR9A8EA22DD25C5F3P6N00Y (+ (get-balance 'SP3RCHWAEVHVRFJ9P6TR9A8EA22DD25C5F3P6N00Y) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u111) 'SP358B55KFVWX034VQJ4BGQ9QV9EGRC59NES0X162))
      (map-set token-count 'SP358B55KFVWX034VQJ4BGQ9QV9EGRC59NES0X162 (+ (get-balance 'SP358B55KFVWX034VQJ4BGQ9QV9EGRC59NES0X162) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u112) 'SPDYC80PMR39KD2TA7WSSS0D9KKKG3GT1FEVK129))
      (map-set token-count 'SPDYC80PMR39KD2TA7WSSS0D9KKKG3GT1FEVK129 (+ (get-balance 'SPDYC80PMR39KD2TA7WSSS0D9KKKG3GT1FEVK129) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u113) 'SP2YDZB938V1QNSRN2XCCP8YTWEXVC89HK9DFYDCP))
      (map-set token-count 'SP2YDZB938V1QNSRN2XCCP8YTWEXVC89HK9DFYDCP (+ (get-balance 'SP2YDZB938V1QNSRN2XCCP8YTWEXVC89HK9DFYDCP) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u114) 'SP68V1SQXGBDVKEQFXP23TCJ55808PW22Q69FGZQ))
      (map-set token-count 'SP68V1SQXGBDVKEQFXP23TCJ55808PW22Q69FGZQ (+ (get-balance 'SP68V1SQXGBDVKEQFXP23TCJ55808PW22Q69FGZQ) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u115) 'SPR907PMYHKNDT5R0ZXTZ6C6HE80PAWMZD3T3N8R))
      (map-set token-count 'SPR907PMYHKNDT5R0ZXTZ6C6HE80PAWMZD3T3N8R (+ (get-balance 'SPR907PMYHKNDT5R0ZXTZ6C6HE80PAWMZD3T3N8R) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u116) 'SPXBNBJBZAQ8YAYS60BAR1280KG2S04HQ7W3YY45))
      (map-set token-count 'SPXBNBJBZAQ8YAYS60BAR1280KG2S04HQ7W3YY45 (+ (get-balance 'SPXBNBJBZAQ8YAYS60BAR1280KG2S04HQ7W3YY45) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u117) 'SP15QV0JWGQX0Y6QCWN4EMQSPNR9XZ5DEH2DA5S7T))
      (map-set token-count 'SP15QV0JWGQX0Y6QCWN4EMQSPNR9XZ5DEH2DA5S7T (+ (get-balance 'SP15QV0JWGQX0Y6QCWN4EMQSPNR9XZ5DEH2DA5S7T) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u118) 'SP8364EWR7EH1VKYTDAFCD89RSQSJP70WCHS673K))
      (map-set token-count 'SP8364EWR7EH1VKYTDAFCD89RSQSJP70WCHS673K (+ (get-balance 'SP8364EWR7EH1VKYTDAFCD89RSQSJP70WCHS673K) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u119) 'SP3EZ7K6XXY642N757AZJN7DN4ZFF0TDV2VQBGHP1))
      (map-set token-count 'SP3EZ7K6XXY642N757AZJN7DN4ZFF0TDV2VQBGHP1 (+ (get-balance 'SP3EZ7K6XXY642N757AZJN7DN4ZFF0TDV2VQBGHP1) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u120) 'SP3SZPQCM9C52GPQB9NR6MDVWFFAAV4M2QM1WN833))
      (map-set token-count 'SP3SZPQCM9C52GPQB9NR6MDVWFFAAV4M2QM1WN833 (+ (get-balance 'SP3SZPQCM9C52GPQB9NR6MDVWFFAAV4M2QM1WN833) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u121) 'SP1MG3AYM38PQ1YQ7FMW1VWV6S869VZT9963AZE6X))
      (map-set token-count 'SP1MG3AYM38PQ1YQ7FMW1VWV6S869VZT9963AZE6X (+ (get-balance 'SP1MG3AYM38PQ1YQ7FMW1VWV6S869VZT9963AZE6X) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u122) 'SP93C8R93B6QSEAYDEJHXHKYN5CDM6K9W6JNEY7K))
      (map-set token-count 'SP93C8R93B6QSEAYDEJHXHKYN5CDM6K9W6JNEY7K (+ (get-balance 'SP93C8R93B6QSEAYDEJHXHKYN5CDM6K9W6JNEY7K) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u123) 'SPV5G03D20EH8ND37NS19EP7D2GG2H5HE0HDW8P3))
      (map-set token-count 'SPV5G03D20EH8ND37NS19EP7D2GG2H5HE0HDW8P3 (+ (get-balance 'SPV5G03D20EH8ND37NS19EP7D2GG2H5HE0HDW8P3) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u124) 'SPNFDGPASBB91FVB0FCRAZ0XCPSSZ4Y56M2AEWDZ))
      (map-set token-count 'SPNFDGPASBB91FVB0FCRAZ0XCPSSZ4Y56M2AEWDZ (+ (get-balance 'SPNFDGPASBB91FVB0FCRAZ0XCPSSZ4Y56M2AEWDZ) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u125) 'SP2ZMHZE792DEC1196H5TQBKXEHP33BBJR2WC1Q0V))
      (map-set token-count 'SP2ZMHZE792DEC1196H5TQBKXEHP33BBJR2WC1Q0V (+ (get-balance 'SP2ZMHZE792DEC1196H5TQBKXEHP33BBJR2WC1Q0V) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u126) 'SP250T71VBB3HR5GDY4D0K3JXPF46YMTZJ1AJAJ1T))
      (map-set token-count 'SP250T71VBB3HR5GDY4D0K3JXPF46YMTZJ1AJAJ1T (+ (get-balance 'SP250T71VBB3HR5GDY4D0K3JXPF46YMTZJ1AJAJ1T) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u127) 'SP3ANWJVVKYEH20BRCHZZDD45ZJGZM9Q1CKXKD9NF))
      (map-set token-count 'SP3ANWJVVKYEH20BRCHZZDD45ZJGZM9Q1CKXKD9NF (+ (get-balance 'SP3ANWJVVKYEH20BRCHZZDD45ZJGZM9Q1CKXKD9NF) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u128) 'SP38C4PCSDNSXD50PE28BM9NNTQ0J2CZ3D190M1XD))
      (map-set token-count 'SP38C4PCSDNSXD50PE28BM9NNTQ0J2CZ3D190M1XD (+ (get-balance 'SP38C4PCSDNSXD50PE28BM9NNTQ0J2CZ3D190M1XD) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u129) 'SP1HFD9VDE9BH6S65F3T8ZBBNJ5PBJM87PAF6KPKN))
      (map-set token-count 'SP1HFD9VDE9BH6S65F3T8ZBBNJ5PBJM87PAF6KPKN (+ (get-balance 'SP1HFD9VDE9BH6S65F3T8ZBBNJ5PBJM87PAF6KPKN) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u130) 'SP1NXT9A2S1MQ866SYC5DM1Q7P3EZ1Y2566QCKPPZ))
      (map-set token-count 'SP1NXT9A2S1MQ866SYC5DM1Q7P3EZ1Y2566QCKPPZ (+ (get-balance 'SP1NXT9A2S1MQ866SYC5DM1Q7P3EZ1Y2566QCKPPZ) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u131) 'SPKMJBHD0P3DT5QPQ40WY3XPV6FV1PPP747AS7J2))
      (map-set token-count 'SPKMJBHD0P3DT5QPQ40WY3XPV6FV1PPP747AS7J2 (+ (get-balance 'SPKMJBHD0P3DT5QPQ40WY3XPV6FV1PPP747AS7J2) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u132) 'SP2KYTW30AB40H686SWEHGFRXA0JM6VPFM45HRD2Y))
      (map-set token-count 'SP2KYTW30AB40H686SWEHGFRXA0JM6VPFM45HRD2Y (+ (get-balance 'SP2KYTW30AB40H686SWEHGFRXA0JM6VPFM45HRD2Y) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u133) 'SP3KPNX78R18997ME6K4PFJ21851P1DG5SAZEFRVF))
      (map-set token-count 'SP3KPNX78R18997ME6K4PFJ21851P1DG5SAZEFRVF (+ (get-balance 'SP3KPNX78R18997ME6K4PFJ21851P1DG5SAZEFRVF) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u134) 'SP1KD2BS98HCAEZQB3A4AXNS2KNAFTXF2CTJBQWF6))
      (map-set token-count 'SP1KD2BS98HCAEZQB3A4AXNS2KNAFTXF2CTJBQWF6 (+ (get-balance 'SP1KD2BS98HCAEZQB3A4AXNS2KNAFTXF2CTJBQWF6) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u135) 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC))
      (map-set token-count 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC (+ (get-balance 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u136) 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC))
      (map-set token-count 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC (+ (get-balance 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u137) 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC))
      (map-set token-count 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC (+ (get-balance 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u138) 'SPCF0W0KGA71B99D7Y271HJTVWJER4YWNWK1P6SQ))
      (map-set token-count 'SPCF0W0KGA71B99D7Y271HJTVWJER4YWNWK1P6SQ (+ (get-balance 'SPCF0W0KGA71B99D7Y271HJTVWJER4YWNWK1P6SQ) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u139) 'SP2EGFCE7C8D10BX55PSSXEM6C9W0MAX86FDEBC8S))
      (map-set token-count 'SP2EGFCE7C8D10BX55PSSXEM6C9W0MAX86FDEBC8S (+ (get-balance 'SP2EGFCE7C8D10BX55PSSXEM6C9W0MAX86FDEBC8S) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u140) 'SP31G3S6QQ62RKF96FJ9QZQ4Z47AEBZTWRVDJCK1Y))
      (map-set token-count 'SP31G3S6QQ62RKF96FJ9QZQ4Z47AEBZTWRVDJCK1Y (+ (get-balance 'SP31G3S6QQ62RKF96FJ9QZQ4Z47AEBZTWRVDJCK1Y) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u141) 'SP3C730EGZBZYVEE03D4K2PRKVVAPQDVB49RFVVMZ))
      (map-set token-count 'SP3C730EGZBZYVEE03D4K2PRKVVAPQDVB49RFVVMZ (+ (get-balance 'SP3C730EGZBZYVEE03D4K2PRKVVAPQDVB49RFVVMZ) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u142) 'SP33QYJHG988R7XD10B5MPKG7NCWQJ77ETKMA2HK4))
      (map-set token-count 'SP33QYJHG988R7XD10B5MPKG7NCWQJ77ETKMA2HK4 (+ (get-balance 'SP33QYJHG988R7XD10B5MPKG7NCWQJ77ETKMA2HK4) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u143) 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE))
      (map-set token-count 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE (+ (get-balance 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u144) 'SP31D40V6DGQ02M1GRZJKKPCTQB8DZKXZVR0CT388))
      (map-set token-count 'SP31D40V6DGQ02M1GRZJKKPCTQB8DZKXZVR0CT388 (+ (get-balance 'SP31D40V6DGQ02M1GRZJKKPCTQB8DZKXZVR0CT388) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u145) 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC))
      (map-set token-count 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC (+ (get-balance 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u146) 'SPR6K4VQ0JQN677W4GGCN5JTPN7XF7YTP7WKAJXH))
      (map-set token-count 'SPR6K4VQ0JQN677W4GGCN5JTPN7XF7YTP7WKAJXH (+ (get-balance 'SPR6K4VQ0JQN677W4GGCN5JTPN7XF7YTP7WKAJXH) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u147) 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C))
      (map-set token-count 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C (+ (get-balance 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u148) 'SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY))
      (map-set token-count 'SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY (+ (get-balance 'SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY) u1))
      (try! (nft-mint? welsh-dreamers (+ last-nft-id u149) 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC))
      (map-set token-count 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC (+ (get-balance 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC) u1))

      (var-set last-id (+ last-nft-id u150))
      (var-set airdrop-called true)
      (ok true))))
```
