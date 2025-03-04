(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission) ;; 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait) ;; 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9

(define-private (transfer-nft (token-contract <nft-trait>) (token-id uint) (sender principal) (recipient principal))
  (contract-call? token-contract transfer token-id sender recipient)
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

(define-constant ERR_ZERO (err u400))
(define-constant ERR_NOT_THE_OWNER (err u401))
(define-constant ERR_NOT_FOUND (err u402))
(define-constant ERR_PAUSED (err u403))
(define-constant ERR_WRONG_ADDRESS (err u404))

;; main contract BNS v2 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF

(define-data-var BNSONE principal 'SM18RN48GX7E3ED23M03BY4QD8EA2DG2R4VX4CDYJ) ;; BNS One commission address
(define-data-var TREASURY principal 'SM18RN48GX7E3ED23M03BY4QD8EA2DG2R4VX4CDYJ)
(define-data-var OWNER principal tx-sender)
(define-data-var PAUSED bool false)

(define-public (admin-change-ownership (address principal))
  (begin 
    (asserts! (is-eq contract-caller (var-get OWNER)) ERR_NOT_THE_OWNER)
    (asserts! (is-standard address) ERR_WRONG_ADDRESS)
    (var-set OWNER address)
    (ok address)
  )
)

(define-public (admin-pause)
  (begin 
    (asserts! (is-eq contract-caller (var-get OWNER)) ERR_NOT_THE_OWNER)
    (var-set PAUSED (not (var-get PAUSED)))
    (ok (var-get PAUSED))
  )
)

(define-public (admin-set-treasury (address principal))
  (begin 
    (asserts! (is-eq contract-caller (var-get OWNER)) ERR_NOT_THE_OWNER)
    (asserts! (is-standard address) ERR_WRONG_ADDRESS)
    (var-set TREASURY address)
    (ok address)
  )
)

(define-public (admin-set-commission-address (address principal))
  (begin 
    (asserts! (is-eq contract-caller (var-get OWNER)) ERR_NOT_THE_OWNER)
    (asserts! (is-standard address) ERR_WRONG_ADDRESS)
    (var-set BNSONE address)
    (ok address)
  )
)

(define-public (admin-withdraw-stx (amount uint))
  (begin 
    (asserts! (> amount u0)  ERR_ZERO)
    (asserts! (is-eq contract-caller (var-get OWNER)) ERR_NOT_THE_OWNER)
    (try! (as-contract (stx-transfer? amount tx-sender (var-get TREASURY))))
    (ok amount)
  )
)

(define-public (admin-set-primary (id uint))
  (begin 
    (asserts! (> id u0)  ERR_ZERO)
    (asserts! (is-eq contract-caller (var-get OWNER)) ERR_NOT_THE_OWNER)
    (try! (as-contract (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 set-primary-name id)))
    (ok id)
  )
)

(define-public (admin-withdraw-name (id uint) (recipient principal))
  (begin 
    (asserts! (> id u0)  ERR_ZERO)
    (asserts! (is-standard recipient) ERR_WRONG_ADDRESS)
    (asserts! (is-eq contract-caller (var-get OWNER)) ERR_NOT_THE_OWNER)
    (try! (as-contract (transfer-nft 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 id tx-sender recipient)))
    (ok id)
  )
)

(define-public (admin-renew-name (ids (list 100 uint)))
  (begin 
    (asserts! (is-eq contract-caller (var-get OWNER)) ERR_NOT_THE_OWNER)
    (fold check-err (map renew-name ids) (ok true))
  )
)

(define-private (renew-name (id uint)) 
  (let (
    (id-data (unwrap! (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 get-bns-from-id id) ERR_NOT_FOUND))
    (name (get name id-data))
    (namespace (get namespace id-data))
  ) 
    (asserts! (> id u0)  ERR_ZERO)
    (try! (as-contract (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 name-renewal namespace name)))
    (ok true)
  )
)

;; function to bulk buy names from all the marketplaces
(define-public (sweep-names (domains (list 100 { commission: <commission-trait>, id: uint, price: uint })))
  (fold check-err (map sweep-single domains) (ok true))
)

(define-private (sweep-single (domains { commission: <commission-trait>, id: uint, price: uint }))
  (sweep (get price domains ) (get id domains ) (get commission domains ) )
)

;; price is the current name price + current market fee
(define-private (sweep (price uint) (id uint)  (comm-trait <commission-trait>))
  (let (
    (sender contract-caller)
    (market-fee (/ (* price u300) u10000))
    (total-amount (+ price market-fee))
    ) 
      (asserts! (and (> price u0) (> id u0))  ERR_ZERO)
      (asserts! (not (var-get PAUSED)) ERR_PAUSED)
      (try! (stx-transfer? price sender (as-contract tx-sender)))
      (try! (as-contract ( contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 buy-in-ustx id comm-trait )))
      (try! (as-contract (transfer-nft 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 id tx-sender sender)))
      (print {a: "buy with bns one", id: id, taker: sender})
      (if (is-bns-one comm-trait)
        ;; if using bns-one commission
        (ok true)
        ;; if using other commission 
        (stx-transfer? market-fee sender (var-get TREASURY))
      )
  )
)

;; function to buy from other marketplaces
(define-public (buy-name (price uint)  (id uint)  (comm-trait <commission-trait>))
  (let (
    (sender contract-caller)
    (market-fee (/ (* price u300) u10000))
  )
  (asserts! (and (> price u0) (> id u0))  ERR_ZERO)
  (asserts! (not (var-get PAUSED)) ERR_PAUSED)
  (try! (stx-transfer? price sender (as-contract tx-sender))   )
  (try! (stx-transfer? market-fee sender (var-get TREASURY)) )
  (try! (as-contract ( contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 buy-in-ustx id comm-trait )))
  (print {a: "buy with bns one", id: id, taker: sender})
  (as-contract (transfer-nft 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 id tx-sender sender))
))

;; helper to check commission
(define-private (is-bns-one (comm-trait <commission-trait>))
  (let ((d (unwrap-panic (principal-destruct? (contract-of comm-trait))))
        (p (unwrap-panic (principal-construct? (get version d) (get hash-bytes d))))
  )
  (is-eq p (var-get BNSONE))  
  )
)