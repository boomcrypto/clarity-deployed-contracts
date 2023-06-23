;; Define clarity-coin with a maximum of 1,000,000 tokens.
(define-fungible-token clarity-coin)

;; Mint 1,000 tokens and give them to tx-sender.
(ft-mint? clarity-coin u1000 'SP30F77CBR0DSZAET7A5WYMGDHRNDQYDHCPK5SWMC)