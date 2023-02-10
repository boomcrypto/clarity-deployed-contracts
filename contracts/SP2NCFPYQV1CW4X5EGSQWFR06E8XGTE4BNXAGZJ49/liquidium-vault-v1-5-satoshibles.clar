
;;;; liquidium-vault-v1-5-satoshibles
;;;; nft: the-guests
;;;; Manages loans and auctions for the-guests assets as collateral
;;;; Offical website that calls the public functions can be found here:
;;;; https://liquidium.finance/

;;;; Constant definitions

;;; Standard principal that deployed contract
(define-constant DEPLOYER_ACCOUNT tx-sender)
(define-constant LIQUIDIUM_PROFITS 'SPYHY9MV6S08YJQVW0R400ADXZBBJ0GM096BMY34.liquidium-profits)
(define-constant LIQUIDIUM 'SPYHY9MV6S08YJQVW0R400ADXZBBJ0GM096BMY34)

;;; Error codes
(define-constant ERR_AUCTION_INACTIVE (err u1000))
(define-constant ERR_LOAN_INACTIVE (err u1001))

(define-constant ERR_AUCTION_NOT_FOUND (err u2000))
(define-constant ERR_LOAN_NOT_FOUND (err u2001))

(define-constant ERR_AMOUNT_INVALID (err u3000))
(define-constant ERR_TERM_INVALID (err u3001))
(define-constant ERR_VALUE_INVALID (err u3002))
(define-constant ERR_ACCOUNT_INVALID (err u3003))
(define-constant ERR_INPUT_INVALID (err u3004))

(define-constant ERR_ASSET_TRANSFER_FAILED (err u4000))
(define-constant ERR_STX_TRANSFER_FAILED (err u4001))

(define-constant ERR_AUCTION_ENDED (err u5000))
(define-constant ERR_LOAN_EXPIRED (err u5001))

(define-constant ERR_MAX_ACTIVE_LOANS_REACHED (err u6000))
(define-constant ERR_INSUFFICIENT_LIQUIDITY (err u6001))
(define-constant ERR_ON_APPEND (err u6002))

(define-constant ERR_ASSET_NOT_OWNED (err u7000))

(define-constant ERR_NOT_ALLOWED (err u9999))

;;;; Data variable definitions
(define-data-var loanToAssetRatio uint u2500) ;; as basis points ;; 2500 bp = 25 percent
(define-data-var loanLiquidationThreshhold uint u4000) ;; as basis points ;; 4000 bp = 40 percent
(define-data-var loanFeeRate uint u50) ;; as basis points ;; 50 bp = 0.5 percent
(define-data-var loanTermLengthMax uint u4380) ;; as blocks ;; 4380 ~= 30 days
(define-data-var loanTermLengthMin uint u1008) ;; as blocks ;; 1008 ~= 7 days
(define-data-var auctionDuration uint u144) ;; as blocks ;; 144 ~= 24 hours
(define-data-var loanTermInterestRates (list 5 {termLengthMin: uint, interestRate: uint})
    (list
        {termLengthMin: u0, interestRate: u0}
        {termLengthMin: u1152, interestRate: u0}
        {termLengthMin: u2160, interestRate: u0}
        {termLengthMin: u3168, interestRate: u0}
        {termLengthMin: u4176, interestRate: u0}
    )
)

;; available lending capital, prevents lending of auction bids
(define-data-var vaultLendingLiquidity uint u0)

;; uint value updated in public function (set-asset-floor-value)
(define-data-var assetFloor uint u1000000) ;; as microstacks ;; 1 microstx = 0.000001 stx

;; uint value calculated in public function (set-asset-floor-value)
(define-data-var loanAmountMax uint u1000000)

;; uint value calculated in public function (set-asset-floor-value)
(define-data-var loanLiquidationValue uint u1000000)

;; uint value incremented by 1 and updated in private function (liquidate-loan)
(define-data-var lastAuctionId uint u0)

;; uint value incremented by 1 and updated in public function (new-loan)
(define-data-var lastLoanId uint u0)

;; uint value updated in private function (liquidate-loan)
;; uint value updated in private function (close-auction)
(define-data-var tempUint uint u0)

;; list of uint values added in private function (liquidate-loan)
;; list of uint values removed in private function (close-auction)
(define-data-var activeAuctionIds (list 2500 uint) (list ))

;; list of uint values added in private function (new-loan)
;; list of uint values removed in private function (liquidate-loan)
(define-data-var activeLoanIds (list 2500 uint) (list ))

;; list of previous 10 asset floor values updated in public function (set-asset-floor)
(define-data-var assetFloorHistory (list 10 uint) (list ))

;;;; Map definitions

(define-map Borrower
    principal
    (list 5 uint)
)

(define-map BorrowerByLoan
    uint
    principal
)

(define-map Loan
    uint
    {
        id: uint,
        assetId: uint,
        principal: uint,
        interest: uint,
        debt: uint,
        termInterestRate: uint,
        termEndAt: uint,
    }
)

(define-map Auction
    uint
    {
        id: uint,
        assetId: uint,
        reserveAmount: uint,
        lastBidAmount: uint,
        lastBidderAccount: (optional principal),
        endAt: (optional uint),
    }
)

(define-map Admin
    principal
    bool
)

;;;; Private function definitions

(define-private (not-tempUint (id uint))
    (not (is-eq id (var-get tempUint)))
)

(define-private (get-auction (auctionId uint))
    (map-get? Auction auctionId)
)

(define-private (get-loan (loanId uint))
    (map-get? Loan loanId)
)

(define-private (term-interest-rate (termInterestRate {termLengthMin: uint, interestRate: uint}) (interestRate uint))
    (begin
        (asserts! (>= (var-get tempUint) (get termLengthMin termInterestRate))
            interestRate
        )
        (get interestRate termInterestRate)
    )
)

(define-private (uint-list-slice-iterator (value uint) (state {accumulator: (list 10 uint), index: uint, start: uint}))
    (let
        (
            (start
                (get start state)
            )
            (index
                (get index state)
            )
            (accumulator
                (get accumulator state)
            )
        )
        {
            start:
                start,
            accumulator:
                (if (>= index start)
                    (unwrap! (as-max-len? (append accumulator value) u10) state)
                    accumulator
                ),
            index:
                (+ index u1)
        }
    )
)

(define-private (uint-list-slice (uintList (list 2500 uint)) (start uint))
    (get accumulator (fold uint-list-slice-iterator uintList {accumulator: (list ), index: u0, start: start}))
)

(define-private (close-auction (auctionId uint) (count uint))
    (let
        (
            (auction
                (unwrap! (map-get? Auction auctionId) count)
            )
            (auctionAssetId
                (get assetId auction)
            )
            (auctionLastBidAmount
                (get lastBidAmount auction)
            )
            (auctionLastBidderAccount
                (unwrap! (get lastBidderAccount auction) count)
            )
            (auctionEndAt
                (unwrap! (get endAt auction) count)
            )
            (reserveAmount
                (get reserveAmount auction)
            )
            (eventCount
                (+ count u1)
            )
        )
        (asserts! (> block-height auctionEndAt)
            count
        )
        (asserts! (is-ok (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.satoshibles transfer auctionAssetId tx-sender auctionLastBidderAccount)))
            count
        )
        (asserts! (is-ok (as-contract (stx-transfer? (- auctionLastBidAmount reserveAmount) tx-sender LIQUIDIUM_PROFITS))) ;; leave loan principal in contract and send extra to LIQUIDIUM_PROFITS
            count
        )
        (var-set tempUint auctionId)
        (var-set activeAuctionIds (filter not-tempUint (var-get activeAuctionIds)))
        (var-set vaultLendingLiquidity (+ (var-get vaultLendingLiquidity) reserveAmount))
        (print
            {
                eventName: "close-auction",
                eventCount: eventCount,
                auctionId: auctionId,
                assetId: auctionAssetId,
                lastBidderAccount: auctionLastBidderAccount,
                endAt: auctionEndAt
            }
        )
        eventCount
    )
)

(define-private (liquidate-loan (loanId uint) (count uint))
    (let
        (
            (loan
                (unwrap! (map-get? Loan loanId) count)
            )
            (loanAssetId
                (get assetId loan)
            )
            (borrowerAccount
                (unwrap! (map-get? BorrowerByLoan loanId) count)
            )
            (loanDebtBalance
                (get debt loan)
            )
            (loanPrincipal
                (get principal loan)
            )
            (loanTermEndAt
                (get termEndAt loan)
            )
            (borrowerActiveLoanIds
                (unwrap! (map-get? Borrower borrowerAccount) count)
            )
            (auctionId
                (begin
                    (+ (var-get lastAuctionId) u1)
                )
            )
            (eventCount
                (+ count u1)
            )
        )
        (asserts! (or (>= block-height loanTermEndAt) (>= loanDebtBalance (var-get loanLiquidationValue)))
            count
        )
        (var-set tempUint loanId)
        (var-set activeLoanIds (filter not-tempUint (var-get activeLoanIds)))
        (map-set Borrower borrowerAccount (filter not-tempUint borrowerActiveLoanIds))
        (var-set activeAuctionIds (unwrap! (as-max-len? (concat (list auctionId) (var-get activeAuctionIds)) u2500) count))
        (var-set lastAuctionId auctionId)
        (map-insert Auction
            auctionId
            {
                id: auctionId,
                assetId: loanAssetId,
                reserveAmount: (if (>= loanPrincipal loanDebtBalance) loanDebtBalance loanPrincipal),
                lastBidAmount: u0,
                lastBidderAccount: none,
                endAt: none,
            }
        )
        (print
            {
                eventName: "liquidate-loan",
                eventCount: eventCount,
                loanId: loanId,
                assetId: loanAssetId,
                debtBalance: loanPrincipal,
                termEndAt: loanTermEndAt,
                loanLiquidationValue: (var-get loanLiquidationValue),
                auctionId: auctionId
            }
        )
        eventCount
    )
)

;;;; Read only function definitions

(define-read-only (get-active-auctions (start uint))
    (map get-auction (uint-list-slice (var-get activeAuctionIds) start))
)

(define-read-only (get-active-loans (start uint))
    (map get-loan (uint-list-slice (var-get activeLoanIds) start))
)

(define-read-only (get-borrower-active-loans (account principal))
    (let
        (
            (borrowerActiveLoanIds
                (default-to (list ) (map-get? Borrower account))
            )
        )
        (map get-loan borrowerActiveLoanIds)
    )
)

(define-read-only (get-data-values-1)
    (let
        (
            (values
                {
                    loanToAssetRatio: (var-get loanToAssetRatio),
                    loanLiquidationThreshhold: (var-get loanLiquidationThreshhold),
                    loanFeeRate: (var-get loanFeeRate),
                    loanTermLengthMin: (var-get loanTermLengthMin),
                    loanTermLengthMax: (var-get loanTermLengthMax),
                }
            )
        )
        values
    )
)

(define-read-only (get-data-values-2)
  (let
        (
            (values
                {
                    auctionDuration: (var-get auctionDuration),
                    loanTermInterestRates: (var-get loanTermInterestRates),
                    assetFloor: (var-get assetFloor),
                    loanAmountMax: (var-get loanAmountMax),
                    loanLiquidationValue: (var-get loanLiquidationValue)
                }
            )
        )
        values
    )
)

(define-read-only (get-data-values-3)
  (let
        (
            (values
                {
                    loanCount: (len (var-get activeLoanIds)),
                    auctionCount: (len (var-get activeAuctionIds)),
                    vaultLendingLiquidity: (var-get vaultLendingLiquidity),
                }
            )
        )
        values
    )
)

;;;; Public function definitions

(define-public (auction-bid (auctionId uint) (amount uint))
    (begin
        (asserts! (is-some (index-of (var-get activeAuctionIds) auctionId))
            ERR_AUCTION_INACTIVE
        )
        (let
            (
                (auction
                    (unwrap! (map-get? Auction auctionId) ERR_AUCTION_NOT_FOUND) ;; should never catch if auctionId is active
                )
                (auctionAssetId
                    (get assetId auction)
                )
                (auctionReserveAmount
                    (get reserveAmount auction)
                )
                (auctionLastBidAmount
                    (get lastBidAmount auction)
                )
                (auctionLastBidderAccount
                    (get lastBidderAccount auction)
                )
                (auctionEndAt
                    (match
                        (get endAt auction) endAt endAt                  
                        block-height
                    )
                )
                (bidderAccount
                    tx-sender
                )
            )
            (asserts! (<= block-height auctionEndAt) ERR_AUCTION_ENDED)
            (asserts! (and (> amount auctionReserveAmount) (> amount auctionLastBidAmount))
                ERR_AMOUNT_INVALID
            )
            (asserts! (not (is-eq bidderAccount (as-contract tx-sender)))
                ERR_ACCOUNT_INVALID
            )
            (map-set Auction
                auctionId
                {
                    id: auctionId,
                    assetId: auctionAssetId,
                    reserveAmount: auctionReserveAmount,
                    lastBidAmount: amount,
                    lastBidderAccount: (some bidderAccount),
                    endAt: (some (+ block-height (var-get auctionDuration))),
                }
            )
            (asserts! (>= (stx-get-balance bidderAccount) amount)
                ERR_STX_TRANSFER_FAILED
            )
            (asserts! (is-ok (stx-transfer? amount bidderAccount (as-contract tx-sender)))
                ERR_STX_TRANSFER_FAILED
            )
            (match auctionLastBidderAccount
                recipient
                    (begin
                        (asserts! (>= (stx-get-balance (as-contract tx-sender)) auctionLastBidAmount)
                            ERR_STX_TRANSFER_FAILED
                        )
                        (asserts! (is-ok (as-contract (stx-transfer? auctionLastBidAmount tx-sender recipient)))
                            ERR_STX_TRANSFER_FAILED
                        )
                        (ok true)
                    )
                (ok true)
            )
        )
    )
)

(define-public (pay-loan (loanId uint) (amount uint))
    (begin
        (asserts! (is-some (index-of (var-get activeLoanIds) loanId))
            ERR_LOAN_INACTIVE
        )
        (asserts! (is-some (index-of (default-to (list ) (map-get? Borrower tx-sender)) loanId))
            ERR_LOAN_INACTIVE
        )
        (asserts! (> amount u0)
            ERR_AMOUNT_INVALID
        )
        (let
            (
                (loan
                    (unwrap! (map-get? Loan loanId) ERR_LOAN_NOT_FOUND) ;; should never catch if valid loanId
                )
                (loanAssetId
                    (get assetId loan)
                )
                (loanDebtBalance
                    (get debt loan)
                )
                (loanPrincipal
                    (get principal loan)
                )
                (loanTermEndAt
                    (get termEndAt loan)
                )
                (paymentAmount
                    (if (>= amount loanDebtBalance)
                        loanDebtBalance
                        amount
                    )
                )
                (newLoanDebtBalance
                    (- loanDebtBalance paymentAmount)
                )
                (borrowerAccount
                    (unwrap! (map-get? BorrowerByLoan loanId) ERR_LOAN_NOT_FOUND)
                )
                (borrowerActiveLoanIds
                    (default-to (list ) (map-get? Borrower borrowerAccount))
                )
            )
            (asserts! (is-eq tx-sender borrowerAccount) ERR_NOT_ALLOWED)
            (asserts! (> loanTermEndAt block-height) ERR_LOAN_EXPIRED)
            (asserts! (is-some (index-of (default-to (list ) (map-get? Borrower borrowerAccount)) loanId))
                ERR_NOT_ALLOWED
            )
            (map-set Loan
                loanId
                {
                    id: loanId,
                    assetId: loanAssetId,
                    principal: loanPrincipal,
                    interest: (get interest loan),
                    debt: newLoanDebtBalance,
                    termInterestRate: (get termInterestRate loan),
                    termEndAt: loanTermEndAt,
                }
            )
            (asserts! (>= (stx-get-balance borrowerAccount) paymentAmount)
                ERR_STX_TRANSFER_FAILED
            )
            (if (> loanDebtBalance loanPrincipal) ;; if interest is still due
                (if (>= (- loanDebtBalance loanPrincipal) paymentAmount) ;; if interest due is greater than payment amount
                    (asserts! (is-ok (stx-transfer? paymentAmount borrowerAccount LIQUIDIUM_PROFITS)) ;; then pay part of interest due with all paymentAmount to LIQM ACCOUNT
                        ERR_STX_TRANSFER_FAILED 
                    )
                    (begin
                        (asserts! (is-ok (stx-transfer? (- loanDebtBalance loanPrincipal) borrowerAccount LIQUIDIUM_PROFITS)) ;; else send rest of interest due to LIQM ACCOUNT
                            ERR_STX_TRANSFER_FAILED
                        )
                        (asserts! (is-ok (stx-transfer? (- paymentAmount (- loanDebtBalance loanPrincipal)) borrowerAccount (as-contract tx-sender)))
                            ERR_STX_TRANSFER_FAILED
                        )
                        (var-set vaultLendingLiquidity (+ (var-get vaultLendingLiquidity) (- paymentAmount (- loanDebtBalance loanPrincipal))))
                    )
                )
                (begin
                    (asserts! (is-ok (stx-transfer? paymentAmount borrowerAccount (as-contract tx-sender))) ;; else no interest due, so send all back to contract
                        ERR_STX_TRANSFER_FAILED
                    )
                    (var-set vaultLendingLiquidity (+ (var-get vaultLendingLiquidity) paymentAmount))
                )
            )
            (if (is-eq newLoanDebtBalance u0)
                (begin
                    (var-set tempUint loanId)
                    (var-set activeLoanIds (filter not-tempUint (var-get activeLoanIds)))
                    (map-set Borrower borrowerAccount (filter not-tempUint borrowerActiveLoanIds))
                    (unwrap! (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.satoshibles transfer loanAssetId tx-sender borrowerAccount)) ERR_ASSET_TRANSFER_FAILED)
                    (ok true)
                )
                (ok true)
            )
        )
    )
)

