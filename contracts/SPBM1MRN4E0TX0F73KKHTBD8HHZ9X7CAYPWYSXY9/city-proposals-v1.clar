
;; proposal
;; <add a description here>
;; local
;; (use-trait sip-010-token .sip-010-trait-ft-standard.sip-010-trait)
;; testnet
;; (use-trait sip-010-token 'ST3CK642B6119EVC6CT550PW5EZZ1AJW6608HK60A.sip-010-trait-ft-standard.sip-010-trait)
;; mainnet
(use-trait sip-010-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; constants
;;
(define-constant CONTRACT_OWNER tx-sender)
(define-constant CONTRACT_ADDRESS (as-contract tx-sender))
(define-constant ERR_UNAUTHORIZED u401)
(define-constant ERR_PROPOSAL_NOT_FOUND u1000)
(define-constant ERR_INVALID_VALUE u1001)
(define-constant ERR_INSUFFICIENT_FUNDS u1002)
(define-constant ERR_FEE_TRANSFER_FAILED u1003)
(define-constant ERR_COIN_NOT_SUPPORTED u1004)
(define-constant ERR_INCORRECT_FUNDING_SOURCE u1005)
(define-constant ERR_INACTIVE_PROPOSAL u1006)
(define-constant ERR_EXTERNAL_ID_ALREADY_USED u1007)
(define-constant FUNDING_LENGTH u2100)
(define-constant ERR_FUNDING_EXPIRED_FOR_PROPOSAL u1008)
(define-constant ERR_INSUFFICIENT_FUNDING_AMOUNT u1009)
(define-constant ERR_SUBMISSION_CREATED u1010)
(define-constant ERR_SUBMISSION_NOT_FOUND u1011)
(define-constant ERR_SUBMISSION_DETAILS_NOT_FOUND u1012)

;; data maps and vars
;;

(define-data-var is-active bool false)
(define-data-var fee-rate uint u1)
(define-data-var next-proposal-id uint u0)
(define-data-var next-submission-id uint u0)


(define-map ProposalIds
  uint  ;; external-id
  uint  ;; proposal-id  
)

(define-map Proposals
  uint ;; proposal-id
  {
    id: uint,
    poster: principal,
    funding-recipient: (optional principal),
    category: (string-ascii 32),
    token: principal,
    funded-amount: uint,
    hash: (buff 64),
    active: bool,
    external-id: uint,
    stacks-height: uint
  }
)

(define-map Submissions 
  uint ;; submission-id
  {external-id: uint, proposal-id: uint, submitter: principal, hash: (buff 64)}
)

(define-map SubmissionIds
  uint ;;external-id
  uint ;;submission-id
)

(define-map SubmissionDetails
  {proposal-id: uint, submitter: principal}
  uint ;;submission-id
)

(define-map ProposalSubmissions
  uint ;;proposal-id
  uint ;;count
)


(define-map CityCoins
  principal ;; token
  {
    name: (string-ascii 32),
    symbol: (string-ascii 32),
  }
)

(define-read-only (get-fee-rate)
  (var-get fee-rate)
)

(define-read-only (get-proposal-count)
  (var-get next-proposal-id)
)

(define-read-only (get-proposal-or-err (proposal-id uint))
  (ok (unwrap! (map-get? Proposals proposal-id) (err ERR_PROPOSAL_NOT_FOUND)))
)

(define-read-only (get-proposal-id (external-id uint))
  (ok (unwrap! (map-get? ProposalIds external-id) (err ERR_PROPOSAL_NOT_FOUND)))
)

(define-read-only (get-proposal-by-external-id (external-id uint))
  (ok (unwrap! (get-proposal-or-err (unwrap! (map-get? ProposalIds external-id) (err ERR_PROPOSAL_NOT_FOUND))) (err ERR_PROPOSAL_NOT_FOUND)))
)

(define-read-only (get-coin-or-err (token <sip-010-token>))
  (ok (unwrap! (map-get? CityCoins (contract-of token)) (err u1)))
)

(define-read-only (get-submission-or-err (submission-id uint))
  (ok (unwrap! (map-get? Submissions submission-id) (err ERR_SUBMISSION_NOT_FOUND)))
)


(define-read-only (get-submission-count (proposal-id uint))
  (ok (unwrap! (map-get? ProposalSubmissions proposal-id) (err ERR_PROPOSAL_NOT_FOUND)))
)


(define-read-only (get-submission-by-external-id (external-id uint))
  (ok (try! (get-submission-or-err (unwrap! (map-get? SubmissionIds external-id) (err ERR_SUBMISSION_NOT_FOUND)))))
)

(define-read-only (get-submission-id (external-id uint))
  (ok (unwrap! (map-get? SubmissionIds external-id) (err ERR_SUBMISSION_NOT_FOUND)))
)
;; private functions
;;


(define-private (get-fee (amount uint))
  (/ (* (var-get fee-rate) amount) u100)
)

;; public functions
;;

(define-public (set-token (token <sip-010-token>))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_UNAUTHORIZED))
    (let (
      (name (try! (contract-call? token get-name)))
      (symbol (try! (contract-call? token get-symbol)))
    )
      (ok (map-set CityCoins (contract-of token) {
        name: name,
        symbol: symbol,
      }))
    )
  )
)

