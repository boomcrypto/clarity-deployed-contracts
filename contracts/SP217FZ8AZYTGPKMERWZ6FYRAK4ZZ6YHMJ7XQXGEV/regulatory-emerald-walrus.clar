(define-constant ERR_NOT_VALID_REFERRAL u100)

;; === Helper ===
(define-private (validate-referral (ref-code (string-ascii 30)))
  (let ((owner-opt (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code)))
    (match owner-opt
      owner (if (not (is-eq tx-sender owner))
                (ok true)
                (err ERR_NOT_VALID_REFERRAL))
      (err u404))))


;; === Claim per spaghettipunk-club ===

(define-public (spaghettipunk-club-claim-one-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim))
    (try! (as-contract (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u1 none)))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u1, reward: total-reward })
    (ok true)))

(define-public (spaghettipunk-club-claim-two-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-two))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u2 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u2, reward: total-reward })
    (ok true)))

(define-public (spaghettipunk-club-claim-three-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-three))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u3 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u3, reward: total-reward })
    (ok true)))

(define-public (spaghettipunk-club-claim-four-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-four))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u4 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u4, reward: total-reward })
    (ok true)))

(define-public (spaghettipunk-club-claim-five-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-five))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u5 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u5, reward: total-reward })
    (ok true)))

(define-public (spaghettipunk-club-claim-six-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-six))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u6 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u6, reward: total-reward })
    (ok true)))

(define-public (spaghettipunk-club-claim-seven-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-seven))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u7 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u7, reward: total-reward })
    (ok true)))

(define-public (spaghettipunk-club-claim-eight-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-eight))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u8 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u8, reward: total-reward })
    (ok true)))

(define-public (spaghettipunk-club-claim-nine-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-nine))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u9 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u9, reward: total-reward })
    (ok true)))

(define-public (spaghettipunk-club-claim-ten-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-ten))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u10 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u10, reward: total-reward })
    (ok true)))

(define-public (spaghettipunk-club-claim-fifteen-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-fifteen))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u15 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u15, reward: total-reward })
    (ok true)))

(define-public (spaghettipunk-club-claim-twenty-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-twenty))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u20 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u20, reward: total-reward })
    (ok true)))

(define-public (spaghettipunk-club-claim-twentyfive-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-twentyfive))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u25 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u25, reward: total-reward })
    (ok true)))

;; === Claim per bitcoin-bears ===

(define-public (bitcoin-bears-claim-one-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u1 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u1, reward: total-reward })
    (ok true)))

(define-public (bitcoin-bears-claim-two-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-two))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u2 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u2, reward: total-reward })
    (ok true)))

(define-public (bitcoin-bears-claim-three-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-three))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u3 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u3, reward: total-reward })
    (ok true)))

(define-public (bitcoin-bears-claim-four-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-four))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u4 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u4, reward: total-reward })
    (ok true)))

(define-public (bitcoin-bears-claim-five-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-five))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u5 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u5, reward: total-reward })
    (ok true)))

(define-public (bitcoin-bears-claim-six-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-six))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u6 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u6, reward: total-reward })
    (ok true)))

(define-public (bitcoin-bears-claim-seven-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-seven))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u7 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u7, reward: total-reward })
    (ok true)))

(define-public (bitcoin-bears-claim-eight-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-eight))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u8 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u8, reward: total-reward })
    (ok true)))

(define-public (bitcoin-bears-claim-nine-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-nine))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u9 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u9, reward: total-reward })
    (ok true)))

(define-public (bitcoin-bears-claim-ten-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-ten))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u10 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u10, reward: total-reward })
    (ok true)))

(define-public (bitcoin-bears-claim-fifteen-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-fifteen))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u15 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u15, reward: total-reward })
    (ok true)))

(define-public (bitcoin-bears-claim-twenty-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-twenty))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u20 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u20, reward: total-reward })
    (ok true)))

(define-public (bitcoin-bears-claim-twentyfive-with-referral (ref-code (string-ascii 30)))
  (let (
    (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address ref-code) (err ERR_NOT_VALID_REFERRAL)))
    (total-reward (contract-call? .attractive-olive-hamster get-total-reward 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears))
  )
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-twentyfive))
    (try! (contract-call? .attractive-olive-hamster handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u25 none))
    (print { action: "claim-with-referral", code: ref-code, address: some-ref-addr, mints: u25, reward: total-reward })
    (ok true)))