(define-public (new-loan (assetId uint) (amount uint) (termLength uint))
    (begin
        (asserts! (is-eq (ok (some tx-sender)) (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.satoshibles get-owner assetId))
            ERR_ASSET_NOT_OWNED
        )
        (asserts! (<= amount (var-get loanAmountMax))
            ERR_AMOUNT_INVALID
        )
        (asserts!
            (and
                (>= termLength (var-get loanTermLengthMin))
                (<= termLength (var-get loanTermLengthMax))
            )
            ERR_TERM_INVALID
        )
        (let
            (
                (borrowerAccount
                    tx-sender
                )
                (borrowerActiveLoanIds
                    (default-to (list ) (map-get? Borrower borrowerAccount))
                )
                (loanId
                    (begin
                        (var-set lastLoanId (+ (var-get lastLoanId) u1))
                        (var-get lastLoanId)
                    )
                )
                (loanTermEndAt
                    (+ block-height termLength)
                )
                (loanTermInterestRate
                    (begin
                        (var-set tempUint termLength)
                        (fold term-interest-rate (var-get loanTermInterestRates) u0)
                    )
                )
                (loanFeeAmount
                    (/ (* amount (var-get loanFeeRate)) u10000)
                )
                (interestAmountPerPeriod
                    (/ (* amount loanTermInterestRate) u10000)
                )
                (interestAmount
                    (/ (* interestAmountPerPeriod termLength) (var-get loanTermLengthMax))
                )
                (debtBalance
                    (+ amount interestAmount)
                )
                (availableLiquidity
                    (var-get vaultLendingLiquidity)
                )
            )
            (asserts! (is-ok (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.satoshibles transfer assetId borrowerAccount (as-contract tx-sender)))
                ERR_ASSET_TRANSFER_FAILED
            )
            (asserts! (>= (stx-get-balance borrowerAccount) loanFeeAmount)
                ERR_STX_TRANSFER_FAILED
            )
            (asserts! (is-ok (stx-transfer? loanFeeAmount borrowerAccount LIQUIDIUM_PROFITS))
                ERR_STX_TRANSFER_FAILED
            )
            (asserts! (>= availableLiquidity amount)
                ERR_INSUFFICIENT_LIQUIDITY
            )
            (asserts! (is-ok (as-contract (stx-transfer? amount tx-sender borrowerAccount)))
                ERR_STX_TRANSFER_FAILED
            )
            (var-set vaultLendingLiquidity (- availableLiquidity amount))
            (map-set Borrower borrowerAccount (unwrap! (as-max-len? (concat (list loanId) borrowerActiveLoanIds) u5) ERR_MAX_ACTIVE_LOANS_REACHED))
            (var-set activeLoanIds (unwrap! (as-max-len? (concat (list loanId) (var-get activeLoanIds)) u2500) ERR_MAX_ACTIVE_LOANS_REACHED))
            (map-insert Loan
                loanId
                {
                    id: loanId,
                    assetId: assetId,
                    principal: amount,
                    interest: interestAmount,
                    debt: debtBalance,
                    termInterestRate: loanTermInterestRate,
                    termEndAt: loanTermEndAt,
                }
            )
            (map-insert BorrowerByLoan
                loanId
                borrowerAccount
            )
            (ok true)
        )
    )
)