(define-public (create
    (token <sip-010-token>)
    (hash (buff 64)) 
    (category (string-ascii 32)) 
    (external-id uint)
    (is-bounty bool)
)
  (let
    (
      (next-id (+ (var-get next-proposal-id) u1))
      (recipient (if is-bounty none (some tx-sender)))
    )
    (begin 
      (asserts! (is-none (map-get? ProposalIds external-id)) (err ERR_EXTERNAL_ID_ALREADY_USED))
      (asserts! (is-ok (get-coin-or-err token)) (err ERR_COIN_NOT_SUPPORTED))
      (map-set Proposals next-id {
        id: next-id,
        poster: tx-sender, 
        category: category, 
        token: (contract-of token), 
        funded-amount: u0,
        hash: hash,
        active: true,
        external-id: external-id,
        stacks-height: block-height,
        funding-recipient: recipient
      })
      (map-set ProposalIds external-id next-id)
      (var-set next-proposal-id next-id)
      (ok next-id)
    )
  )
)


(define-public (edit 
    (proposal-id uint) 
    (new-hash (buff 64))
)
  (let
    (
      (proposal (try! (get-proposal-or-err proposal-id)))
    )
    (asserts! (is-eq tx-sender (get poster proposal)) (err ERR_UNAUTHORIZED))
    (ok (map-set Proposals proposal-id (
      merge proposal {
          hash: new-hash
      }
    )))
  )
)

(define-public (toggle-active 
    (proposal-id uint) 
)
  (let
    (
      (proposal (try! (get-proposal-or-err proposal-id)))
      (active (unwrap-panic (if (get active proposal) (ok false) (ok true))))
    )
    (asserts! (is-eq tx-sender (get poster proposal)) (err ERR_UNAUTHORIZED))
    (ok (map-set Proposals proposal-id (
      merge proposal {
          active: active
      }
    )))
  )
)

;; Fund a proposal with a city coin and update proposal and stats
(define-public (fund
    (token <sip-010-token>)
    (proposal-id uint)
    (amount uint) 
)
  (let
      (
        (proposal (try! (get-proposal-or-err proposal-id)))
        (recipient (get poster proposal))
        (txFee (get-fee amount))
        (txAmount (- amount txFee))
      )
      (asserts! (>= amount u100) (err ERR_INSUFFICIENT_FUNDING_AMOUNT))
      (asserts! (<= (- block-height (get stacks-height proposal)) FUNDING_LENGTH) (err ERR_FUNDING_EXPIRED_FOR_PROPOSAL))
      (asserts! (is-eq (get active proposal) true) (err ERR_INACTIVE_PROPOSAL))
      (asserts! (is-ok (get-coin-or-err token)) (err ERR_COIN_NOT_SUPPORTED))
      (asserts! (is-eq (get token proposal) (contract-of token)) (err ERR_INCORRECT_FUNDING_SOURCE))
      (asserts! (is-ok (contract-call? token transfer txAmount tx-sender recipient none)) (err ERR_INSUFFICIENT_FUNDS))
      (asserts! (is-ok (contract-call? token transfer txFee tx-sender CONTRACT_ADDRESS none)) (err ERR_FEE_TRANSFER_FAILED))
      (ok (map-set Proposals proposal-id (
        merge proposal {
            funded-amount: (+ (get funded-amount proposal) txAmount)
        }
      )))
  )
)

