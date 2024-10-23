;; .derupt-feed Contract
;; (use-trait sip-010-trait 'ST3D8PX7ABNZ1DPP9MRRCYQKVTAC16WXJ7VCN3Z97.sip-010-trait-ft-standard.sip-010-trait)
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; (use-trait derupt-ext-trait 'ST1ZK0A249B4SWAHVXD70R13P6B5HNKZAA0WNTJTR.derupt-ext-trait.derupt-ext)
(use-trait derupt-ext-trait 'SP7MKPEA5DVQQ1PQNYPC1P5YRF14CY3CWZF70R01.derupt-ext-trait.derupt-ext)

(define-constant DAPP tx-sender)

;; Error constants
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOTFOUND (err u101))
(define-constant ERR-MISSINGARG (err u103))
(define-constant ERR-INSUFFICIENT-BALANCE (err u104))
(define-constant ERR-INSUFFICIENT-ARG (err u106))

;; Core contract reference
(define-data-var derupt-core-contract principal (as-contract tx-sender))

;; Cost map
(define-map cost principal { chime-stx-cost: (optional uint), chime-ft-cost: (optional uint), like-ft-cost: (optional uint), dislike-ft-cost: (optional uint) })
(define-map crypto-bros (string-ascii 11) principal)
(define-map crypto-partners (string-ascii 11) principal)

;; Setter for costs
(define-public (set-cost (chime-stx-cost (optional uint)) (chime-ft-cost (optional uint)) (like-ft-cost (optional uint)) (dislike-ft-cost (optional uint))) 
  (begin 
    (asserts! (is-eq tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED)) ERR-UNAUTHORIZED)
      (match chime-stx-cost value (map-set cost DAPP 
        { 
            chime-stx-cost:   (some value), 
            chime-ft-cost:   (unwrap! (get chime-ft-cost (map-get? cost DAPP)) ERR-NOTFOUND),
            like-ft-cost:   (unwrap! (get like-ft-cost (map-get? cost DAPP)) ERR-NOTFOUND),
            dislike-ft-cost:  (unwrap! (get dislike-ft-cost (map-get? cost DAPP)) ERR-NOTFOUND) 
        }) false)
      (match chime-ft-cost value (map-set cost DAPP 
        { 
            chime-stx-cost:   (unwrap! (get chime-stx-cost (map-get? cost DAPP)) ERR-NOTFOUND),
            chime-ft-cost:  (some value), 
            like-ft-cost:   (unwrap! (get like-ft-cost (map-get? cost DAPP)) ERR-NOTFOUND),
            dislike-ft-cost:   (unwrap! (get dislike-ft-cost (map-get? cost DAPP)) ERR-NOTFOUND),
        }) false)
      (match like-ft-cost value (map-set cost DAPP
        { 
            chime-stx-cost:   (unwrap! (get chime-stx-cost (map-get? cost DAPP)) ERR-NOTFOUND),
            chime-ft-cost:   (unwrap! (get chime-ft-cost (map-get? cost DAPP)) ERR-NOTFOUND),  
            like-ft-cost:   (some value), 
            dislike-ft-cost:   (unwrap! (get dislike-ft-cost (map-get? cost DAPP)) ERR-NOTFOUND) 
        }) false)
      (match dislike-ft-cost value (map-set cost DAPP
        {
            chime-stx-cost:   (unwrap! (get chime-stx-cost (map-get? cost DAPP)) ERR-NOTFOUND), 
            chime-ft-cost:   (unwrap! (get chime-ft-cost (map-get? cost DAPP)) ERR-NOTFOUND), 
            like-ft-cost:   (unwrap! (get like-ft-cost (map-get? cost DAPP)) ERR-NOTFOUND), 
            dislike-ft-cost:   (some value) 
        }) false)
      (ok true)
  )
)

;; Get All Costs
(define-read-only (view-cost)
  (ok (map-get? cost DAPP))
)

;; Get Costs Individually
(define-read-only (get-chime-stx-amount)
  (ok (unwrap! (unwrap! (get chime-stx-cost (map-get? cost DAPP)) ERR-NOTFOUND) ERR-NOTFOUND))
)

(define-read-only (get-chime-ft-amount)
  (ok (unwrap! (unwrap! (get chime-ft-cost (map-get? cost DAPP)) ERR-NOTFOUND) ERR-NOTFOUND))
)

(define-read-only (get-like-ft-amount)
  (ok (unwrap! (unwrap! (get like-ft-cost (map-get? cost DAPP)) ERR-NOTFOUND) ERR-NOTFOUND))
)

(define-read-only (get-dislike-ft-amount)
  (ok (unwrap! (unwrap! (get dislike-ft-cost (map-get? cost DAPP)) ERR-NOTFOUND) ERR-NOTFOUND))
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

(define-read-only (view-crypto-bros (bro (string-ascii 11))) 
  (ok (unwrap! (map-get? crypto-bros bro) ERR-NOTFOUND))
)

;; Setter for updating crypto-partners
(define-public (update-crypto-partners (partner (string-ascii 9)) (new-partner principal))        
    (begin 
      (asserts! (is-eq tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED)) ERR-UNAUTHORIZED)
      (ok (map-set crypto-partners partner new-partner))
    )
)

(define-read-only (view-crypto-partners (partner (string-ascii 9))) 
  (ok (unwrap! (map-get? crypto-partners partner) ERR-NOTFOUND))
)

;; Log Send Messages
(define-public (log-send-message 
    (content (string-utf8 256)) (attachment-uri (optional (string-utf8 256))) 
    (thumbnail-uri (optional (string-utf8 256))) (reply-to (optional (string-utf8 256))) 
    (mine-amounts (list 200 uint)) (alt-origin (string-utf8 256))
    (ext (optional <derupt-ext-trait>))
    (pay-dev bool) 
    (pay-gaia bool) 
    (dev-stx-total uint) 
    (gaia-stx-total uint)
    (dev-address (optional principal)) 
    (gaia-address (optional principal)) 
  )
    (let 
      (        
        (chime-stx-total (unwrap! (unwrap! (get chime-stx-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG)) 
        (mine-total (fold + mine-amounts u0))
      ) 
      (asserts! (is-eq contract-caller (var-get derupt-core-contract)) ERR-UNAUTHORIZED)
      (print 
        { 
          event: "send-message", content: content, publisher: tx-sender, attachment-uri: attachment-uri, 
          thumbnail-uri: thumbnail-uri, reply-to: reply-to, alt-origin: alt-origin, ext: ext,
          pay-dev: pay-dev, pay-gaia: pay-gaia, dev-address: dev-address, gaia-address: gaia-address,
          dev-stx-total: dev-stx-total, gaia-stx-total: gaia-stx-total, chime-stx-total: chime-stx-total, mine-total: mine-total, mine-amounts: mine-amounts
        }
      )
      (ok true)
    )
)

;; CryptoCash Transfering
(define-public (transfer-cryptocash (amount uint) (recipient principal) (contractId <sip-010-trait>))
  (contract-call? contractId transfer amount tx-sender recipient none)
)

(define-public (pay-stx 
  (mine-amounts (list 200 uint)) 
  (pay-dev bool) 
  (pay-gaia bool) 
  (dev-stx-amount uint) 
  (gaia-stx-amount uint)
  (dev-address (optional principal)) 
  (gaia-address (optional principal)) 
  )
  (let 
    (
      (dev-stx-total dev-stx-amount) 
      (gaia-stx-total gaia-stx-amount) 
      (chime-stx-total (unwrap! (unwrap! (get chime-stx-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG)) 
      (mine-stx-total (fold + mine-amounts u0)) 
      (user-stx-balance (stx-get-balance tx-sender))
    )     
    (if (and pay-dev pay-gaia) 
    ;; Case 1: pay-dev and pay-gaia are both true hence pay all
      (begin 
        (asserts! (> user-stx-balance (+ chime-stx-total dev-stx-total gaia-stx-total mine-stx-total)) ERR-INSUFFICIENT-BALANCE)
        (try! (contract-call? .cryptocash-core mine mine-amounts))
        (try! (stx-transfer? (/ chime-stx-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED)))
        (try! (stx-transfer? (/ chime-stx-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED)))
        (try! (stx-transfer? (/ chime-stx-total u3) tx-sender (unwrap! (map-get? crypto-partners "charity") ERR-UNAUTHORIZED)))
        (try! (stx-transfer? dev-stx-total tx-sender (unwrap! dev-address ERR-MISSINGARG)))
        (try! (stx-transfer? gaia-stx-total tx-sender (unwrap! gaia-address ERR-MISSINGARG)))
        (ok true)
      )
      (if (or pay-dev pay-gaia)
      ;; Here we use 'or' to switch either if pay-dev or pay-gaia is true
        (if pay-dev 
        ;; Case 2: pay-dev is true while pay-gaia is false hence pay dev + normal
          (begin 
            (asserts! (> user-stx-balance (+ chime-stx-total dev-stx-total mine-stx-total)) ERR-INSUFFICIENT-BALANCE)
            (try! (contract-call? .cryptocash-core mine mine-amounts))
            (try! (stx-transfer? (/ chime-stx-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED)))
            (try! (stx-transfer? (/ chime-stx-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED)))
            (try! (stx-transfer? (/ chime-stx-total u3) tx-sender (unwrap! (map-get? crypto-partners "charity") ERR-UNAUTHORIZED)))
            (try! (stx-transfer? dev-stx-total tx-sender (unwrap! dev-address ERR-MISSINGARG)))
            (ok true)
          )
          ;; Case 3: pay-gaia is true while pay-dev is false hence pay-gaia + normal
          (begin 
            (asserts! (> user-stx-balance (+ chime-stx-total gaia-stx-total mine-stx-total)) ERR-INSUFFICIENT-BALANCE)
            (try! (contract-call? .cryptocash-core mine mine-amounts))
            (try! (stx-transfer? (/ chime-stx-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED)))
            (try! (stx-transfer? (/ chime-stx-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED)))
            (try! (stx-transfer? (/ chime-stx-total u3) tx-sender (unwrap! (map-get? crypto-partners "charity") ERR-UNAUTHORIZED)))
            (try! (stx-transfer? gaia-stx-total tx-sender (unwrap! gaia-address ERR-MISSINGARG)))
            (ok true)
          )
        )
        ;; Case 4: pay-dev and pay-gaia are both false hence pay only normal
        (begin 
          (asserts! (> user-stx-balance (+ chime-stx-total mine-stx-total)) ERR-INSUFFICIENT-BALANCE)
          (try! (contract-call? .cryptocash-core mine mine-amounts))
          (try! (stx-transfer? (/ chime-stx-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED)))
          (try! (stx-transfer? (/ chime-stx-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED)))
          (try! (stx-transfer? (/ chime-stx-total u3) tx-sender (unwrap! (map-get? crypto-partners "charity") ERR-UNAUTHORIZED)))
          (ok true)
        )
      )     
    )
  )
)

(define-public (pay-ft-like
  (author-principal principal)
  (like-ft-amount uint)
  (pay-dev bool) 
  (pay-gaia bool) 
  (dev-ft-amount uint) 
  (gaia-ft-amount uint)
  (dev-address (optional principal)) 
  (gaia-address (optional principal)) 
  (contractId <sip-010-trait>)
  )
  (let 
    (
      (dev-ft-total dev-ft-amount) 
      (gaia-ft-total gaia-ft-amount) 
      (chime-ft-total (unwrap! (unwrap! (get chime-ft-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG)) 
      (like-ft-total like-ft-amount) 
      (like-ft-minimum (unwrap! (unwrap! (get like-ft-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG)) 
      (user-ft-balance (unwrap! (contract-call? contractId get-balance tx-sender) ERR-MISSINGARG))
    ) 
    (begin
      (asserts! (>= like-ft-total like-ft-minimum) ERR-INSUFFICIENT-ARG)
      (if (and pay-dev pay-gaia) 
      ;; Case 1: pay-dev and pay-gaia are both true hence pay all
        (begin 
          (asserts! (> user-ft-balance (+ chime-ft-total dev-ft-total gaia-ft-total like-ft-total)) ERR-INSUFFICIENT-BALANCE)
          (try! (transfer-cryptocash like-ft-total author-principal contractId))
          (try! (contract-call? contractId transfer (/ chime-ft-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED) none))
          (try! (contract-call? contractId transfer (/ chime-ft-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED) none))
          (try! (contract-call? contractId transfer (/ chime-ft-total u3) tx-sender (unwrap! (map-get? crypto-partners "charity") ERR-UNAUTHORIZED) none))
          (try! (contract-call? contractId transfer dev-ft-total tx-sender (unwrap! dev-address ERR-MISSINGARG) none))
          (try! (contract-call? contractId transfer gaia-ft-total tx-sender (unwrap! gaia-address ERR-MISSINGARG) none))
          (ok true)
        )
        (if (or pay-dev pay-gaia)
        ;; Here we use 'or' to switch either if pay-dev or pay-gaia is true
          (if pay-dev 
          ;; Case 2: pay-dev is true while pay-gaia is false hence pay dev + normal
            (begin
              (asserts! (> user-ft-balance (+ chime-ft-total dev-ft-total like-ft-total)) ERR-INSUFFICIENT-BALANCE)
              (try! (transfer-cryptocash like-ft-total author-principal contractId))
              (try! (contract-call? contractId transfer (/ chime-ft-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED) none))
              (try! (contract-call? contractId transfer (/ chime-ft-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED) none))
              (try! (contract-call? contractId transfer (/ chime-ft-total u3) tx-sender (unwrap! (map-get? crypto-partners "charity") ERR-UNAUTHORIZED) none))
              (try! (contract-call? contractId transfer dev-ft-total tx-sender (unwrap! dev-address ERR-MISSINGARG) none))
              (ok true)
            )
            ;; Case 3: pay-gaia is true while pay-dev is false hence pay-gaia + normal
            (begin 
              (asserts! (> user-ft-balance (+ chime-ft-total gaia-ft-total like-ft-total)) ERR-INSUFFICIENT-BALANCE)
              (try! (transfer-cryptocash like-ft-total author-principal contractId))
              (try! (contract-call? contractId transfer (/ chime-ft-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED) none))
              (try! (contract-call? contractId transfer (/ chime-ft-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED) none))
              (try! (contract-call? contractId transfer (/ chime-ft-total u3) tx-sender (unwrap! (map-get? crypto-partners "charity") ERR-UNAUTHORIZED) none))
              (try! (contract-call? contractId transfer gaia-ft-total tx-sender (unwrap! gaia-address ERR-MISSINGARG) none))
              (ok true)
            )
          )
          ;; Case 4: pay-dev and pay-gaia are both false hence pay only normal
          (begin 
            (asserts! (> user-ft-balance (+ chime-ft-total like-ft-total)) ERR-INSUFFICIENT-BALANCE)
            (try! (transfer-cryptocash like-ft-total author-principal contractId))
            (try! (contract-call? contractId transfer (/ chime-ft-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED) none))
            (try! (contract-call? contractId transfer (/ chime-ft-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED) none))
            (try! (contract-call? contractId transfer (/ chime-ft-total u3) tx-sender (unwrap! (map-get? crypto-partners "charity") ERR-UNAUTHORIZED) none))
            (ok true)
          )
        )     
      )    
    )    
  )
)

(define-public (pay-ft-dislike
  (dislike-ft-amount uint)
  (lockPeriod uint)
  (pay-dev bool) 
  (pay-gaia bool) 
  (dev-ft-amount uint) 
  (gaia-ft-amount uint)
  (dev-address (optional principal)) 
  (gaia-address (optional principal)) 
  (contractId <sip-010-trait>)
  )
  (let 
    (
      (dev-ft-total dev-ft-amount) 
      (gaia-ft-total gaia-ft-amount) 
      (chime-ft-total (unwrap! (unwrap! (get chime-ft-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG)) 
      (dislike-ft-total dislike-ft-amount) 
      (dislike-ft-minimum (unwrap! (unwrap! (get dislike-ft-cost (map-get? cost DAPP)) ERR-MISSINGARG) ERR-MISSINGARG)) 
      (user-ft-balance (unwrap! (contract-call? contractId get-balance tx-sender) ERR-MISSINGARG))
    ) 
    (begin
      (asserts! (> lockPeriod u0) ERR-INSUFFICIENT-ARG)
      (asserts! (>= dislike-ft-total dislike-ft-minimum) ERR-INSUFFICIENT-ARG) 
      (if (and pay-dev pay-gaia) 
      ;; Case 1: pay-dev and pay-gaia are both true hence pay all
        (begin          
          (asserts! (> user-ft-balance (+ chime-ft-total dev-ft-total gaia-ft-total dislike-ft-total)) ERR-INSUFFICIENT-BALANCE)
          (try! (contract-call? .cryptocash-core stack dislike-ft-total lockPeriod))
          (try! (contract-call? contractId transfer (/ chime-ft-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED) none))
          (try! (contract-call? contractId transfer (/ chime-ft-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED) none))
          (try! (contract-call? contractId transfer (/ chime-ft-total u3) tx-sender (unwrap! (map-get? crypto-partners "charity") ERR-UNAUTHORIZED) none))
          (try! (contract-call? contractId transfer dev-ft-total tx-sender (unwrap! dev-address ERR-MISSINGARG) none))
          (try! (contract-call? contractId transfer gaia-ft-total tx-sender (unwrap! gaia-address ERR-MISSINGARG) none))
          (ok true)
        )
        (if (or pay-dev pay-gaia)
        ;; Here we use 'or' to switch either if pay-dev or pay-gaia is true
          (if pay-dev 
          ;; Case 2: pay-dev is true while pay-gaia is false hence pay dev + normal
            (begin 
              (asserts! (> user-ft-balance (+ chime-ft-total dev-ft-total dislike-ft-total)) ERR-INSUFFICIENT-BALANCE)
              (try! (contract-call? .cryptocash-core stack dislike-ft-total lockPeriod))
              (try! (contract-call? contractId transfer (/ chime-ft-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED) none))
              (try! (contract-call? contractId transfer (/ chime-ft-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED) none))
              (try! (contract-call? contractId transfer (/ chime-ft-total u3) tx-sender (unwrap! (map-get? crypto-partners "charity") ERR-UNAUTHORIZED) none))
              (try! (contract-call? contractId transfer dev-ft-total tx-sender (unwrap! dev-address ERR-MISSINGARG) none))
              (ok true)
            )
            ;; Case 3: pay-gaia is true while pay-dev is false hence pay-gaia + normal
            (begin
              (asserts! (> user-ft-balance (+ chime-ft-total gaia-ft-total dislike-ft-total)) ERR-INSUFFICIENT-BALANCE)
              (try! (contract-call? .cryptocash-core stack dislike-ft-total lockPeriod))
              (try! (contract-call? contractId transfer (/ chime-ft-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED) none))
              (try! (contract-call? contractId transfer (/ chime-ft-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED) none))
              (try! (contract-call? contractId transfer (/ chime-ft-total u3) tx-sender (unwrap! (map-get? crypto-partners "charity") ERR-UNAUTHORIZED) none))
              (try! (contract-call? contractId transfer gaia-ft-total tx-sender (unwrap! gaia-address ERR-MISSINGARG) none))
              (ok true)
            )
          )
          ;; Case 4: pay-dev and pay-gaia are both false hence pay only normal
          (begin
            (asserts! (> user-ft-balance (+ chime-ft-total dislike-ft-total)) ERR-INSUFFICIENT-BALANCE)
            (try! (contract-call? .cryptocash-core stack dislike-ft-total lockPeriod))
            (try! (contract-call? contractId transfer (/ chime-ft-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED) none))
            (try! (contract-call? contractId transfer (/ chime-ft-total u3) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED) none))
            (try! (contract-call? contractId transfer (/ chime-ft-total u3) tx-sender (unwrap! (map-get? crypto-partners "charity") ERR-UNAUTHORIZED) none))
            (ok true)
          )
        )     
      )
    )
    
  )
)

;; Default cost map insertion
(map-insert cost DAPP { chime-stx-cost:  (some u100000), chime-ft-cost:  (some u10), like-ft-cost:  (some u100), dislike-ft-cost:  (some u100) })

;; Mapp insertion for crypto-bros principals
(map-insert crypto-bros "cryptodude" 'SP3ABD2FW64Y75W22R4G9TVKF6EA79RZHRC5BG4HD)
(map-insert crypto-bros "cryptosmith" 'SP2E9NTWSFGEN393GHT0CC4K7QCEX2CGYK0G2TY2F)
;; (map-insert crypto-bros "cryptodude" 'ST14YBS2A02FMW452Z94Z5DPBXYDMBBWG1SYJBWDZ)
;; (map-insert crypto-bros "cryptosmith" 'ST30RNTQNY63F6XR66J2Q3WP1THZT3VHZGYEXA9XX)


;; Map insertion for crypto partners
;; replace periodically with a variable charity principal that we partner with for a temparory period of time. Rotating in new charities
(map-insert crypto-partners "charity" 'SP16DCVM40B7DDPZQ6R9XZ8FXSH52246GP1C4FJPP)
;; (map-insert crypto-partners "charity" 'ST2ZW0BDG3T2G2RRD13R4FH9DNPJD6DEHF6BP9XZS)