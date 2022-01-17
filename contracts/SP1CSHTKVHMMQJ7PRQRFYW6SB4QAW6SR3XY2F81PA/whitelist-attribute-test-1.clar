;; whitelist-attribute-test-1

;; testnet
;; (impl-trait 'ST1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XZ54PKG7.nft-trait.nft-trait)
;; mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token whitelist-attribute-test-1 uint)

;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant COMM u1000)
(define-constant COMM_ADDR 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)

(define-constant ERR_NOT_ENOUGH_PASSES u300)
(define-constant ERR_PUBLIC_SALE_DISABLED u301)
(define-constant ERR_CONTRACT_INITIALIZED u302)
(define-constant ERR_UNAUTHORIZED u302)
(define-constant ERR-NO-MORE-NFTS u304)
(define-constant ERR-INVALID-USER u500)
(define-constant ERR-MINT u600)

;; Internal variables
(define-map mint-passes principal uint)

(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)

(define-data-var mint-limit uint u10)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0000000)
(define-data-var artist-address principal 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmNn8pegrNpDruubsXTqbt41t5Z7mQcJuceu9iUnDVCFxG/json/")

(define-public (claim)
    (mint (list true))
)

(define-public (claim-three)
    (mint (list true true true))
)

(define-public (claim-five)
    (mint (list true true true true true))
)

(define-public (claim-ten)
    (mint (list true true true true true true true true true true))
)

(define-private (mint (orders (list 10 bool)))
    (let 
        (
            (passes (get-passes tx-sender))
        )
        (if (var-get premint-enabled)
            (begin
                (asserts! (>= passes (len orders)) (err ERR_NOT_ENOUGH_PASSES))
                (map-set mint-passes tx-sender (- passes (len orders)))
                (mint-many orders)
            )
            (begin
                (asserts! (var-get sale-enabled) (err ERR_PUBLIC_SALE_DISABLED))
                (mint-many orders)
            )
        )
    )
)

(define-private (mint-many (orders (list 10 bool )))  
  (let (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price) (- id-reached last-nft-id)))
      (total-commission (/ (* price COMM) u10000))
      (total-artist (- price total-commission))
    )
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER))
      (var-set last-id id-reached)
      (begin
        (var-set last-id id-reached)
        (try! (stx-transfer? total-artist tx-sender (var-get artist-address)))
        (try! (stx-transfer? total-commission tx-sender COMM_ADDR))
      )    
    )
    (ok id-reached)
  )
)

(define-private (mint-many-iter (ignore bool) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? whitelist-attribute-test-1 next-id tx-sender) next-id)
      (+ next-id u1)    
    )
    next-id
  )
)

(define-public (toggle-sale-state)
    (let 
        (
          (premint (not (var-get premint-enabled)))
          (sale (not (var-get sale-enabled)))
        )
        (asserts! (is-eq tx-sender DEPLOYER) (err ERR_UNAUTHORIZED))
        (var-set premint-enabled premint)
        (var-set sale-enabled sale)
        (print { premint: premint, sale: sale })
        (ok true)
    )
)

(define-public (init)
    (begin
        (asserts! (is-eq tx-sender DEPLOYER) (err ERR_UNAUTHORIZED))
        (ok (var-set premint-enabled true))
    )
)

(define-read-only (get-passes (caller principal))
    (default-to u0 (map-get? mint-passes caller))
)

(define-public (set-artist-address (address principal))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (ok (var-set artist-address address))
  )
)

(define-public (set-price (price uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (ok (var-set total-price price))
  )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-INVALID-USER))
    (nft-transfer? whitelist-attribute-test-1 token-id sender recipient)
  )
)

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? whitelist-attribute-test-1 token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))

(define-read-only (get-premint-enabled)
  (ok (var-get premint-enabled)))

(define-read-only (get-sale-enabled)
  (ok (var-get sale-enabled)))

