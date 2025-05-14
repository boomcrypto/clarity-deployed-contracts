;; Website: https://boltproto.org
(define-constant ERR-PRECONDITION-FAILED (err u1001))
(define-constant ERR-PERMISSION-DENIED (err u2001))
(define-constant ERR-UNAUTHORIZED-SPONSOR-OPERATOR (err u2002))
(define-constant ERR-NOT-CURRENT-OPERATOR (err u2003))
(define-constant ERR-CONTRACT-LOCKED (err u3001))
(define-constant ERR-INSUFFICIENT-FUNDS (err u4001))
(define-constant ERR-INSUFFICIENT-FUNDS-FOR-FEE (err u4002))
(define-constant ERR-NOT-MANAGER (err u2004))
(define-constant ERR-INSUFFICIENT-FEE-BALANCE (err u4003))
(define-constant ERR-UNAUTHORIZED-FEE-COLLECTOR (err u2005))
(define-constant ERR-NO-OPERATOR (err u2006))
(define-data-var blocks-to-withdraw uint u5)
(define-data-var governance-fee-ratio uint u30)
(define-data-var governance-treasury uint u0)
(define-data-var operator-treasury uint u0)
(define-data-var governance-withdrawer principal tx-sender)
(define-data-var contract-fee-fund uint u0)
(define-map wallet-data principal 
    {
        balance: uint,
        withdraw-requested-amount: uint,
        withdraw-requested-block: uint
    })
(define-data-var contract-manager principal tx-sender)
(define-data-var sponsor-operator principal tx-sender)
(define-data-var fee-collector-operator principal tx-sender)
(define-read-only (get-wallet-data (user principal))
    (default-to 
        {
            balance: u0,
            withdraw-requested-amount: u0,
            withdraw-requested-block: u0
        }
        (map-get? wallet-data user)
    ))
(define-read-only (get-sponsor-operator)
    (var-get sponsor-operator))
(define-read-only (get-contract-manager)
    (var-get contract-manager))
(define-read-only (get-fee-collector-operator)
    (var-get fee-collector-operator))
(define-read-only (get-blocks-to-withdraw)
    (var-get blocks-to-withdraw))
(define-read-only (get-governance-treasury)
    (var-get governance-treasury))
(define-read-only (get-operator-treasury)
    (var-get operator-treasury))
(define-read-only (get-governance-withdrawer)
    (var-get governance-withdrawer))
(define-read-only (get-governance-fee-ratio)
    (var-get governance-fee-ratio))
(define-read-only (get-contract-fee-fund)
    (var-get contract-fee-fund))
(define-public (transfer-stacks-to-stacks 
                    (amount uint) 
                    (recipient principal) 
                    (memo (optional (buff 34))) 
                    (fee uint))
    (let (
          (sender tx-sender)
         )
        (try! (pay-fee fee))
        (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer amount tx-sender recipient memo))
        (print {
            event: "transfer-stacks-to-stacks",
            sender: tx-sender,
            amount: amount,
            recipient: recipient,
            fee: fee,
            memo: (match memo to-print (print to-print) 0x)
        })
        (ok true)
    )
)
(define-public (deposit
                    (amount uint)
                    (recipient principal)
                    (memo (optional (buff 34))))
    (let (
            (wd (get-wallet-data recipient))
        )
        (asserts! (> amount u0) ERR-PRECONDITION-FAILED)
        (map-set wallet-data recipient
            (merge wd { balance: (+ (get balance wd) amount) }))
        (match memo to-print (print to-print) 0x)
        (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer amount tx-sender (as-contract tx-sender) memo))
        (print {
            event: "deposit",
            sender: tx-sender,
            amount: amount,
            recipient: recipient
        })
        (ok true)
    )
)
(define-public (transfer-stacks-to-bolt 
                    (amount uint)
                    (recipient principal)
                    (memo (optional (buff 34)))
                    (fee uint))
    (let (
        (recipient-wallet (get-wallet-data recipient))
    )
        (asserts! (is-eq (unwrap! tx-sponsor? ERR-NO-OPERATOR) (var-get sponsor-operator)) ERR-UNAUTHORIZED-SPONSOR-OPERATOR)
        (asserts! (> amount u0) ERR-PRECONDITION-FAILED)
        (map-set wallet-data recipient
            (merge recipient-wallet { balance: (+ (get balance recipient-wallet) amount) }))
        (split-fee fee)
        (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer (+ amount fee) tx-sender (as-contract tx-sender) memo))
        (print {
            event: "transfer-stacks-to-bolt",
            sender: tx-sender,
            amount: amount,
            recipient: recipient,
            fee: fee
        })
        (ok true)
    )
)
(define-public (transfer-bolt-to-bolt 
                (amount uint)
                (recipient principal)
                (memo (optional (buff 34)))
                (fee uint))
    (let (
        (sender tx-sender)
        (sender-data (get-wallet-data sender))
        (current-balance (get balance sender-data))
        (withdraw-amount (get withdraw-requested-amount sender-data))
        (balance-required (+ amount fee))
        (recipient-wallet (get-wallet-data recipient))
    )
        (asserts! (is-eq (unwrap! tx-sponsor? ERR-NO-OPERATOR) (var-get sponsor-operator)) ERR-UNAUTHORIZED-SPONSOR-OPERATOR)
        (asserts! (>= (+ current-balance withdraw-amount) balance-required) ERR-INSUFFICIENT-FUNDS)
        (if (>= current-balance balance-required)
            (map-set wallet-data sender 
                (merge sender-data { balance: (- current-balance balance-required) }))
            (let ((remaining-amount (- balance-required current-balance)))
                (map-set wallet-data sender 
                    (merge sender-data { 
                        balance: u0,
                        withdraw-requested-amount: (- withdraw-amount remaining-amount)
                    }))
            )
        )
        (map-set wallet-data recipient 
            (merge recipient-wallet 
                { balance: (+ (get balance recipient-wallet) amount) }))
        (split-fee fee)
        (print {
            event: "transfer-bolt-to-bolt",
            sender: tx-sender,
            amount: amount,
            recipient: recipient,
            fee: fee,
            memo: (match memo to-print (print to-print) 0x)
        })
        (ok true)
    ))
