;; Title: CCD004 City Registry
;; Version: 1.0.0
;; Summary: A central city registry for the CityCoins protocol.
;; Description: An extension contract that associates a city name (string-ascii 10) with an ID (uint) for use in other CityCoins extensions.

;; TRAITS

(impl-trait .extension-trait.extension-trait)

;; CONSTANTS

(define-constant ERR_UNAUTHORIZED (err u4000))

;; DATA VARS

(define-data-var citiesNonce uint u0)

;; DATA MAPS

(define-map CityNames uint (string-ascii 10))
(define-map CityIds (string-ascii 10) uint)

;; PUBLIC FUNCTIONS

(define-public (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender .base-dao)
    (contract-call? .base-dao is-extension contract-caller)) ERR_UNAUTHORIZED
  ))
)

(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)

(define-public (get-or-create-city-id (cityName (string-ascii 10)))
  (begin 
    (try! (is-dao-or-extension))
    (match (map-get? CityIds cityName)
      value (ok value)
      (let
        ((newId (+ u1 (var-get citiesNonce))))
        (map-insert CityNames newId cityName)
        (map-insert CityIds cityName newId)
        (var-set citiesNonce newId)
        (ok newId)
      )
    )
  )
)

;; READ ONLY FUNCTIONS

(define-read-only (get-city-id (cityName (string-ascii 10)))
  (map-get? CityIds cityName)
)

(define-read-only (get-city-name (cityId uint))
  (map-get? CityNames cityId)
)
