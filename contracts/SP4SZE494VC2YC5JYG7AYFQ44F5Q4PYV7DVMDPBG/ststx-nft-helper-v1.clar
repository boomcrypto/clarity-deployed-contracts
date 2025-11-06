(use-trait reserve-trait .reserve-trait-v1.reserve-trait)

(define-constant ERR_SHUTDOWN u39001)
(define-constant ERR_WITHDRAW_NOT_NFT_OWNER u39002)
(define-constant ERR_WITHDRAW_NFT_DOES_NOT_EXIST u39003)
(define-constant ERR_GET_OWNER u39004)
(define-constant ERR_WITHDRAW_ALREADY_USED u39005)

(define-map withdrawals-by-nft uint bool)

(define-read-only (get-withdrawal-status (nft-id uint))
  (default-to false (map-get? withdrawals-by-nft nft-id))
)

(define-public (withdraw (reserve-contract <reserve-trait>) (nft-id uint))
  (let (
    (receiver tx-sender)
    
    (withdrawal-status (get-withdrawal-status nft-id))
    (withdrawal-entry (contract-call? .stacking-dao-core-v1 get-withdrawals-by-nft nft-id))  
    (nft-owner (unwrap! (contract-call? .ststx-withdraw-nft get-owner nft-id) (err ERR_GET_OWNER)))
    (stx-to-receive (get stx-amount withdrawal-entry))
  )
    (asserts! (not withdrawal-status) (err ERR_WITHDRAW_ALREADY_USED))
    (try! (contract-call? .dao check-is-enabled))
    (try! (contract-call? .dao check-is-protocol (contract-of reserve-contract)))
    (asserts! (is-some nft-owner) (err ERR_WITHDRAW_NFT_DOES_NOT_EXIST))
    (asserts! (is-eq (unwrap! nft-owner (err ERR_GET_OWNER)) tx-sender) (err ERR_WITHDRAW_NOT_NFT_OWNER))

    ;; STX to user, burn stSTX
    (try! (as-contract (contract-call? reserve-contract request-stx-for-withdrawal stx-to-receive receiver)))
    (try! (as-contract (contract-call? .ststx-token burn-for-protocol (get ststx-amount withdrawal-entry) (as-contract .stacking-dao-core-v1))))
    (try! (as-contract (contract-call? .ststx-withdraw-nft burn-for-protocol nft-id)))

    ;; Mark NFT as used for withdrawal
    (map-set withdrawals-by-nft nft-id true)

    (print { action: "withdraw", data: { stacker: tx-sender, amount: (get ststx-amount withdrawal-entry), block-height: block-height } })
    (ok stx-to-receive)
  )
)