;;; Admin functions

(define-read-only (is-admin (account principal))
    (or
        (is-eq DEPLOYER_ACCOUNT tx-sender)
        (default-to false (map-get? Admin account))
    )
)

(define-public (set-admin (account principal) (allowed bool))
    (begin
        (asserts!
            (and
                (is-admin tx-sender)
                (not (is-eq account tx-sender))
            )
            ERR_NOT_ALLOWED
        )
        (ok (map-set Admin account allowed))
    )
)

(define-private (remove-first (value uint))
    (let ((index (+ u1 (var-get tempUint))))
        (var-set tempUint index)
        (not (is-eq index u1))
    )
)

(define-public (update-asset-floor (amount uint))
    (let ((currentHistory (var-get assetFloorHistory)))
        (asserts! (is-admin tx-sender)
            ERR_NOT_ALLOWED
        )
        (asserts! (> amount u0)
            ERR_AMOUNT_INVALID
        )
        (var-set tempUint u0)
        (if (< (len currentHistory) u10)
            (var-set assetFloorHistory (unwrap! (as-max-len? (append currentHistory amount) u10) ERR_ON_APPEND))
            (var-set assetFloorHistory (unwrap! (as-max-len? (append (filter remove-first currentHistory) amount) u10) ERR_ON_APPEND))
        )
        (var-set assetFloor (/ (fold + (var-get assetFloorHistory) u0) (len (var-get assetFloorHistory))))
        (var-set loanAmountMax (/ (* (var-get loanToAssetRatio) (var-get assetFloor)) u10000))
        (var-set loanLiquidationValue (/ (* (var-get loanLiquidationThreshhold) (var-get assetFloor)) u10000))
        (ok (var-get assetFloor))
    )
)

