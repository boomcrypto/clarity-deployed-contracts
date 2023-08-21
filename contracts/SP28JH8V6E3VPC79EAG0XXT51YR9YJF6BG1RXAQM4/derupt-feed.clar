;; .derupt-feed Contract
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(define-constant DAPP tx-sender)

;; Error constants
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOTFOUND (err u101))
(define-constant ERR-MISSINGARG (err u103))
(define-constant ERR-INSUFFICIENT-BALANCE (err u104))

;; Core contract reference
(define-data-var derupt-core-contract principal (as-contract tx-sender))

;; Cost map
(define-map cost principal { chime-cost: (optional uint), mine-cost: (optional uint), like-cost: (optional uint), dislike-cost: (optional uint) })
(define-map crypto-bros (string-ascii 11) principal)
(define-map crypto-partners (string-ascii 11) principal)

;; Setter for costs
(define-public (set-cost (chime-cost (optional uint)) (mine-cost (optional uint)) (like-cost (optional uint)) (dislike-cost (optional uint))) 
  (begin 
    (asserts! (is-eq tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED)) ERR-UNAUTHORIZED)
      (match chime-cost value (map-set cost DAPP 
        { 
            chime-cost:   (some value), 
            mine-cost:   (unwrap! (get mine-cost (map-get? cost DAPP)) ERR-NOTFOUND),
            like-cost:   (unwrap! (get like-cost (map-get? cost DAPP)) ERR-NOTFOUND),
            dislike-cost:  (unwrap! (get dislike-cost (map-get? cost DAPP)) ERR-NOTFOUND) 
        }) false)
      (match mine-cost value (map-set cost DAPP 
        { 
            chime-cost:   (unwrap! (get chime-cost (map-get? cost DAPP)) ERR-NOTFOUND),
            mine-cost:  (some value), 
            like-cost:   (unwrap! (get like-cost (map-get? cost DAPP)) ERR-NOTFOUND),
            dislike-cost:   (unwrap! (get dislike-cost (map-get? cost DAPP)) ERR-NOTFOUND),
        }) false)
      (match like-cost value (map-set cost DAPP
        { 
            chime-cost:   (unwrap! (get chime-cost (map-get? cost DAPP)) ERR-NOTFOUND),
            mine-cost:   (unwrap! (get mine-cost (map-get? cost DAPP)) ERR-NOTFOUND),  
            like-cost:   (some value), 
            dislike-cost:   (unwrap! (get dislike-cost (map-get? cost DAPP)) ERR-NOTFOUND) 
        }) false)
      (match dislike-cost value (map-set cost DAPP
        {
            chime-cost:   (unwrap! (get chime-cost (map-get? cost DAPP)) ERR-NOTFOUND), 
            mine-cost:   (unwrap! (get mine-cost (map-get? cost DAPP)) ERR-NOTFOUND), 
            like-cost:   (unwrap! (get like-cost (map-get? cost DAPP)) ERR-NOTFOUND), 
            dislike-cost:   (some value) 
        }) false)
      (ok true)
  )
)

;; Get All Costs
(define-read-only (view-cost)
  (ok (map-get? cost DAPP))
)

;; Get Costs Individually
(define-read-only (get-chime-amount)
  (ok (unwrap! (unwrap! (get chime-cost (map-get? cost DAPP)) ERR-NOTFOUND) ERR-NOTFOUND))
)

(define-read-only (get-mine-amount)
  (ok (unwrap! (unwrap! (get mine-cost (map-get? cost DAPP)) ERR-NOTFOUND) ERR-NOTFOUND))
)

(define-read-only (get-like-amount)
  (ok (unwrap! (unwrap! (get like-cost (map-get? cost DAPP)) ERR-NOTFOUND) ERR-NOTFOUND))
)

(define-read-only (get-dislike-amount)
  (ok (unwrap! (unwrap! (get dislike-cost (map-get? cost DAPP)) ERR-NOTFOUND) ERR-NOTFOUND))
)

;; Validates core-contract
(define-read-only (validate-core-contract (input-core-contract principal)) 
  (if (is-eq input-core-contract (var-get derupt-core-contract)) 
    (ok true)
    (ok false)
  )
)

;; Setter for derupt core contract address (callable by DAPP, eg when a new .derupt-core-yyyymmdd is deployed by DAPP)
(define-public (set-derupt-core-contract (new-core-contract principal))
  (begin
    (asserts! (is-eq tx-sender DAPP) ERR-UNAUTHORIZED)    
    (ok (var-set derupt-core-contract new-core-contract))
  )
)

