
;;;;;;;;;;;;;;;
;; Constants ;;
;;;;;;;;;;;;;;;
;; below needs to be changed...
(define-constant ADMIN 'SP1GMKTXAKNTS7MKF5QN5HYCKPM3EHDD0E5CCWZC)
(define-constant ERR-REFUND-NOT-ACTIVE (err u0))
(define-constant ERR-ARTIES-ID-NOT-ELIGIBLE (err u1))
(define-constant ERR-ARTIES-WALLET-NOT-ELIGIBLE (err u2))
(define-constant ERR-GET-OWNER-FAILED (err u3))
(define-constant ERR-STX-TRANSFER (err u4))
(define-constant ERR-NOT-AUTH (err u5))

;;;;;;;;;;;;;;;;;
;; Vars & Maps ;;
;;;;;;;;;;;;;;;;;
(define-data-var is-refund-active bool false)
(define-data-var end-height uint u0)
(define-map eligible-arties uint
  {
    eligible: bool,
    wallet: principal
  }
)

;;;;;;;;;;
;; Core ;;
;;;;;;;;;;
(define-public (refund (artieID uint))
  (let
    (
      (eligible-artie (default-to {eligible: false, wallet: 'SP000000000000000000002Q6VF78} (map-get? eligible-arties artieID)))
      (eligible-status (get eligible eligible-artie))
      (eligible-wallet (get wallet eligible-artie))
    )
    (asserts! (and (var-get is-refund-active) (< block-height (var-get end-height))) ERR-REFUND-NOT-ACTIVE)
    (asserts! eligible-status ERR-ARTIES-ID-NOT-ELIGIBLE)
    (asserts! (is-eq tx-sender eligible-wallet) ERR-ARTIES-WALLET-NOT-ELIGIBLE)

    ;; need to assert get-owner to check that this tx-sender is owner of Artie in question
    (asserts! (is-eq tx-sender (unwrap-panic (unwrap-panic (contract-call? 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.arties get-owner artieID)))) ERR-GET-OWNER-FAILED)

    ;; transfer Artie from tx-sender to burn address
    (unwrap-panic (contract-call? 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.arties transfer artieID tx-sender 'SP000000000000000000002Q6VF78))
    (unwrap! (as-contract (stx-transfer? u490000 (as-contract tx-sender) eligible-wallet)) ERR-STX-TRANSFER)
    (ok (map-set eligible-arties artieID {eligible: false, wallet: eligible-wallet}))
  )
)

;;;;;;;;;;;;;;;;;;;;;
;; Admin Functions ;;
;;;;;;;;;;;;;;;;;;;;;

(define-public (admin-load-wallet (stx-amount uint))
  (begin
    (asserts! (is-eq tx-sender ADMIN) ERR-NOT-AUTH)
    (ok (try! (stx-transfer? stx-amount tx-sender (as-contract tx-sender))))
  )
)

(define-public (admin-return-wallet (stx-amount uint))
  (begin
    (asserts! (is-eq tx-sender ADMIN) ERR-NOT-AUTH)
    (as-contract (stx-transfer? stx-amount (as-contract tx-sender) ADMIN))
  )
)

(define-public (admin-start-refund)
  (begin
    (asserts! (is-eq tx-sender ADMIN) ERR-NOT-AUTH)
    (var-set end-height (+ block-height u288))
    (ok (var-set is-refund-active true))
  )
)

(define-public (set-eligible)
  (begin
    (asserts! (is-eq tx-sender ADMIN) ERR-NOT-AUTH)
    (ok (map-set eligible-arties u1635 {eligible: true, wallet: 'SP25VWGTPR19E344S4ENTHQT8651216EPNABRYE51}))
  )
)