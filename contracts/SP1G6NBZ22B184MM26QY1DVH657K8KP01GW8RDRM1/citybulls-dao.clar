;; ***** START MINTER CODE ***** ;;

(use-trait ft-trait 'SP2BSV94A650WGZ2YZ5Y8HM93W01NGT4GY0W2BN3P.ft-trait.ft-trait)
(use-trait nft-trait 'SP2BSV94A650WGZ2YZ5Y8HM93W01NGT4GY0W2BN3P.nft-trait.nft-trait)
(use-trait treasury-trait 'SP2BSV94A650WGZ2YZ5Y8HM93W01NGT4GY0W2BN3P.treasury-trait.treasury-trait)
(use-trait commission-trait 'SP2BSV94A650WGZ2YZ5Y8HM93W01NGT4GY0W2BN3P.commission-trait.commission-trait)

;; errors
(define-constant err-not-authorized u401)

;; constants
(define-constant contract-owner tx-sender)

;; public functions

;; mint an nft
(define-public (mint (nft <nft-trait>) (comm <commission-trait>))
  (begin
    (try! (contract-call? comm send-funds))
    (try! (contract-call? nft mint tx-sender))
    (ok true)
  )
)

;; set minter after deploy for nft contract
(define-public (set-as-minter (nft <nft-trait>))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-authorized))
    (as-contract (contract-call? nft set-dao-address))
  )
)

;; ***** END MINTER CODE ***** ;;

;; ***** START DAO CODE ***** ;;

(impl-trait 'SP2BSV94A650WGZ2YZ5Y8HM93W01NGT4GY0W2BN3P.dao-trait.dao-trait)

;; constants
(define-constant err-member-not-found u404)
(define-constant err-empty-string u100)
(define-constant err-member-already-exists u102)

;; data maps and vars
(define-data-var dao-name (string-ascii 256) "CityCoins Bulls DAO") ;; TODO: change default dao name
(define-data-var number-of-members uint u0)
(define-data-var number-of-historical-members uint u0) ;; won't be decremented when a member is removed

;; stores current members in the dao
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

(define-public (transfer (nft <nft-trait>) (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq sender tx-sender) (err err-not-authorized))
    (try! (contract-call? nft transfer token-id sender recipient))
    (ok true)
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

;; historically admitted number
(define-read-only (get-number-of-historical-members)
  (var-get number-of-historical-members)
)

(define-read-only (get-member-name (member-address principal))
  (map-get? dao-members {member: member-address})
)

;; ***** END DAO CODE ***** ;;