(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; ERRS
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-INITIALIZED (err u1001))
(define-constant ERR-NOT-INITIALIZED (err u1001))
(define-constant ERR-BELOW-MIN-PERIOD (err u6000))
(define-constant ERR-PRESALE-ENDED (err u7002))
(define-constant ERR-NOT-PARTICIPANT (err u7004))
(define-constant ERR-ALREADY-CLAIMED (err u7005))
(define-constant ERR-MAX-DEPOSIT-EXCEEDED (err u8001))
(define-constant ERR-HARDCAP-EXCEEDED (err u8002))
(define-constant ERR-MIN-TARGET-NOT-REACHED (err u8003))
(define-constant ERR-INVALID-LAUNCH (err u5002))
(define-constant ERR-INVALID-AMOUNT (err u5003))
(define-constant ERR-INVALID-TOKEN (err u7001))
(define-constant ERR-TOKEN-LAUNCH-NOT-ENDED (err u7003))

;; STORAGE
(define-data-var initialized bool true)
(define-data-var deployer principal tx-sender)
(define-constant LAUNCHPAD-TOKEN 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC.tenmetsu)
(define-constant LAUNCHPAD-ADDRESS (as-contract tx-sender))

(define-map users-deposits
    { user-addr: principal }
    uint
)

(define-map user-claimed 
  { user-addr : principal }
  bool
)

;; READ ONLY CALLS

(define-read-only (get-launchpad-info)
  (ok (unwrap! (contract-call? .memegoat-tokenlaunch-tenmetsu-v3 get-launchpad-info) ERR-INVALID-LAUNCH))
)

(define-read-only (get-user-deposits (user-addr principal)) 
  (let
    (
      (old-deposit (contract-call? .memegoat-tokenlaunch-tenmetsu get-user-deposits user-addr))
      (old-deposit-v3 (contract-call? .memegoat-tokenlaunch-tenmetsu-v3 get-user-deposits-curr user-addr))
    )
    (+ old-deposit old-deposit-v3 (default-to u0 (map-get? users-deposits {user-addr: user-addr})))
  )
)

(define-read-only (get-user-deposits-curr (user-addr principal)) 
  (let
    (
      (old-deposit-v3 (contract-call? .memegoat-tokenlaunch-tenmetsu-v3 get-user-deposits-curr user-addr))
    )
    (+ old-deposit-v3 (default-to u0 (map-get? users-deposits {user-addr: user-addr})))
  )
)

(define-read-only (calculate-allocation (user-addr principal))
  (let
    (
      (stx-quote (contract-call? .memegoat-tokenlaunch-tenmetsu-v3 get-stx-quote))
      (user-deposit (get-user-deposits user-addr))
    )
    (* stx-quote user-deposit) 
  )
)

(define-read-only (check-if-claimed (user-addr principal)) 
  (default-to false (map-get? user-claimed { user-addr: user-addr }))
)

(define-public (withdraw (token-trait <ft-trait>) (recipient principal))
  (let
    (
      (remaining-bal (try! (contract-call? token-trait get-balance LAUNCHPAD-ADDRESS)))
    )
    (try! (check-is-deployer))
    (as-contract (contract-call? token-trait transfer remaining-bal tx-sender recipient none))
  )
)

;; PUBLIC CALLS
(define-public (claim-token (token-trait <ft-trait>)) 
  (let
    (
      (launchpad-info (try! (get-launchpad-info)))
      (stx-pool-balance (get pool-amount launchpad-info))
      (recipient tx-sender)
      (softcap (get softcap launchpad-info))
      (hardcap (get hardcap launchpad-info))
      (end-block- (get end-block launchpad-info))
      (user-allocation (calculate-allocation recipient))
      (claimed (check-if-claimed recipient))
    )
    (try! (check-is-initialized))
    (asserts! (or (< end-block- block-height) (is-eq stx-pool-balance hardcap)) ERR-TOKEN-LAUNCH-NOT-ENDED)
    (asserts! (is-eq LAUNCHPAD-TOKEN (contract-of token-trait)) ERR-INVALID-TOKEN)
    (asserts! (not claimed) ERR-ALREADY-CLAIMED)
    ;; transfer to users
    (try! (as-contract (contract-call? token-trait transfer user-allocation tx-sender recipient none)))
    ;; set user status to claimed 
    (ok (map-set user-claimed { user-addr: recipient } true))
  )
)

;; PRIVATE CALLS
(define-private (check-is-deployer)
  (ok (asserts! (is-eq tx-sender (var-get deployer)) ERR-NOT-AUTHORIZED))
)

(define-private (check-is-initialized)
  (ok (asserts! (var-get initialized) ERR-NOT-INITIALIZED))
)

(begin 
  ;; move record from v2
  (map-set users-deposits { user-addr: 'SP1023WDK96BH5DQ5RRS5PQ8MH1PKRH1MKJ6NSZ20} u100000000)
  (map-set users-deposits { user-addr: 'SP3E8DBPXWV15PR41J863ZVB3GW0CG6KZ7SDKZ43S} u150000000)
  (map-set users-deposits { user-addr: 'SP2HNT72RQCMJBJH1YAXBFTVKSC2G5M2T7N9J62CW} u500000000)
)