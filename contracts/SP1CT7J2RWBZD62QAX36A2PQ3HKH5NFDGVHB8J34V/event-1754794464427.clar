;; ======================
;; TITLE: Alpha Test Giveaway
;; VERSION: 1.0.0
;; SUMMARY: The first ever DeOrganized Giveaway... let's hope this works. First come, first serve. 50 Slots Available.
;; ======================

;; ======================
;; CONSTANTS
;; ======================

;; Event Constants
(define-constant contract-owner tx-sender)
(define-constant contract-deployer tx-sender)
(define-constant contract-name "event-1754794464427")
(define-constant asset-identifier "event-1754794464427")
(define-constant default-name "Alpha Test Giveaway")
(define-constant default-description "The first ever DeOrganized Giveaway... let's hope this works. First come, first serve. 50 Slots Available.")
(define-constant thumbnail-uri "https://9ok0w2gk6hipqasu.public.blob.vercel-storage.com/Alpha%20Test%20Special-N10ohrckqb2uk5dkCozP3L7UMIbREJ.jpg")
(define-constant event-type u2)

;; Currency Constants
(define-constant currency-stx u1)
(define-constant currency-sbtc u2)

;; Host Constants
(define-constant web-host "https://deorganized.events")
(define-constant api-host "https://deorganized-events-api.vercel.app")
(define-constant token-uri-template (concat api-host "/api/contracts/SP1CT7J2RWBZD62QAX36A2PQ3HKH5NFDGVHB8J34V/event-1754794464427/tokens/"))

;; Creator Fee Schedule Constants
(define-constant creator-info { 
  creator-1: { percent-of-100: u100, name: "DeOrganized", address: 'SP2Z2CBMGWB9MQZAF5Z8X56KS69XRV3SJF4WKJ7J9 }
})

;; ======================
;; ERROR CONSTANTS
;; ======================

;; Common Errors (2000-2099)
(define-constant err-unknown-event (err u2000))
(define-constant err-unknown-contract (err u2001))
(define-constant err-unknown-sender (err u2002))
(define-constant err-unknown-recipient (err u2003))

;; Auth Errors (2100-2199)
(define-constant err-unauthorized (err u2100))
(define-constant err-invalid-fee-config (err u2101))

;; Game Specific Errors (3000-3099)
(define-constant err-reservation-id-exists (err u3000))
(define-constant err-insufficient-fee (err u3001))
(define-constant err-insufficient-offer (err u3002))
(define-constant err-offer-accepted (err u3003))
(define-constant err-offers-closed (err u3004))
(define-constant err-max-reservations (err u3005))
(define-constant err-non-transferable (err u3006))

;; HTTP-like Errors (4000-4099)
(define-constant err-not-found (err u4004))


;; ======================
;; TOKEN DEFINITIONS
;; ======================

;; NFT collection that stores reservations
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-non-fungible-token event-1754794464427 uint)

;; ======================
;; DATA VARS
;; ======================

;; Nonce Counters
(define-data-var reservation-nonce uint u0)

;; Event Details
(define-data-var event-details {
  name: (string-ascii 256),
  start-time: uint, 
  end-time: uint,
  address-one: (string-ascii 256),
  address-two: (string-ascii 256),
  city: (string-ascii 256),
  state: (string-ascii 256),
  postal: (string-ascii 256),
  country: (string-ascii 256),
  phone: (string-ascii 28),
  contact: (string-ascii 128)
  } {
    name: "",
    start-time: u1756425600,
    end-time: u1756436400,
    address-one: "",
    address-two: "",
    city: "",
    state: "",
    postal: "",
    country: "",
    phone: "",
    contact: "email@example.com"
})

;; Event Information
(define-data-var event-name (string-ascii 32) default-name)
(define-data-var event-description (string-ascii 256) default-description)
(define-data-var event-thumbnail (string-ascii 256) thumbnail-uri)
(define-data-var min-reservation-fee uint u0)
(define-data-var max-reservations uint u50)
(define-data-var open-reservations uint u0)
(define-data-var is-transferable bool true)
(define-data-var allow-offers bool false)

