;; Charisma wrapper for STX-CHA swaps

(define-public (swap-stx-for-cha (amount-stx uint))
  (contract-call? .univ2-path2 do-swap (* amount-stx (pow u10 u6)) .wstx .charisma-token .univ2-share-fee-to))

(define-public (swap-cha-for-stx (amount-cha uint))
  (contract-call? .univ2-path2 do-swap (* amount-cha (pow u10 u6)) .charisma-token .wstx .univ2-share-fee-to))