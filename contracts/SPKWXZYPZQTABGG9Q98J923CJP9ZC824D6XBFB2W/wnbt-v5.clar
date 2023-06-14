
;; wnbt-v5
;; Wannabe (semi-fungible) Token
(impl-trait 'SPDBEG5X8XD50SPM1JJH0E5CTXGDV5NJTKAKKR5V.sip013-semi-fungible-token-trait.sip013-semi-fungible-token-trait)

;;
;; =========
;; CONSTANTS
;; =========
;;
(define-fungible-token wnbt-sft)
(define-non-fungible-token wnbt-sft-id 
    { token-id: uint, 
         owner: principal,
        expiry: uint,
    })

(define-constant contract-owner tx-sender)


;; Error definitions
(define-constant ERR-CONTRACT-OWNER-ONLY (err u1000))
(define-constant ERR-OPERATOR-ONLY (err u1001))
(define-constant ERR-TOKEN-EXPIRED (err u1002))
(define-constant ERR-TOKEN-EXISTS (err u1003))
(define-constant ERR-INVALID-TOKEN-ID (err u1004))
(define-constant ERR-BALANCE-EXCEEDED (err u1005))
(define-constant ERR-TOKEN-NOT-EXPIRED (err u1006))

;; error codes required by sip-013
(define-constant ERR-INSUFFICIENT-BALANCE (err u1))
(define-constant ERR-RECIPIENT-IS-SENDER (err u2))
(define-constant ERR-AMOUNT-IS-ZERO (err u3))
(define-constant ERR-INVALID-SENDER (err u4))

;;
;; ==================
;; DATA MAPS AND VARS
;; ==================
;;
(define-data-var operator principal tx-sender)


(define-map balances { token-id: uint, owner: principal, expiry: uint } uint)
(define-map token-supplies uint uint)
(define-map uris uint (string-ascii 256))
(define-map token-expiry uint uint)

;;
;; =================
;; PRIVATE FUNCTIONS
;; =================
;;

(define-private (assert-owner)
    (ok (asserts! (is-eq tx-sender contract-owner)
                  ERR-CONTRACT-OWNER-ONLY)))

(define-private (assert-operator)
    (ok (asserts! (is-eq tx-sender (var-get operator))
                  ERR-OPERATOR-ONLY)))

(define-private (tag-nft-token-id (nft-token-id {token-id: uint,
                                                 owner: principal,
                                                 expiry: uint}))
    (let (
          (owner (get owner nft-token-id))
          )
      (and
       (is-some (nft-get-owner? wnbt-sft-id nft-token-id))
       (try! (nft-burn? wnbt-sft-id nft-token-id owner))
      )
     (nft-mint? wnbt-sft-id  nft-token-id owner)
     )
  )

(define-private (get-balance-uint (token-id uint) (user principal)
                                  (expiry uint))
    (default-to u0 (map-get? balances
                             { token-id: token-id, owner: user,
                               expiry: expiry })))

(define-private (set-balance (token-id uint)
                             (owner principal)
                             (expiry uint)
                             (balance uint)
                             )
    (map-set balances { token-id: token-id, owner: owner, expiry: expiry }
             balance)
  )

(define-private (get-time) 
    (default-to block-height 
        (get-block-info? time block-height)))


;;
;; ================
;; PUBLIC FUNCTIONS
;; ================
;;
(define-public (set-operator (new-op principal))
    (if (is-eq tx-sender contract-owner)
        (ok (var-set operator new-op))
        ERR-CONTRACT-OWNER-ONLY))

(define-read-only (get-operator) 
    (var-get operator))

(define-read-only (get-token-expiry (token-id uint))
    (map-get? token-expiry token-id))

;; SIP-013 required functions
(define-read-only (get-balance (token-id uint) 
                               (user principal))
    (match (map-get? token-expiry token-id)
           exp (ok (get-balance-uint token-id user exp))
           (ok u0)))

(define-read-only (get-overall-balance (user principal))
    (ok (ft-get-balance wnbt-sft user)))

(define-read-only (get-total-supply (token-id uint))
    (ok (default-to u0 (map-get? token-supplies token-id))))

(define-read-only (get-overall-supply)
    (ok (ft-get-supply wnbt-sft))
  )

(define-read-only (get-decimals (token-id uint))
    (ok u0))

(define-read-only (get-token-uri (token-id uint))
    (ok (map-get? uris token-id)))

(define-public (transfer (token-id uint)
                         (amount uint)
                         (sender principal)
                         (recipient principal))
    (let
        (
         (expiry (unwrap! (map-get? token-expiry token-id)
                          ERR-INVALID-TOKEN-ID))
         (balance (get-balance-uint token-id sender expiry))
         (rbalance (get-balance-uint token-id recipient expiry))
         )
      (asserts! (or (is-eq sender tx-sender)
                    (is-eq sender contract-caller))
                ERR-INVALID-SENDER)
      (asserts! (<= (get-time) expiry) ERR-TOKEN-EXPIRED)
      (asserts! (<= amount balance) ERR-INSUFFICIENT-BALANCE)
      (try! (ft-transfer? wnbt-sft amount sender recipient))
      (try! (tag-nft-token-id {token-id: token-id, owner: sender,
                              expiry: expiry }))
      (try! (tag-nft-token-id {token-id: token-id, owner: recipient,
                              expiry: expiry}))
      (set-balance token-id sender expiry (- balance amount))
      (set-balance token-id recipient expiry (+ rbalance amount))
      (print { type: "sft_transfer", token-id: token-id,
             amount: amount, sender: sender, recipient: recipient })
      (ok true)
      )
  )

(define-public (transfer-memo (token-id uint)
                              (amount uint)
                              (sender principal)
                              (recipient principal)
                              (memo (buff 34)))
    (begin
     (try! (transfer token-id amount sender recipient))
     (print memo)
     (ok true)
     )
  )

;; Burning
;;

(define-public (destroy-expired-token (token-id uint)
                                      (user principal))
    (let
        (
         (expiry (unwrap! (map-get? token-expiry token-id)
                          ERR-INVALID-TOKEN-ID))
         (balance (get-balance-uint token-id user expiry))
         )

      (try! (assert-operator))
      (asserts! (< expiry (get-time)) ERR-TOKEN-NOT-EXPIRED)
      (and (> balance u0)
           (try! (ft-burn? wnbt-sft balance user)))
      (map-delete balances { token-id: token-id, owner: user, expiry: expiry })
      (map-set token-supplies token-id 
               (- (default-to u0 
                      (map-get? token-supplies token-id))
                  balance))
      (try! (nft-burn? wnbt-sft-id {token-id: token-id,
                                    owner: user,
                                    expiry: expiry} user))
      (print {type: "sft_burn", token-id: token-id, amount: balance,
             sender: user})
      (ok true)
      )
  )


(define-public (burn (token-id uint)
                     (amount uint)
                     (user principal))
    (let
        (
         (expiry (unwrap! (map-get? token-expiry token-id)
                          ERR-INVALID-TOKEN-ID))
         (balance (get-balance-uint token-id user expiry))
         )
      (asserts! (> amount u0) ERR-AMOUNT-IS-ZERO)
      (asserts! (>= expiry (get-time)) ERR-TOKEN-EXPIRED)
      (asserts! (>= balance amount) ERR-BALANCE-EXCEEDED)
      (try! (assert-operator))
      (set-balance token-id user expiry (- balance amount))
      (map-set token-supplies token-id 
               (- (default-to u0 
                      (map-get? token-supplies token-id))
                  amount))
      (try! (ft-burn? wnbt-sft amount user))
      (print {type: "sft_burn", token-id: token-id, amount: amount,
             sender: user})
      (ok true)
      )
  )

;; Minting
(define-public (mint (token-id uint)
                     (amount uint)
                     (expiry uint)
                     (recipient principal))
    (let (
          (time (get-time))
          )
     (try! (assert-operator))
     (asserts! (is-none (map-get? token-expiry token-id))
               ERR-TOKEN-EXISTS)
     (asserts! (> amount u0) ERR-AMOUNT-IS-ZERO)
     (asserts! (> expiry time) ERR-TOKEN-EXPIRED)
     (try! (ft-mint? wnbt-sft amount recipient))
     (try! (tag-nft-token-id { token-id: token-id, 
                             owner: recipient,
                             expiry: expiry }))
     (set-balance token-id recipient expiry
                  (+ (get-balance-uint token-id recipient expiry)
                     amount))
     (map-set token-expiry token-id expiry)
     (map-set token-supplies token-id (+ (unwrap-panic
                                          (get-total-supply token-id))
                                         amount))
     (print {type: "sft_mint", token-id: token-id, amount: amount,
            recipient: recipient})
     (ok true)
     )
  )

(define-public (set-token-uri (token-id uint)
                              (uri-maybe (optional (string-ascii 256))))
    (begin
     (try! (assert-operator))
     (ok
      (match uri-maybe
             uri (map-set uris token-id uri)
             (map-delete uris token-id)))
     )
  )