;; Preferred Currency
(define-data-var preferred-currency uint currency-stx)

;; Add to DATA VARS section
(define-data-var min-reservation-fee-sbtc uint u0)


;; ======================
;; DATA MAPS
;; ======================

;; Reservation Information - reservation metadata
(define-map reservation-data uint { 
    reservation-id: uint,
    reservation-owner: principal,
    reservation-text1: (string-ascii 128),
    reservation-text2: (string-ascii 256),
    currency-type: uint
})

(define-map reservations uint { 
    reservation-id: uint
})


;; ======================
;; PUBLIC FUNCTIONS
;; ======================

;; mint to create a reservation
;; #[allow(unchecked_data)]
(define-public (make-reservation 
    (reservation-id uint)
    (fee uint) 
    (owner principal) 
    (text1 (string-ascii 128))
    (text2 (string-ascii 256))
)
  (begin 

    (asserts! (is-eq tx-sender owner) err-unauthorized)
    (asserts! (or (is-eq u0 (var-get max-reservations)) (< (var-get open-reservations) (var-get max-reservations))) err-max-reservations)
    (asserts! (is-none (map-get? reservation-data reservation-id)) err-reservation-id-exists)
    (asserts! (>= fee (var-get min-reservation-fee)) err-insufficient-fee)

    (if (> fee u0) (distribute-fees fee) false)
    (try! (mint owner reservation-id))
    (var-set open-reservations (+ u1 (var-get open-reservations)))

    (print { 
      eventName: "rt-reservation-created", 
      eventData: {
        destinationDeployer: contract-owner,
        destinationContractName: contract-name,
        tokenUri: (create-token-uri reservation-id),
        launchUri: (create-launch-uri reservation-id),
        reservationId: reservation-id, 
        reservationOwner: owner, 
        reservationText1: text1, 
        reservationText2: text2,
        currency-type: currency-stx
      }
    })
    
    (ok (map-set reservation-data reservation-id {
      reservation-id: reservation-id, 
      reservation-owner: owner, 
      reservation-text1: text1, 
      reservation-text2: text2,
      currency-type: currency-stx
    })) 

  )
)

;; burn reservation to close it
(define-public (burn-reservation (reservation-id uint))
    (begin 
        (asserts! (> reservation-id u0) err-not-found)
        (if (map-delete reservation-data reservation-id)
            (begin
            (var-set open-reservations (- (var-get open-reservations) u1))

            (print { 
              eventName: "rt-reservation-closed", 
              eventData: {
                destinationDeployer: contract-owner,
                destinationContractName: contract-name,
                reservationId: reservation-id
              }
            })
            
            (ok (unwrap-panic (nft-burn? event-1754794464427 reservation-id tx-sender)))
            )
            (ok false)
        )
    )
)

;; set fee, event owner only
;; #[allow(unchecked_data)] 
(define-public (set-event-info 
    (name (string-ascii 32)) 
    (description (string-ascii 256)) 
    (thumbnail (string-ascii 256))
    (open-reservation-fee uint) 
    (max-reservations-allowed uint)
    (transferable bool)
  ) 
  (begin 
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (asserts! (or (is-eq max-reservations-allowed u0) (>= max-reservations-allowed (var-get open-reservations))) err-insufficient-fee)
    (ok 
      (and 
        (and 
          (and (var-set event-name name) (var-set event-description description))
          (and 
            (and (var-set min-reservation-fee open-reservation-fee) (var-set event-thumbnail thumbnail)) 
            (and (var-set is-transferable transferable) (var-set max-reservations max-reservations-allowed))
          )
        )
      )
    )
  )
)

