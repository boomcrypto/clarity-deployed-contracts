;; @contract Data Core
;; @version 2
;;
;; Helper methods to get STX per stSTX.
;; Storing stSTXbtc withdrawal NFT info.

(use-trait reserve-trait .reserve-trait-v1.reserve-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant DENOMINATOR_6 u1000000)

;;-------------------------------------
;; STX per stSTX  
;;-------------------------------------

(define-public (get-stx-per-ststx (reserve-contract <reserve-trait>))
  (let (
    (total-stx-amount (try! (contract-call? reserve-contract get-total-stx)))
    (ststxbtc-supply (unwrap-panic (contract-call? .ststxbtc-token get-total-supply)))
    (stx-for-ststx (- total-stx-amount ststxbtc-supply))
  )
    (try! (contract-call? .dao check-is-protocol (contract-of reserve-contract)))
    (ok (get-stx-per-ststx-helper stx-for-ststx))
  )
)

(define-read-only (get-stx-per-ststx-helper (stx-amount uint))
  (let (
    (ststx-supply (unwrap-panic (contract-call? .ststx-token get-total-supply)))
  )
    (if (is-eq ststx-supply u0)
      DENOMINATOR_6
      (/ (* stx-amount DENOMINATOR_6) ststx-supply)
    )
  )
)

;;-------------------------------------
;; Cycle Withdraw Offset
;;-------------------------------------

;; Use data-core-v1

;;-------------------------------------
;; Withdrawal NFT (stSTX)
;;-------------------------------------

;; Use data-core-v1

;;-------------------------------------
;; Cycle Withdraw Inset
;;-------------------------------------

;; In the last X blocks of the cycle
(define-data-var cycle-withdraw-inset uint (if is-in-mainnet u50 u3)) 

(define-read-only (get-cycle-withdraw-inset)
  (var-get cycle-withdraw-inset)
)

(define-public (set-cycle-withdraw-inset (inset uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (var-set cycle-withdraw-inset inset)
    (ok true)
  )
)

;;-------------------------------------
;; Withdrawal NFT (stSTXbtc)
;;-------------------------------------

(define-map ststxbtc-withdrawals-by-nft
  { 
    nft-id: uint
  }
  {
    unlock-burn-height: uint, 
    stx-amount: uint
  }
)

(define-read-only (get-ststxbtc-withdrawals-by-nft (nft-id uint))
  (default-to 
    {
      unlock-burn-height: u0,
      stx-amount: u0,
    }  
    (map-get? ststxbtc-withdrawals-by-nft { nft-id: nft-id })
  )
)

(define-public (set-ststxbtc-withdrawals-by-nft (nft-id uint) (stx-amount uint) (unlock-burn-height uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (map-set ststxbtc-withdrawals-by-nft { nft-id: nft-id } { stx-amount: stx-amount, unlock-burn-height: unlock-burn-height })

    (print { action: "set-ststxbtc-withdrawals-by-nft", data: { nft-id: nft-id, stx-amount: stx-amount, unlock-burn-height: unlock-burn-height, block-height: block-height } })
    (ok true)
  )
)

(define-public (delete-ststxbtc-withdrawals-by-nft (nft-id uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (map-delete ststxbtc-withdrawals-by-nft { nft-id: nft-id })

    (print { action: "delete-ststxbtc-withdrawals-by-nft", data: { nft-id: nft-id, block-height: block-height } })
    (ok true)
  )
)

;;-------------------------------------
;; Idle
;;-------------------------------------

;; Cycle to STX amount
(define-map stx-idle uint uint)

(define-read-only (get-stx-idle (cycle uint))
  (default-to 
    u0 
    (map-get? stx-idle cycle)
  )
)

(define-public (set-stx-idle (cycle uint) (amount uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (map-set stx-idle cycle amount)
    (ok true)
  )
)

(define-public (increase-stx-idle (cycle uint) (amount uint))
  (let (
    (current-amount (get-stx-idle cycle))
  )
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (map-set stx-idle cycle (+ current-amount amount))
    (ok true)
  )
)

(define-public (decrease-stx-idle (cycle uint) (amount uint))
  (let (
    (current-amount (get-stx-idle cycle))
  )
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (map-set stx-idle cycle (- current-amount amount))
    (ok true)
  )
)