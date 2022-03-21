---
title: "Trait disastrous-teal-rabbit"
draft: true
---
```

;; escrow
;; <add a description here>

;; errors 

(define-constant ERR_ADDRESS_NOT_FOUND u100)
(define-constant ERR_ID_NOT_FOUND u101)
(define-constant ERR_ADDRESSES_IDENTICAL u102)
(define-constant ERR_PAYMENT_BELOW_MINIMUM u103)
(define-constant ERR_ESCROW_NOT_FOUND u104)
(define-constant ERR_ESCROW_ALREADY_CLOSED u105)
(define-constant ERR_BOTH_PARTIES_MUST_AGREE u106)

(define-constant CONTRACT_ADDRESS (as-contract tx-sender))

;; constants
(define-data-var escrowIdTip uint u0)
(define-data-var addressIdTip uint u0)

(define-data-var minimumPayment uint u1000000)

;;

;; MAPS

;; stores all escrows

(define-map Escrows
    { id: uint }
    {
        clientId: uint,
        freelancerId: uint,
        stxPayment: uint,
        blockInitiated: uint,
        blockOfResolution: uint,
        clientAgreed: bool,
        freelancerAgreed: bool,
    }
)

;; lookup table to get address from id
(define-map IdToAddress
    { id: uint }
    { address: principal}
)

;; lookup table to get id from address
(define-map AddressToId
    { address: principal}
    { id: uint }
)

;; private functions
;; returns address id if it has been created, or creates and returns new ID
(define-private (get-or-create-address-id (address principal))
  (match (get id (map-get? AddressToId { address: address })) id
    id
    (let
      ((newId (+ u1 (var-get addressIdTip))))
      (map-set IdToAddress {id: newId} {address: address})
      (map-set AddressToId {address: address} {id: newId})
      (var-set addressIdTip newId)
      newId
    )
  )
)
;;

;; public functions
(define-public (open-escrow (freelancerAddress principal) (stxPayment uint))
    ;; maybe we immediately take fee to discourage spamming escrows?
    (let
      (
        (clientAddress contract-caller)
        (escrowId (var-get escrowIdTip))
      )
      (asserts! (not (is-eq clientAddress freelancerAddress)) (err ERR_ADDRESSES_IDENTICAL))
      (asserts! (not (< stxPayment (var-get minimumPayment))) (err ERR_PAYMENT_BELOW_MINIMUM))

      (try! (stx-transfer? stxPayment clientAddress CONTRACT_ADDRESS))

      (asserts! (map-insert Escrows {id: (+ escrowId u1)}
                  {
                    clientId: (get-or-create-address-id clientAddress),
                    freelancerId: (get-or-create-address-id freelancerAddress),
                    stxPayment: stxPayment,
                    blockInitiated: block-height,
                    blockOfResolution: u0,
                    clientAgreed: false,
                    freelancerAgreed: false,
                  }
                ) 
      (err u0))
      (var-set escrowIdTip (+ escrowId u1))
      ;; (ok (map-get? Escrows { id: (+ escrowId u1) }))
      (ok true)
    )
)
(define-public (close-escrow (escrowId uint))
    (let
        (
            (escrow (unwrap! (map-get? Escrows { id: escrowId }) (err ERR_ESCROW_NOT_FOUND)))
            (blockOfResolution (get blockOfResolution escrow))
            (clientAgreed (get clientAgreed escrow))
            (freelancerAgreed (get freelancerAgreed escrow))
            (freelancerId (get freelancerId escrow))
            (freelancerAddress (unwrap! (get address (map-get? IdToAddress { id: freelancerId })) (err ERR_ADDRESS_NOT_FOUND)))
            (stxPayment (get stxPayment escrow))
        )
      (asserts! (is-eq blockOfResolution u0) (err ERR_ESCROW_ALREADY_CLOSED))
      (asserts! (and (is-eq clientAgreed true) (is-eq freelancerAgreed true)) (err ERR_BOTH_PARTIES_MUST_AGREE))

      (try! (as-contract (stx-transfer? stxPayment CONTRACT_ADDRESS freelancerAddress)))
    
      (asserts! (map-set Escrows {id: escrowId}
                  {
                    clientId: (get clientId escrow),
                    freelancerId: freelancerId,
                    stxPayment: stxPayment,
                    blockInitiated: (get blockInitiated escrow),
                    blockOfResolution: block-height,
                    clientAgreed: true,
                    freelancerAgreed: true,
                  }
                ) 
      (err u0))

      (ok true)
    )
)

(define-public (agree-to-close-escrow (escrowId uint))
   (let
        (
            (escrow (unwrap! (map-get? Escrows { id: escrowId }) (err ERR_ESCROW_NOT_FOUND)))
            (callerAddress contract-caller)
            (clientId (get clientId escrow))
            (clientAddress (unwrap! (get address (map-get? IdToAddress { id: clientId })) (err ERR_ADDRESS_NOT_FOUND)))
            (freelancerId (get freelancerId escrow))
            (freelancerAddress (unwrap! (get address (map-get? IdToAddress { id: freelancerId })) (err ERR_ADDRESS_NOT_FOUND)))
            (stxPayment (get stxPayment escrow))
            (blockInitiated (get blockInitiated escrow))
            (blockOfResolution (get blockOfResolution escrow))
            (clientAgreed (get clientAgreed escrow))
            (freelancerAgreed (get freelancerAgreed escrow))
        )
      (asserts! (is-eq blockOfResolution u0) (err ERR_ESCROW_ALREADY_CLOSED))

      (if (is-eq callerAddress clientAddress)
        (asserts! (map-set Escrows {id: escrowId}
                  {
                    clientId: clientId,
                    freelancerId: freelancerId,
                    stxPayment: stxPayment,
                    blockInitiated: blockInitiated,
                    blockOfResolution: u0,
                    clientAgreed: true,
                    freelancerAgreed: freelancerAgreed,
                  }
                ) 
        (err u0))
        (if (is-eq callerAddress freelancerAddress)
          (asserts! (map-set Escrows {id: escrowId}
                    {
                      clientId: clientId,
                      freelancerId: freelancerId,
                      stxPayment: stxPayment,
                      blockInitiated: blockInitiated,
                      blockOfResolution: u0,
                      clientAgreed: clientAgreed,
                      freelancerAgreed: true,
                    }
                  ) 
          (err u0))
          false
       )
      )
      (ok true)
  )
)


;; read-only functions

(define-read-only (address-to-id (address principal))
    (ok (unwrap! (get id (map-get? AddressToId { address: address })) (err ERR_ADDRESS_NOT_FOUND)))
)

(define-read-only (id-to-address (id uint))
    (ok (unwrap! (get address (map-get? IdToAddress { id: id })) (err ERR_ID_NOT_FOUND)))
)

(define-read-only (get-escrow (escrowId uint))
    (ok (unwrap! (map-get? Escrows { id: escrowId }) (err ERR_ESCROW_NOT_FOUND)))
)

```
