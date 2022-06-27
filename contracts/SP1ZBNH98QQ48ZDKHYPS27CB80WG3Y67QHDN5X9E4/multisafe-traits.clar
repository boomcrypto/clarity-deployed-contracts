;; Title: MultiSafe traits
;; Author: Talha Bugra Bulut & Trust Machines

(define-trait safe-trait
	(
		(add-owner (principal) (response bool uint))
		(remove-owner (principal) (response bool uint))
		(set-threshold (uint) (response bool uint))
	)
)

(define-trait sip-009-trait
  (
    (transfer (uint principal principal) (response bool uint))
  )
)

(define-trait sip-010-trait
  (
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
  )
)

(define-trait executor-trait
	(
		(execute (<safe-trait> <sip-010-trait> <sip-009-trait> (optional principal) (optional uint) (optional (buff 20))) (response bool uint))
	)
)


(define-trait magic-bridge-trait
  (
    (initialize-swapper () (response uint uint))

	(escrow-swap ( 
		{ header: (buff 80), height: uint } ;; block
		(list 10 (buff 80)) ;; prev-blocks
		(buff 1024) ;; tx
		{ tx-index: uint, hashes: (list 12 (buff 32)), tree-depth: uint } ;; proof
		uint ;; output-index
		(buff 33) ;; sender
		(buff 33) ;; recipient
		(buff 4) ;; expiration-buff
		(buff 32) ;; hash
		(buff 4) ;; swapper-buff
		uint ;; supplier-id
		uint ;; min-to-receive
	) (response  {
     	sender: (buff 33),
		output-index: uint,
		csv: uint,
		redeem-script: (buff 120),
		sats: uint
      } uint))

    (finalize-swap (
		(buff 32) ;; txid
		(buff 128) ;; preimage
	) (response {
  		swapper: uint,
  		xbtc: uint,
  		supplier: uint,
  		expiration: uint,
  		hash: (buff 32),
	} uint))

	(revoke-expired-inbound (
		(buff 32) ;; txid
	) (response {
  		swapper: uint,
  		xbtc: uint,
  		supplier: uint,
  		expiration: uint,
  		hash: (buff 32),
	} uint))
  )
)