(define-public (run-maintenance)
    (begin
        (fold close-auction (var-get activeAuctionIds) u0)
        (fold liquidate-loan (var-get activeLoanIds) u0)
        (ok true)
    )
)

(define-public (set-lending-liquidity (amount uint))
    (begin
        (asserts! (is-admin tx-sender)
            ERR_NOT_ALLOWED
        )
        (var-set vaultLendingLiquidity amount)
        (ok true)
    )
)

(define-public (fund-vault (amount uint))
    (begin
        (asserts! (> amount u0)
            ERR_AMOUNT_INVALID
        )
        (asserts! (>= (stx-get-balance tx-sender) amount)
            ERR_STX_TRANSFER_FAILED
        )
        (asserts! (is-ok (stx-transfer? amount tx-sender (as-contract tx-sender)))
            ERR_STX_TRANSFER_FAILED
        )
        (var-set vaultLendingLiquidity (+ (var-get vaultLendingLiquidity) amount))
        (ok true)
    )
)

(define-public (drain-vault (amount uint))
    (begin
        (asserts! (is-admin tx-sender)
            ERR_NOT_ALLOWED
        )
        (asserts! (and (> amount u0) (>= (stx-get-balance (as-contract tx-sender)) amount))
            ERR_AMOUNT_INVALID
        )
        (asserts! (is-ok (as-contract (stx-transfer? amount tx-sender LIQUIDIUM)))
            ERR_STX_TRANSFER_FAILED
        )
        (var-set vaultLendingLiquidity (- (var-get vaultLendingLiquidity) amount))
        (ok true)
    )
)

