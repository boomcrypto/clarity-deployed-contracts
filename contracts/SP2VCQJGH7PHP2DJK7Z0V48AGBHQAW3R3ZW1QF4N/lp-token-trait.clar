(define-trait lp-token-trait
  (

    ;; -- SIP-013-trait
    ;; Get a token type balance of the passed principal.
		(get-balance (uint principal) (response uint uint))

		;; Get the total SFT balance of the passed principal.
		(get-overall-balance (principal) (response uint uint))

		;; Get the current total supply of a token type.
		(get-total-supply (uint) (response uint uint))

		;; Get the overall SFT supply.
		(get-overall-supply () (response uint uint))

		;; Get the number of decimal places of a token type.
		(get-decimals (uint) (response uint uint))

		;; Get an optional token URI that represents metadata for a specific token.
		(get-token-uri (uint) (response (optional (string-ascii 256)) uint))

		;; Transfer from one principal to another.
		(transfer (uint uint principal principal) (response bool uint))

		;; Transfer from one principal to another with a memo.
		(transfer-memo (uint uint principal principal (buff 34)) (response bool uint))


    ;; -- SIP-013-transfer-many-trait
    ;; Transfer many tokens at once.
		(transfer-many ((list 200 {token-id: uint, amount: uint, sender: principal, recipient: principal})) (response bool uint))

		;; Transfer many tokens at once with memos.
		(transfer-many-memo ((list 200 {token-id: uint, amount: uint, sender: principal, recipient: principal, memo: (buff 34)})) (response bool uint))


    ;; -- DFT trait functions
    ;; withdraw earned rewards
    (withdraw-rewards (uint principal) (response uint uint))

    ;; withdraw earned rewards
    (add-rewards (uint uint) (response uint uint))

    ;; mint and apply points correction
    (mint (uint uint principal) (response bool uint))

    ;; mint and apply points correction
    (burn (uint uint principal) (response bool uint))


    ;; -- Additional DFT functions

    ;; cycle rewards functions
    (set-cycle-start (uint uint) (response bool uint))

    ;; get amount of losses per account
    (recognize-losses (uint principal) (response uint uint))

    (recognizable-losses-of (uint principal) (response uint uint))


    ;; distribute losses to all stakers
    (distribute-losses (uint uint) (response uint uint))
  )
)
