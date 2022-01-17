(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token rock uint)

(define-data-var fee-per-rock uint u100000000)
(define-data-var number-of-rocks uint u0)

;; storage of mint-address and admin
(define-map mint-address bool principal)
;; storage of marketplace-address
(define-map marketplace-address bool principal)
;; storage of admin-address
(define-map admin bool principal)

(define-map approvals {owner: principal, operator: principal, id: uint} bool)
(define-map approvals-all {owner: principal, operator: principal} bool)

(define-read-only (get-last-token-id)
  (ok u50))

(define-read-only (get-number-of-rocks)
  (var-get number-of-rocks))

(define-read-only (get-floor)
  (* (var-get number-of-rocks) (var-get fee-per-rock)))

(define-read-only (get-fee-per-rock)
  (var-get fee-per-rock))

(define-public (get-token-uri (id uint))
  (ok (some "ipfs://Qmeq7Z5vdhJwfKauf2XWL44YqgCTpHmAgrzrb1BKSEeY7x/{id}.json")))

(define-public (get-owner (id uint))
  (ok (nft-get-owner? rock id)))

;;
;; transfer functions
;;
(define-private (floor-stx-transfer (id uint))
  (match (nft-get-owner? rock id)
  rock-owner
    (if (not (is-eq tx-sender rock-owner))
      (stx-transfer? (var-get fee-per-rock) tx-sender rock-owner)
      (ok true))
  (ok true)))

(define-private (check-err (current (response bool uint)) (result (response bool uint)))
  (if (is-err result) result current))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (let ((floor-result (map floor-stx-transfer indices)))
    (try! (fold check-err floor-result (ok true)))
    (nft-transfer? rock id sender recipient)))

 ;; SIP009: Transfer token to a specified principal
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (let ((owner (unwrap! (nft-get-owner? rock id) err-not-found)))
    (asserts! (is-eq sender owner) err-invalid-sender)
    (asserts! (is-approved-with-owner id contract-caller owner) err-not-authorized)
    (trnsfr id sender recipient)))

(define-public (transfer-memo (id uint) (sender principal) (recipient principal) (memo (buff 34)))
    (let ((result (transfer id sender recipient)))
      (print memo)
      result))
;;
;; operable functions
;;
(define-private (is-approved-with-owner (id uint) (operator principal) (owner principal))
  (or
    (is-eq owner operator)
    (default-to (default-to
      (is-eq operator (get-marketplace))
        (map-get? approvals-all {owner: owner, operator: operator}))
          (map-get? approvals {owner: owner, operator: operator, id: id}))))

(define-read-only (is-approved (id uint) (operator principal))
  (let ((owner (unwrap! (nft-get-owner? rock id) err-not-found)))
    (ok (is-approved-with-owner id operator owner))))

(define-public (set-approved (id uint) (operator principal) (approved bool))
  (let ((owner (unwrap! (nft-get-owner? rock id) err-not-found)))
	  (ok (map-set approvals {owner: contract-caller, operator: operator, id: id} approved))))

(define-public (set-approved-all (operator principal) (approved bool))
	  (ok (map-set approvals-all {owner: contract-caller, operator: operator} approved)))

;; upgrade btc rock - can only be called from mint contract
(define-public (upgrade (id uint))
  (begin
    (asserts! (is-eq contract-caller (unwrap! (map-get? mint-address true) err-fatal)) err-not-authorized)
    (var-set number-of-rocks (+ u1 (var-get number-of-rocks)))
    (nft-mint? rock id tx-sender)))

;;
;; admin function
;;
;; can only be called once
(define-public (set-mint)
  (let ((the-mint (map-get? mint-address true)))
    (asserts! (and (is-none the-mint)
              (map-insert mint-address true contract-caller))
                err-fatal)
    (print contract-caller)
    (ok contract-caller)))

;; can only be called once
(define-public (set-marketplace)
  (let ((marketplace (map-get? marketplace-address true)))
    (asserts! (and
                (is-none marketplace)
                (map-insert marketplace-address true contract-caller))
              err-fatal)
    (print contract-caller)
    (ok contract-caller)))

(define-read-only (get-marketplace)
  (unwrap! (map-get? marketplace-address true) 'SP000000000000000000002Q6VF78))

(define-public (set-fee-per-rock (ustx uint))
  (begin
    (asserts! (is-eq (unwrap! (map-get? admin true) err-fatal) contract-caller) err-not-authorized)
    (ok (var-set fee-per-rock ustx))))

(define-public (set-admin (user principal))
  (begin
    (asserts! (is-eq (unwrap! (map-get? admin true) err-fatal) contract-caller) err-not-authorized)
    (ok (map-set admin true user))))

(define-constant indices
  (list
    u1 u2 u3 u4 u5 u6 u7 u8 u9 u10
    u11 u12 u13 u14 u15 u16 u17 u18 u19 u20
    u21 u22 u23 u24 u25 u26 u27 u28 u29 u30
    u31 u32 u33 u34 u35 u36 u37 u38 u39 u40
    u41 u42 u43 u44 u45 u46 u47 u48 u49 u50))

(define-constant err-not-authorized (err u403))
(define-constant err-not-found (err u404))
(define-constant err-invalid-sender (err u503))
(define-constant err-fatal (err u999))