(map-set mint-passes 'SP1NBCK2JP3KNCHGGM8FGWPT7VFWSCBAXGMJ1WMZB u3)
(map-set mint-passes 'SP35MEYYBHSFCFXY296YGP7NAT6Y4XBJW2VETR8AV u3)
(map-set mint-passes 'SP1CCC68DRYZZKMPAZPWKE3VP2R7YSVN9DZJG86Y8 u3)
(map-set mint-passes 'SP1P72Z3704VMT3DMHPP2CB8TGQWGDBHD3RPR9GZS u3)
(map-set mint-passes 'SPV4GYHQ2B7R831M3F7ZNN22RDDHEKQ52ZN50CDE u3)
(map-set mint-passes 'SPRKDCBZ9FA886BSK7SF70TWZK0RPEY02KMFAXCQ u3)
(map-set mint-passes 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD u3)
(map-set mint-passes 'SP9M7RXPPQ1MZSDQR2NXD4SB28VFSXQX7XZYPXT8 u3)
(map-set mint-passes 'SP1QA548TFNZ2BDE1A7TSP49PKCRERZWEEG74BKAJ u3)
(map-set mint-passes 'SP17YP1HGWK7DP5Q69GRG14W34E078S4D78YM1FA5 u3)
(map-set mint-passes 'SP2M63YGBZCTWBWBCG77RET0RMP42C08T73MKAPNP u3)
(map-set mint-passes 'SP35DMWWRRY69NBYA8FJN8FY3T70GFP08EP5NN2ZQ u3)
(map-set mint-passes 'SP2W3ZFMA5CPFA21FW15ZYD1J0QMR96RWZQEJ2Z00 u3)
(map-set mint-passes 'SPBFEJKY3D335G9R4QX5T7W9K6N4EVF8QC8NN9BG u3)
(map-set mint-passes 'SP2M4TQW8B0KW0YSF1N6GGW36FD1G7G439NTF5CQ u3)
(map-set mint-passes 'SPHP588Y6ES886214AA3S7WPCN6QQR2S3Z8348TC u3)
(map-set mint-passes 'SP146JTSKFPYAXPBHJTWF56D7G3ZHBDJTKVJQXA3D u3)
(map-set mint-passes 'SPBW8GGZTH6C9W7H9QAMAFCA44TJS3DA629VZPWP u3)
(map-set mint-passes 'SP1PG8YC8DEPW1NK8PQRT3TRWGHVFDH1RBHANRSCY u3)
(map-set mint-passes 'SP2C8P3MM137K1A48D1SRENG67KHEVPZV4K36G3JY u3)
(map-set mint-passes 'SP2SB5G2XKX7H6H5PH6FKWH3FY80821B4JH2S03K4 u3)
(map-set mint-passes 'SP2HS73HXN7K5X4QJ5GK6S4MGDSPH24QWZ4NVRB3G u3)
(map-set mint-passes 'SPY11X2CFKJ9JG213HJP1Z4JFT2H88079MQFW2MS u3)
(map-set mint-passes 'SPF8K98V7GW58RD7D4CEC2F1W6C1Q6TTPPAJQRAB u3)
(map-set mint-passes 'SP3J0Z8YSJD20TGEBE6M992CWFDG18VB0PR599VY9 u3)
(map-set mint-passes 'SPNC4G6P4V8VSYVTW3CGW8ZQYPZ4M51S35AXX5AC u3)
(map-set mint-passes 'SP3VGB2FS9FGN6M6SHWYWTCV3F0A08MQ6Q78F7E9 u3)
(map-set mint-passes 'SP4S033WJCAEKQ474AKEE4GGPWFYEMTGVR7WT4ZS u3)
(map-set mint-passes 'SPX0FKCZ2QNS7AWYT95HQ89S1YGEEY89AYG8ASZ4 u3)
(map-set mint-passes 'SP1E4798MP7RNHPVSBM954MSS5EJNM1AC3R53DC31 u3)
(map-set mint-passes 'SP2891F1DM9QJ14F711C62NQS3RQG4VFV6ZTEEN60 u3)
(map-set mint-passes 'SP20ZAVGZ8QT6SEGWD3XD94NXZ3TA6T2KSKQYVJPA u3)
(map-set mint-passes 'SP3MYM8YGM8MVT10WKQ3A19E3MAG2H6PHCW8PMZWT u3)
(map-set mint-passes 'SP1XA1Z1ZYRMWZAYR5TA756CSDRPP7WN415MZZYHM u3)
(map-set mint-passes 'SP2RS0YJZ2QH5VYXQ91X06B9QYR90BNGJETWP0V69 u3)
