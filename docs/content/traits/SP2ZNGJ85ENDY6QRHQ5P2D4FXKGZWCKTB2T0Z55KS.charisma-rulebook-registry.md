---
title: "Trait charisma-rulebook-registry"
draft: true
---
```
;; Charisma Rulebook Registry
;;
;; This contract manages the official rulebooks that can be used within the Charisma protocol.
;; It provides centralized control over which rulebook implementations are considered valid,
;; allowing for graceful protocol upgrades and emergency circuit breaking if needed.

;; Traits
(use-trait rulebook-trait .charisma-traits-v1.rulebook-trait)

;; Constants
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_INVALID_RULEBOOK (err u403))
(define-constant ERR_RULEBOOK_DISABLED (err u404))

;; Data Variables
(define-data-var contract-owner principal tx-sender)

;; Maps
(define-map registered-rulebooks principal bool)
(define-map rulebook-metadata principal 
   {name: (string-ascii 64), 
    version: (string-ascii 32), 
    enabled: bool})

;; Initialize rulebooks
(map-set registered-rulebooks .charisma-rulebook-v0 true)
(map-set rulebook-metadata .charisma-rulebook-v0 
    {name: "Charisma Rulebook", 
     version: "v0", 
     enabled: true})

;; Private functions
(define-private (is-contract-owner)
   (is-eq contract-caller (var-get contract-owner)))

;; Authorization function
(define-public (authorize (rulebook <rulebook-trait>))
   (match (map-get? rulebook-metadata (contract-of rulebook))
        metadata (if (get enabled metadata) (ok true) 
            (err "ERR_RULEBOOK_DISABLED"))
        (err "ERR_INVALID_RULEBOOK")))

;; Public functions
(define-public (set-contract-owner (new-owner principal))
   (begin
       (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
       (ok (var-set contract-owner new-owner))))

(define-public (register-rulebook (rulebook principal) (name (string-ascii 64)) (version (string-ascii 32)))
    (let ((metadata {name: name, version: version, enabled: true}))
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        (map-set registered-rulebooks rulebook true)
        (map-set rulebook-metadata rulebook metadata)
        (ok metadata)))

(define-public (disable-rulebook (rulebook principal))
   (begin
       (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
       (match (map-get? rulebook-metadata rulebook)
           metadata (ok (map-set rulebook-metadata rulebook 
               (merge metadata {enabled: false})))
           ERR_INVALID_RULEBOOK)))

(define-public (enable-rulebook (rulebook principal))
   (begin
       (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
       (match (map-get? rulebook-metadata rulebook)
           metadata (ok (map-set rulebook-metadata rulebook 
               (merge metadata {enabled: true})))
           ERR_INVALID_RULEBOOK)))

;; Read-only functions
(define-read-only (get-rulebook-info (rulebook principal))
   (ok (map-get? rulebook-metadata rulebook)))

(define-read-only (get-contract-owner)
   (ok (var-get contract-owner)))
```
