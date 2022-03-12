;; @contract Governance
;; @version 1.1

(use-trait lydian-dao-proposal-trait .lydian-dao-proposal-trait.lydian-dao-proposal-trait)
(use-trait ft-trait .sip-010-trait-ft-standard.sip-010-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant ERR-NOT-AUTHORIZED u2103001)

(define-constant ERR-CONTRACT-DISABLED u2101001)

(define-constant ERR-INSUFFICIENT-BALANCE u2100001)
(define-constant ERR-BLOCK-HEIGHT-NOT-REACHED u2100002)
(define-constant ERR-WRONG-START-BLOCK u2100003)
(define-constant ERR-PROPOSAL-CLOSED u2100004)
(define-constant ERR-PROPOSAL-NOT-STARTED u2100005)
(define-constant ERR-WRONG-CONTRACT u2100006)
(define-constant ERR-PROPOSAL-ENDED u2100007)
(define-constant ERR-NO-VOTES-LEFT u2100008)
(define-constant ERR-VOTE-LENGTH u2100009)
(define-constant ERR-BOOTSTRAP-ENDED u2100010)

;; ------------------------------------------
;; Variables
;; ------------------------------------------

(define-data-var contract-owner principal tx-sender)
(define-data-var contract-is-enabled bool true)

(define-data-var proposal-count uint u0)
(define-data-var bootstrap-phase-end uint (+ block-height u13000))

;; ------------------------------------------
;; Maps
;; ------------------------------------------

(define-map proposals
  { id: uint }
  {
    proposer: principal,
    title: (string-utf8 256),
    url: (string-utf8 256),
    contract: principal,
    is-ended: bool,
    start-block-height: uint,
    end-block-height: uint,
    yes-votes: uint,
    no-votes: uint,
  }
)

(define-map votes-by-member 
  { 
    proposal-id: uint, 
    member: principal, 
  } 
  { 
    yes-votes: uint,
    no-votes: uint
  }
)

;; ------------------------------------------
;; Var & Map Helpers
;; ------------------------------------------

(define-read-only (get-contract-is-enabled)
  (var-get contract-is-enabled)
)

(define-read-only (get-proposal-count)
  (var-get proposal-count)
)

(define-read-only (get-proposal-by-id (proposal-id uint))
  (default-to
    {
      proposer: (var-get contract-owner),
      title: u"",
      url: u"",
      contract: (var-get contract-owner),
      is-ended: false,
      start-block-height: u0,
      end-block-height: u0,
      yes-votes: u0,
      no-votes: u0,
    }
    (map-get? proposals { id: proposal-id })
  )
)

(define-read-only (get-votes-by-member (proposal-id uint) (member principal))
  (default-to
    {
      yes-votes: u0,
      no-votes: u0,
    }
    (map-get? votes-by-member { proposal-id: proposal-id, member: member })
  )
)

;; ------------------------------------------
;; Core
;; ------------------------------------------

(define-public (propose-public
  (title (string-utf8 256))
  (url (string-utf8 256))
  (contract principal)
  (start-block-height uint)
)
  (let (
    (supply (unwrap-panic (contract-call? .lydian-token get-total-supply)))
    (total-balance (unwrap-panic (user-max-votes (- block-height u1) tx-sender)))
  )
    ;; Requires 1% of the supply 
    (asserts! (>= (* total-balance u100) supply) (err ERR-INSUFFICIENT-BALANCE))
    
    ;; Update proposals
    (propose title url contract start-block-height u1008)
  )
)

(define-public (propose-owner
  (title (string-utf8 256))
  (url (string-utf8 256))
  (contract principal)
  (start-block-height uint)
  (vote-length uint)
)
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err  ERR-NOT-AUTHORIZED))

    ;; Min 2 days
    (asserts! (>= vote-length u288) (err ERR-VOTE-LENGTH))

    ;; Update proposals
    (propose title url contract start-block-height vote-length)
  )
)

(define-private (propose
  (title (string-utf8 256))
  (url (string-utf8 256))
  (contract principal)
  (start-block-height uint)
  (vote-length uint)
)
  (let (
    (proposal-id (var-get proposal-count))
    (proposal {
      proposer: tx-sender,
      title: title,
      url: url,
      contract: contract,
      is-ended: false,
      start-block-height: start-block-height,
      end-block-height: (+ start-block-height vote-length),
      yes-votes: u0,
      no-votes: u0,
    })
  )
    (asserts! (var-get contract-is-enabled) (err ERR-CONTRACT-DISABLED))
    (asserts! (> start-block-height block-height) (err ERR-WRONG-START-BLOCK))

    ;; Update proposals
    (map-set proposals
      { id: proposal-id }
      proposal
    )
    (var-set proposal-count (+ proposal-id u1))

    (print { type: "proposal", action: "created", data: proposal })
    (ok true)
  )
)