(define-public (transfer-bolt-to-stacks 
                (amount uint)
                (recipient principal)
                (memo (optional (buff 34)))
                (fee uint))
    (let (
        (sender tx-sender)
        (sender-data (get-wallet-data sender))
        (current-balance (get balance sender-data))
        (withdraw-amount (get withdraw-requested-amount sender-data))
        (balance-required (+ amount fee))
    )
        (asserts! (is-eq (unwrap! tx-sponsor? ERR-NO-OPERATOR) (var-get sponsor-operator)) ERR-UNAUTHORIZED-SPONSOR-OPERATOR)
        (asserts! (>= (+ current-balance withdraw-amount) amount) ERR-INSUFFICIENT-FUNDS)
        (if (>= current-balance balance-required)
            (map-set wallet-data sender 
                (merge sender-data { balance: (- current-balance balance-required) }))
            (let ((remaining-amount (- balance-required current-balance)))
                (map-set wallet-data sender 
                    (merge sender-data { 
                        balance: u0,
                        withdraw-requested-amount: (- withdraw-amount remaining-amount)
                    }))
            )
        )
        (match memo to-print (print to-print) 0x)
        (split-fee fee)
        (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer 
            amount
            tx-sender 
            recipient 
            memo)))
        (print {
            event: "transfer-bolt-to-stacks",
            sender: tx-sender,
            amount: amount,
            recipient: recipient,
            fee: fee
        })
        (ok true)
    ))
(define-public (pay-fee (amount uint))
    (begin
        (asserts! (> amount u0) ERR-PRECONDITION-FAILED)
        (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer amount tx-sender (as-contract tx-sender) none))
        (split-fee amount)
        (print {
            event: "pay-fee",
            amount: amount,
            fee: amount
        })
        (ok true)
    ))
(define-private (split-fee (amount uint))
    (let (
        (gov-ratio (var-get governance-fee-ratio))
        (gov-amount (/ (* amount gov-ratio) u100))
        (op-amount (- amount gov-amount))
    )
        (var-set governance-treasury (+ (var-get governance-treasury) gov-amount))
        (var-set operator-treasury (+ (var-get operator-treasury) op-amount))
    ))
(define-public (deposit-governance-treasury (amount uint))
    (begin
        (asserts! (> amount u0) ERR-PRECONDITION-FAILED)
        (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer amount tx-sender (as-contract tx-sender) none))
        (var-set governance-treasury (+ (var-get governance-treasury) amount))
        (print {
            event: "deposit-governance-treasury",
            sender: tx-sender,
            amount: amount
        })
        (ok true)
    ))
(define-public (set-sponsor-operator (new-operator principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-manager)) ERR-NOT-MANAGER)
        (var-set sponsor-operator new-operator)
        (ok true)))
(define-public (set-governance-fee-ratio (new-ratio uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-manager)) ERR-NOT-MANAGER)
        (asserts! (<= new-ratio u100) ERR-PRECONDITION-FAILED)
        (var-set governance-fee-ratio new-ratio)
        (ok true)))
