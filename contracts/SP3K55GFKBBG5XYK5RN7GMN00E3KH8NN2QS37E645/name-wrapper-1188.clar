;; Source code for the name wrapper contract.
;; 
;; This contract is not meant to be deployed as a standalone contract in
;; the BNSx protocol. Instead, it is deployed for each individual name that
;; is upgraded to BNSx.
;; 
;; The purpose of this contract is to own a BNS name, and only allow
;; owners of the equivalent name on BNSx to control the legacy name.
;; 
;; For example, if a wrapper contract owns `name.btc`, and Alice owns `name.btc`
;; on BNSx, then only Alice can interact with this contract.

(define-constant ERR_NO_NAME (err u10000))
(define-constant ERR_NAME_TRANSFER (err u10001))
(define-constant ERR_UNAUTHORIZED (err u10002))
(define-constant ERR_NOT_WRAPPED (err u10003))

(define-data-var wrapper-id-var (optional uint) none)

;; Unwrap the BNS name from this contract.
;; 
;; When unwrapping, the BNSx name is burned. This ensures that there is a 1-to-1
;; mapping between BNSx and BNS names.
;; 
;; @throws if called by anyone other than the BNSx name owner
;; 
;; @param recipient; the name owner can optionally transfer the BNS name to
;; a different account. If `none`, recipient defauls to `tx-sender`.
(define-public (unwrap (recipient (optional principal)))
  (let
    (
      (props (try! (get-name-info)))
      (new-owner (default-to tx-sender recipient))
      (owner (get owner props))
    )
    (asserts! (is-eq tx-sender owner) ERR_UNAUTHORIZED)
    (try! (contract-call? 'SP1JTCR202ECC6333N7ZXD7MK7E3ZTEEE1MJ73C60.bnsx-registry burn (get id props)))
    (unwrap! (as-contract (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer (get namespace props) (get name props) new-owner none)) ERR_NAME_TRANSFER)
    (ok props)
  )
)

;; Helper method to fetch the BNS name owned by this contract.
(define-read-only (get-own-name)
  (ok (unwrap! (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal (as-contract tx-sender)) ERR_NO_NAME))
)

;; Helper method to fetch information about the BNSx name that is equivalent to the
;; BNS name owned by this contract. For example, if this contract owns `name.btc`,
;; it returns the properties of `name.btc` on BNSx.
(define-read-only (get-name-info)
  (let
    (
      (name (try! (get-own-name)))
      (props (unwrap! (contract-call? 'SP1JTCR202ECC6333N7ZXD7MK7E3ZTEEE1MJ73C60.bnsx-registry get-name-properties name) ERR_NOT_WRAPPED))
    )
    (ok props)
  )
)

;; Helper method to return the owner of the BNSx name that is equivalent to this
;; contract's legacy name
(define-read-only (get-owner)
  (ok (get owner (try! (get-name-info))))
)

;; Helper method to interact with BNS to update the zonefile for this name
;; 
;; @throws if called by anyone other than the BNSx name owner
(define-public (name-update (namespace (buff 20)) (name (buff 48)) (zonefile-hash (buff 20)))
  (let
    (
      (props (try! (get-name-info)))
    )
    (asserts! (is-eq tx-sender (get owner props)) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get namespace props) namespace) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get name props) name) ERR_UNAUTHORIZED)
    (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.bns name-update namespace name zonefile-hash))
      r (ok true)
      e (err (to-uint e))
    )
  )
)

;; Helper method to interact with BNS to renew the name
;; 
;; @param stx-to-burn; the number of STX to burn to renew the name
(define-public (name-renewal (stx-to-burn uint))
  (let
    (
      (props (try! (get-name-info)))
    )
    (asserts! (is-eq tx-sender (get owner props)) ERR_UNAUTHORIZED)
    (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.bns name-renewal
      (get namespace props)
      (get name props)
      stx-to-burn
      none
      none
    ))
      r (ok true)
      e (err (to-uint e))
    )
  )
)

;; Allow BNSx name owner to withdraw any NFTs that were sent to this contract
(define-public (withdraw-nft (nft <nft-trait>) (token-id uint) (recipient principal))
  (begin
    ;; #[filter(nft)]
    (try! (validate-owner))
    (as-contract (contract-call? nft transfer token-id tx-sender recipient))
  )
)

;; Allow BNSx name owner to withdraw any fungible tokens that were sent to this contract
(define-public (withdraw-ft (ft <ft-trait>) (amount uint) (recipient principal))
  (begin
    ;; #[filter(ft)]
    (try! (validate-owner))
    (as-contract (contract-call? ft transfer amount tx-sender recipient none))
  )
)

;; Allow BNSx name owner to withdraw any STX that were sent to this contract
(define-public (withdraw-stx (amount uint) (recipient principal))
  (begin
    ;; #[filter(amount, recipient)]
    (try! (validate-owner))
    (as-contract (stx-transfer? amount tx-sender recipient))
  )
)

(define-read-only (get-wrapper-id)
  (var-get wrapper-id-var)
)

(define-private (register-self)
  (let
    (
      (self (as-contract tx-sender))
      (id (try! (contract-call? 'SP1JTCR202ECC6333N7ZXD7MK7E3ZTEEE1MJ73C60.wrapper-migrator register-wrapper self)))
    )
    (var-set wrapper-id-var (some id))
    (ok id)
  )
)

(define-private (validate-owner)
  (let
    (
      (props (try! (get-name-info)))
    )
    (asserts! (is-eq tx-sender (get owner props)) ERR_UNAUTHORIZED)
    (ok true)
  )
)

(try! (register-self))

(define-trait nft-trait
  (
    (get-last-token-id () (response uint uint))
    (get-token-uri (uint) (response (optional (string-ascii 256)) uint))
    (get-owner (uint) (response (optional principal) uint))
    (transfer (uint principal principal) (response bool uint))
  )
)
(define-trait ft-trait
  (
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
    (get-name () (response (string-ascii 32) uint))
    (get-symbol () (response (string-ascii 32) uint))
    (get-decimals () (response uint uint))
    (get-balance (principal) (response uint uint))
    (get-total-supply () (response uint uint))
    (get-token-uri () (response (optional (string-utf8 256)) uint))
  )
)