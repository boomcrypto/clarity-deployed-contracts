;; Energy Helper v1
;; This contract handles whitelisting of CDK contracts, wraps the tap function,
;; and manages energy for MemoBot NFT holders using the Energy Storage contract


(use-trait nft-trait .dao-traits-v4.nft-trait)
(use-trait cdk-trait .dao-traits-v4.cdk-trait)

(impl-trait .dao-traits-v4.edk-trait)

;; Constants
(define-constant ERR-INVALID-CDK (err u100))
(define-constant ERR-UNAUTHORIZED (err u101))

;; Data vars and maps
(define-map whitelisted-cdks principal bool)

;; Authorization check
(define-private (is-dao-or-extension)
    (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller))
)

(define-read-only (is-authorized)
    (ok (asserts! (is-dao-or-extension) ERR-UNAUTHORIZED))
)

;; Helper functions

(define-private (is-nft-owner (user principal))
  (> (unwrap-panic (contract-call? .memobots-guardians-of-the-gigaverse get-balance user)) u0)
)

;; Whitelist functions

(define-public (set-whitelisted-cdk (cdk-contract principal) (whitelisted bool))
  (begin
    (try! (is-authorized))
    (ok (map-set whitelisted-cdks cdk-contract whitelisted))
  )
)

(define-read-only (is-whitelisted-cdk (cdk-contract principal))
  (default-to false (map-get? whitelisted-cdks cdk-contract))
)

(define-private (calculate-energy-usage (tapped-energy uint) (stored-energy uint) (energy-max-out (optional uint)))
  (let (
    (total-available-energy (+ tapped-energy stored-energy))
    (energy-to-use (match energy-max-out
      max-out (min total-available-energy max-out)
      total-available-energy
    ))
  )
    {
        event: "energy-usage",
        energy-to-use: energy-to-use,
        energy-from-storage: (min stored-energy energy-to-use),
        excess-energy: (- total-available-energy energy-to-use)
    }
  )
)

(define-private (use-stored-energy (amount uint))
  (if (> amount u0)
    (contract-call? .energy-storage use-energy tx-sender amount)
    (ok u0)
  )
)

(define-private (store-excess-energy (amount uint))
  (if (> amount u0)
    (contract-call? .energy-storage store-energy tx-sender amount)
    (ok true)
  )
)

;; Wrapped tap function with energy management for NFT holders

(define-public (tap (land-id uint) (cdk-contract <cdk-trait>) (energy-max-out (optional uint)))
  (begin
    (asserts! (is-whitelisted-cdk (contract-of cdk-contract)) ERR-INVALID-CDK)
    (let (
      (tapped-energy (unwrap-panic (contract-call? cdk-contract tap land-id)))
    )
      (if (is-nft-owner tx-sender)
        (let (
          (stored-energy (contract-call? .energy-storage get-stored-energy tx-sender))
          (energy-usage (calculate-energy-usage (get energy tapped-energy) stored-energy energy-max-out))
        )
            (try! (use-stored-energy (get energy-from-storage energy-usage)))
            (try! (store-excess-energy (get excess-energy energy-usage)))
            (print energy-usage)
            (ok tapped-energy)
        )
        (ok tapped-energy)
      )
    )
  )
)

;; Utility functions

(define-private (min (a uint) (b uint))
  (if (<= a b) a b)
)