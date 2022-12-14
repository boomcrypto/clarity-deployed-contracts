;; helper contract to claim two times five at .nft-mint contract
(define-public (claim-ten)
    (begin 
        (try! (contract-call? .ryder-mint claim-five))
        (contract-call? .ryder-mint claim-five)))