(define-public (set-contract-manager (new-manager principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-manager)) ERR-NOT-MANAGER)
        (var-set contract-manager new-manager)
        (ok true)))
(define-public (set-fee-collector-operator (new-operator principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-manager)) ERR-NOT-MANAGER)
        (var-set fee-collector-operator new-operator)
        (ok true)))
(define-public (set-governance-withdrawer (new-withdrawer principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-manager)) ERR-NOT-MANAGER)
        (var-set governance-withdrawer new-withdrawer)
        (ok true)))
(define-public (withdraw-governance-treasury (amount uint) (recipient principal))
    (let ((current-balance (var-get governance-treasury)))
        (asserts! (is-eq tx-sender (var-get governance-withdrawer)) ERR-UNAUTHORIZED-FEE-COLLECTOR)
        (asserts! (>= current-balance amount) ERR-INSUFFICIENT-FEE-BALANCE)
        (var-set governance-treasury (- current-balance amount))
        (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer 
            amount
            tx-sender 
            recipient
            none)))
        (print {
            event: "withdraw-governance-treasury",
            sender: tx-sender,
            amount: amount,
            recipient: recipient
        })
        (ok true)))
(define-public (withdraw-operator-treasury (amount uint) (recipient principal))
    (let ((current-balance (var-get operator-treasury)))
        (asserts! (is-eq tx-sender (var-get fee-collector-operator)) ERR-UNAUTHORIZED-FEE-COLLECTOR)
        (asserts! (>= current-balance amount) ERR-INSUFFICIENT-FEE-BALANCE)
        (var-set operator-treasury (- current-balance amount))
        (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer 
            amount
            tx-sender 
            recipient
            none)))
        (print {
            event: "withdraw-operator-treasury",
            sender: tx-sender,
            amount: amount,
            recipient: recipient
        })
        (ok true)))
(define-public (request-withdrawal (amount uint))
    (let (
        (user contract-caller)
        (sender-data (get-wallet-data user))
        (current-balance (get balance sender-data))
    )
        (asserts! (>= current-balance amount) ERR-INSUFFICIENT-FUNDS)
        (map-set wallet-data user
            (merge sender-data {
                balance: (- current-balance amount),
                withdraw-requested-amount: (+ (get withdraw-requested-amount sender-data) amount),
                withdraw-requested-block: stacks-block-height
            }))
        (ok true)
    ))
(define-public (claim-withdrawal)
    (let (
        (user contract-caller)
        (sender-data (get-wallet-data user))
        (withdraw-amount (get withdraw-requested-amount sender-data))
        (request-block (get withdraw-requested-block sender-data))
    )
        (asserts! (> withdraw-amount u0) ERR-INSUFFICIENT-FUNDS)
        (asserts! (>= stacks-block-height (+ request-block (var-get blocks-to-withdraw))) ERR-PRECONDITION-FAILED)
        (map-set wallet-data user
            (merge sender-data {
                withdraw-requested-amount: u0,
                withdraw-requested-block: u0
            }))
        (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer 
            withdraw-amount
            tx-sender 
            user
            none)))
        (print {
            event: "claim-withdrawal",
            sender: tx-sender,
            amount: withdraw-amount,
            recipient: user
        })
        (ok true)
    ))
(define-public (set-blocks-to-withdraw (blocks uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-manager)) ERR-NOT-MANAGER)
        (var-set blocks-to-withdraw blocks)
        (ok true)))
(define-public (deposit-fee-fund (amount uint) (fee uint))
    (begin
        (asserts! (is-eq (unwrap! tx-sponsor? ERR-NO-OPERATOR) (var-get sponsor-operator)) ERR-UNAUTHORIZED-SPONSOR-OPERATOR)
        (asserts! (> amount u0) ERR-PRECONDITION-FAILED)
        (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer (+ amount fee) tx-sender (as-contract tx-sender) none))
        (var-set contract-fee-fund (+ (var-get contract-fee-fund) amount))
        (split-fee fee)
        (print {
            event: "deposit-fee-fund",
            sender: tx-sender,
            amount: amount,
            fee: fee
        })
        (ok true)
    )
)
(define-public (consume-fee-fund (amount uint))
    (begin
        (asserts! (is-eq tx-sender (var-get fee-collector-operator)) ERR-UNAUTHORIZED-FEE-COLLECTOR)
        (asserts! (>= (var-get contract-fee-fund) amount) ERR-INSUFFICIENT-FUNDS)
        (var-set contract-fee-fund (- (var-get contract-fee-fund) amount))
        (split-fee amount)
        (print {
            event: "use-fee-fund",
            amount: amount,
            operator: tx-sender
        })
        (ok true)
    )
)
