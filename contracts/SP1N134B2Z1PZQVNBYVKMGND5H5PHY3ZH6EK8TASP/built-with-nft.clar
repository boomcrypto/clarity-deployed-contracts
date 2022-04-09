;; builtwithnft

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token builtwithnft uint)

;; Constants
(define-constant DEPLOYER tx-sender)

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

;; Internal variables
(define-data-var mint-limit uint u10000)
(define-data-var last-id uint u5001)
(define-data-var total-price uint u85000000)
(define-data-var artist-address principal 'SP1N134B2Z1PZQVNBYVKMGND5H5PHY3ZH6EK8TASP)
(define-data-var ipfs-root (string-ascii 80) "https://api.builtwithnft.org/token/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool true)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u0)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

(define-public (claim) 
  (mint (list true)))

(define-public (claim-two) 
  (mint (list true true)))

(define-public (claim-three) (mint (list true true true)))

(define-public (claim-five) (mint (list true true true true true)))

(define-public (claim-ten) (mint (list true true true true true true true true true true)))

(define-public (claim-twentyfive)
  (mint-many (list true true true true true true true true true true
                   true true true true true true true true true true 
                   true true true true true))
)

(define-public (claim-fifty)
  (mint-many (list true true true true true true true true true true
                   true true true true true true true true true true
                   true true true true true true true true true true
                   true true true true true true true true true true
                   true true true true true true true true true true))
)

;; Mintpass Minting
(define-private (mint (orders (list 50 bool)))
  (let 
    (
      (passes (get-passes tx-sender))
    )
    (if (var-get premint-enabled)
      (begin
        (asserts! (>= passes (len orders)) (err ERR-NOT-ENOUGH-PASSES))
        (map-set mint-passes tx-sender (- passes (len orders)))
        (mint-many orders)
      )
      (begin
        (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
        (mint-many orders)
      )
    )))

(define-private (mint-many (orders (list 50 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price) (- id-reached last-nft-id)))
      (current-balance (get-balance tx-sender))
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
        (try! (stx-transfer? price tx-sender (var-get artist-address)))
      )    
    )
    (ok id-reached)))

(define-private (mint-many-iter (ignore bool) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? builtwithnft next-id tx-sender) next-id)
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
    (nft-burn? builtwithnft token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? builtwithnft token-id) false)))

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

;; Non-custodial SIP-009 transfer function
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? builtwithnft token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (var-get ipfs-root) "{id}"))))

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-price)
  (ok (var-get total-price)))

(define-read-only (get-mints (caller principal))
  (default-to u0 (map-get? mints-per-user caller)))

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

;; Non-custodial marketplace extras
(define-trait commission-trait
  ((pay (uint uint) (response bool uint))))

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? builtwithnft id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? builtwithnft id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? builtwithnft id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))

;; Extra functionality required for mintpass
(define-public (toggle-sale-state)
  (let 
    (
      ;; (premint (not (var-get premint-enabled)))
      (sale (not (var-get sale-enabled)))
    )
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set premint-enabled false)
    (var-set sale-enabled sale)
    (print { sale: sale })
    (ok true)))

(define-public (enable-premint)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set premint-enabled true))))

(define-public (disable-premint)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set premint-enabled false))))

(define-read-only (get-passes (caller principal))
  (default-to u0 (map-get? mint-passes caller)))

(define-read-only (get-premint-enabled)
  (ok (var-get premint-enabled)))

(define-read-only (get-sale-enabled)
  (ok (var-get sale-enabled)))  

