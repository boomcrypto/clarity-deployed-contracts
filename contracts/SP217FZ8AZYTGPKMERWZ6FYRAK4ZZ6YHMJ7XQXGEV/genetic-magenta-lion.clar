(define-constant ERR_NOT_VALID_REFERRAL u100)

;; === Helper ===
(define-private (validate-referral (ref-code (string-ascii 30)))
  (let ((owner-opt (contract-call? .modern-amethyst-albatross get-referral-address ref-code)))
    (match owner-opt
      owner (if (not (is-eq tx-sender owner))
                (ok true)
                (err ERR_NOT_VALID_REFERRAL))
      (err u404))))

;; === Claim per spaghettipunk-club ===

(define-public (spaghettipunk-club-claim-one-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim))
    (try! (contract-call? .logical-tan-rat handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u1 none))
    (ok true)))

(define-public (spaghettipunk-club-claim-two-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-two))
    (try! (contract-call? .logical-tan-rat handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u2 none))
    (ok true)))

(define-public (spaghettipunk-club-claim-five-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-five))
    (try! (contract-call? .logical-tan-rat handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u5 none))
    (ok true)))

(define-public (spaghettipunk-club-claim-ten-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-ten))
    (try! (contract-call? .logical-tan-rat handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u10 none))
    (ok true)))

(define-public (spaghettipunk-club-claim-fifteen-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-fifteen))
    (try! (contract-call? .logical-tan-rat handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u15 none))
    (ok true)))

(define-public (spaghettipunk-club-claim-twenty-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-twenty))
    (try! (contract-call? .logical-tan-rat handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u20 none))
    (ok true)))

(define-public (spaghettipunk-club-claim-twentyfive-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club claim-twentyfive))
    (try! (contract-call? .logical-tan-rat handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club u25 none))
    (ok true)))

;; === Claim per bitcoin-bears ===

(define-public (bitcoin-bears-claim-one-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim))
    (try! (contract-call? .logical-tan-rat handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u1 none))
    (ok true)))

(define-public (bitcoin-bears-claim-two-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-two))
    (try! (contract-call? .logical-tan-rat handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u2 none))
    (ok true)))

(define-public (bitcoin-bears-claim-five-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-five))
    (try! (contract-call? .logical-tan-rat handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u5 none))
    (ok true)))

(define-public (bitcoin-bears-claim-ten-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-ten))
    (try! (contract-call? .logical-tan-rat handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u10 none))
    (ok true)))

(define-public (bitcoin-bears-claim-fifteen-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-fifteen))
    (try! (contract-call? .logical-tan-rat handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u15 none))
    (ok true)))

(define-public (bitcoin-bears-claim-twenty-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-twenty))
    (try! (contract-call? .logical-tan-rat handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u20 none))
    (ok true)))

(define-public (bitcoin-bears-claim-twentyfive-with-referral (ref-code (string-ascii 30)))
  (begin
    (asserts! (is-eq (validate-referral ref-code) (ok true)) (err ERR_NOT_VALID_REFERRAL))
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears claim-twentyfive))
    (try! (contract-call? .logical-tan-rat handout-referral-reward ref-code 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears u25 none))
    (ok true)))