;; set max reservation limit, used to increase available reservations, set to 0 for unlimited
(define-public (set-max-reservations (slots uint)) 
  (begin 
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (asserts! (> slots (var-get max-reservations)) err-not-found)
    (var-set max-reservations slots)
    (ok slots)
  )
)

;; sip-009
;; allow reservation owner to transfer ownership
(define-public (transfer (reservation-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-unauthorized)
    (asserts! (or (is-eq tx-sender contract-owner) (var-get is-transferable)) err-non-transferable)
    (asserts! (is-some (map-get? reservation-data reservation-id)) err-not-found)

    (print { 
      eventName: "rt-reservation-transferred", 
      eventData: {
        destinationDeployer: contract-owner,
        destinationContractName: contract-name,
        reservationId: reservation-id,
        sender: sender,
        recipient: recipient
      }
    })

    (let ((sm (unwrap-panic (map-get? reservation-data reservation-id))))
      (map-set reservation-data reservation-id (merge sm
       {reservation-owner: recipient}))
    )
    
    (nft-transfer? event-1754794464427 reservation-id sender recipient)
  )
)

;; Add new function for sBTC reservations
;; #[allow(unchecked_data)]
(define-public (make-reservation-sbtc 
    (reservation-id uint)
    (fee uint) 
    (owner principal) 
    (text1 (string-ascii 128))
    (text2 (string-ascii 256)))
  (begin
    ;; Validate inputs
    (asserts! (is-none (map-get? reservation-data reservation-id)) err-reservation-id-exists)
    (asserts! (>= fee (var-get min-reservation-fee-sbtc)) err-insufficient-fee)
    (asserts! (< (var-get open-reservations) (var-get max-reservations)) err-max-reservations)
    
    ;; Process sBTC payment and distribute fees
    (try! (if (> fee u0) (distribute-fees-sbtc fee) (ok true)))

    ;; Create reservation
    (try! (mint owner reservation-id))
    
    ;; Update reservation data
    (map-set reservation-data reservation-id {
      reservation-id: reservation-id,
      reservation-owner: owner,
      reservation-text1: text1,
      reservation-text2: text2,
      currency-type: currency-sbtc
    })

    ;; Update open reservations count
    (var-set open-reservations (+ (var-get open-reservations) u1))

    ;; Print event for chainhook monitoring
    (print { 
      eventName: "rt-reservation-created", 
      eventData: {
        destinationDeployer: contract-owner,
        destinationContractName: contract-name,
        tokenUri: (create-token-uri reservation-id),
        launchUri: (create-launch-uri reservation-id),
        reservationId: reservation-id, 
        reservationOwner: owner, 
        reservationText1: text1, 
        reservationText2: text2,
        currency-type: currency-sbtc
      }
    })

    (ok true)
  )
)


;; ======================
;; READ ONLY FUNCTIONS
;; ======================

;; event information
(define-read-only (get-event-info)
    (ok {
        ;; event data
        event-contract: (as-contract tx-sender),
        event-name: (var-get event-name),
        event-description: (var-get event-description),
        event-thumbnail: (var-get event-thumbnail),
        asset-identifier: asset-identifier,
        event-type: event-type,
        min-reservation-fee: (var-get min-reservation-fee),
        min-reservation-fee-sbtc: (var-get min-reservation-fee-sbtc),
        max-reservations: (var-get max-reservations),
        open-reservations: (var-get open-reservations),
        is-transferable: (var-get is-transferable),
        allow-offers: (var-get allow-offers)
    })
)

;; reservation information
(define-read-only (get-reservation (reservation-id uint)) 
(begin
  (asserts! (is-some (map-get? reservation-data reservation-id)) err-not-found)
    (ok {
        reservation-id: (default-to u0 (get reservation-id (map-get? reservation-data reservation-id))),
        reservation-owner: (get reservation-owner (map-get? reservation-data reservation-id)),
        reservation-text1: (get reservation-text1 (map-get? reservation-data reservation-id)),
        reservation-text2: (get reservation-text2 (map-get? reservation-data reservation-id)),
        token-uri: (unwrap-panic (get-token-uri reservation-id)),
        launch-uri: (unwrap-panic (get-launch-uri reservation-id)),
        event-info: (unwrap-panic (get-event-info))
    })
  )
)

