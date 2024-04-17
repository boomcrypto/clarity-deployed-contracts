;; Please note and agreed with these before interacting with this contract
;; this is an experimental token
;; these tokens dont hold any financial value
;; no one is asking for any moneys or offering any services
;; this is not an ICO, IDO, IPO, or any similar instrument
;; this is for fun and enjoyment of the crypto community, provide as is on a experimental stage
;; there is no promise of financial returns or any kind
;; we dont control the market and have no idea what people will do with this token
;; you are free to do whatever you want with the tokens
;; the intention is for people to have fun with it and, after all fun is had, simply swap it back
;; there are risks involved on any sort of trading when using crypto
;; all tokens are at risk and may not be returned in case something goes wrong, including the ones used for the original swap
;; dont swap more than the indicated amount, and dont use tokens that you may need later
;; we can not guarantee any tokens used on this swap
;; the liquidity pool is designed for swapping back, not for buying more tokens
;; if you buy more tokens from the liquidity pool, you are likely to become exit liquidity for someone using the token in the wrong
;; way
;; these tokens are for fun. They are not a financial product, are not backed by any assets or goods, and have no utility
;; please be aware of your own country regulations, we dont recommend anyone using this token if that is not allowed by any
;; goverment body they may be subject to
;; by using this contract you agree the neither the developer nor and deployer have any liability for missing funds, damage, harm, loss, opportunity cost

;; This contract implements the SIP-010 community-standard Fungible Token trait.
(impl-trait .traits.ft-trait)



;; Define errors
(define-constant ERR_NOT_MINTER (err u200))
(define-constant ERR_AMOUNT_ZERO (err u201))
(define-constant ERR_NOT_TOKEN_OWNER (err u203))
(define-constant PRICE u10000000)

;; Define constants for contract
(define-constant MINTER 'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE) ;;central wallet
(define-constant TOKEN_NAME "Kangaroo the Jumping Coin")
(define-constant TOKEN_SYMBOL "$ROO")
(define-constant TOKEN_DECIMALS u6) ;; 6 units displayed past decimal, e.g. 1.000_000 = 1 token


;; Define the FT, with maximum supply
(define-fungible-token kangaroo u42000000000000)

(define-data-var TOKEN_URI (optional (string-utf8 256)) none)

;; SIP-010 function: Get the token balance of a specified principal
(define-read-only (get-balance (user principal))
  (ok (ft-get-balance kangaroo user))
)

;; SIP-010 function: Returns the total supply of fungible token
(define-read-only (get-total-supply)
  (ok (ft-get-supply kangaroo))
)

;; SIP-010 function: Returns the human-readable token name
(define-read-only (get-name)
  (ok TOKEN_NAME)
)

;; SIP-010 function: Returns the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL)
)

;; SIP-010 function: Returns number of decimals to display
(define-read-only (get-decimals)
  (ok TOKEN_DECIMALS)
)

(define-read-only (get-token-uri)
  (ok (var-get TOKEN_URI))
)

(define-public (transfer (amount uint) (sender principal) (receiver principal) (memo (optional (buff 34)))) 
    (begin
    ;; #[allow(unchecked_data)]
        (asserts! (is-eq tx-sender sender) ERR_NOT_TOKEN_OWNER)
        (try! (ft-transfer? kangaroo amount sender receiver))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)

(define-public (mint (amount uint) (user principal))
  (begin
    ;; #[allow(unchecked_data)]
    (asserts! (is-eq tx-sender MINTER) ERR_NOT_MINTER)
    (asserts! (> amount u0) ERR_AMOUNT_ZERO)
    (ft-mint? kangaroo amount user)
  )
)

(define-public (mint_one (user principal))
  (begin
    (try! (stx-transfer? PRICE tx-sender MINTER))
    (try! (ft-mint? kangaroo u1000000 user))
    (ok true)
  )
)

(define-public (set-token-uri (value (string-utf8 256)))
  (if
    (is-eq tx-sender MINTER)
    (ok (var-set TOKEN_URI (some value)))
    (err ERR_NOT_MINTER)
  )
)

;; To be used later [kangaroo -> *** -> ***]
(define-public (burn (amount uint))
  (ft-burn? kangaroo amount tx-sender)
)

;;