(use-trait faktory-token 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.faktory-trait-v1.sip-010-trait)

(define-trait dex-trait
  (
    ;; buy from the bonding curve dex
    (buy (<faktory-token> uint) (response bool uint))

    ;; sell from the bonding curve dex
    (sell (<faktory-token> uint) (response bool uint))

    ;; the status of the dex
    (get-open () (response bool uint))

    ;; data to inform a buy
    (get-in (uint) (response {
        total-stx: uint,
        total-stk: uint,
        ft-balance: uint,
        k: uint,
        fee: uint,
        stx-in: uint,
        new-stk: uint,
        new-ft: uint,
        tokens-out: uint,
        new-stx: uint,
        stx-to-grad: uint
    } uint))

    ;; data to inform a sell
    (get-out (uint) (response {
        total-stx: uint,
        total-stk: uint,
        ft-balance: uint,
        k: uint,
        new-ft: uint,
        new-stk: uint,
        stx-out: uint,
        fee: uint,
        stx-to-receiver: uint,
        amount-in: uint,
        new-stx: uint,
    } uint))
  )
)