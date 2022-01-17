(impl-trait .dao-trait.dao-trait)
(use-trait ft-trait .ft-trait.ft-trait)
(use-trait nft-trait .nft-trait.nft-trait)
(use-trait treasury-trait .treasury-trait.treasury-trait)

;; errors
(define-constant err-empty-string u100)
(define-constant err-member-already-exists u102)
(define-constant err-not-authorized u401)
(define-constant err-member-not-found u404)

;; constants
(define-constant contract-owner tx-sender)

;; data maps and vars
(define-data-var dao-name (string-ascii 256) "StackerDAO")
(define-data-var number-of-members uint u0)
(define-data-var number-of-historical-members uint u0)
(define-map dao-members { member: principal } { name: (string-ascii 256) })

;; public functions

(define-public (move-stx (treasury <treasury-trait>) (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-authorized))
    (try! (as-contract (contract-call? treasury move-stx amount recipient)))
    (ok true)
  )
)

(define-public (move-ft (treasury <treasury-trait>) (ft <ft-trait>) (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-authorized))
    (try! (as-contract (contract-call? treasury move-ft ft amount recipient)))
    (ok true)
  )
)

(define-public (move-nft (treasury <treasury-trait>) (nft <nft-trait>) (token-id uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-authorized))
    (try! (as-contract (contract-call? treasury move-nft nft token-id recipient)))
    (ok true)
  )
)

(define-public (set-dao-name (new-dao-name (string-ascii 256)))
  (begin
    (asserts! (> (len new-dao-name) u0) (err err-empty-string))
    (var-set dao-name new-dao-name)
    (ok new-dao-name)
  )
)

(define-public (set-name (member principal) (new-member-name (string-ascii 256)))
  (begin
    (asserts! (is-eq member tx-sender) (err err-not-authorized))
    (asserts! (> (len new-member-name) u0) (err err-empty-string))
    (ok (map-set dao-members { member: member } { name: new-member-name }))
  )
)

(define-public (add-member (member-to-add principal) (name (string-ascii 256)))
  (begin
    (asserts! (not (unwrap-panic (is-member member-to-add))) (err err-member-already-exists))
    (asserts! (> (len name) u0) (err err-empty-string))

    (map-insert dao-members { member: member-to-add } { name: name })
    (var-set number-of-members (+ (var-get number-of-members) u1))
    (var-set number-of-historical-members (+ (var-get number-of-historical-members) u1))
    (ok member-to-add)
  )
)

(define-public (remove-member (member-to-remove principal))
  (begin
    (asserts! (unwrap-panic (is-member member-to-remove)) (err err-member-not-found))

    (map-delete dao-members { member: member-to-remove })
    (var-set number-of-members (- (var-get number-of-members) u1))
    (ok member-to-remove)
  )
)

;; read-only functions

(define-read-only (get-version)
  (ok "1.0.0")
)

(define-read-only (get-name)
  (ok (var-get dao-name))
)

(define-read-only (is-member (user principal))
  (ok
    (is-some
      (map-get? dao-members { member: user })
    )
  )
)

(define-read-only (get-number-of-members)
  (var-get number-of-members)
)

(define-read-only (get-number-of-historical-members)
  (var-get number-of-historical-members)
)

(define-read-only (get-member-name (member-address principal))
  (map-get? dao-members {member: member-address})
)