;; get event details
(define-read-only (get-event-details) 
  (ok (var-get event-details))
)

(define-read-only (get-reservation-id (reservation-index uint)) 
  (ok (map-get? reservations reservation-index))
)

;; creator traits
(define-read-only (get-creator-info)
  (ok creator-info)
)

;; get fee for opening a reservation
(define-read-only (get-reservation-fee) 
    (ok (var-get min-reservation-fee))
)

;; get the current owner of a reservation
(define-read-only (get-owner (reservation-id uint))
  (ok (nft-get-owner? event-1754794464427 reservation-id))
)

;; lookup most recent reservation nonce
(define-read-only (get-last-token-id)
  (ok (var-get open-reservations)))

;; deeplink route to the reservation view location
(define-read-only (get-token-uri (reservation-id uint))
  (begin
    (asserts! (is-some (map-get? reservation-data reservation-id)) err-not-found)
    (ok 
      (some (create-token-uri reservation-id))
    )
  )
)

;; return a launch url to destination
(define-read-only (get-launch-uri (reservation-id uint))
  (begin
    (asserts! (is-some (map-get? reservation-data reservation-id)) err-not-found)
    (ok 
      (some (create-launch-uri reservation-id))
    )
  )
)

;; ======================
;; PRIVATE FUNCTIONS
;; ======================

;; mint function to mint a new reservation
(define-private (mint (new-owner principal) (reservation-id uint))
  (begin 
      (asserts! (is-none (map-get? reservation-data reservation-id)) err-reservation-id-exists)
      (nft-mint? event-1754794464427 reservation-id new-owner)
  )
)

;;generate token uri
(define-private (create-token-uri (reservation-id uint))
    (concat token-uri-template (int-to-ascii reservation-id))
)

;;generate launch uri
(define-private (create-launch-uri (reservation-id uint))
  (concat "https://deorganized-events-api.vercel.app/api/contracts/SP1CT7J2RWBZD62QAX36A2PQ3HKH5NFDGVHB8J34V/event-1754794464427/reservations/" (int-to-ascii reservation-id))
)

;; rt-distribute-trait
;; distribute fees per fee schedule
(define-private (distribute-fees (total-fees uint))
  (begin
    (if (not (is-eq tx-sender (get address (get creator-1 creator-info)))) (unwrap-panic (stx-transfer? (* (/ total-fees u100) (get percent-of-100 (get creator-1 creator-info))) tx-sender (get address (get creator-1 creator-info)))) true)
  )
)

;; Add sBTC fee distribution
(define-private (distribute-fees-sbtc (total-fees uint))
  (begin
    (if (not (is-eq tx-sender (get address (get creator-1 creator-info)))) (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer (* (/ total-fees u100) (get percent-of-100 (get creator-1 creator-info))) tx-sender (get address (get creator-1 creator-info)) none)) true) (ok true)
  )
)

(print { 
  eventName: "rt-event-deployed", 
  eventData: {
    managerContract: "not applicable",
    eventDeployer: contract-owner,
    eventContractName: contract-name,
    eventName: (var-get event-name),
    eventDescription: (var-get event-description),
    thumbnailUri: (var-get event-thumbnail),
    assetIdentifier: asset-identifier,
    eventType: event-type,
    minReservationFee: (var-get min-reservation-fee),
    maxReservationsAllowed: (var-get max-reservations),
    isTransferable: (var-get is-transferable),
    offersAllowed: (var-get allow-offers),
    distributions: (get-creator-info),
    eventDetails: (get-event-details)
  }
})
