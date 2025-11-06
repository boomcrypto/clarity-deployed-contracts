(define-constant ERR_NOT_VALID_REFERRAL u100)

;; === Helper ===
(define-private (validate-referral (ref-code (string-ascii 30)))
  (let ((owner-opt (contract-call? .specific-scarlet-badger get-referral-address ref-code)))
    (match owner-opt
      owner (if (not (is-eq tx-sender owner))
                (ok true)
                (err ERR_NOT_VALID_REFERRAL))
      (err u404))))

;; Mock handout referral reward
(define-public (mock-handout-referral-reward (ref-code (string-ascii 30)) (col principal) (qty uint) (spc_id (optional uint)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? .meaningful-rose-opossum mock-handout-referral-reward ref-code col qty spc_id))
    (ok true)))

;; === Claim per spaghettipunk-club ===

(define-public (spaghettipunk-club-claim-one-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u1 none))
    (ok true)))

(define-public (spaghettipunk-club-claim-two-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-two))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u2 none))
    (ok true)))

(define-public (spaghettipunk-club-claim-three-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-three))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u3 none))
    (ok true)))

(define-public (spaghettipunk-club-claim-four-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-four))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u4 none))
    (ok true)))

(define-public (spaghettipunk-club-claim-five-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-five))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u5 none))
    (ok true)))

(define-public (spaghettipunk-club-claim-six-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-six))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u6 none))
    (ok true)))

(define-public (spaghettipunk-club-claim-seven-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-seven))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u7 none))
    (ok true)))

(define-public (spaghettipunk-club-claim-eight-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-eight))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u8 none))
    (ok true)))

(define-public (spaghettipunk-club-claim-nine-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-nine))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u9 none))
    (ok true)))

(define-public (spaghettipunk-club-claim-ten-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-ten))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u10 none))
    (ok true)))

(define-public (spaghettipunk-club-claim-fifteen-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-fifteen))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u15 none))
    (ok true)))

(define-public (spaghettipunk-club-claim-twenty-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-twenty))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u20 none))
    (ok true)))

(define-public (spaghettipunk-club-claim-twentyfive-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-twentyfive))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u25 none))
    (ok true)))

;; === Claim per bitcoin-bears ===

(define-public (bitcoin-bears-claim-one-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u1 none))
    (ok true)))

(define-public (bitcoin-bears-claim-two-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-two))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u2 none))
    (ok true)))

(define-public (bitcoin-bears-claim-three-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-three))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u3 none))
    (ok true)))

(define-public (bitcoin-bears-claim-four-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-four))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u4 none))
    (ok true)))

(define-public (bitcoin-bears-claim-five-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-five))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u5 none))
    (ok true)))

(define-public (bitcoin-bears-claim-six-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-six))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u6 none))
    (ok true)))

(define-public (bitcoin-bears-claim-seven-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-seven))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u7 none))
    (ok true)))

(define-public (bitcoin-bears-claim-eight-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-eight))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u8 none))
    (ok true)))

(define-public (bitcoin-bears-claim-nine-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-nine))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u9 none))
    (ok true)))

(define-public (bitcoin-bears-claim-ten-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-ten))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u10 none))
    (ok true)))

(define-public (bitcoin-bears-claim-fifteen-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-fifteen))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u15 none))
    (ok true)))

(define-public (bitcoin-bears-claim-twenty-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-twenty))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u20 none))
    (ok true)))

(define-public (bitcoin-bears-claim-twentyfive-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-twentyfive))
    (try! (contract-call? .meaningful-rose-opossum handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u25 none))
    (ok true)))