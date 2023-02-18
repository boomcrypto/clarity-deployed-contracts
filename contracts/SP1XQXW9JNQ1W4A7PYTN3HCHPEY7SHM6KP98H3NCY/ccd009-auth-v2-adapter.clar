;; Title: CCD009 Auth V2 Adapter
;; Version: 1.0.0
;; Summary: Connects to the auth v2 contract in the CityCoins legacy protocol as an approver.
;; Description: An extension contract that allows the DAO to access protected contract functions in the legacy protocol as part of CCIP-010.

;; TRAITS

(impl-trait .extension-trait.extension-trait)
(use-trait coreTraitV2 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.citycoin-core-v2-trait.citycoin-core-v2)
(use-trait tokenTraitV2 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.citycoin-token-v2-trait.citycoin-token-v2)

;; CONSTANTS

(define-constant ERR_UNAUTHORIZED (err u9000))

;; PUBLIC FUNCTIONS

(define-public (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender .base-dao)
    (contract-call? .base-dao is-extension contract-caller)) ERR_UNAUTHORIZED
  ))
)

(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)

;; create-job
(define-public (create-job-mia (name (string-ascii 255)) (target principal))
  (begin
    (try! (is-dao-or-extension))
    (as-contract (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-auth-v2 create-job name target))
  )
)
(define-public (create-job-nyc (name (string-ascii 255)) (target principal))
  (begin
    (try! (is-dao-or-extension))
    (as-contract (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-auth-v2 create-job name target))
  )
)

;; activate-job
(define-public (activate-job-mia (jobId uint))
  (begin
    (try! (is-dao-or-extension))
    (as-contract (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-auth-v2 activate-job jobId))
  )
)
(define-public (activate-job-nyc (jobId uint))
  (begin
    (try! (is-dao-or-extension))
    (as-contract (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-auth-v2 activate-job jobId))
  )
)

;; approve-job
(define-public (approve-job-mia (jobId uint))
  (begin
    (try! (is-dao-or-extension))
    (as-contract (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-auth-v2 approve-job jobId))
  )
)
(define-public (approve-job-nyc (jobId uint))
  (begin
    (try! (is-dao-or-extension))
    (as-contract (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-auth-v2 approve-job jobId))
  )
)

;; disapprove-job
(define-public (disapprove-job-mia (jobId uint))
  (begin
    (try! (is-dao-or-extension))
    (as-contract (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-auth-v2 disapprove-job jobId))
  )
)
(define-public (disapprove-job-nyc (jobId uint))
  (begin
    (try! (is-dao-or-extension))
    (as-contract (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-auth-v2 disapprove-job jobId))
  )
)

;; add-uint-argument
(define-public (add-uint-argument-mia (jobId uint) (name (string-ascii 255)) (value uint))
  (begin
    (try! (is-dao-or-extension))
    (as-contract (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-auth-v2 add-uint-argument jobId name value))
  )
)
(define-public (add-uint-argument-nyc (jobId uint) (name (string-ascii 255)) (value uint))
  (begin
    (try! (is-dao-or-extension))
    (as-contract (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-auth-v2 add-uint-argument jobId name value))
  )
)

;; add-principal-argument
(define-public (add-principal-argument-mia (jobId uint) (name (string-ascii 255)) (value principal))
  (begin
    (try! (is-dao-or-extension))
    (as-contract (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-auth-v2 add-principal-argument jobId name value))
  )
)
(define-public (add-principal-argument-nyc (jobId uint) (name (string-ascii 255)) (value principal))
  (begin
    (try! (is-dao-or-extension))
    (as-contract (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-auth-v2 add-principal-argument jobId name value))
  )
)

;; execute-upgrade-core-contract-job
;;   oldContract: corev2 trait
;;   newContract: corev2 trait
;;   requires set-city-wallet in core contract
(define-public (execute-upgrade-core-contract-job-mia (jobId uint) (oldContract <coreTraitV2>) (newContract <coreTraitV2>))
  (begin
    (try! (is-dao-or-extension))
    (as-contract (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-auth-v2 execute-upgrade-core-contract-job jobId oldContract newContract))
  )
)
(define-public (execute-upgrade-core-contract-job-nyc (jobId uint) (oldContract <coreTraitV2>) (newContract <coreTraitV2>))
  (begin
    (try! (is-dao-or-extension))
    (as-contract (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-auth-v2 execute-upgrade-core-contract-job jobId oldContract newContract))
  )
)

;; execute-update-coinbase-thresholds-job
;;   threshold1: uint
;;   threshold2: uint
;;   threshold3: uint
;;   threshold4: uint
;;   threshold5: uint
(define-public (execute-update-coinbase-thresholds-job-mia (jobId uint) (targetCore <coreTraitV2>) (targetToken <tokenTraitV2>))
  (begin
    (try! (is-dao-or-extension))
    (as-contract (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-auth-v2 execute-update-coinbase-thresholds-job jobId targetCore targetToken))
  )
)
(define-public (execute-update-coinbase-thresholds-job-nyc (jobId uint) (targetCore <coreTraitV2>) (targetToken <tokenTraitV2>))
  (begin
    (try! (is-dao-or-extension))
    (as-contract (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-auth-v2 execute-update-coinbase-thresholds-job jobId targetCore targetToken))
  )
)

;; execute-update-coinbase-amounts-job
;;   amountBonus: uint
;;   amount1: uint
;;   amount2: uint
;;   amount3: uint
;;   amount4: uint
;;   amount5: uint
;;   amountDefault: uint
(define-public (execute-update-coinbase-amounts-job-mia (jobId uint) (targetCore <coreTraitV2>) (targetToken <tokenTraitV2>))
  (begin
    (try! (is-dao-or-extension))
    (as-contract (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-auth-v2 execute-update-coinbase-amounts-job jobId targetCore targetToken))
  )
)
(define-public (execute-update-coinbase-amounts-job-nyc (jobId uint) (targetCore <coreTraitV2>) (targetToken <tokenTraitV2>))
  (begin
    (try! (is-dao-or-extension))
    (as-contract (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-auth-v2 execute-update-coinbase-amounts-job jobId targetCore targetToken))
  )
)

;; execute-replace-approver-job
;;   oldApprover: principal
;;   newApprover: principal
(define-public (execute-replace-approver-job-mia (jobId uint))
  (begin
    (try! (is-dao-or-extension))
    (as-contract (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-auth-v2 execute-replace-approver-job jobId))
  )
)
(define-public (execute-replace-approver-job-nyc (jobId uint))
  (begin
    (try! (is-dao-or-extension))
    (as-contract (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-auth-v2 execute-replace-approver-job jobId))
  )
)
