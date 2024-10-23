(define-trait sip010-ft-trait
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

(define-trait proposal-trait
	(
		(execute (principal) (response bool uint))
	)
)

(define-trait governance-token-trait
	(
		(dmg-get-balance (principal) (response uint uint))
		(dmg-has-percentage-balance (principal uint) (response bool uint))
		(dmg-transfer (uint principal principal) (response bool uint))
		(dmg-lock (uint principal) (response bool uint))
		(dmg-unlock (uint principal) (response bool uint))
		(dmg-get-locked (principal) (response uint uint))
		(dmg-mint (uint principal) (response bool uint))
		(dmg-burn (uint principal) (response bool uint))
	)
)

(define-trait extension-trait
	(
		(callback (principal (buff 34)) (response bool uint))
	)
)

(define-trait nft-trait
  (
    (get-last-token-id () (response uint uint))
    (get-token-uri (uint) (response (optional (string-ascii 256)) uint))
    (get-owner (uint) (response (optional principal) uint))
    (transfer (uint principal principal) (response bool uint))
  )
)

(define-trait liquid-ft-trait
	(
		(get-balance (principal) (response uint uint))
		(transfer (uint principal principal (optional (buff 34))) (response bool uint))
		(deflate (uint) (response bool uint))
	)
)

(define-trait cdk-trait
	(
		(tap (uint) (response (tuple (type (string-ascii 256)) (land-id uint) (land-amount uint) (energy uint)) uint))
	)
)

(define-trait edk-trait
	(
		(tap (uint <cdk-trait> (optional uint)) (response (tuple (type (string-ascii 256)) (land-id uint) (land-amount uint) (energy uint)) uint))
	)
)

(define-trait ft-plus-trait
  ((mint (uint principal) (response bool uint))
   (burn (uint principal) (response bool uint))

   ;; sip-010-trait
   (transfer (uint principal principal (optional (buff 34)))
             (response bool uint))
   (get-name         ()          (response (string-ascii 32) uint))
   (get-symbol       ()          (response (string-ascii 32) uint))
   (get-decimals     ()          (response uint uint))
   (get-balance      (principal) (response uint uint))
   (get-total-supply ()          (response uint uint))
   (get-token-uri    ()          (response (optional (string-utf8 256)) uint))
))

(define-trait share-fee-to-trait
  ((receive (uint bool uint) (response bool uint))
))