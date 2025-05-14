---
title: "Trait blaze-rc10"
draft: true
---
```
;; title: blaze-intent
;; authors: rozar.btc
;; summary: Utility contract for verifying intent-based signed messages (v2).

(define-constant structured-data-prefix 0x534950303138)                               ;; "SIP018"
(define-constant message-domain-hash (sha256 (unwrap-panic (to-consensus-buff? { name: "BLAZE_PROTOCOL", version: "intent-v1", chain-id: chain-id }))))
(define-constant structured-data-header (concat structured-data-prefix message-domain-hash))

(define-constant ERR_INVALID_SIGNATURE (err u400))
(define-constant ERR_CONSENSUS_BUFF    (err u401))
(define-constant ERR_UUID_SUBMITTED    (err u402))

(define-map submitted-uuids (string-ascii 36) bool)

(define-public (execute
    (signature (buff 65))
    (intent    (string-ascii 32))
    (opcode    (optional (buff 16)))
    (amount    (optional uint))
    (target    (optional principal))
    (uuid      (string-ascii 36))
  )
  (let (
        (message (try! (hash contract-caller intent opcode amount target uuid)))
      )
    ;; 1. replay-protection
    (asserts! (is-none (map-get? submitted-uuids uuid)) ERR_UUID_SUBMITTED)
    ;; 2. consume uuid
    (map-set submitted-uuids uuid true)
    ;; 3. verify signature, return recovered signer
    (verify message signature)
  )
)

(define-read-only (check (uuid (string-ascii 36)))
  (is-some (map-get? submitted-uuids uuid))
)

(define-read-only (hash
    (contract principal)
    (intent   (string-ascii 32))
    (opcode   (optional (buff 16)))
    (amount   (optional uint))
    (target   (optional principal))
    (uuid     (string-ascii 36))
  )
  (let (
        (payload {
          contract: contract,
          intent:   intent,
          opcode:   opcode,
          amount:   amount,
          target:   target,
          uuid:     uuid
        })
        (digest (sha256 (unwrap! (to-consensus-buff? payload) ERR_CONSENSUS_BUFF)))
      )
    (ok (sha256 (concat structured-data-header digest)))
  )
)

(define-read-only (recover
    (signature (buff 65))
    (contract  principal)
    (intent    (string-ascii 32))
    (opcode    (optional (buff 16)))
    (amount    (optional uint))
    (target    (optional principal))
    (uuid      (string-ascii 36))
  )
  (let ((message (try! (hash contract intent opcode amount target uuid))) )
    (verify message signature)
  )
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
```
