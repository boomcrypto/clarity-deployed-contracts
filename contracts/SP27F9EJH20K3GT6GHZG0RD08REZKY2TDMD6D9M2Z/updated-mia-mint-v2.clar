;; start constants/errors, variables & sequences
;; last one minted will have id 2099
;; no one owns 1049
;; this will be deployed by the jesus.btc wallet which will be the contract-owner
(define-constant contract-owner tx-sender)
(define-constant start-final-mint u40776)
(define-constant nft-limit u2100)
(define-constant mint-price-stx u69000000)
(define-constant commission-address-stxnft 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)

;; errors
(define-constant NOT-OWNER (err u101))
(define-constant STX-TRNSF-ERR (err u102))
(define-constant BDGR-TRNSF-ERR (err u103))
(define-constant MINTED-OUT (err u104))
(define-constant MINT-HASNT-STARTED (err u105))
(define-constant MIA-TRNSF-ERR (err u106))
(define-constant MINT-STOPPED (err u107))

;; vars
(define-data-var admin-override bool true)
(define-data-var last-id uint u1048)
(define-data-var mint-price-mia uint u8502)
(define-data-var mint-mia-commission uint u448)

;; main claim function
(define-public (claim-one (mint-in-mia bool))
  (let (
      (next-id (+ u1 (var-get last-id)))
      (new-owner tx-sender)
    )
    (asserts! (is-eq true (var-get admin-override)) MINT-STOPPED)
    (asserts! (< start-final-mint block-height) MINT-HASNT-STARTED)
    (asserts! (< next-id nft-limit) MINTED-OUT)
    (if mint-in-mia
      (begin
        ;; the line below is simply for testing the IF, **do not ship to prod**
        ;;(unwrap! (stx-transfer? mint-price-stx tx-sender contract-owner) (err u104))
        (unwrap! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer (var-get mint-price-mia) tx-sender contract-owner (some 0x00)) MIA-TRNSF-ERR)
        (unwrap! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer (var-get mint-mia-commission) tx-sender commission-address-stxnft (some 0x00)) MIA-TRNSF-ERR)
      )
      (unwrap! (stx-transfer? mint-price-stx tx-sender contract-owner) STX-TRNSF-ERR)
    )
    (unwrap! (as-contract (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 transfer next-id (as-contract tx-sender) new-owner)) BDGR-TRNSF-ERR)
    (ok (var-set last-id next-id))
  )
)

;;;;;;;;;;;;;;;;;;;;
;; List Functions ;;
;;;;;;;;;;;;;;;;;;;;

;; Mint 2
(define-public (claim-two (mint-in-mia bool))
  (begin
    (try! (claim-one mint-in-mia))
    (try! (claim-one mint-in-mia))
    (ok true)
  )
)

;; Mint 4
(define-public (claim-four (mint-in-mia bool))
  (begin
    (try! (claim-one mint-in-mia))
    (try! (claim-one mint-in-mia))
    (try! (claim-one mint-in-mia))
    (try! (claim-one mint-in-mia))
    (ok true)
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;
;; Failsafe Functions ;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; change MIA price
(define-public (change-mia-price (new-price uint) (new-commission uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) NOT-OWNER)
    (var-set mint-mia-commission new-commission)
    (ok (var-set mint-price-mia new-price))
  )
)

;; emergency start/end mint
(define-public (admin-stop-mint (mint-live bool))
  (begin
    (asserts! (is-eq tx-sender contract-owner) NOT-OWNER)
    (ok (var-set admin-override mint-live))
  )
)

;; admin transfer
(define-public (admin-transfer (recipient principal) (id uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) NOT-OWNER)
    (ok (unwrap! (as-contract (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 transfer id (as-contract tx-sender) recipient)) BDGR-TRNSF-ERR))
  )
)

;; admin test
(define-public (admin-claim-test (mint-in-mia bool) (test-id uint))
  (let (
      (new-owner tx-sender)
    )
    (asserts! (is-eq tx-sender contract-owner) NOT-OWNER)
    (if mint-in-mia
      (begin
        ;; the line below is simply for testing the IF, **do not ship to prod**
        ;;(unwrap! (stx-transfer? mint-price-stx tx-sender contract-owner) (err u104))
        (unwrap! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer (var-get mint-price-mia) tx-sender contract-owner (some 0x00)) MIA-TRNSF-ERR)
        (unwrap! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer (var-get mint-mia-commission) tx-sender commission-address-stxnft (some 0x00)) MIA-TRNSF-ERR)
      )
      (unwrap! (stx-transfer? u1000 tx-sender contract-owner) STX-TRNSF-ERR)
    )
    ;;(unwrap! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop new-owner next-id) BDGR-TRNSF-ERR) -> tradeoff contract will be left open
    (ok (unwrap! (as-contract (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 transfer test-id (as-contract tx-sender) new-owner)) BDGR-TRNSF-ERR))
  )
)