(define-public (withdrawl-fees (token <sip-010-token>) (recipient principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_UNAUTHORIZED))
    (asserts! (is-ok (as-contract (contract-call? token transfer amount CONTRACT_ADDRESS recipient none))) (err ERR_INSUFFICIENT_FUNDS))
    (ok true)
  )
)

(define-public (create-submission (proposal-id uint) (external-id uint) (hash (buff 64)))
  (let 
    (
      (next-id (+ (var-get next-submission-id) u1))
      (proposal (try! (get-proposal-or-err proposal-id)))
      (submission-stats (default-to u0 (map-get? ProposalSubmissions proposal-id)))
    ) 
    (begin 
      ;;prevent caller from submitting to own proposal
      (asserts! (not (is-eq tx-sender (get poster proposal))) (err ERR_UNAUTHORIZED))
      ;;make sure proposal hasn't expired
      (asserts! (<= (- block-height (get stacks-height proposal)) FUNDING_LENGTH) (err ERR_FUNDING_EXPIRED_FOR_PROPOSAL))
      ;;store submission data
      (asserts! (is-none (map-get? SubmissionDetails {proposal-id: proposal-id, submitter: tx-sender})) (err ERR_SUBMISSION_CREATED))
      (map-set SubmissionDetails {proposal-id: proposal-id, submitter: tx-sender} next-id)
      (map-set SubmissionIds external-id next-id)
      (map-set Submissions next-id {
        external-id: external-id,
        hash: hash,
        proposal-id: proposal-id,
        submitter: tx-sender
      })
      (map-set ProposalSubmissions proposal-id (+ submission-stats u1))
      ;;set next-id
      (var-set next-submission-id next-id)
      (ok true)
    )
  )

)

(define-public (choose-submission (submission-id uint))
  (let 
    (
      (submission (try! (get-submission-or-err submission-id)))
      (proposal-id (get proposal-id submission))
      (proposal (try! (get-proposal-or-err proposal-id)))
    )
    ;;check that proposal creator is choosing submission
    (asserts! (is-eq tx-sender (get poster proposal)) (err ERR_UNAUTHORIZED))
    ;;check that proposal isn't expired
    (asserts! (<= (- block-height (get stacks-height proposal)) FUNDING_LENGTH) (err ERR_FUNDING_EXPIRED_FOR_PROPOSAL))
    ;;merge new information on the proposal
    (ok (map-set Proposals proposal-id (
      merge proposal {
          hash: (get hash submission),
          stacks-height: block-height,
          funding-recipient: (some (get submitter submission))
      }
    )))
  )
)

(define-public (choose-and-fund-submission (submission-id uint) (amount uint) (token <sip-010-token>))
  (let 
    (
      (submission (try! (get-submission-or-err submission-id)))
      (proposal-id (get proposal-id submission))
      (proposal (try! (get-proposal-or-err proposal-id)))
    )
    ;;check that proposal creator is choosing submission
    (asserts! (is-eq tx-sender (get poster proposal)) (err ERR_UNAUTHORIZED))
    ;;check that proposal isn't expired
    (asserts! (<= (- block-height (get stacks-height proposal)) FUNDING_LENGTH) (err ERR_FUNDING_EXPIRED_FOR_PROPOSAL))
    ;;merge new information on the proposal
    (map-set Proposals proposal-id (
      merge proposal {
          hash: (get hash submission),
          stacks-height: block-height,
          funding-recipient: (some (get submitter submission))
      }
    ))
    (ok (fund token proposal-id amount))
  )
)