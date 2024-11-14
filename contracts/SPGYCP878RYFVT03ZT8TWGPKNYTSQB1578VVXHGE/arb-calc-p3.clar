;; Token Price Calculator Contract V5

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-pool (err u101))

;; Helper function to calculate token price based on pool reserves
(define-private (calculate-token-price (reserve0 uint) (reserve1 uint))
    (/ (* reserve1 u1000000) reserve0))

;; Get all prices in one call
(define-public (get-prices)
    (let (
        (data (unwrap! (contract-call? .arb-pricev3 call-me) err-invalid-pool))
        (pools (get pools data))
        
        ;; Get individual reserves
        (welsh-stx-r0 (get reserve00 pools))
        (welsh-stx-r1 (get reserve10 pools))
        (pepe-stx-r0 (get reserve06 pools))
        (pepe-stx-r1 (get reserve16 pools))
        (welsh-iou-r0 (get reserve01 pools))
        (welsh-iou-r1 (get reserve11 pools))
        (stx-cha-r0 (get reserve04 pools))
        (stx-cha-r1 (get reserve14 pools))
        (stx-syn-r0 (get reserve05 pools))
        (stx-syn-r1 (get reserve15 pools))
        
        ;; Calculate prices
        (welsh-price (calculate-token-price welsh-stx-r1 welsh-stx-r0))
        (pepe-price (calculate-token-price pepe-stx-r1 pepe-stx-r0))
        (welsh-iou-ratio (calculate-token-price welsh-iou-r1 welsh-iou-r0))
        (iouwelsh-price (/ (* welsh-iou-ratio welsh-price) u1000000))
        (cha-price (calculate-token-price stx-cha-r1 stx-cha-r0))
        (synstx-price (calculate-token-price stx-syn-r1 stx-syn-r0))
    )
    (ok {
        welsh: welsh-price,
        pepe: pepe-price,
        iouwelsh: iouwelsh-price,
        cha: cha-price,
        synstx: synstx-price
    })))