(define-public (vote (vote-for bool) (proposal-id uint) (amount uint))
  (let (
    (proposal (get-proposal-by-id proposal-id))
    (member-votes (get-votes-by-member proposal-id tx-sender))
    (total-member-votes (+ (get yes-votes member-votes) (get no-votes member-votes)))
    (max-member-votes (unwrap-panic (user-max-votes (get start-block-height proposal) tx-sender)))
    (member-votes-left (- max-member-votes total-member-votes))
  )
    (asserts! (var-get contract-is-enabled) (err ERR-CONTRACT-DISABLED))

    ;; Proposal should be open for voting
    (asserts! (< block-height (get end-block-height proposal)) (err ERR-PROPOSAL-CLOSED))

    ;; Vote should be cast after the start-block-height
    (asserts! (>= block-height (get start-block-height proposal)) (err ERR-PROPOSAL-NOT-STARTED))

    ;; Check if member has votes left
    (asserts! (<= amount member-votes-left) (err ERR-NO-VOTES-LEFT))

    ;; Update proposal votes
    (if vote-for
      (begin
        (map-set proposals
          { id: proposal-id }
          (merge proposal { yes-votes: (+ amount (get yes-votes proposal)) })
        )
        (map-set votes-by-member
          { proposal-id: proposal-id, member: tx-sender }
          (merge member-votes { yes-votes: (+ amount (get yes-votes member-votes)) })
        )
      )
      (begin
        (map-set proposals
          { id: proposal-id }
          (merge proposal { no-votes: (+ amount (get no-votes proposal)) })
        )
        (map-set votes-by-member
          { proposal-id: proposal-id, member: tx-sender }
          (merge member-votes { no-votes: (+ amount (get no-votes member-votes)) })
        )
      )
    )

    (print { type: "proposal", action: "voted", data: proposal })
    (ok amount)
  )
)

(define-public (end-proposal (proposal-id uint) (proposal-trait <lydian-dao-proposal-trait>))
  (let (
    (proposal (get-proposal-by-id proposal-id))
  )
    (asserts! (var-get contract-is-enabled) (err ERR-CONTRACT-DISABLED))
    (asserts! (is-eq (contract-of proposal-trait) (get contract proposal)) (err ERR-WRONG-CONTRACT))
    (asserts! (is-eq (get is-ended proposal) false) (err ERR-PROPOSAL-ENDED))
    (asserts! (>= block-height (get end-block-height proposal)) (err ERR-BLOCK-HEIGHT-NOT-REACHED))

    ;; Update proposal ended
    (map-set proposals
      { id: proposal-id }
      (merge proposal { is-ended: true })
    )

    ;; Execute proposal if needed
    (if (> (get yes-votes proposal) (get no-votes proposal))
      (begin
        (try! (as-contract (contract-call? .lydian-dao execute-proposal proposal-trait)))
        true
      )
      false
    )

    (print { type: "proposal", action: "ended", data: proposal })
    (ok true)
  )
)

;; ------------------------------------------
;; Getters
;; ------------------------------------------

(define-read-only (user-max-votes-on-proposal (proposal-id uint) (member principal))
  (let (
    (proposal (get-proposal-by-id proposal-id))
  )
    (user-max-votes (get start-block-height proposal) member)
  )
)

(define-read-only (user-max-votes (block uint) (member principal))
  (if (>= block block-height)
    (ok u0)
    (let (
      (block-hash (unwrap-panic (get-block-info? id-header-hash block)))

      (votes-ldn (unwrap-panic (at-block block-hash (contract-call? .lydian-token get-balance member))))
      (votes-sldn (unwrap-panic (at-block block-hash (contract-call? .staked-lydian-token get-balance member))))

      (balance-wldn (unwrap-panic (at-block block-hash (contract-call? .wrapped-lydian-token get-balance member))))
      (sldn-index (at-block block-hash (contract-call? .staked-lydian-token get-index)))
      (votes-wldn (/ (* balance-wldn sldn-index) u1000000))
    )
      (ok (+ votes-ldn votes-sldn votes-wldn))
    )
  )
)

;; ------------------------------------------
;; Owner
;; ------------------------------------------

;; Executes a proposal immediately. Needed during the bootstrap phase.
;; After the bootstrap phase a new governance contract will be deployed
;; without this function to make the protocol fully decentralised. 
(define-public (execute-proposal (proposal-trait <lydian-dao-proposal-trait>))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))

    ;; Check if bootstrap phase not ended yet
    (asserts! (<= block-height (var-get bootstrap-phase-end)) (err ERR-BOOTSTRAP-ENDED))

    (print { type: "contract-owner", action: "execute-proposal", data: { bootstrap-phase-end: (var-get bootstrap-phase-end)} })

    (as-contract (contract-call? .lydian-dao execute-proposal proposal-trait))
  )
)

;; ------------------------------------------
;; Admin
;; ------------------------------------------

(define-public (set-contract-is-enabled (enabled bool))
  (begin
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))
    (var-set contract-is-enabled enabled)
    (ok true)
  )
)
