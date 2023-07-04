;;contract to produce, send, spend spoints 
;;depends on the collection SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club

(impl-trait .points-trait.points)
;;consts
(define-constant ERR-INSUFFICIENT-BALANCE u001)
(define-constant ERR-SENDER-IS-RECEIVER u002)
(define-constant ERR-INSUFFICIENT-AMOUNT u003)
(define-constant ERR-NOT-AUTHORIZED u004)
(define-constant ERR-MAX-SUPPLY-REACHED u005)
(define-constant ERR-ITEM-LIMIT-REACHED u006)
(define-constant ERR-ITEM-NOT-FOUND u007)
(define-constant SPOINTS-MAX-SUPPLY u21000000000000)
(define-constant ITEM-LIMIT u4200000000)
;;data vars
(define-data-var admin principal tx-sender)
(define-data-var supply uint u0)
(define-data-var spent uint u0)
(define-data-var approved-principals (list 1000 principal) (list 'ST1N057R0S5BBAQKTW0GF2J7BXKFHY2GQVBSVP6TE tx-sender))
(define-data-var shutoff-valve bool false)
(define-data-var removing-address-from-list principal tx-sender)
;;data maps
(define-map balances {item: uint} {balance: uint} )
(define-map lifetime { address: principal } { earnings: uint })

;;collect spoints from subscriber contracts on a spaghettipunk-club nft
(define-public (collect (item uint) (amount uint))
    (let (
        (spoints-supply (unwrap-panic (get-supply)))
        (spoints-spent (unwrap-panic (get-spent)))
        (item-balance (unwrap-panic (get-balance item)))
        (earnings (unwrap-panic (get-lifetime tx-sender)))
    )
        (asserts! (<= (+ (+ spoints-spent spoints-supply) amount) SPOINTS-MAX-SUPPLY) (err ERR-MAX-SUPPLY-REACHED))
        (asserts! (<= (+ item-balance amount) ITEM-LIMIT) (err ERR-ITEM-LIMIT-REACHED))
        (asserts! (is-eq (unwrap-panic (unwrap-panic (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club get-owner item))) tx-sender) (err ERR-NOT-AUTHORIZED))
        (asserts! (is-some (index-of (var-get approved-principals) contract-caller)) (err ERR-NOT-AUTHORIZED))
        (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
        (begin
            (var-set supply (+ spoints-supply amount))
            (map-set balances {item: item} {balance: (+ amount item-balance)})
            (map-set lifetime {address: tx-sender} {earnings: (+ earnings amount)})
            (print { action: "collect spoints", amount: amount})
            (ok true))))
;;send spoints from a spaghettipunk-club nft to another
(define-public (send (item-sender uint) (item-receiver uint) (amount uint)) 
    (let (
        (item-balance-sender (unwrap-panic (get-balance item-sender)))
        (item-balance-receiver (unwrap-panic (get-balance item-receiver)))
        (owner-receiver (unwrap-panic (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club get-owner item-receiver)))
    ) 
        (asserts! (<= (+ item-balance-receiver amount) ITEM-LIMIT) (err ERR-ITEM-LIMIT-REACHED))
        (asserts! (<= amount item-balance-sender) (err ERR-INSUFFICIENT-BALANCE))
        (asserts! (not (is-eq item-sender item-receiver)) (err ERR-SENDER-IS-RECEIVER))
        (asserts! (is-eq (unwrap-panic (unwrap-panic (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club get-owner item-sender))) tx-sender) (err ERR-NOT-AUTHORIZED))
        (asserts! (not (is-none (unwrap-panic (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club get-owner item-receiver)))) (err ERR-ITEM-NOT-FOUND))
        (map-set balances {item: item-sender} {balance: (- item-balance-sender amount)})
        (map-set balances {item: item-receiver} {balance: (+ item-balance-receiver amount)})
        (print { action: "send spoints", amount: amount})
        (ok true)))
;;spend spoints from a spaghettipunk-club nft
(define-public (spend (item uint) (amount uint)) 
    (let (
        (item-balance (unwrap-panic (get-balance item)))   
        (spoints-spent (unwrap-panic (get-spent))) 
        (spoints-supply (unwrap-panic (get-supply)))
        ) 
        (asserts! (> amount u0) (err ERR-INSUFFICIENT-AMOUNT))
        (asserts! (<= amount item-balance) (err ERR-INSUFFICIENT-BALANCE))
        (asserts! (<= amount spoints-supply) (err ERR-INSUFFICIENT-BALANCE))
        (asserts! (is-eq (unwrap-panic (unwrap-panic (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club get-owner item))) tx-sender) (err ERR-NOT-AUTHORIZED))
        (var-set supply (- spoints-supply amount))
        (var-set spent (+ spoints-spent amount))
        (map-set balances {item: item} {balance: (- item-balance amount)})
        (print { action: "spend spoints", amount: amount})
        (ok true)))

(define-public (admin-airdrop (item uint) (amount uint))
    (let (
        (spoints-supply (unwrap-panic (get-supply)))
        (spoints-spent (unwrap-panic (get-spent)))
        (item-balance (unwrap-panic (get-balance item)))
        (owner (unwrap-panic (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club get-owner item)))
    )
        (asserts! (<= (+ (+ spoints-spent spoints-supply) amount) SPOINTS-MAX-SUPPLY) (err ERR-MAX-SUPPLY-REACHED))
        (asserts! (<= (+ item-balance amount) ITEM-LIMIT) (err ERR-ITEM-LIMIT-REACHED))
        (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
        (asserts! (not (is-none owner)) (err ERR-ITEM-NOT-FOUND))
        (begin
            (var-set supply (+ spoints-supply amount))
            (map-set balances {item: item} {balance: (+ amount item-balance)})
            (map-set lifetime {address: (unwrap-panic owner)} {earnings: (+ (unwrap-panic (get-lifetime (unwrap-panic owner))) amount)})
            (ok true))))  
;;enables an address to collect spoints
(define-public (principal-approve (address principal))
    (begin  
        (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
        (ok (var-set approved-principals (unwrap-panic (as-max-len? (append (var-get approved-principals) address) u1000))))
    ))
;;disable an address to collect spoints
(define-public (principal-remove (address principal)) 
    (begin  
        (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
        (var-set removing-address-from-list address)    
        (ok (var-set approved-principals (filter remove-address-from-list (var-get approved-principals))))))
;;stop collecting spoints
(define-public (shutoff (switch bool))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set shutoff-valve switch))))
  ;;checks addresses authorized for the issuance of spoints
(define-read-only (get-approved-principals)
    (ok (var-get approved-principals)))
;;controls the number of spoints generated by an address since ever
(define-read-only (get-lifetime (address principal))
    (ok (default-to u0 (get earnings (map-get? lifetime {address: address})))))
;;controls the number of spoints related to a given spaghettipunk-club nft
(define-read-only (get-balance (item uint))
    (ok (default-to u0 (get balance (map-get? balances {item: item})))))
;;checks the total number of circulating spoints 
(define-read-only (get-supply)
    (ok (var-get supply)))
;;checks the total number of spoints spent
(define-read-only (get-spent)
    (ok (var-get spent)))
;;controls the total number of issued spoints i.e. the number of spoints spent + the number of circulating spoints
(define-read-only (get-total-supply)
    (ok (+ (var-get supply) (var-get spent))))
;;private functions
(define-private (remove-address-from-list (address principal))
  (if (is-eq address (var-get removing-address-from-list)) false true))