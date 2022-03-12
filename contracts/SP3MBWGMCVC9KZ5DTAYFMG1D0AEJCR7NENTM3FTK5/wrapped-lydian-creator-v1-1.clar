;; @contract Wrapped Lydian Creator
;; @version 1

;; ---------------------------------------------------------
;; Wrap
;; ---------------------------------------------------------

(define-public (wrap (amount uint))
  (let (
    ;; Claim rebase if needed
    (claim-result (claim))

    (recipient tx-sender)
    (index (contract-call? .staked-lydian-token get-index))
    (wrapped-amount (/ (* amount u1000000) index))
  )
    ;; Transfer sLDN to contract
    (try! (contract-call? .staked-lydian-token transfer amount recipient (as-contract tx-sender) none))

    ;; Mint wLDN for user
    (try! (contract-call? .wrapped-lydian-token mint recipient wrapped-amount))

    (ok wrapped-amount)
  )
)

(define-public (unwrap (amount uint))
  (let (
    ;; Claim rebase if needed
    (claim-result (claim))

    (recipient tx-sender)
    (index (contract-call? .staked-lydian-token get-index))
    (staked-amount (/ (* amount index) u1000000))
  )
    ;; Transfer sLDN to recipient
    (try! (as-contract (contract-call? .staked-lydian-token transfer staked-amount (as-contract tx-sender) recipient none)))

    ;; Burn wLDN for user
    (try! (contract-call? .wrapped-lydian-token burn recipient amount))

    (ok staked-amount)
  )
)

(define-private (claim)
  (let (
    (claim-amount (unwrap-panic (contract-call? .staked-lydian-token get-claim-rebase (as-contract tx-sender))))
  )
    (if (> claim-amount u0)
      (as-contract (contract-call? .staked-lydian-token claim-rebase))
      (ok u0)
    )
  )
)
