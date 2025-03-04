;; This contract implements the SIP-010 community-standard Fungible Token trait.
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Define the FT, with no maximum supply
(define-fungible-token ssats)

;; Define errors
(define-constant ERR_SBTC_TRANSFER_FAILED (err u100))
(define-constant ERR_NOT_TOKEN_OWNER (err u101))
(define-constant ERR_SSATS_MINT_FAILED (err u102))
(define-constant ERR_SSATS_BURN_FAILED (err u103))

;; Define constants for contract
(define-constant TOKEN_URI u"ipfs://bafkreiffymcyxcn7krplfqvrzc2p2g5i5wmhc2s2wbmudanybuztn2efym")
(define-constant TOKEN_NAME "sSats")
(define-constant TOKEN_SYMBOL "sSats")
(define-constant TOKEN_DECIMALS u6)
(define-constant SSATS_HEX 0x7353617473)

;; Define constants for conversion
(define-constant SSATS_PER_SAT u1000000)

;;; SIP-010 function: Get the token balance of a specified principal
(define-read-only (get-balance (who principal))
  (ok (ft-get-balance ssats who))
)

;;; SIP-010 function: Returns the total supply of fungible token
(define-read-only (get-total-supply)
  (ok (ft-get-supply ssats))
)

;;; SIP-010 function: Returns the human-readable token name
(define-read-only (get-name)
  (ok TOKEN_NAME)
)

;;; SIP-010 function: Returns the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL)
)

;;; SIP-010 function: Returns number of decimals to display
(define-read-only (get-decimals)
  (ok TOKEN_DECIMALS)
)

;;; SIP-010 function: Returns the URI containing token metadata
(define-read-only (get-token-uri)
  (ok (some TOKEN_URI))
)

;;; Peg-in sBTC to mint sSats
(define-public (peg-in (sats uint))
  (let ((ssats-amount (* sats SSATS_PER_SAT)))
    (unwrap!
      (contract-call?
        'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
        transfer
        sats
        tx-sender
        (as-contract tx-sender)
        (some SSATS_HEX)
      )
      ERR_SBTC_TRANSFER_FAILED
    )
    (ft-mint? ssats ssats-amount tx-sender)
  )
)

;;; Peg-out sBTC by burning sSats
(define-public (peg-out (sats uint))
  (let ((ssats-amount (* sats SSATS_PER_SAT)))
    (unwrap!
      (ft-burn? ssats ssats-amount tx-sender)
      ERR_SSATS_BURN_FAILED
    )
    (unwrap!
      (contract-call?
        'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
        transfer
        sats
        (as-contract tx-sender)
        tx-sender
        (some SSATS_HEX)
      )
      ERR_SBTC_TRANSFER_FAILED
    )
    (ok true)
  )
)

;;; SIP-010 function: Transfers tokens to a recipient
;;; Sender must be the same as the caller to prevent principals from transferring tokens they do not own.
(define-public (transfer
  (amount uint)
  (sender principal)
  (recipient principal)
  (memo (optional (buff 34)))
)
  (begin
    ;; #[filter(amount, recipient)]
    (asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) ERR_NOT_TOKEN_OWNER)
    (try! (ft-transfer? ssats amount sender recipient))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)

(print
  {
    notification: "token-metadata-update",
    payload: {
      token-class: "ft",
      contract-id: (as-contract tx-sender),
      update-mode: "frozen",
    }
  }
)