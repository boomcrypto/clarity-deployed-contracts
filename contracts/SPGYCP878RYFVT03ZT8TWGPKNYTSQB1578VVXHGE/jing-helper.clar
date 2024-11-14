(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-price-zero (err u102))
(define-constant err-amount-zero (err u103))

(define-public (make-batch-offers (price uint) (amount uint) (diff uint))
    (begin
        (asserts! (> price u0) err-price-zero)
        (asserts! (> amount u0) err-amount-zero)
        
        ;; Price ve diff decimal 8, amount decimal 6
        ;; Convert diff to decimal 8
        (let 
            (
                (price-decimal (* price u100000000))  ;; decimal 8
                (amount-decimal (* amount u1000000))   ;; decimal 6
                (diff-decimal (* diff u1000000))     ;; decimal 6
            )
            
            ;; First offer
            (try! (contract-call? 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.dmg-cha offer 
                price-decimal
                amount-decimal 
                none))
                
            ;; Second offer
            (try! (contract-call? 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.dmg-cha offer 
                (+ price-decimal diff-decimal)
                amount-decimal 
                none))
                
            ;; Third offer
            (try! (contract-call? 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.dmg-cha offer 
                (+ price-decimal (* diff-decimal u2))
                amount-decimal 
                none))
                
            ;; Fourth offer
            (try! (contract-call? 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.dmg-cha offer 
                (+ price-decimal (* diff-decimal u3))
                amount-decimal 
                none))
                
            ;; Fifth offer
            (try! (contract-call? 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.dmg-cha offer 
                (+ price-decimal (* diff-decimal u4))
                amount-decimal 
                none))
                
            ;; Sixth offer
            (try! (contract-call? 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.dmg-cha offer 
                (+ price-decimal (* diff-decimal u5))
                amount-decimal 
                none))
                
            ;; Seventh offer
            (try! (contract-call? 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.dmg-cha offer 
                (+ price-decimal (* diff-decimal u6))
                amount-decimal 
                none))
                
            ;; Eighth offer
            (try! (contract-call? 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.dmg-cha offer 
                (+ price-decimal (* diff-decimal u7))
                amount-decimal 
                none))
                
            ;; Ninth offer
            (try! (contract-call? 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.dmg-cha offer 
                (+ price-decimal (* diff-decimal u8))
                amount-decimal 
                none))
                
            ;; Tenth offer
            (try! (contract-call? 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.dmg-cha offer 
                (+ price-decimal (* diff-decimal u9))
                amount-decimal 
                none))
            
            (ok true)
        )
    )
)

;; Read-only function to get contract owner
(define-read-only (get-contract-owner)
    contract-owner)