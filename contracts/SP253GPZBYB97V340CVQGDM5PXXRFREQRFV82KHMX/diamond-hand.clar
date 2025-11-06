(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant DEPLOYER tx-sender)
(define-constant USERS (list 'SP2TVC346VTH6NE53YEBPWWGEH8JECTHGW4YQ01R2 'SPQ3Y096ZTM0RWSQHV5CRHPB5MAM31425JF82P31 'SPQR6XEHZFYMMT8GD6ZVEZ6WG3SWH8AD67GWJG57))

(define-map nfts 
  { nft: principal, id: uint }
  {
    unlock-time: uint,
    min-price: uint,
  }
)

(define-map withdraw-note
  { nft: principal, id: uint, tag: uint }
  {
    indexes: (list 3 uint),
    beneficiary: principal,
  }
)

(define-map buyer-note
  { nft: principal, id: uint, tag: uint }
  {
    indexes: (list 3 uint),
    buyer: principal,
    price: uint,
    beneficiary: principal,
  }
)

(define-public (store (nft <nft-trait>) (id uint) (unlock-time uint) (min-price uint))
  (begin
    (asserts! (is-eq DEPLOYER contract-caller) (err u101))
    (asserts! (is-eq (contract-of nft) 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2) (err u102))
    (try! (contract-call? nft transfer id contract-caller (as-contract tx-sender)))
    (map-set nfts { nft: (contract-of nft), id: id } {
      unlock-time: unlock-time,
      min-price: min-price,
    })
    (ok true)
  )
)

(define-public (withdraw (tag uint) (nft <nft-trait>) (id uint) (beneficiary principal))
  (let
    (
      (user-index (unwrap! (index-of USERS contract-caller) (err u101)))
      (nft-info (unwrap! (map-get? nfts { nft: (contract-of nft), id: id }) (err u102)))
      (note (default-to { indexes: (list ), beneficiary: DEPLOYER } (map-get? withdraw-note { tag: tag, nft: (contract-of nft), id: id })))
    )
    (asserts! (is-eq (contract-of nft) 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2) (err u103))
    (asserts! (is-none (index-of (get indexes note) user-index)) (err u104))
    (asserts! (>= (unwrap! (get-stacks-block-info? time (- stacks-block-height u1)) (err u105)) (get unlock-time nft-info)) (err u106))
    (and
      (> (len (get indexes note)) u0)
      (asserts! (is-eq beneficiary (get beneficiary note)) (err u107))
    )
    (if (is-eq (+ (len (get indexes note)) u1) (len USERS))
      (begin
        (map-delete nfts { nft: (contract-of nft), id: id })
        (map-delete withdraw-note { tag: tag, nft: (contract-of nft), id: id })
        (try! (as-contract (contract-call? nft transfer id tx-sender beneficiary)))
      )
      (map-set withdraw-note
        { tag: tag, nft: (contract-of nft), id: id }
        {
          indexes: (unwrap! (as-max-len? (append (get indexes note) user-index) u3) (err u108)),
          beneficiary: beneficiary
        }
      )
    )
    (ok true)
  )
)

(define-public (set-buy-info (tag uint) (nft principal) (id uint) (buyer principal) (price uint) (beneficiary principal))
  (let
    (
      (user-index (unwrap! (index-of USERS contract-caller) (err u101)))
      (nft-info (unwrap! (map-get? nfts { nft: nft, id: id }) (err u102)))
      (note (default-to { indexes: (list ), buyer: DEPLOYER, price: u0, beneficiary: DEPLOYER } (map-get? buyer-note { tag: tag, nft: nft, id: id })))
    )
    (asserts! (is-eq nft 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2) (err u103))
    (asserts! (is-none (index-of (get indexes note) user-index)) (err u104))
    (asserts! (>= price (get min-price nft-info)) (err u105))
    (and
      (> (len (get indexes note)) u0)
      (asserts! (is-eq buyer (get buyer note)) (err u106))
      (asserts! (is-eq price (get price note)) (err u107))
      (asserts! (is-eq beneficiary (get beneficiary note)) (err u108))
    )
    (map-set buyer-note
      { tag: tag, nft: nft, id: id }
      {
        indexes: (unwrap! (as-max-len? (append (get indexes note) user-index) u3) (err u109)),
        buyer: buyer,
        price: price,
        beneficiary: beneficiary,
      }
    )
    (ok true)
  )
)

(define-public (buy (tag uint) (nft <nft-trait>) (id uint) (price uint) (beneficiary principal))
  (let
    (
      (note (default-to { indexes: (list ), buyer: DEPLOYER, price: u0, beneficiary: DEPLOYER } (map-get? buyer-note { tag: tag, nft: (contract-of nft), id: id })))
    )
    (asserts! (is-eq (contract-of nft) 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2) (err u101))
    (asserts! (is-eq (len (get indexes note)) (len USERS)) (err u102))
    (asserts! (is-eq contract-caller (get buyer note)) (err u103))
    (asserts! (is-eq price (get price note)) (err u104))
    (asserts! (is-eq beneficiary (get beneficiary note)) (err u105))
    (try! (stx-transfer? (get price note) (get buyer note) (get beneficiary note)))
    (try! (as-contract (contract-call? nft transfer id tx-sender (get buyer note))))
    (map-delete nfts { nft: (contract-of nft), id: id })
    (map-delete buyer-note { tag: tag, nft: (contract-of nft), id: id })
    (ok true)
  )
)

(define-read-only (get-last-block-time)
  (get-stacks-block-info? time (- stacks-block-height u1))
)
