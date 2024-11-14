;;
;; MEMEGOAT PROPOSALS
;;
(impl-trait .proposal-trait.proposal-trait)

;; ERRS
(define-constant ERR-UNAUTHORISED (err u1000))
(define-constant ERR-NOT-QUALIFIED (err u1001))
(define-constant ERR-ALREADY-ACTIVATED (err u1002))
(define-constant ERR-NOT-ACTIVATED (err u1003))
(define-constant ERR-BELOW-MIN-PERIOD (err u2001))
(define-constant ERR-INVALID-OPTION (err u2002))
(define-constant ERR-HAS-VOTED (err u3002))

;; STORAGE
(define-data-var activated bool false)
(define-data-var duration uint u0)
(define-data-var start-block uint u0)
(define-data-var end-block uint u0)
(define-map votes {option: uint} uint)
(define-map vote-record principal bool)

;; READ-ONLY CALLS
(define-read-only (get-votes-by-op (op uint))
  (default-to u0 (map-get? votes {option: op}))
)

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .memegoat-community-dao) (contract-call? .memegoat-community-dao is-extension contract-caller)) ERR-UNAUTHORISED))
)

(define-read-only (get-proposal-data)
  (ok {
    start-block: (var-get start-block),
    end-block: (var-get end-block),
    duration: (var-get duration)
  })
)

(define-read-only (get-votes)
  (ok {
    op1: {id: u0, votes: (get-votes-by-op u0)},
    op2: {id: u1, votes: (get-votes-by-op u1)},
    op3: {id: u2, votes: (get-votes-by-op u2)},
    op4: {id: u3, votes: (get-votes-by-op u3)}
  })
)

(define-read-only (get-total-votes)
  (let
    (
      (vote-opts (list u0 u1 u2 u3))
    )
    (ok (fold get-votes-by-op-iter vote-opts u0))
  )
)

(define-read-only (check-has-voted (addr principal))
 (default-to false (map-get? vote-record addr))
)

;; PUBLIC CALLS
(define-public (activate (duration_ uint))
  (begin
    (try! (is-dao-or-extension))
    (asserts! (not (var-get activated)) ERR-ALREADY-ACTIVATED)
    (asserts! (> duration_ u0) ERR-BELOW-MIN-PERIOD)
    (var-set activated true)
    (var-set duration duration_)
    (var-set start-block burn-block-height)
    (ok (var-set end-block (+ burn-block-height duration_)))
  )
)

(define-public (vote (opt uint))
  (let
    (
      (sender tx-sender)
      (has-stake (contract-call? .memegoat-staking-v1 get-user-stake-has-staked sender))
      (stake-amount (get deposit-amount (try! (contract-call? .memegoat-staking-v1 get-user-staking-data sender))))
      (curr-votes (get-votes-by-op opt))
    )
    (asserts! has-stake ERR-NOT-QUALIFIED)
    (asserts! (< opt u4) ERR-INVALID-OPTION)
    (asserts! (not (check-has-voted sender)) ERR-HAS-VOTED)

    (map-set votes {option: opt} (+ curr-votes stake-amount))
    (ok (map-set vote-record sender true))
  )
)

(define-public (execute (sender principal) (opt uint))
  (begin
    (try! (is-dao-or-extension))

    (try! (contract-call? .memegoat-vault set-approval-status 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aewbtc u0 true))
    (try! (contract-call? .memegoat-community-pools-v1 set-approval-status 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aewbtc u29 true))


    (try! (contract-call? .memegoat-community-pools-v2 move-user-records
      u24
      (list 
        {user: 'SP3WCCSWRS55W72WRXTTEYMFWFGPS2YW6Y27FN1YE, old-id: u24}
      )
    ))

    (try! (contract-call? .memegoat-community-pools-v2 move-user-records
      u27
      (list 
        {user: 'SP1G18KGVMP2RF5S2387DBC4VRZGK2T9ETMMVT7BB, old-id: u27}
        {user: 'SPTBAXKRKT7EXTZ6QRZFG1145M0BZ0TTX3HJZTFW, old-id: u27}
        {user: 'SPH1ZAHN998PFH9A2CBNQ5EM3HKXG08FA0CKF4MB, old-id: u27}
      )
    ))

    (try! (contract-call? .memegoat-community-pools-v2 move-user-records
      u28
      (list 
        {user: 'SPTBAXKRKT7EXTZ6QRZFG1145M0BZ0TTX3HJZTFW, old-id: u28}
        {user: 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C, old-id: u28}
      )
    ))

    (try! (contract-call? .memegoat-community-pools-v2 move-user-records
      u30
      (list 
        {user: 'SP1H45JS07GWQWMT57JE20X17AQCNVYAS7NHW2HVR, old-id: u30}
        {user: 'SP2T5ZS0WA4BP31E3CTK5GDAY3VKJ1JXSGHDQZD66, old-id: u30}
        {user: 'SP1WK5MA8RPTT10C2EQ4BEQYN3BBEYY8MCY5FFKRQ, old-id: u30}
      )
    ))

    (ok true)
  )
)

;; PRIVATE CALLS
(define-private (get-votes-by-op-iter (op uint) (total uint))
  (+ total (get-votes-by-op op))
)