(define-public (withdrawl-the-guests (id uint))
    (begin
        (asserts! (is-admin tx-sender)
            ERR_NOT_ALLOWED
        )
        (unwrap! (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.satoshibles transfer id tx-sender LIQUIDIUM_PROFITS)) ERR_ASSET_TRANSFER_FAILED)
        (ok true)
    )
)

(define-public (set-loanToAssetRatio (ratio uint))
    (begin
        (asserts! (is-admin tx-sender)
            ERR_NOT_ALLOWED
        )
        (asserts! (and (> ratio u0) (<= ratio u10000))
            ERR_INPUT_INVALID
        )
        (var-set loanToAssetRatio ratio)
        (var-set loanAmountMax (/ (* (var-get loanToAssetRatio) (var-get assetFloor)) u10000))
        (ok true)
    )
)

(define-public (set-loanLiquidationThreshhold (ratio uint))
    (begin
        (asserts! (is-admin tx-sender)
            ERR_NOT_ALLOWED
        )
        (asserts! (and (> ratio u0) (<= ratio u10000) (>= ratio (var-get loanToAssetRatio)))
            ERR_INPUT_INVALID
        )
        (var-set loanLiquidationThreshhold ratio)
        (var-set loanLiquidationValue (/ (* (var-get loanLiquidationThreshhold) (var-get assetFloor)) u10000))
        (ok true)
    )
)