;; Get .derupt-core contract address
(define-read-only (get-derupt-core-contract) 
    (ok (var-get derupt-core-contract))
)

;; Setter for updating crypto-bros
(define-public (update-crypto-bros (bro (string-ascii 11)) (new-bro principal))        
    (begin 
      (asserts! (is-eq (unwrap! (map-get? crypto-bros bro) ERR-UNAUTHORIZED) tx-sender) ERR-UNAUTHORIZED)
      (ok (map-set crypto-bros bro new-bro))
    )
)

(define-public (view-crypto-bros (bro (string-ascii 11))) 
  (ok (unwrap! (map-get? crypto-bros bro) ERR-NOTFOUND))
)

;; Setter for updating crypto-partners
(define-public (update-crypto-partners (partner (string-ascii 9)) (new-partner principal))        
    (begin 
      (asserts! (is-eq tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED)) ERR-UNAUTHORIZED)
      (ok (map-set crypto-partners partner new-partner))
    )
)

(define-public (view-crypto-partners (partner (string-ascii 9))) 
  (ok (unwrap! (map-get? crypto-partners partner) ERR-NOTFOUND))
)

;; Log Send Messages
(define-public (log-send-message 
    (content (string-utf8 256)) (attachment-uri (optional (string-utf8 256))) 
    (thumbnail-uri (optional (string-utf8 256))) (reply-to (optional (string-utf8 256))) 
    (cityName (string-ascii 10)) (alt-origin (optional (string-utf8 256)))
    (extras 
      (optional 
        (tuple 
          (arg0 (optional (string-utf8 256)))
          (arg1 (optional (string-utf8 256))) 
          (arg2 (optional (string-utf8 256))) 
          (arg3 (optional (string-utf8 256)))   
          (arg4 (optional (string-utf8 256))) 
          (arg5 (optional (string-utf8 256))) 
          (arg6 (optional (string-utf8 256)))
          (arg7 (optional (string-utf8 256))) 
          (arg8 (optional (string-utf8 256))) 
          (arg9 (optional (string-utf8 256)))
        )
      )
    )
    (pay-dev bool) 
    (pay-gaia bool) 
    (dev-total uint) 
    (gaia-total uint)
    (dev-address (optional principal)) 
    (gaia-address (optional principal)) 
  )
    (let 
      (        
        (chime-total (/ (* (unwrap! (unwrap! (get mine-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG) (unwrap! (unwrap! (get chime-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG)) u100))
        (mine-total (unwrap! (unwrap! (get mine-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG))
      ) 
      (asserts! (is-eq contract-caller (var-get derupt-core-contract)) ERR-UNAUTHORIZED)
      (print 
        { 
          event: "send-message", content: content, publisher: tx-sender, attachment-uri: attachment-uri, 
          thumbnail-uri: thumbnail-uri, reply-to: reply-to, cityName: cityName, alt-origin: alt-origin, extras: extras,
          pay-dev: pay-dev, pay-gaia: pay-gaia, dev-address: dev-address, gaia-address: gaia-address,
          dev-stx-total: dev-total, gaia-stx-total: gaia-total, chime-stx-total: chime-total, mine-total: mine-total
        }
      )
      (ok true)
    )
)

;; CityCoin Transfering
(define-public (transfer-citycoin (amount uint) (recipient principal) (contractId <sip-010-trait>))
  (contract-call? contractId transfer amount tx-sender recipient none)
)

(define-public (pay-stx 
  (cityName (string-ascii 10))
  (pay-dev bool) 
  (pay-gaia bool) 
  (dev-amount uint) 
  (gaia-amount uint)
  (dev-address (optional principal)) 
  (gaia-address (optional principal)) 
  )
  (let 
    (
      (dev-total (/ (* (unwrap! (unwrap! (get mine-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG) dev-amount) u100))
      (gaia-total (/ (* (unwrap! (unwrap! (get mine-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG) gaia-amount) u100))
      (chime-total (/ (* (unwrap! (unwrap! (get mine-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG) (unwrap! (unwrap! (get chime-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG)) u100))
      (mine-total (unwrap! (unwrap! (get mine-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG))
      (like-total (unwrap! (unwrap! (get like-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG)) 
      (dislike-total (unwrap! (unwrap! (get dislike-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG)) 
      (user-balance (stx-get-balance tx-sender))
    )     
    (if (and pay-dev pay-gaia) 
    ;; Case 1: Pay-dev and Pay-gaia are both true hence pay all
      (begin 
        (asserts! (> user-balance (+ chime-total dev-total gaia-total mine-total)) ERR-INSUFFICIENT-BALANCE)
        (try! (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd006-citycoin-mining-v2 mine cityName (list mine-total)))
        (try! (stx-transfer? (/ chime-total u4) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED)))
        (try! (stx-transfer? (/ chime-total u4) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED)))
        (try! (stx-transfer? (/ chime-total u4) tx-sender (unwrap! (map-get? crypto-partners "deruptars") ERR-UNAUTHORIZED)))
        (try! (stx-transfer? (/ chime-total u4) tx-sender (unwrap! (map-get? crypto-partners "charity") ERR-UNAUTHORIZED)))
        (try! (stx-transfer? dev-total tx-sender (unwrap! dev-address ERR-MISSINGARG)))
        (try! (stx-transfer? gaia-total tx-sender (unwrap! gaia-address ERR-MISSINGARG)))
        (ok true)
      )
      (if (or pay-dev pay-gaia)
      ;; Here we use 'or' to switch either if pay-dev or pay-gaia is true
        (if pay-dev 
        ;; Case 2: Pay-dev is true while Pay-gaia is false hence pay dev + normal
          (begin 
            (asserts! (> user-balance (+ chime-total dev-total mine-total)) ERR-INSUFFICIENT-BALANCE)
            (try! (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd006-citycoin-mining-v2 mine cityName (list mine-total)))
            (try! (stx-transfer? (/ chime-total u4) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED)))
            (try! (stx-transfer? (/ chime-total u4) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED)))
            (try! (stx-transfer? (/ chime-total u4) tx-sender (unwrap! (map-get? crypto-partners "deruptars") ERR-UNAUTHORIZED)))
            (try! (stx-transfer? (/ chime-total u4) tx-sender (unwrap! (map-get? crypto-partners "charity") ERR-UNAUTHORIZED)))
            (try! (stx-transfer? dev-total tx-sender (unwrap! dev-address ERR-MISSINGARG)))
            (ok true)
          )
          ;; Case 3: Pay-gai is true while Pay-dev is false hence pay-gaia + normal
          (begin 
            (asserts! (> user-balance (+ chime-total gaia-total mine-total)) ERR-INSUFFICIENT-BALANCE)
            (try! (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd006-citycoin-mining-v2 mine cityName (list mine-total)))
            (try! (stx-transfer? (/ chime-total u4) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED)))
            (try! (stx-transfer? (/ chime-total u4) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED)))
            (try! (stx-transfer? (/ chime-total u4) tx-sender (unwrap! (map-get? crypto-partners "deruptars") ERR-UNAUTHORIZED)))
            (try! (stx-transfer? (/ chime-total u4) tx-sender (unwrap! (map-get? crypto-partners "charity") ERR-UNAUTHORIZED)))
            (try! (stx-transfer? gaia-total tx-sender (unwrap! gaia-address ERR-MISSINGARG)))
            (ok true)
          )
        )
        ;; Case 4: Pay-dev and Pay-gaia are both false hence pay only normal
        (begin 
          (asserts! (> user-balance (+ chime-total mine-total)) ERR-INSUFFICIENT-BALANCE)
          (try! (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd006-citycoin-mining-v2 mine cityName (list mine-total)))
          (try! (stx-transfer? (/ chime-total u4) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED)))
          (try! (stx-transfer? (/ chime-total u4) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED)))
          (try! (stx-transfer? (/ chime-total u4) tx-sender (unwrap! (map-get? crypto-partners "deruptars") ERR-UNAUTHORIZED)))
          (try! (stx-transfer? (/ chime-total u4) tx-sender (unwrap! (map-get? crypto-partners "charity") ERR-UNAUTHORIZED)))
          (ok true)
        )
      )     
    )
  )
)

(define-public (pay-ft-like
  (author-principal principal)
  (pay-dev bool) 
  (pay-gaia bool) 
  (dev-amount uint) 
  (gaia-amount uint)
  (dev-address (optional principal)) 
  (gaia-address (optional principal)) 
  (contractId <sip-010-trait>)
  )
  (let 
    (
      (dev-total (/ (* (unwrap! (unwrap! (get like-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG) dev-amount) u100))
      (gaia-total (/ (* (unwrap! (unwrap! (get like-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG) gaia-amount) u100))
      (chime-total (/ (* (unwrap! (unwrap! (get like-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG) (unwrap! (unwrap! (get chime-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG)) u100))
      (like-total (unwrap! (unwrap! (get like-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG)) 
      (user-balance (unwrap! (contract-call? contractId get-balance tx-sender) ERR-MISSINGARG))
    ) 
    (if (and pay-dev pay-gaia) 
    ;; Case 1: Pay-dev and Pay-gaia are both true hence pay all
       (begin 
        (asserts! (> user-balance (+ chime-total dev-total gaia-total like-total)) ERR-INSUFFICIENT-BALANCE)
        (try! (transfer-citycoin like-total author-principal contractId))
        (try! (contract-call? contractId transfer (/ chime-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED) none))
        (try! (contract-call? contractId transfer (/ chime-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED) none))
        (try! (contract-call? contractId transfer (/ chime-total u3) tx-sender (unwrap! (map-get? crypto-partners "charity") ERR-UNAUTHORIZED) none))
        (try! (contract-call? contractId transfer dev-total tx-sender (unwrap! dev-address ERR-MISSINGARG) none))
        (try! (contract-call? contractId transfer gaia-total tx-sender (unwrap! gaia-address ERR-MISSINGARG) none))
        (ok true)
      )
      (if (or pay-dev pay-gaia)
      ;; Here we use 'or' to switch either if pay-dev or pay-gaia is true
        (if pay-dev 
        ;; Case 2: Pay-dev is true while Pay-gaia is false hence pay dev + normal
          (begin 
            (asserts! (> user-balance (+ chime-total dev-total like-total)) ERR-INSUFFICIENT-BALANCE)
            (try! (transfer-citycoin like-total author-principal contractId))
            (try! (contract-call? contractId transfer (/ chime-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED) none))
            (try! (contract-call? contractId transfer (/ chime-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED) none))
            (try! (contract-call? contractId transfer (/ chime-total u3) tx-sender (unwrap! (map-get? crypto-partners "charity") ERR-UNAUTHORIZED) none))
            (try! (contract-call? contractId transfer dev-total tx-sender (unwrap! dev-address ERR-MISSINGARG) none))
            (ok true)
          )
          ;; Case 3: Pay-gai is true while Pay-dev is false hence pay-gaia + normal
          (begin 
            (asserts! (> user-balance (+ chime-total gaia-total like-total)) ERR-INSUFFICIENT-BALANCE)
            (try! (transfer-citycoin like-total author-principal contractId))
            (try! (contract-call? contractId transfer (/ chime-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED) none))
            (try! (contract-call? contractId transfer (/ chime-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED) none))
            (try! (contract-call? contractId transfer (/ chime-total u3) tx-sender (unwrap! (map-get? crypto-partners "charity") ERR-UNAUTHORIZED) none))
            (try! (contract-call? contractId transfer gaia-total tx-sender (unwrap! gaia-address ERR-MISSINGARG) none))
            (ok true)
          )
        )
        ;; Case 4: Pay-dev and Pay-gaia are both false hence pay only normal
        (begin 
          (asserts! (> user-balance (+ chime-total like-total)) ERR-INSUFFICIENT-BALANCE)
          (try! (transfer-citycoin like-total author-principal contractId))
          (try! (contract-call? contractId transfer (/ chime-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED) none))
          (try! (contract-call? contractId transfer (/ chime-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED) none))
          (try! (contract-call? contractId transfer (/ chime-total u3) tx-sender (unwrap! (map-get? crypto-partners "charity") ERR-UNAUTHORIZED) none))
          (ok true)
        )
      )     
    )
  )
)

(define-public (pay-ft-dislike
  (cityName (string-ascii 10))
  (pay-dev bool) 
  (pay-gaia bool) 
  (dev-amount uint) 
  (gaia-amount uint)
  (dev-address (optional principal)) 
  (gaia-address (optional principal)) 
  (contractId <sip-010-trait>)
  )
  (let 
    (
      (dev-total (/ (* (unwrap! (unwrap! (get dislike-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG) dev-amount) u100))
      (gaia-total (/ (* (unwrap! (unwrap! (get dislike-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG) gaia-amount) u100))
      (chime-total (/ (* (unwrap! (unwrap! (get dislike-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG) (unwrap! (unwrap! (get chime-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG)) u100))
      (dislike-total (unwrap! (unwrap! (get dislike-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG)) 
      (user-balance (unwrap! (contract-call? contractId get-balance tx-sender) ERR-MISSINGARG))
    ) 
    (if (and pay-dev pay-gaia) 
    ;; Case 1: Pay-dev and Pay-gaia are both true hence pay all
       (begin 
        (asserts! (> user-balance (+ chime-total dev-total gaia-total dislike-total)) ERR-INSUFFICIENT-BALANCE)
        (try! (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd007-citycoin-stacking stack cityName dislike-total u1))
        (try! (contract-call? contractId transfer (/ chime-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED) none))
        (try! (contract-call? contractId transfer (/ chime-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED) none))
        (try! (contract-call? contractId transfer (/ chime-total u3) tx-sender (unwrap! (map-get? crypto-partners "charity") ERR-UNAUTHORIZED) none))
        (try! (contract-call? contractId transfer dev-total tx-sender (unwrap! dev-address ERR-MISSINGARG) none))
        (try! (contract-call? contractId transfer gaia-total tx-sender (unwrap! gaia-address ERR-MISSINGARG) none))
        (ok true)
      )
      (if (or pay-dev pay-gaia)
      ;; Here we use 'or' to switch either if pay-dev or pay-gaia is true
        (if pay-dev 
        ;; Case 2: Pay-dev is true while Pay-gaia is false hence pay dev + normal
          (begin 
            (asserts! (> user-balance (+ chime-total dev-total dislike-total)) ERR-INSUFFICIENT-BALANCE)
            (try! (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd007-citycoin-stacking stack cityName dislike-total u1))
            (try! (contract-call? contractId transfer (/ chime-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED) none))
            (try! (contract-call? contractId transfer (/ chime-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED) none))
            (try! (contract-call? contractId transfer (/ chime-total u3) tx-sender (unwrap! (map-get? crypto-partners "charity") ERR-UNAUTHORIZED) none))
            (try! (contract-call? contractId transfer dev-total tx-sender (unwrap! dev-address ERR-MISSINGARG) none))
            (ok true)
          )
          ;; Case 3: Pay-gai is true while Pay-dev is false hence pay-gaia + normal
          (begin 
            (asserts! (> user-balance (+ chime-total gaia-total dislike-total)) ERR-INSUFFICIENT-BALANCE)
            (try! (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd007-citycoin-stacking stack cityName dislike-total u1))
            (try! (contract-call? contractId transfer (/ chime-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED) none))
            (try! (contract-call? contractId transfer (/ chime-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED) none))
            (try! (contract-call? contractId transfer (/ chime-total u3) tx-sender (unwrap! (map-get? crypto-partners "charity") ERR-UNAUTHORIZED) none))
            (try! (contract-call? contractId transfer gaia-total tx-sender (unwrap! gaia-address ERR-MISSINGARG) none))
            (ok true)
          )
        )
        ;; Case 4: Pay-dev and Pay-gaia are both false hence pay only normal
        (begin 
          (asserts! (> user-balance (+ chime-total dislike-total)) ERR-INSUFFICIENT-BALANCE)
          (try! (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd007-citycoin-stacking stack cityName dislike-total u1))
          (try! (contract-call? contractId transfer (/ chime-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED) none))
          (try! (contract-call? contractId transfer (/ chime-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED) none))
          (try! (contract-call? contractId transfer (/ chime-total u3) tx-sender (unwrap! (map-get? crypto-partners "charity") ERR-UNAUTHORIZED) none))
          (ok true)
        )
      )     
    )
  )
)

;; Default cost map insertion
(map-insert cost DAPP { chime-cost:  (some u4), mine-cost:  (some u100000), like-cost:  (some u100000000), dislike-cost:  (some u100000000) })

;; Mapp insertion for crypto-bros principals
(map-insert crypto-bros "cryptodude" 'SP2NJS7ZQT3N55E6YQ0RMAQR7RHVPES1PY16TKNK5)
(map-insert crypto-bros "cryptosmith" 'SPT4SQP5RC1BFAJEQKBHZMXQ8NQ7G118F335BD85)

;; Map insertion for crypto partners
;; replace with the modified .deruptars-treasury nft contract principal once ready
(map-insert crypto-partners "deruptars" 'SP2NJS7ZQT3N55E6YQ0RMAQR7RHVPES1PY16TKNK5) 
;; replace periodically with a variable charity principal that we partner with for a temparory period of time. Rotating in new charities
(map-insert crypto-partners "charity" 'SP2NJS7ZQT3N55E6YQ0RMAQR7RHVPES1PY16TKNK5) 