(claim-ten)
(claim-ten)
(claim-ten)
(claim-ten)
(claim-five)
(transfer u5001 tx-sender 'SP1JCPNPAMAQJ364AFHPTW3HY7X0HYZ3TJ0ZDGWZH)
(transfer u5002 tx-sender 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6)
(transfer u5003 tx-sender 'SP1P4KFDR0BJSDAN5176ZR5642QGMAE310M6JHTAW)
(transfer u5004 tx-sender 'SP2QKSYRXDT39F4BY5D8A021WNQ6S7P0NJDSVWTQY)
(transfer u5005 tx-sender 'SP1JCPNPAMAQJ364AFHPTW3HY7X0HYZ3TJ0ZDGWZH)
(transfer u5006 tx-sender 'SP1CMZCXP4D5BPTXGDEGHE008WTYVECS02WWB2KGM)
(transfer u5007 tx-sender 'SP1JCPNPAMAQJ364AFHPTW3HY7X0HYZ3TJ0ZDGWZH)
(transfer u5008 tx-sender 'SP1J5W1FN3P80XV1YK14BKC6A912WWFGJSW9M92HA)
(transfer u5009 tx-sender 'SP1J5W1FN3P80XV1YK14BKC6A912WWFGJSW9M92HA)
(transfer u5010 tx-sender 'SP1J5W1FN3P80XV1YK14BKC6A912WWFGJSW9M92HA)
(transfer u5011 tx-sender 'SP1J5W1FN3P80XV1YK14BKC6A912WWFGJSW9M92HA)
(transfer u5012 tx-sender 'SP1J5W1FN3P80XV1YK14BKC6A912WWFGJSW9M92HA)
(transfer u5013 tx-sender 'SP2NHZDAMMEEASE4DKHYYCVAG8RF8PA7YHPPW40BX)
(transfer u5014 tx-sender 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD)
(transfer u5015 tx-sender 'SP1G7B9MKFAX1E09HJSTRBSBBTJ9ZTDW9921X5JZV)
(transfer u5016 tx-sender 'SP1G7B9MKFAX1E09HJSTRBSBBTJ9ZTDW9921X5JZV)
(transfer u5017 tx-sender 'SP1G7B9MKFAX1E09HJSTRBSBBTJ9ZTDW9921X5JZV)
(transfer u5018 tx-sender 'SP1G7B9MKFAX1E09HJSTRBSBBTJ9ZTDW9921X5JZV)
(transfer u5019 tx-sender 'SP1G7B9MKFAX1E09HJSTRBSBBTJ9ZTDW9921X5JZV)
(transfer u5020 tx-sender 'SPP5HXFRZVANS3TGERYQKXHANA7TZZGZYJHBFN13)
(transfer u5021 tx-sender 'SPP5HXFRZVANS3TGERYQKXHANA7TZZGZYJHBFN13)
(transfer u5022 tx-sender 'SPP5HXFRZVANS3TGERYQKXHANA7TZZGZYJHBFN13)
(transfer u5023 tx-sender 'SPP5HXFRZVANS3TGERYQKXHANA7TZZGZYJHBFN13)
(transfer u5024 tx-sender 'SPP5HXFRZVANS3TGERYQKXHANA7TZZGZYJHBFN13)
(transfer u5025 tx-sender 'SPP5HXFRZVANS3TGERYQKXHANA7TZZGZYJHBFN13)
(transfer u5026 tx-sender 'SPP5HXFRZVANS3TGERYQKXHANA7TZZGZYJHBFN13)
(transfer u5027 tx-sender 'SPP5HXFRZVANS3TGERYQKXHANA7TZZGZYJHBFN13)
(transfer u5028 tx-sender 'SPP5HXFRZVANS3TGERYQKXHANA7TZZGZYJHBFN13)
(transfer u5029 tx-sender 'SPP5HXFRZVANS3TGERYQKXHANA7TZZGZYJHBFN13)
(transfer u5030 tx-sender 'SP2K8K42BWZJAS1ZFGACBWZVS5Y6VQEYMQCYRHZ90)
(transfer u5031 tx-sender 'SP3SQCH6QVEH8T3BNGFH17PJ8VZW8Z96CFMG4T07A)
(transfer u5032 tx-sender 'SP143YHR805B8S834BWJTMZVFR1WP5FFC03WZE4BF)
(transfer u5033 tx-sender 'SP3SQCH6QVEH8T3BNGFH17PJ8VZW8Z96CFMG4T07A)
(transfer u5034 tx-sender 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ)
(transfer u5035 tx-sender 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ)
(transfer u5036 tx-sender 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ)
(transfer u5037 tx-sender 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ)
(transfer u5038 tx-sender 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ)
(transfer u5039 tx-sender 'SP34XEPDJJFJKFPT87CCZQCPGXR4PJ8ERFVQETKZ4)
(transfer u5040 tx-sender 'SP34XEPDJJFJKFPT87CCZQCPGXR4PJ8ERFVQETKZ4)
(transfer u5041 tx-sender 'SP34XEPDJJFJKFPT87CCZQCPGXR4PJ8ERFVQETKZ4)
(transfer u5042 tx-sender 'SPAEDT82ZCE7S87HS0X7ZCF4G60XB2X05SC2VRKZ)
(transfer u5043 tx-sender 'SP3TA5AJCJ2W58JV9VHAKD17DA739Y195QNQV7QG5)
(transfer u5044 tx-sender 'SP1X11HKCJ46PT9GSRS1PRYA53NB1VZ5P2B7KGASE)
(transfer u5045 tx-sender 'SP12BEEDG31J0AH68DFDJJYZ36D002PKDZCP1DZQE)