(define-public (set-loanFeeRate (rate uint))
    (begin
        (asserts! (is-admin tx-sender)
            ERR_NOT_ALLOWED
        )
        (asserts! (and (> rate u0) (<= rate u500))
            ERR_INPUT_INVALID
        )
        (var-set loanFeeRate rate)
        (ok true)
    )
)

(define-public (set-loanTermLengthMax (max uint))
    (begin
        (asserts! (is-admin tx-sender)
            ERR_NOT_ALLOWED
        )
        (asserts! (>= max (var-get loanTermLengthMin)) ERR_INPUT_INVALID)
        (var-set loanTermLengthMax max)
        (ok true)
    )
)

(define-public (set-loanTermLengthMin (min uint))
    (begin
        (asserts! (is-admin tx-sender)
            ERR_NOT_ALLOWED
        )
        (asserts! (<= min (var-get loanTermLengthMax)) ERR_INPUT_INVALID)
        (var-set loanTermLengthMin min)
        (ok true)
    )
)

(define-public (set-auctionDuration (duration uint))
    (begin
        (asserts! (is-admin tx-sender)
            ERR_NOT_ALLOWED
        )
        (asserts! (>= duration u0) ERR_INPUT_INVALID)
        (var-set auctionDuration duration)
        (ok true)
    )
)

(define-public (set-loanTermInterestRates (rates (list 5 (tuple (interestRate uint) (termLengthMin uint)))))
    (begin
        (asserts! (is-admin tx-sender)
            ERR_NOT_ALLOWED
        )
        (asserts! (is-eq (len rates) u5) ERR_INPUT_INVALID)
        (var-set loanTermInterestRates rates)
        (ok true)
    )
)
