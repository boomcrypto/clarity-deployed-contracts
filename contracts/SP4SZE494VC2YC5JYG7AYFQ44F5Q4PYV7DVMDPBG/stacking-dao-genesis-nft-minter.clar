;; @contract Stacking DAO Genesis NFT
;; @version 1
;;
;; Stacking DAO Genesis NFT minter
;; 

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_NOT_AUTHORIZED u1101)
(define-constant ERR_CANNOT_CLAIM u1102)
(define-constant ERR_ALREADY_CLAIMED u1103)
(define-constant DEPLOYER tx-sender)

;;-------------------------------------
;; Maps
;;-------------------------------------

(define-map claims principal bool)

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var cycle-end-block uint u135418)

;;-------------------------------------
;; Getters
;;-------------------------------------

;; If people held at least 100 stSTX throughout cycle 74/75, they can claim a Stacking DAO Genesis NFT
(define-read-only (can-claim (account principal))
  (let (
    (balances (contract-call? .block-info-v1 get-user-ststx-at-block account (var-get cycle-end-block)))
    (ststx-balance (get ststx-balance balances))
    (lp-balance (get lp-balance balances))
  )
    (>= (+ ststx-balance lp-balance) u99000000)
  )
)

(define-read-only (has-claimed (account principal))
  (default-to false (map-get? claims account))
)

(define-read-only (get-cycle-end-block)
  (var-get cycle-end-block)
)

;;-------------------------------------
;; Setters
;;-------------------------------------

(define-public (set-cycle-end-block (end-block uint))
  (ok (var-set cycle-end-block end-block))
)

;;-------------------------------------
;; Claim
;;-------------------------------------

(define-public (claim)
  (begin
    (asserts! (can-claim tx-sender) (err ERR_CANNOT_CLAIM))
    (asserts! (not (has-claimed tx-sender)) (err ERR_ALREADY_CLAIMED))

    (try! (contract-call? .stacking-dao-genesis-nft mint-for-protocol tx-sender u0))
    (map-set claims tx-sender true)
    (ok true)
  )
)

(define-public (airdrop (info (tuple (recipient principal) (type uint))))
  (let (
    (recipient (get recipient info))
    (type (get type info))
  )
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR_NOT_AUTHORIZED))
    (asserts! (can-claim recipient) (err ERR_CANNOT_CLAIM))
    (asserts! (not (has-claimed recipient)) (err ERR_ALREADY_CLAIMED))

    (try! (contract-call? .stacking-dao-genesis-nft mint-for-protocol recipient type))
    (map-set claims recipient true)
    (ok true)
  )
)

(define-public (airdrop-many (recipients (list 25 (tuple (recipient principal) (type uint)))))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR_NOT_AUTHORIZED))
    (ok (map airdrop recipients))
  )
)
