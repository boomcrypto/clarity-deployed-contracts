
;; creature-racer-staking
;; Contract for staking creature NFT tokens


;;
;; =========
;; CONSTANTS
;; =========
;;

(define-constant contract-owner tx-sender)

;; Error definitions
;; -----------------
(define-constant err-forbidden (err u403))
(define-constant err-not-found (err u404))
(define-constant err-expired (err u419))
(define-constant err-not-owner (err u8001))
(define-constant err-creature-locked (err u8002))
(define-constant err-nothing-to-withdraw (err u8003))


;;
;; ==================
;; DATA MAPS AND VARS
;; ==================
;;
(define-map user-position principal uint)
(define-map staked-creatures { user: principal,
            creature: uint } uint)

(define-data-var cycle uint u0)
(define-data-var total-share uint u0)
(define-map creature-staking-cycle { user: principal,
                                      creature: uint }
                                    uint)


;;
;; =================
;; PRIVATE FUNCTIONS
;; =================
;;

;;
;; ================
;; PUBLIC FUNCTIONS
;; ================
;;
(define-public (enter-staking (nft-id uint))
    (let
        (
         (token-owner 
          (unwrap! 
           (contract-call? .creature-racer-nft-v3
                           get-current-owner
                           nft-id) err-not-found))
         (token-expired (try! 
                         (contract-call? .creature-racer-nft-v3
                                         is-expired nft-id)))
         (weight (try!
                  (contract-call? .creature-racer-nft-v3
                                  creature-weight nft-id)))
         (sender tx-sender)
         (cur-cycle (var-get cycle))
         (prev-share (var-get total-share))
         (prev-position 
          (default-to u0 (map-get? user-position
                                   sender)))              
         (user-staking-key { user: sender, creature: nft-id })
         (prev-staked-creatures 
          (default-to u0 (map-get? staked-creatures
                                   user-staking-key)))
         )
      (asserts! (is-eq token-owner tx-sender) err-not-owner)
      (asserts! (not token-expired) err-expired)
     
      (try! (as-contract 
             (contract-call? .creature-racer-nft-v3
                             transfer nft-id
                             sender tx-sender)))
      (var-set total-share (+ prev-share weight))
      (map-set user-position sender (+ prev-position weight))
      (map-set creature-staking-cycle
               user-staking-key cur-cycle)
      (map-set staked-creatures
               user-staking-key 
               (+ prev-staked-creatures u1))
      (ok true)
      )
  )

(define-public (leave-staking (nft-id uint))
    (let
        (
         (sender tx-sender)
         (user-staking-key { user: sender, creature: nft-id })
         (prev-staked-creatures 
          (unwrap! (map-get? staked-creatures user-staking-key)
                   err-nothing-to-withdraw))
         )
      (asserts! (not (unwrap-panic
                      (is-creature-locked sender nft-id)))
                err-creature-locked)
      (asserts! (> prev-staked-creatures u0) 
                err-nothing-to-withdraw)
      (let (
            (weight (try!
                     (contract-call? .creature-racer-nft-v3
                                     creature-weight nft-id)))
            (prev-total-share (var-get total-share))
            (prev-user-position (unwrap-panic
                                 (map-get? user-position sender)))
            )
        (try! 
         (as-contract
          (contract-call? .creature-racer-nft-v3
                          transfer
                          nft-id tx-sender sender)))
        (var-set total-share (- prev-total-share weight))
        (map-set user-position sender (- prev-user-position
                                         weight))
        (map-set staked-creatures user-staking-key
                 (- prev-staked-creatures u1))
        (ok true)
        )
      )
  )

(define-public (open-new-cycle)
    (begin
     (try! (contract-call? .creature-racer-admin-v3
                           assert-invoked-by-operator))
     (var-set cycle (+ (var-get cycle) u1))
     (ok true)
   )
  )

(define-public (remove-expired-creature (user principal)
                                        (nft-id uint))
    (let (
          (weight (try!
                   (contract-call? .creature-racer-nft-v3
                                   creature-weight nft-id)))
          (prev-total-share (var-get total-share))
          (prev-user-position (unwrap-panic
                               (map-get? user-position user)))
          (user-staking-key { user: user, creature: nft-id })
          (prev-staked-creatures (unwrap-panic
                                  (map-get? staked-creatures
                                            user-staking-key)))
          )          
      (try! (contract-call? .creature-racer-admin-v3
                            assert-invoked-by-operator))
      (as-contract (try!
                    (contract-call? .creature-racer-nft-v3
                                    transfer nft-id
                                    tx-sender user)))
      ;; #[allow(unchecked_data)]
      (var-set total-share (- prev-total-share weight))
      ;; #[allow(unchecked_data)]
      (map-set user-position user (- prev-user-position weight))
      (map-set staked-creatures user-staking-key 
               (- prev-staked-creatures u1))
      (ok true)
     )
  )

(define-read-only (is-creature-locked (user principal)
                                      (nft-id uint))
    (let
        (
         (cur-cycle (var-get cycle))
         (staking-cycle (map-get? creature-staking-cycle
                                  { user: user,
                                  creature: nft-id }))
         )
      (ok (match staking-cycle
                 c (is-eq c cur-cycle)
                 false))
      )
  )

(define-read-only (get-user-share (user principal))
    (match (map-get? user-position user)
           v (ok v)
           err-not-found)
  )

(define-read-only (get-total-share)
    (ok (var-get total-share))
  )


(define-read-only (get-staked-creatures
                   (user principal) 
                   (creature-id uint))
    (ok (unwrap!
         (map-get? staked-creatures { user: user,
                   creature: creature-id} )
         err-not-found))
  )


(define-read-only (get-current-cycle)
    (ok (var-get cycle)))
