;; title: welsh-credits-rc5
;; authors: rozar.btc
;; summary: A permissionless credit tracking system supporting variable-amount physical note transfers.
;;   Notes are redeemed via `redeem-note`. Supports depositing to specific accounts and 
;;   withdrawing credits to specific recipients. Uses an external signer utility.

;; --- Constants ---
(define-constant MAX_BATCH_SIZE u200)
(define-constant DECIMALS u6) ;; Welshcorgicoin has 6 decimal places
(define-constant ONE (pow u10 DECIMALS)) ;; e.g., u1000000 if DECIMALS is u6

;; --- Errors ---
(define-constant ERR_INSUFFICIENT_BALANCE  (err u100))
(define-constant ERR_UNAUTHORIZED          (err u106)) ;; For standard transfer auth check or withdrawal check
(define-constant ERR_TOO_MANY_OPERATIONS   (err u104))
(define-constant ERR_OPCODE_ACTION_FAILED  (err u109)) ;; Insufficient balance during transfer execution

;; --- Data Storage ---
;; Map storing internal credit balances
(define-map balances principal uint)

;; --- Public Functions ---

;; Deposit underlying tokens FROM tx-sender TO the recipient's credit balance.
;; If recipient is none, defaults to tx-sender.
(define-public (deposit (amount uint) (recipient (optional principal)))
  (let
    (
      (sender tx-sender) ;; The principal sending the tokens
      ;; If recipient is none, use sender, otherwise use the provided recipient.
      (effective-recipient (default-to sender recipient))
      (current-recipient-balance (default-to u0 (map-get? balances effective-recipient)))
    )
    ;; 1. Transfer actual tokens from sender to this contract
    (try! (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token transfer amount sender (as-contract tx-sender) none))

    ;; 2. Credit the internal balance of the effective recipient
    (map-set balances effective-recipient (+ current-recipient-balance amount))

    (print { event: "deposit", sender: sender, recipient: effective-recipient, amount: amount })
    (ok true)
  )
)

;; Withdraw credits FROM tx-sender's balance, sending underlying tokens TO the recipient.
;; If recipient is none, defaults to tx-sender.
(define-public (withdraw (amount uint) (recipient (optional principal)))
  (let
    (
      (owner tx-sender) ;; Owner of the credits is the one sending the transaction
      ;; If recipient is none, send tokens to owner, otherwise send to the provided recipient.
      (effective-recipient (default-to owner recipient))
      (current-owner-balance (default-to u0 (map-get? balances owner)))
    )
    ;; 1. Check sufficient internal credit balance of the owner (tx-sender)
    (asserts! (>= current-owner-balance amount) ERR_INSUFFICIENT_BALANCE)

    ;; 2. First reduce the internal credit balance of the owner
    (map-set balances owner (- current-owner-balance amount))

    ;; 3. Then transfer actual tokens from this contract TO the effective recipient
    (try! (as-contract (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token transfer amount tx-sender effective-recipient none)))

    (print { event: "withdraw", owner: owner, recipient: effective-recipient, amount: amount })
    (ok true)
  )
)

;; Standard SIP-010 compatible transfer function *for internal credits*
(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (let
    (
      (sender tx-sender)
      (current-from-balance (default-to u0 (map-get? balances from)))
      (current-to-balance (default-to u0 (map-get? balances to)))
    )
    (asserts! (is-eq sender from) ERR_UNAUTHORIZED) ;; Sender must be the 'from' address
    (asserts! (>= current-from-balance amount) ERR_INSUFFICIENT_BALANCE)
    (map-set balances from (- current-from-balance amount))
    (map-set balances to (+ current-to-balance amount))
    (print { event: "transfer", from: from, to: to, amount: amount, memo: memo })
    (ok true)
  )
)

;; --- Signed "Physical Note" Redemption Entry Point ---
;; Redeems a variable-denomination note authorized by an off-chain signature.
;; Amount is provided directly and scaled by token decimals.
;; Recipient ('to') is specified at submission time.
(define-public (redeem-note
    (signature (buff 65))
    (amount uint)               ;; The transfer amount (already in token units)
    (uuid (string-ascii 36))
    (to principal)              ;; Recipient provided at submission time
  )
  (let
    (
      ;; 1. Verify signature via Signer Contract & consume UUID
      ;; Note: for simplicity, we pass amount as a string in the signature verification
      (opcode (concat "TRANSFER_" (int-to-ascii amount)))
      (signer-principal (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.blaze-rc9 submit signature opcode uuid)))
    )
    ;; 2. Execute the internal credit transfer from signer to the provided 'to' address
    (try! (do-internal-transfer signer-principal to (* amount ONE)))

    ;; If successful, return ok
    (print { event: "redeem-note", action: "transfer", from: signer-principal, to: to, amount: (* amount ONE), uuid: uuid })
    (ok true)
  )
)

;; Batch redemption of signed variable-denomination physical notes
(define-public (batch-redeem-notes
    (operations (list 200 {
      signature: (buff 65),
      amount: uint,               ;; The transfer amount (already in token units)
      uuid: (string-ascii 36),
      to: principal              ;; Recipient for each operation
    }))
  )
  (begin
    ;; Check list size *before* processing
    (asserts! (<= (len operations) MAX_BATCH_SIZE) ERR_TOO_MANY_OPERATIONS)
    ;; Map over operations, attempting each one
    (ok (map try-redeem-note operations))
  )
)

;; --- SIP-010 Compatibility Passthrough ---
;; Using literal principal for contract-call?
(define-read-only (get-name) (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-name))
(define-read-only (get-symbol) (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-symbol))
(define-read-only (get-decimals) (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-decimals))
(define-read-only (get-token-uri) (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-token-uri))
(define-read-only (get-total-supply) (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-total-supply))

;; --- Other Read-Only Functions ---
(define-read-only (get-balance (owner principal))
  (default-to u0 (map-get? balances owner))
)

;; --- Private Functions ---

;; Helper to attempt executing a single signed note redemption for batch processing
(define-private (try-redeem-note
    (operation { signature: (buff 65), amount: uint, uuid: (string-ascii 36), to: principal })
  )
  (match (redeem-note
    (get signature operation)
    (get amount operation)
    (get uuid operation)
    (get to operation)
  )
    success true
    error false
  )
)

;; Helper to perform the internal credit transfer logic
(define-private (do-internal-transfer (from principal) (to principal) (amount uint))
  (let
    (
      (current-from-balance (default-to u0 (map-get? balances from)))
      (current-to-balance (default-to u0 (map-get? balances to)))
    )
    (asserts! (>= current-from-balance amount) ERR_OPCODE_ACTION_FAILED) ;; Check 'from' balance
    (map-set balances from (- current-from-balance amount))
    (map-set balances to (+ current-to-balance amount))
    (ok true)
  )
)