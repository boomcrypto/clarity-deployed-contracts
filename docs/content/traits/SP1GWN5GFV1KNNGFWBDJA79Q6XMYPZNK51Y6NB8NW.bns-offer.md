---
title: "Trait bns-offer"
draft: true
---
```
;; BNS One offers

(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait) ;; 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9

(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait) ;; 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE

(define-private (transfer-nft (token-contract <nft-trait>) (token-id uint) (sender principal) (recipient principal))
  (contract-call? token-contract transfer token-id sender recipient)
)

(define-private (transfer-ft (token-contract <sip-010-trait>) (amount uint) (sender principal) (recipient principal))
  (contract-call? token-contract transfer amount sender recipient none)
)

(define-private (get-balance-ft (token-contract <sip-010-trait>) (address principal) )
    (contract-call? token-contract get-balance address)
)

(define-private (get-last-id (token-contract <nft-trait>))
  (contract-call? token-contract get-last-token-id)
)
(define-private (get-owner-id (token-contract <nft-trait>) (id uint))
  (contract-call? token-contract get-owner id)
)

(define-constant BNS 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2) ;; SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2
;; errors
(define-constant NOT_ZERO (err u200))
(define-constant NOT_IN_THE_PAST (err u201))
(define-constant NOT_MINTED (err u202))
(define-constant NOT_THE_TAKER (err u203))
(define-constant NOT_A_VALID_OFFER (err u204))
(define-constant NOT_THE_SELLER (err u205))
(define-constant NOT_VALID_ID (err u206))
(define-constant TOO_LOW (err u207))
(define-constant NOT_THE_OWNER (err u208))
(define-constant NO_COUNTEROFFER (err u209))
(define-constant NOT_EDITABLE (err u210))
(define-constant ALREADY_ACCEPTED (err u211)) ;; offerer accepted the counteroffer
(define-constant NOT_IN_THE_VAULT (err u212))
(define-constant TOO_SHORT (err u213)) ;; minimum one day => 144 btc blocks
(define-constant NOT_YOURSELF (err u214)) 
(define-constant TOO_MUCH (err u215))
(define-constant IS_PAUSED (err u216))
(define-constant NOT_ACTIVE (err u217))
(define-constant NOT_VALID_TOKEN (err u218))

;; main mapping for Offers
(define-map OFFER uint {
    id: uint,
    seller: principal,
    taker: principal,
    amount: uint,
    token: (optional principal),
    expiration: uint,
    counteroffer: (optional uint),
    status: (string-ascii 12),
})

(define-data-var NEXT_OFFER uint u1)
(define-data-var AMOUNT_LOCKED uint u0) ;; track the amount locked in the contract
(define-constant VAULT (as-contract tx-sender)) ;; the contract address
(define-data-var OWNER principal tx-sender) ;; BNS One 'SM18RN48GX7E3ED23M03BY4QD8EA2DG2R4VX4CDYJ
(define-data-var TREASURY principal 'SM18RN48GX7E3ED23M03BY4QD8EA2DG2R4VX4CDYJ) 
(define-data-var PAUSED bool false) ;; Pause only the creation of new offers
(define-data-var MIN_AMOUNT uint u1000000) ;; min amount for offers 1STX
(define-map TOKENS principal {active: bool, min: uint, locked: uint})
(map-set TOKENS 'ST1F7QA2MDF17S807EPA36TSS8AMEFY4KA9TVGWXT.sbtc-token {active: true, min: u100, locked: u0})

;; offers are sent to current owner of the name
(define-public (place-offer (id uint) (amount uint) (expiration uint)  )
    (let (
        (current-offer (var-get NEXT_OFFER))
        (owner (unwrap! (get-owner-id BNS id ) NOT_VALID_ID))
    )   
        (asserts! (>= amount (var-get MIN_AMOUNT)) TOO_LOW)
        (asserts! (is-some owner) NOT_MINTED)
        (asserts! (not (is-eq (unwrap-panic owner) contract-caller)) NOT_YOURSELF)
        (asserts! (> expiration burn-block-height) NOT_IN_THE_PAST)
        (asserts! (>= expiration (+ burn-block-height u144)) TOO_SHORT)
        (asserts! (not (var-get PAUSED)) IS_PAUSED)
        (try! (stx-transfer? amount contract-caller VAULT))
        
        (map-set OFFER current-offer {
            id: id,
            seller: (unwrap-panic owner),
            taker: contract-caller,
            amount: amount,
            token: none,
            expiration: expiration,
            counteroffer: none,
            status: "active"
        })
        (print {
            topic: "Offer",
            offer: current-offer,
            id: id,
            seller: (unwrap-panic owner),
            taker: contract-caller,
            amount: amount,
            expiration: expiration,
            url: (get-url current-offer),
        })
        (var-set NEXT_OFFER (+ current-offer u1))
        (var-set AMOUNT_LOCKED (+ (var-get AMOUNT_LOCKED) amount))
        (try! (as-contract (stx-transfer? u1 tx-sender (unwrap-panic owner)) ))
        (ok true)
    )
)

(define-public (place-offer-ft (id uint) (amount uint) (expiration uint) (token <sip-010-trait>) )
    (let (
        (current-offer (var-get NEXT_OFFER))
        (owner (unwrap! (get-owner-id BNS id ) NOT_VALID_ID))
        (tokendata (get-token token))
    )   
        (asserts! (get active tokendata) NOT_VALID_TOKEN)
        (asserts! (>= amount (get min tokendata)) TOO_LOW)
        (asserts! (is-some owner) NOT_MINTED)
        (asserts! (not (is-eq (unwrap-panic owner) contract-caller)) NOT_YOURSELF)
        (asserts! (> expiration burn-block-height) NOT_IN_THE_PAST)
        (asserts! (>= expiration (+ burn-block-height u144)) TOO_SHORT)
        (asserts! (not (var-get PAUSED)) IS_PAUSED)
        (try! (transfer-ft token amount contract-caller VAULT))
        
        (map-set OFFER current-offer {
            id: id,
            seller: (unwrap-panic owner),
            taker: contract-caller,
            amount: amount,
            token: (some (contract-of token)),
            expiration: expiration,
            counteroffer: none,
            status: "active"
        })
        (print {
            topic: "Offer",
            offer: current-offer,
            id: id,
            seller: (unwrap-panic owner),
            taker: contract-caller,
            amount: amount,
            token: token,
            expiration: expiration,
            url: (get-url current-offer),
        })
        (var-set NEXT_OFFER (+ current-offer u1))
        (add-amount token amount)
        (try! (as-contract (stx-transfer? u1 tx-sender (unwrap-panic owner)) ))
        (ok true)
    )
)

;; User can extend expiration or increase the offer amount
(define-public (change-offer (offer uint) (amount uint) (expiration uint))
    (let (
        (current-offer (get-offer offer))
        (id (get id current-offer))
        (seller (get seller current-offer))
        (taker (get taker current-offer))
        (offer-amount (get amount current-offer))
        (exp-block (get expiration current-offer))
        (status (get status current-offer))
        (owner (unwrap! (get-owner-id BNS id ) NOT_VALID_ID))
        
    )   
        (asserts! (not (is-eq status "not valid")) NOT_A_VALID_OFFER)
        (asserts! (is-eq status "active") ALREADY_ACCEPTED) ;; Accepted counteroffers cannot be changed
        (asserts! (>= expiration exp-block) NOT_IN_THE_PAST)
        (asserts! (>= expiration (+ burn-block-height u144)) TOO_SHORT)
        (asserts! (not (is-eq (unwrap-panic owner) VAULT)) NOT_EDITABLE) ;; if name is in the contract cannot be changed
        (asserts! (>= amount offer-amount) TOO_LOW) ;; Offerer can only increase amount. Create a new offer to decrease
        (map-set OFFER offer {
            id: id,
            seller: seller,
            taker: taker,
            amount: amount,
            token: none,
            expiration: expiration,
            counteroffer: (get counteroffer current-offer),
            status: status,
        })
        (print {
            topic: "Offer update",
            offer: offer,
            id: id,
            seller: seller,
            taker: taker,
            amount: amount,
            expiration: expiration,
            url: (get-url offer),
        })
        (try! (as-contract (stx-transfer? u1 tx-sender (unwrap-panic owner)) ))
        (if (is-eq offer-amount amount)
            (ok offer) ;; no transfer if amount doesn't change
            (begin ;; user transfer only the difference
                (var-set AMOUNT_LOCKED (+ (var-get AMOUNT_LOCKED) (- amount offer-amount)))
                (try! (stx-transfer? (- amount offer-amount) contract-caller VAULT))
                (ok offer)
            )
            
        ) 
    )
)

(define-public (change-offer-ft (offer uint) (amount uint) (expiration uint) (token <sip-010-trait>))
    (let (
        (current-offer (get-offer offer))
        (id (get id current-offer))
        (seller (get seller current-offer))
        (taker (get taker current-offer))
        (offer-amount (get amount current-offer))
        (exp-block (get expiration current-offer))
        (status (get status current-offer))
        (owner (unwrap! (get-owner-id BNS id ) NOT_VALID_ID))
        
    )   
        (asserts! (not (is-eq status "not valid")) NOT_A_VALID_OFFER)
        (asserts! (is-eq (unwrap-panic (get token current-offer)) (contract-of token)) NOT_VALID_TOKEN)
        (asserts! (is-eq status "active") ALREADY_ACCEPTED) ;; Accepted counteroffers cannot be changed
        (asserts! (>= expiration exp-block) NOT_IN_THE_PAST)
        (asserts! (>= expiration (+ burn-block-height u144)) TOO_SHORT)
        (asserts! (not (is-eq (unwrap-panic owner) VAULT)) NOT_EDITABLE) ;; if name is in the contract cannot be changed
        (asserts! (>= amount offer-amount) TOO_LOW) ;; Offerer can only increase amount. Create a new offer to decrease
        (map-set OFFER offer {
            id: id,
            seller: seller,
            taker: taker,
            amount: amount,
            token: (get token current-offer),
            expiration: expiration,
            counteroffer: (get counteroffer current-offer),
            status: status,
        })
        (print {
            topic: "Offer update",
            offer: offer,
            id: id,
            seller: seller,
            taker: taker,
            amount: amount,
            expiration: expiration,
            url: (get-url offer),
        })
        (try! (as-contract (stx-transfer? u1 tx-sender (unwrap-panic owner)) ))
        (if (is-eq offer-amount amount)
            (ok offer) ;; no transfer if amount doesn't change
            (begin ;; user transfer only the difference
                (add-amount token (- amount offer-amount))
                (try! (transfer-ft token (- amount offer-amount) contract-caller VAULT))
                (ok offer)
            )
            
        ) 
    )
)

;; to bypass BNS-V2 limitations owner needs to send the name 
;; to the contract vault before accepting the offer

(define-public (accept-offer (offer uint))
    (let (
        (sender contract-caller)
        (current-offer (get-offer offer))
        (id (get id current-offer))
        (seller (get seller current-offer))
        (taker (get taker current-offer))
        (amount (get amount current-offer))
        (exp-block (get expiration current-offer))
        (status (get status current-offer))
        (commission (/ (* amount u5) u100))
        (owner (unwrap! (get-owner-id BNS id ) NOT_VALID_ID))
    )   
        (asserts! (not (is-eq status "not valid")) NOT_A_VALID_OFFER)
        (asserts! (is-eq sender seller) NOT_THE_SELLER) ;; only the seller can accept
        (asserts! (is-eq (unwrap-panic owner) VAULT) NOT_IN_THE_VAULT) ;; check if the contract is the owner
        (asserts! (< burn-block-height exp-block) NOT_IN_THE_PAST) ;; Check if offer is not expired
        (map-delete OFFER offer)
        (print {
            topic: "taken",
            offer: offer,
            id: id,
            seller: contract-caller,
            taker: taker,
            amount: amount,
            url: (get-url offer),
        })
        (var-set AMOUNT_LOCKED (- (var-get AMOUNT_LOCKED) amount))
        (try! (as-contract (transfer-nft BNS id tx-sender taker)))
        (try! (as-contract (stx-transfer? commission tx-sender (var-get TREASURY))))
        (try! (as-contract (stx-transfer? (- amount commission) tx-sender sender)))
        (ok offer) 
    )
)

(define-public (accept-offer-ft (offer uint) (token <sip-010-trait>))
    (let (
        (sender contract-caller)
        (current-offer (get-offer offer))
        (id (get id current-offer))
        (seller (get seller current-offer))
        (taker (get taker current-offer))
        (amount (get amount current-offer))
        (exp-block (get expiration current-offer))
        (status (get status current-offer))
        (commission (/ (* amount u5) u100))
        (owner (unwrap! (get-owner-id BNS id ) NOT_VALID_ID))
    )   
        (asserts! (not (is-eq status "not valid")) NOT_A_VALID_OFFER)
        (asserts! (is-eq (unwrap-panic (get token current-offer)) (contract-of token)) NOT_VALID_TOKEN)
        (asserts! (is-eq sender seller) NOT_THE_SELLER) ;; only the seller can accept
        (asserts! (is-eq (unwrap-panic owner) VAULT) NOT_IN_THE_VAULT) ;; check if the contract is the owner
        (asserts! (< burn-block-height exp-block) NOT_IN_THE_PAST) ;; Check if offer is not expired
        (map-delete OFFER offer)
        (print {
            topic: "taken",
            offer: offer,
            id: id,
            seller: contract-caller,
            taker: taker,
            amount: amount,
            token: (get token current-offer),
            url: (get-url offer),
        })
        (remove-amount token amount)
        (try! (as-contract (transfer-nft BNS id tx-sender taker)))
        (try! (as-contract (transfer-ft token commission tx-sender (var-get TREASURY))))
        (try! (as-contract (transfer-ft token (- amount commission) tx-sender sender)))
        (ok offer) 
    )
)

;; owner of the name can send a counter offer to taker

(define-public (counter-offer (offer uint) (counteroffer uint))
    (let (
        (sender contract-caller)
        (current-offer (get-offer offer))
        (id (get id current-offer))
        (seller (get seller current-offer))
        (taker (get taker current-offer))
        (amount (get amount current-offer))
        (exp-block (get expiration current-offer))
        (status (get status current-offer))
        (owner (unwrap! (get-owner-id BNS id ) NOT_VALID_ID))
    )   
        (asserts! (not (is-eq status "not valid")) NOT_A_VALID_OFFER)
        (asserts! (< burn-block-height exp-block) NOT_IN_THE_PAST)
        (asserts! (> counteroffer amount) TOO_LOW)
        (asserts! (is-eq (unwrap-panic owner) sender) NOT_THE_OWNER)
        (map-set OFFER offer {
            id: id,
            seller: seller,
            taker: taker,
            amount: amount,
            token: (get token current-offer),
            expiration: exp-block,
            counteroffer: (some counteroffer),
            status: "active",
        })
        (print {
            topic: "Counteroffer",
            offer: offer,
            id: id,
            seller: sender,
            taker: taker,
            amount: amount,
            counteroffer: counteroffer,
            token: (get token current-offer),
            url: (get-url offer),
        })
        (try! (as-contract (stx-transfer? u1 tx-sender taker) ))
        (ok offer) 
    )
)

;; the taker need to transfer the difference before the
;; offer can be accepted by seller

(define-public (accept-counter-offer (offer uint) (expiration uint))
    (let (
        (sender contract-caller)
        (current-offer (get-offer offer))
        (id (get id current-offer))
        (seller (get seller current-offer))
        (taker (get taker current-offer))
        (amount (get amount current-offer))
        (exp-block (get expiration current-offer))
        (counteroffer (get counteroffer current-offer))
        (status (get status current-offer))
        (owner (unwrap! (get-owner-id BNS id ) NOT_VALID_ID))
    )   
        (asserts! (is-some counteroffer) NO_COUNTEROFFER)
        (asserts! (not (is-eq status "not valid")) NOT_A_VALID_OFFER)
        (asserts! (is-eq status "active") NOT_ACTIVE) ;; only active offers can be accepted
        (asserts! (is-eq sender taker) NOT_THE_TAKER)
        (asserts! (and (< burn-block-height expiration) (>= expiration exp-block)) NOT_IN_THE_PAST)
        (asserts! (>= expiration (+ burn-block-height u144)) TOO_SHORT)
        (let (
            (counter_amount (unwrap-panic counteroffer) )
        )
            (map-set OFFER offer {
                id: id,
                seller: seller,
                taker: taker,
                amount: counter_amount,
                token: none,
                expiration: expiration,
                counteroffer: counteroffer,
                status: "accepted",
            })
            (print {
                topic: "Counteroffer accepted",
                offer: offer,
                id: id,
                seller: seller,
                taker: taker,
                amount: counter_amount,
                counteroffer: counter_amount,
                url: (get-url offer),
            })
            (var-set AMOUNT_LOCKED (+ (var-get AMOUNT_LOCKED) (- counter_amount amount)))
            (try! (as-contract (stx-transfer? u1 tx-sender (unwrap-panic owner)) ))
            (try! (stx-transfer? (- counter_amount amount) sender VAULT))
            (ok offer) 
        )
    )
)

(define-public (accept-counter-offer-ft (offer uint) (expiration uint) (token <sip-010-trait>))
    (let (
        (sender contract-caller)
        (current-offer (get-offer offer))
        (id (get id current-offer))
        (seller (get seller current-offer))
        (taker (get taker current-offer))
        (amount (get amount current-offer))
        (exp-block (get expiration current-offer))
        (counteroffer (get counteroffer current-offer))
        (status (get status current-offer))
        (owner (unwrap! (get-owner-id BNS id ) NOT_VALID_ID))
    )   
        (asserts! (is-some counteroffer) NO_COUNTEROFFER)
        (asserts! (is-eq (unwrap-panic (get token current-offer)) (contract-of token)) NOT_VALID_TOKEN)
        (asserts! (not (is-eq status "not valid")) NOT_A_VALID_OFFER)
        (asserts! (is-eq status "active") NOT_ACTIVE) ;; only active offers can be accepted
        (asserts! (is-eq sender taker) NOT_THE_TAKER)
        (asserts! (and (< burn-block-height expiration) (>= expiration exp-block)) NOT_IN_THE_PAST)
        (asserts! (>= expiration (+ burn-block-height u144)) TOO_SHORT)
        (let (
            (counter_amount (unwrap-panic counteroffer) )
        )
            (map-set OFFER offer {
                id: id,
                seller: seller,
                taker: taker,
                amount: counter_amount,
                token: (get token current-offer),
                expiration: expiration,
                counteroffer: counteroffer,
                status: "accepted",
            })
            (print {
                topic: "Counteroffer accepted",
                offer: offer,
                id: id,
                seller: seller,
                taker: taker,
                amount: counter_amount,
                counteroffer: counter_amount,
                url: (get-url offer),
            })
            (add-amount token (- counter_amount amount))
            (try! (as-contract (stx-transfer? u1 tx-sender (unwrap-panic owner)) ))
            (try! (transfer-ft token (- counter_amount amount) sender VAULT))
            (ok offer) 
        )
    )
)

;; at any moment the taker can withdraw his funds.
;; if the name is in the contract it will be sent to seller

(define-public (withdraw-offer (offer uint))
    (let (
        (sender contract-caller)
        (current-offer (get-offer offer))
        (id (get id current-offer))
        (seller (get seller current-offer))
        (taker (get taker current-offer))
        (amount (get amount current-offer))
        (exp-block (get expiration current-offer))
        (status (get status current-offer))
        (owner (unwrap! (get-owner-id BNS id ) NOT_VALID_ID))
    )   
        (asserts! (not (is-eq status "not valid")) NOT_A_VALID_OFFER)
        (asserts! (is-eq sender taker) NOT_THE_TAKER)
        ;; this asserts enforce the admin-accept-offer
        (asserts! (not (is-eq seller VAULT)) NOT_THE_SELLER)
        
        (map-delete OFFER offer )
            (print {
                topic: "Offer deleted",
                offer: offer,
                id: id,
                taker: taker,
            })
        (var-set AMOUNT_LOCKED (- (var-get AMOUNT_LOCKED) amount))
        (try! (as-contract (stx-transfer? amount tx-sender sender )))
        (if (is-eq (unwrap-panic owner) VAULT)
            (begin 
                (try! (as-contract (transfer-nft BNS id tx-sender seller)))
                (ok offer)
            )
            (begin 
                (try! (as-contract (stx-transfer? u1 tx-sender (unwrap-panic owner)) ))
                (ok offer)
            )
        
        )
        
    )   
)

(define-public (withdraw-offer-ft (offer uint) (token <sip-010-trait>))
    (let (
        (sender contract-caller)
        (current-offer (get-offer offer))
        (id (get id current-offer))
        (seller (get seller current-offer))
        (taker (get taker current-offer))
        (amount (get amount current-offer))
        (exp-block (get expiration current-offer))
        (status (get status current-offer))
        (owner (unwrap! (get-owner-id BNS id ) NOT_VALID_ID))
    )   
        (asserts! (not (is-eq status "not valid")) NOT_A_VALID_OFFER)
        (asserts! (is-eq sender taker) NOT_THE_TAKER)
        (asserts! (is-eq (unwrap-panic (get token current-offer)) (contract-of token)) NOT_VALID_TOKEN)
        ;; this asserts enforce the admin-accept-offer
        (asserts! (not (is-eq seller VAULT)) NOT_THE_SELLER)
        
        (map-delete OFFER offer )
            (print {
                topic: "Offer deleted",
                offer: offer,
                id: id,
                taker: taker,
            })
        (remove-amount token amount)
        (try! (as-contract (transfer-ft token amount tx-sender sender )))
        (if (is-eq (unwrap-panic owner) VAULT)
            (begin 
                (try! (as-contract (transfer-nft BNS id tx-sender seller)))
                (ok offer)
            )
            (begin 
                (try! (as-contract (stx-transfer? u1 tx-sender (unwrap-panic owner)) ))
                (ok offer)
            )
        
        )
        
    )   
)

;; panic function to withdraw name from contract
;; works with an active offer only and seller as contract caller
(define-public (withdraw-name (offer uint))
    (let (
        (sender contract-caller)
        (current-offer (get-offer offer))
        (id (get id current-offer))
        (seller (get seller current-offer))
        (taker (get taker current-offer))
        (amount (get amount current-offer))
        (exp-block (get expiration current-offer))
        (status (get status current-offer))
        (owner (unwrap! (get-owner-id BNS id ) NOT_VALID_ID))
    )   
        (asserts! (not (is-eq status "not valid")) NOT_A_VALID_OFFER)
        (asserts! (is-eq sender seller) NOT_THE_SELLER)
        (asserts! (is-eq (unwrap-panic owner) VAULT) NOT_IN_THE_VAULT)

        (map-set OFFER offer {
                id: id,
                seller: seller,
                taker: taker,
                amount: amount,
                token: (get token current-offer),
                expiration: u0,
                counteroffer: (get counteroffer current-offer),
                status: status,
            })
            (print {
                topic: "Name withdraw",
                offer: offer,
                id: id,
                seller: seller,
                taker: taker,
            })
        (try! (as-contract (transfer-nft BNS id tx-sender seller)))
        (ok offer)
    )   
)

;; panic admin function in case a user sends a name
;; to the contract without an active offer
;; Seller must be the contract 

(define-public (admin-accept-offer (offer uint))
    (let (
        (current-offer (get-offer offer))
        (id (get id current-offer))
        (seller (get seller current-offer))
        (taker (get taker current-offer))
        (amount (get amount current-offer))
        (exp-block (get expiration current-offer))
        (status (get status current-offer))
        (commission (/ (* amount u5) u100))
        (owner (unwrap! (get-owner-id BNS id ) NOT_VALID_ID))
    )   
        (asserts! (not (is-eq status "not valid")) NOT_A_VALID_OFFER)
        (asserts! (is-eq seller VAULT) NOT_THE_SELLER) ;; Prevents admin to accept normal offers
        (asserts! (is-eq contract-caller (var-get OWNER)) NOT_THE_OWNER) ;; Only owner can accept
        (asserts! (is-eq (unwrap-panic owner) VAULT) NOT_IN_THE_VAULT) ;; check if the contract is the owner
        (asserts! (< burn-block-height exp-block) NOT_IN_THE_PAST)

        (map-delete OFFER offer)
        (print {
            topic: "unlocked",
            offer: offer,
            id: id,
            seller: contract-caller,
            taker: taker,
            amount: amount,
        })
        (var-set AMOUNT_LOCKED (- (var-get AMOUNT_LOCKED) amount))
        (try! (as-contract (transfer-nft BNS id tx-sender taker)))
        (try! (as-contract (stx-transfer? commission tx-sender (var-get OWNER))))
        (try! (as-contract (stx-transfer? (- amount commission) tx-sender taker)))
        (ok offer) 
    )
)

;; safe admin stx withdraw 

(define-public (admin-safe-withdraw-stx (amount uint))
    (let (
        (balance (stx-get-balance VAULT))
        ;; amount locked cannot be withdraw
        (available (- balance (var-get AMOUNT_LOCKED)))
    ) 
    (asserts! (<= amount available) TOO_MUCH ) ;; amount must be less the available
    (asserts! (is-eq contract-caller (var-get OWNER)) NOT_THE_OWNER) ;; Only owner can withdraw
    (try! (as-contract (stx-transfer? amount tx-sender (var-get OWNER))))
    (ok amount)
    )
)

;; safe admin ft withdraw 

(define-public (admin-safe-withdraw-ft (amount uint) (token <sip-010-trait>))
    (let (
        (balance (unwrap-panic (get-balance-ft token VAULT)))
        (tokendata (get-token token))
        ;; amount locked cannot be withdraw
        (available (- balance (get locked tokendata)))
    ) 
    (asserts! (<= amount available) TOO_MUCH ) ;; amount must be less the available
    (asserts! (is-eq contract-caller (var-get OWNER)) NOT_THE_OWNER) ;; Only owner can withdraw
    (try! (as-contract (transfer-ft token amount tx-sender (var-get OWNER))))
    (ok amount)
    )
)

;; admin can pause only the creation of new offers

(define-public (admin-pause)
    (begin
    (asserts! (is-eq contract-caller (var-get OWNER)) NOT_THE_OWNER) ;; Only owner can pause
    (var-set PAUSED (not (var-get PAUSED)))
    (ok (var-get PAUSED))
    )
)

;; admin can transfer ownership

(define-public (admin-transfer-ownership (address principal))
    (begin
    (asserts! (is-eq contract-caller (var-get OWNER)) NOT_THE_OWNER) ;; Only owner can change
    (var-set OWNER address)
    (ok true)
    )
)

;; admin can change treasury address

(define-public (admin-change-treasury (address principal))
    (begin
    (asserts! (is-eq contract-caller (var-get OWNER)) NOT_THE_OWNER) ;; Only owner can change
    (var-set TREASURY address)
    (ok true)
    )
)

;; admin sBTC reward enroolment

(define-public (admin-enroll)
    (begin
    (asserts! (is-eq contract-caller (var-get OWNER)) NOT_THE_OWNER) ;; Only owner can change
    (try! (contract-call? 'SP804CDG3KBN9M6E00AD744K8DC697G7HBCG520Q.sbtc-yield-rewards-v3 enroll (some (var-get TREASURY))))
    (ok true)
    )
)

;; admin can set min amount for offers

(define-public (admin-set-min-amount (amount uint))
    (begin
    (asserts! (> amount u0) NOT_ZERO)
    (asserts! (is-eq contract-caller (var-get OWNER)) NOT_THE_OWNER) 
    (var-set MIN_AMOUNT amount)
    (ok amount)
    )
)

;; admin add/edit whitelisted tokens

(define-public (admin-add-token (token <sip-010-trait>) (min uint))
    (let (
        (tokendata (get-token token)) ;; check previous locked 
    )
        (asserts! (> min u0) NOT_ZERO)
        (asserts! (is-eq contract-caller (var-get OWNER)) NOT_THE_OWNER) 
        (map-set TOKENS (contract-of token) {active: true, min: min, locked: (get locked tokendata)})
    (ok true)
    )
)

;; admin remove token but don't change locked data
(define-public (admin-remove-token (token <sip-010-trait>) )
    (let (
        (tokendata (get-token token)) ;; check previous locked 
    )
        (asserts! (is-eq contract-caller (var-get OWNER)) NOT_THE_OWNER) ;; Only owner can pause
        (map-set TOKENS (contract-of token) {active: false, min: (get min tokendata), locked: (get locked tokendata)})
    (ok true)
    )
)

;; helper for token locked amount operations
(define-private (add-amount (token <sip-010-trait>) (amount uint)) 
    (let
        (
            (tokendata (get-token token))
            (locked (get locked tokendata))
        )
        (map-set TOKENS (contract-of token) {active: true, min: (get min tokendata), locked: (+ locked amount)})
    )
)
(define-private (remove-amount (token <sip-010-trait>) (amount uint)) 
    (let
        (
            (tokendata (get-token token))
            (locked (get locked tokendata))
        )
        (map-set TOKENS (contract-of token) {active: true, min: (get min tokendata), locked: (- locked amount)})
    )
)

;; return offer url on bns.one
(define-private (get-url (offer uint))
    (concat "https:/bns.one/offer/" (int-to-ascii offer))
)

;; read-only functions

(define-read-only (get-offer (offer uint))
    (default-to {
        id: u0,
        seller: VAULT,
        taker: VAULT,
        amount: u0,
        token: none,
        expiration: u0,
        counteroffer: none,
        status: "not valid"
    } (map-get? OFFER offer))
)

(define-read-only (get-token (token <sip-010-trait>))
    (default-to {active: false, min: u0, locked: u0} (map-get? TOKENS (contract-of token)))
)

(define-read-only (total-stx-locked)
    (var-get AMOUNT_LOCKED)
)

;; contract funds to manage internal messagging
(begin 
    (stx-transfer? u1000000 tx-sender VAULT)
)
```
