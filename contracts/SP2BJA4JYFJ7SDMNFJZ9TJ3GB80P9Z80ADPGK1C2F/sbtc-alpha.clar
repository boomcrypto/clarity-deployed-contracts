
;; title: sbtc-token-key-admin
;; version:
;; summary:
;; description:

;; traits
;;
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; token definitions
;; 
(define-fungible-token sbtc u21000000)

;; constants
;;
(define-constant err-invalid-caller u1)
(define-constant err-invalid-signer-id u2)
(define-constant err-not-token-owner u3)
(define-constant err-trading-halted u4)

;; data vars
;;
(define-data-var contract-owner principal tx-sender)
(define-data-var coordinator (optional {addr: principal, key: (buff 33)}) none)
(define-data-var num-keys uint u4000)
(define-data-var num-parties uint u4000)
(define-data-var threshold uint u2800)
(define-data-var bitcoin-wallet-address (optional (string-ascii 72)) none)
(define-data-var trading-halted bool false)

;; data maps
;;
(define-map signers uint {addr: principal, key: (buff 33)})

;; public functions
;;
(define-public (set-contract-owner (owner principal))
    (begin
        (asserts! (is-contract-owner) (err err-invalid-caller))
        (ok (var-set contract-owner owner))
    )
)

(define-public (set-coordinator-data (data {addr: principal, key: (buff 33)}))
    (begin
        (asserts! (is-contract-owner) (err err-invalid-caller))
        (ok (var-set coordinator (some data)))
    )
)

(define-public (set-num-keys (n uint))
    (begin
        (asserts! (is-contract-owner) (err err-invalid-caller))
        (ok (var-set num-keys n))
    )
)

(define-public (set-num-parties (n uint))
    (begin
        (asserts! (is-contract-owner) (err err-invalid-caller))
        (ok (var-set num-parties n))
    )
)

(define-public (set-threshold (n uint))
    (begin
        (asserts! (is-contract-owner) (err err-invalid-caller))
        (ok (var-set threshold n))
    )
)

(define-public (set-trading-halted (b bool))
    (begin
        (asserts! (is-coordinator) (err err-invalid-caller))
        (ok (var-set trading-halted b))
    )
)

(define-public (set-signer-data (id uint) (data {addr: principal, key: (buff 33)}))
    (begin
        (asserts! (is-contract-owner) (err err-invalid-caller))
        (asserts! (is-valid-signer-id id) (err err-invalid-signer-id))
        (ok (map-set signers id data))
    )
)

(define-public (delete-signer-data (id uint))
    (begin
        (asserts! (is-contract-owner) (err err-invalid-caller))
        (asserts! (is-valid-signer-id id) (err err-invalid-signer-id))
        (ok (map-delete signers id))
    )
)

(define-public (set-bitcoin-wallet-address (addr (string-ascii 72)))
    (begin
        (asserts! (is-coordinator) (err err-invalid-caller))
        (ok (var-set bitcoin-wallet-address (some addr)))
    )
)

(define-public (mint! (amount uint) (dst principal) (peg-in-txid (string-ascii 72)))
    (begin
        (asserts! (is-coordinator) (err err-invalid-caller))
        (print peg-in-txid)
        (ft-mint? sbtc amount dst)
    )
)

(define-public (burn! (amount uint) (src principal) (peg-out-txid (string-ascii 72)))
    (begin
        (asserts! (is-coordinator) (err err-invalid-caller))
        (print peg-out-txid)
        (ft-burn? sbtc amount src)
    )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (is-eq tx-sender sender) (err err-not-token-owner))
		(asserts! (is-eq (var-get trading-halted) false) (err err-trading-halted))
		(try! (ft-transfer? sbtc amount sender recipient))
		(match memo to-print (print to-print) 0x)
		(ok true)
	)
)

;; read only functions
;;
(define-read-only (get-coordinator-data)
    (var-get coordinator)
)

(define-read-only (get-num-keys)
    (var-get num-keys)
)

(define-read-only (get-num-parties)
    (var-get num-parties)
)

(define-read-only (get-threshold)
    (var-get threshold)
)

(define-read-only (get-trading-halted)
    (var-get trading-halted)
)

(define-read-only (get-bitcoin-wallet-address)
    (var-get bitcoin-wallet-address)
)

(define-read-only (get-signer-data (signer uint))
    (map-get? signers signer)
)

;;(define-read-only (get-signers)
;;    (map-get? signers)
;;)

(define-read-only (get-name)
	(ok "sBTC")
)

(define-read-only (get-symbol)
	(ok "sBTC")
)

(define-read-only (get-decimals)
	(ok u8)
)

(define-read-only (get-balance (who principal))
	(ok (ft-get-balance sbtc who))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply sbtc))
)

(define-read-only (get-token-uri)
	(ok (some u"https://assets.stacks.co/sbtc.pdf"))
)

;; private functions
;;
(define-private (is-contract-owner)
    (is-eq (var-get contract-owner) tx-sender)
)

(define-private (is-coordinator)
    (match (var-get coordinator) cdata
        (is-eq (get addr cdata) tx-sender)
        false
    )
)

(define-private (is-valid-signer-id (id uint))
    (and (>= id u0) (< id (var-get num-keys)))
)
