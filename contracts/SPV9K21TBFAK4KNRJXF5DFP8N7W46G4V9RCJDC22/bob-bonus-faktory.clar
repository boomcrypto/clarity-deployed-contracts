;; Burn Bob Bonus Faktory
;; Selects random bonus recipients from daily burn participants

(define-constant err-block-not-found (err u404))
(define-constant err-not-at-draw-block (err u400))
(define-constant err-standard-principal-only (err u401))
(define-constant err-unable-to-get-random-seed (err u500))
(define-constant err-no-participants (err u403))
(define-constant err-unauthorized (err u402))
(define-constant err-epoch-already-drawn (err u405))
(define-constant err-epoch-not-ready (err u406))
(define-constant err-transfer-failed (err u407))
(define-constant err-already-set (err u408))
(define-constant err-epoch-already-set (err u409))

(define-constant admin tx-sender) 
(define-constant SPONSOR 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G) 

(define-map epoch-bonus uint uint)

(define-constant BURN-CONTRACT 'SP29D6YMDNAKN1P045T6Z817RTE1AC0JAA99WAX2B.burn-bob-faktory)
(define-constant BURN-GENESIS-BLOCK u902351) 
(define-constant EPOCH-LENGTH u144) 

(define-read-only (get-rnd (block uint))
    (let (
        (vrf (buff-to-uint-be (unwrap-panic (as-max-len? (unwrap-panic (slice? (unwrap! (get-tenure-info? vrf-seed block) err-block-not-found) u16 u32)) u16))))
        (time (unwrap! (get-tenure-info? time block) err-block-not-found)))
        (ok (if is-in-mainnet (+ vrf time) vrf))))

(define-map epoch-participants uint (list 1000 principal)) 
(define-map epoch-bonus-recipients uint principal)
(define-map epoch-draw-blocks uint uint) 
(define-map epoch-status uint bool) 

(define-private (is-standard-principal-call)
    (is-none (get name (unwrap-panic (principal-destruct? contract-caller)))))

(define-read-only (calc-epoch (block uint))
  (/ (- block BURN-GENESIS-BLOCK) EPOCH-LENGTH))

(define-read-only (calc-epoch-end (epoch uint))
  (- (+ BURN-GENESIS-BLOCK (* EPOCH-LENGTH (+ epoch u1))) u1))

(define-read-only (is-epoch-finished (epoch uint))
  (> burn-block-height (calc-epoch-end epoch)))

(define-read-only (current-epoch)
  (calc-epoch burn-block-height))

(define-public (set-burners (epoch uint) (participants (list 1000 principal)))
    (begin
        (asserts! (is-eq tx-sender admin) err-unauthorized)
        (asserts! (is-none (map-get? epoch-status epoch)) err-epoch-already-set)
        (asserts! (is-epoch-finished epoch) err-epoch-not-ready)
        (map-set epoch-participants epoch participants)  
        (map-set epoch-draw-blocks epoch (+ stacks-block-height u6))    ;; 6 times amount of stacks block per burn block
        (map-set epoch-status epoch false)    
        (print {
            event: "epoch-participants-set",
            epoch: epoch,
            epoch-end-block: (calc-epoch-end epoch),
            current-burn-block: burn-block-height,
            participant-count: (len participants),
            draw-block: (+ stacks-block-height u6) ;; 6 times amount of stacks block per burn block
        })
        
        (ok true)))

(define-public (reveal-winner (epoch uint))
        (let 
            ((participants (unwrap! (map-get? epoch-participants epoch) err-no-participants))
             (draw-block (unwrap! (map-get? epoch-draw-blocks epoch) err-not-at-draw-block))
             (already-drawn (default-to false (map-get? epoch-status epoch)))
             (taille (len participants))
             (sponsor-bonus (default-to u0 (map-get? epoch-bonus epoch)))
             (max-bonus (if (> sponsor-bonus taille) sponsor-bonus taille)))
            
            (asserts! (not already-drawn) err-epoch-already-drawn)
            (asserts! (> stacks-block-height draw-block) err-not-at-draw-block)
            (asserts! (> taille u0) err-no-participants)
            
            (let
                ((random-number (unwrap! (get-rnd draw-block) err-unable-to-get-random-seed))
                 (recipient-index (mod random-number taille))
                 (chosen-recipient (unwrap! (element-at? participants recipient-index) err-no-participants)))
                
                (map-set epoch-bonus-recipients epoch chosen-recipient)
                
                (map-set epoch-status epoch true)

                (try! (as-contract (contract-call? 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G.built-on-bitcoin-stxcity 
                           transfer (* max-bonus u1000000) (as-contract tx-sender) chosen-recipient none)))
                
                (try! (as-contract (contract-call? 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.fakfun-faktory 
                           transfer (* max-bonus u100000000) (as-contract tx-sender) chosen-recipient none)))
                
                (print {
                    event: "epoch-bonus-recipient-selected",
                    epoch: epoch,
                    recipient: chosen-recipient,
                    total-participants: taille,
                    sponsor-bonus: sponsor-bonus,
                    final-bonus: max-bonus,
                    draw-block: draw-block,
                    random-seed: random-number
                })
                
                (ok chosen-recipient))))

;; Read-only
(define-read-only (get-epoch-participants (epoch uint))
    (map-get? epoch-participants epoch))

(define-read-only (get-epoch-bonus-recipient (epoch uint))
    (map-get? epoch-bonus-recipients epoch))

(define-read-only (get-epoch-draw-block (epoch uint))
    (map-get? epoch-draw-blocks epoch))

(define-read-only (is-epoch-drawn (epoch uint))
    (default-to false (map-get? epoch-status epoch)))

(define-read-only (get-bonus-info (epoch uint))
    (let ((participants (map-get? epoch-participants epoch))
          (recipient (map-get? epoch-bonus-recipients epoch))
          (draw-block (map-get? epoch-draw-blocks epoch))
          (is-drawn (default-to false (map-get? epoch-status epoch))))
        {
            participants: participants,
            recipient: recipient,
            draw-block: draw-block,
            is-drawn: is-drawn,
            can-draw: (and (is-some draw-block) 
                          (not is-drawn)
                          (> stacks-block-height (unwrap-panic draw-block)))
        }))

;; Sponsor
(define-public (set-next-epoch-bonus (bonus-amount uint))
    (let 
        ((next-epoch (+ (current-epoch) u1)))
        (asserts! (is-eq tx-sender SPONSOR) err-unauthorized)
        
        (asserts! (map-insert epoch-bonus next-epoch bonus-amount) err-already-set)
        
        (print {
            event: "next-epoch-bonus-set",
            next-epoch: next-epoch,
            bonus-amount: bonus-amount,
            sponsor: SPONSOR
        })
        
        (ok true)))

(define-read-only (get-epoch-sponsor-bonus (epoch uint))
    (map-get? epoch-bonus epoch))

(define-public (fund-bonus (bob-bonus uint))
    (begin
        (asserts! (> bob-bonus u0) err-transfer-failed) 

        (try! (contract-call? 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G.built-on-bitcoin-stxcity 
               transfer bob-bonus tx-sender (as-contract tx-sender) none))
        (try! (contract-call? 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.fakfun-faktory 
               transfer (* bob-bonus u100) tx-sender (as-contract tx-sender) none))
        
        (print {
            event: "contract-funded",
            funder: tx-sender,
            bob-bonus: bob-bonus,
            fakfun-bonus: (* bob-bonus u100)
        })
        
        (ok true)))

(define-read-only (get-bob-balance)
    (contract-call? 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G.built-on-bitcoin-stxcity 
                    get-balance (as-contract tx-sender)))

(define-read-only (get-fakfun-balance)
    (contract-call? 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.fakfun-faktory 
                    get-balance (as-contract tx-sender)))

(define-public (withdraw-dble)
    (begin
        (asserts! (is-eq tx-sender SPONSOR) err-unauthorized)
        (let ((bob-balance (unwrap-panic (contract-call? 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G.built-on-bitcoin-stxcity get-balance (as-contract tx-sender))))
              (fakfun-balance (unwrap-panic (contract-call? 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.fakfun-faktory get-balance (as-contract tx-sender)))))
            
            (if (> bob-balance u0)
                (try! (as-contract (contract-call? 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G.built-on-bitcoin-stxcity transfer
                                            bob-balance (as-contract tx-sender) SPONSOR none)))
                true)
            
            (if (> fakfun-balance u0)
                (try! (as-contract (contract-call? 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.fakfun-faktory transfer
                                            fakfun-balance (as-contract tx-sender) SPONSOR none)))
                true)
            
            (ok true))))