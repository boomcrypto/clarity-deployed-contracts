
;; title: alex-go-swap-wrapper
;; summary: wrapper contract to Swap STX to xBTC using AlexGo pools 
;; description:
;;
;; units are in 10^8 => 1 STX = 100000000
;; use AlexGo sandbox to check 

;; fee-helper 
;; https://app.alexlab.co/_sandbox?contract=swap-helper-v1-03&function=fee-helper&args_token-x=SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx&args_token-y=SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc
;; 3000000 = 3 * 10^8 * 10^-2

;; get-helper y amount for 5 STX 
;; https://app.alexlab.co/_sandbox?contract=swap-helper-v1-03&function=get-helper&args_token-x=SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx&args_token-y=SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc&args_dx=500000000
;; 17535 =  17535 * 10^8 * 10^-3 
;; remove fees = 17535 * (1 - 0.03) = 16989.65
;; y_amount = get-helper * (1 - (fee-hlper / 10^8))
;;          = get-helper * (10^8 - fee-helper) / 10^8
;;          = mul-down(get-helper, (ONE_8 - fee-helper))

;; swap-helper 
;; https://app.alexlab.co/_sandbox?contract=swap-helper-v1-03&function=swap-helper&args_token-x-trait=SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx&args_token-y-trait=SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc&args_dx=500000000&args_min-dy=15000

(use-trait ft-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)

(define-constant ONE_8 u100000000)

(define-private (to-one-8 (a uint))
  (* a ONE_8))

(define-private (mul-down (a uint) (b uint))
  (/ (* a b) ONE_8))

(define-private (div-down (a uint) (b uint))
  (if (is-eq a u0)
    u0
    (/ (* a ONE_8) b)))

(define-private (minus-percent (a uint) (percent uint))
  (if (is-eq a u0)
    u0
    (/ (- (* a u100) (* a percent)) u100)))


;; input:  'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc 5 4
(define-public (swap-stx-to-xbtc (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (stx-amount uint) (slippeage uint)) 
  (let (
    (stx-formatted-amount (to-one-8 stx-amount))
    (token-x (contract-of token-x-trait))
    (token-y (contract-of token-y-trait))
    (fee-amount 
      (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 fee-helper token-x token-y))
    (xbtc-amount 
      (mul-down 
        (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 get-helper token-x token-y stx-formatted-amount)) 
        (- ONE_8 (unwrap-panic fee-amount))))
    (xbtc-amount-slippeage (minus-percent xbtc-amount slippeage)))
    (try! (print fee-amount))
    (print (some xbtc-amount))
    (print (some xbtc-amount-slippeage))
    (try! (contract-call? 
        'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 
        swap-helper
        token-x-trait
        token-y-trait
        stx-formatted-amount
        (some xbtc-amount-slippeage)))
    (ok true)))
