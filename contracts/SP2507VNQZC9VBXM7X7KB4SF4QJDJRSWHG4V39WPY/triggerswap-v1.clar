;; triggers claimstx from lnswap and claim-for from any nft for trustless LN purchases

;; claim/mint an nft for a principal
(define-trait claim-for-trait
  (
    (claim-for (principal) (response uint uint))
  )
)

(define-public (triggerStx (preimage (buff 32)) (amount (buff 16)) (claimAddress (buff 42)) (refundAddress (buff 42)) (timelock (buff 16)) (nftPrincipal <claim-for-trait>) (userPrincipal principal))
    (begin 
        (try! (contract-call? .stxswap_v8 claimStx preimage amount claimAddress refundAddress timelock))
        (try! (contract-call? nftPrincipal claim-for userPrincipal))
        (ok true)
    )
)