;; title: blaze
;; author: rozar.btc
;; version: 1.0
;; contributors: @obycode, @LNow_
;; summary: Core SIP-018 verifier + replay-protection that underpins all blaze subnets.
;;   Verifies secp256k1 signatures, prevents UUID re-use, and exposes signer principals
;;   for token subnets, NFTs, and DeFi modules built atop this intent-based protocol.

(define-constant structured-data-prefix 0x534950303138)
(define-constant message-domain {name: "BLAZE_PROTOCOL", version: "v1.0", chain-id: chain-id})
(define-constant message-domain-hash (sha256 (unwrap-panic (to-consensus-buff? message-domain))))
(define-constant structured-data-header (concat structured-data-prefix message-domain-hash))

(define-constant ERR_INVALID_SIGNATURE (err u401000))
(define-constant ERR_CONSENSUS_BUFF    (err u422000))
(define-constant ERR_UUID_SUBMITTED    (err u409000))

(define-map submitted-uuids (string-ascii 36) bool)

(define-read-only (hash
    (contract principal)
    (intent   (string-ascii 32))
    (opcode   (optional (buff 16)))
    (amount   (optional uint))
    (target   (optional principal))
    (uuid     (string-ascii 36))
  )
  (ok (sha256 (concat structured-data-header (sha256 
    (unwrap! (to-consensus-buff? {
      contract: contract, 
      intent: intent, 
      opcode: opcode, 
      amount: amount, 
      target: target, 
      uuid: uuid
    }) ERR_CONSENSUS_BUFF)
  ))))
)

;; (define-public (execute
;;     (signature (buff 65))
;;     (intent    (string-ascii 32))
;;     (opcode    (optional (buff 16)))
;;     (amount    (optional uint))
;;     (target    (optional principal))
;;     (uuid      (string-ascii 36))
;;   )
;;   (if (map-insert? submitted-uuids uuid true)
;;     (verify (try! (hash contract-caller intent opcode amount target uuid)) signature)
;;     ERR_UUID_SUBMITTED
;;   )
;; )

(define-read-only (recover
    (signature (buff 65))
    (contract  principal)
    (intent    (string-ascii 32))
    (opcode    (optional (buff 16)))
    (amount    (optional uint))
    (target    (optional principal))
    (uuid      (string-ascii 36))
  )
  (verify (try! (hash contract intent opcode amount target uuid)) signature)
)

(define-read-only (verify 
    (message   (buff 32)) 
    (signature (buff 65))
  )
  (match (secp256k1-recover? message signature)
    public-key (principal-of? public-key)
    error ERR_INVALID_SIGNATURE
  )
)

(define-read-only (check (uuid (string-ascii 36)))
  (is-some (map-get? submitted-uuids uuid))
)