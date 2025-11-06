;; Caturday Faktory - Saturday LEO Bonus for BOB Winners
;; Awards LEO tokens to BOB daily winners on Saturdays
(define-constant err-unauthorized (err u401))
(define-constant err-not-saturday (err u402))
(define-constant err-already-claimed (err u403))
(define-constant err-no-bob-winner (err u404))
(define-constant err-transfer-failed (err u405))
(define-constant err-epoch-not-drawn (err u406))
(define-constant err-insufficient-balance (err u407))
(define-constant err-already-set (err u408))

(define-constant admin 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22)
(define-constant SPONSOR_1 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G)
(define-constant SPONSOR_2 'SP2KZ24AM4X9HGTG8314MS4VSY1CVAFH0G1KBZZ1D)

(define-constant SPONSORS (list  SPONSOR_1 SPONSOR_2 admin))

(define-constant BURN-GENESIS-BLOCK u902351)
(define-constant EPOCH-LENGTH u144)
(define-data-var saturday-offset uint u41) 

(define-map saturday-claims uint bool)
(define-map leo-bonus-amounts uint uint) 
(define-data-var default-leo-bonus uint u1000000000) 

(define-read-only (is-saturday-epoch (epoch uint))
    (if (>= epoch (var-get saturday-offset))
        (is-eq (mod (- epoch (var-get saturday-offset)) u7) u0)
        false))

(define-read-only (calc-epoch (block uint))
    (/ (- block BURN-GENESIS-BLOCK) EPOCH-LENGTH))

(define-read-only (current-epoch)
    (calc-epoch burn-block-height))

(define-public (adjust-saturday-offset (new-offset uint))
    (begin
        (asserts! (is-eq tx-sender admin) err-unauthorized)
        (let ((old-offset (var-get saturday-offset)))
            (var-set saturday-offset new-offset)
            (print {
                event: "saturday-offset-adjusted",
                old-offset: old-offset,
                new-offset: new-offset,
                adjusted-by: tx-sender
            })
            (ok true))))

(define-public (set-saturday-leo-bonus (epoch uint) (leo-amount uint))
    (begin
        (asserts! (is-sponsor tx-sender) err-unauthorized)
        (asserts! (is-saturday-epoch epoch) err-not-saturday)
        (asserts! (map-insert leo-bonus-amounts epoch leo-amount) err-already-set)
        (print {
            event: "saturday-leo-bonus-set",
            epoch: epoch,
            leo-amount: leo-amount
        })
        (ok true)))

(define-public (set-default-leo-bonus (leo-amount uint))
    (begin
        (asserts! (is-eq tx-sender admin) err-unauthorized)
        (var-set default-leo-bonus leo-amount)
        (print {
            event: "default-leo-bonus-updated",
            leo-amount: leo-amount
        })
        (ok true)))

(define-public (claim-saturday-leo-bonus)
    (let ((curr-epoch (current-epoch))                    
          (previous-epoch (- curr-epoch u1))              
          (is-current-saturday (is-saturday-epoch curr-epoch))  
          (bob-winner (unwrap! (contract-call? 'SP29D6YMDNAKN1P045T6Z817RTE1AC0JAA99WAX2B.bob-bonus-faktory get-epoch-bonus-recipient previous-epoch) err-no-bob-winner))
          (is-already-claimed (default-to false (map-get? saturday-claims previous-epoch)))
          (leo-bonus (default-to (var-get default-leo-bonus) (map-get? leo-bonus-amounts previous-epoch)))
          (contract-leo-balance (unwrap-panic (contract-call? 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token get-balance (as-contract tx-sender)))))
        
        (asserts! is-current-saturday err-not-saturday)
        (asserts! (not is-already-claimed) err-already-claimed)
        (asserts! (>= contract-leo-balance leo-bonus) err-insufficient-balance)
        
        (map-set saturday-claims previous-epoch true)
        
        (try! (as-contract (contract-call? 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token transfer 
                           leo-bonus (as-contract tx-sender) bob-winner none)))
        
        (print {
            event: "saturday-leo-bonus-claimed",
            current-epoch: curr-epoch,              
            winner-epoch: previous-epoch,
            bob-winner: bob-winner,
            leo-bonus: leo-bonus,
            remaining-balance: (- contract-leo-balance leo-bonus)
        })
        
        (ok bob-winner)))

(define-public (fund-leo-bonus (leo-amount uint))
    (begin
        (asserts! (> leo-amount u0) err-transfer-failed)
        
        (try! (contract-call? 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token transfer 
               leo-amount tx-sender (as-contract tx-sender) none))
        
        (print {
            event: "contract-funded-leo",
            funder: tx-sender,
            leo-amount: leo-amount
        })
        
        (ok true)))

(define-public (withdraw-leo)
    (let ((withdrawer tx-sender))
        (asserts! (is-sponsor tx-sender) err-unauthorized)
        (let ((leo-balance (unwrap-panic (contract-call? 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token get-balance (as-contract tx-sender)))))
            
            (if (> leo-balance u0)
                (try! (as-contract (contract-call? 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token transfer
                                            leo-balance (as-contract tx-sender) withdrawer none)))
                true)
            
            (print {
                event: "leo-withdrawn",
                withdrawer: tx-sender,
                amount: leo-balance
            })
            
            (ok leo-balance))))

(define-read-only (get-leo-balance)
    (contract-call? 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token get-balance (as-contract tx-sender)))

(define-read-only (get-saturday-offset)
    (var-get saturday-offset))

(define-read-only (get-saturday-claim-status (epoch uint))
    (default-to false (map-get? saturday-claims epoch)))

(define-read-only (get-saturday-leo-bonus (epoch uint))
    (default-to (var-get default-leo-bonus) (map-get? leo-bonus-amounts epoch)))

(define-read-only (get-default-leo-bonus)
    (var-get default-leo-bonus))


(define-read-only (get-current-saturday-info)
    (let ((curr-epoch (current-epoch))          
          (previous-epoch (- curr-epoch u1))     
          (is-current-saturday (is-saturday-epoch curr-epoch))  
          (leo-bonus (get-saturday-leo-bonus previous-epoch))
          (bob-winner (default-to 'SP000000000000000000002Q6VF78 (contract-call? 'SP29D6YMDNAKN1P045T6Z817RTE1AC0JAA99WAX2B.bob-bonus-faktory get-epoch-bonus-recipient previous-epoch))))
        {
            current-epoch: curr-epoch,           
            previous-epoch: previous-epoch,
            is-current-saturday: is-current-saturday,
            leo-bonus: leo-bonus,
            previous-epoch-bob-winner: bob-winner,
            contract-leo-balance: (unwrap-panic (get-leo-balance))
        }))

(define-read-only (is-sponsor (who principal))
  (is-some (index-of SPONSORS who))
)