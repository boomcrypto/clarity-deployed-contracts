(use-trait sip-010-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.sip-010-v1a.sip-010-trait)

;;//////////////////////////////////////////////////////////////////////////////////////
(define-constant ERR_EMERGENCY_STOP u9990000)
(define-constant ERR_REACH_MAX_LIST u9990001)
(define-constant ERR_INVALID_CALLER u9990002)
(define-constant ERR_ETH_TOKEN_VALUE u9990004)
(define-constant ERR_TOKEN_BALANCE u9990005)
(define-constant ERR_FEE_BALANCE u9990006)
(define-constant ERR_STX_TOKEN_ADDRESS u9990007)
(define-constant ERR_INVALID_ORDER_OWNER u9990008)
(define-constant ERR_INVALID_ORDER_TYPE u9990009)
(define-constant ERR_INVALID_ORDER_STATUS u9990010)
(define-constant ERR_MAX_AMT u9990012)
(define-constant ERR_MIN_AMT u9990013)
(define-constant LIMIT_SET_PARAM_NOT_VALID u9990018)


(define-constant BASIC_PRINCIPAL tx-sender)

;;//////////////////////////////////////////////////////////////////////////////////////

(define-map ETHInfo
    principal           ;; STX Token Address
    {  ;; ETH Token Address
        ETH_TOKEN_ADDRESS: (string-ascii 64),
        FEE_RATIO_1_AMT: uint,
        FEE_RATIO_2_AMT: uint,
        FEE_RATIO_3_AMT: uint,
        MAX_AMT: uint,
        MIN_AMT: uint,
    }
)

;;//////////////////////////////////////////////////////////////////////////////////////

(define-data-var currentBalance uint u0)

;; Total Order Info
(define-map OrderInfo_From
    {
        OrderID: uint ;; OrderID
    }
    {
        STXWallet: principal,
        STXToken: principal,
        ETHWallet: (string-ascii 64),
        ETHToken: (string-ascii 64),
        ;; ETH Tx...
        TokenAmt: uint,
        BlockNumber: uint,
        MODE: bool,      
        STATUS: bool    
    }
)

(define-data-var ORDERID_To uint u0)
(define-map OrderInfo_To
    {
        OrderID: uint ;; OrderID
    }
    {
        STXWallet: principal,
        STXToken: principal,
        ETHWallet: (string-ascii 64),
        ETHToken: (string-ascii 64),
        ;; ETH Tx...
        TokenAmt: uint,
        BlockNumber: uint,
        MODE: bool,      
        STATUS: bool    
    }
)

;;//////////////////////////////////////////////////////////////////////////////////////


(define-private (updateOrderList_To (orderList (list 200 uint)))
    (begin 
        (filter updateItem orderList)
    )
    
)

(define-private (updateItem (orderID uint))
    (let 
        (
            (orderInfo (getOrderIDInfo_To orderID))
        ) 
        (if (get STATUS orderInfo)
        ;; (if (is-eq orderStatus true)
            (begin 
                (map-set OrderInfo_To
                    {
                        OrderID: orderID
                    }
                    (merge 
                        orderInfo
                        {
                            STATUS: false
                        }
                    )
                )
            )
            true
        )
    )
)


;;//////////////////////////////////////////////////////////////////////////////////////

;; Whitelist
(define-constant ADMIN_PRINCIPAL tx-sender)

(define-map whitelist principal bool)

(define-read-only (is-updater (user principal))
  (match (map-get? whitelist user)
    value (ok true)
    (err ERR_INVALID_CALLER)
  )
)
(define-public (add-updater (user principal))
  (begin
    (asserts! (is-eq contract-caller ADMIN_PRINCIPAL) (err ERR_INVALID_CALLER))
    (ok (map-set whitelist
      user true
    ))
  )
)
(define-public (remove-updater (user principal))
  (begin
    (asserts! (is-eq contract-caller ADMIN_PRINCIPAL) (err ERR_INVALID_CALLER))
    (ok (map-delete whitelist
      user
    ))
  )
)

(map-set whitelist tx-sender true)
;;//////////////////////////////////////////////////////////////////////////////////////
;; Register ETH-STX Token Pair 

(define-public (RegisterTokenPair (sip10 principal) (erc20 (string-ascii 64)) (min uint) (max uint))
  (begin
    (asserts! (is-eq contract-caller ADMIN_PRINCIPAL) (err ERR_INVALID_CALLER))
    (map-set ETHInfo
        sip10
        (merge 
            (getETHToken sip10)
            {  ;; ETH Token Address
                ETH_TOKEN_ADDRESS: erc20,
                MAX_AMT: max,
                MIN_AMT: min,
            }
        )
    )
    (ok true)
  )
)
;;//////////////////////////////////////////////////////////////////////////////////////
;; Emergency Stop 
(define-data-var IS_STOP bool false)
(define-public (EmergencyStop )
  (let
    (
        (is_stop (var-get IS_STOP))
    )
    (asserts! (is-eq contract-caller ADMIN_PRINCIPAL) (err ERR_INVALID_CALLER))
    (var-set IS_STOP (not is_stop))
    (ok (not is_stop))
  )
)

(define-public (EmergencyWithdraw (sip10_token <sip-010-token>)  )
  (let
    (
        (contractBalance (getContractBalance sip10_token))
        (user tx-sender)
    )

    (asserts! (is-eq contract-caller ADMIN_PRINCIPAL) (err ERR_INVALID_CALLER))
    (asserts! (var-get IS_STOP) (err ERR_EMERGENCY_STOP))
    (asserts! (>= (getVoteRes) VOTE_REQUIRE ) (err ERR_VOTING_RESULT_NOT_MET))

    (if (> contractBalance u0) 
        (begin (try! (as-contract (contract-call? sip10_token transfer contractBalance tx-sender user none))))
        false
    )
    
    (ok true)
  )
)
;;//////////////////////////////////////////////////////////////////////////////////////
;; Fee
(define-data-var FEE_UNIT uint u1000000)
(define-data-var FEE_FIX uint u10000000)
(define-data-var FEE_RATIO_1 uint u20000)
(define-data-var FEE_RATIO_2 uint u20000)
(define-data-var FEE_RATIO_3 uint u20000)

(define-data-var FEE_FIX_AMT uint u0)

(define-public (SetFee (fee_unit uint) (fee_fix uint) (fee_ratio_1 uint) (fee_ratio_2 uint) (fee_ratio_3 uint))
  (begin
    (asserts! (is-eq contract-caller ADMIN_PRINCIPAL) (err ERR_INVALID_CALLER))
    (var-set FEE_UNIT fee_unit)
    (var-set FEE_FIX fee_fix)
    (var-set FEE_RATIO_1 fee_ratio_1)
    (var-set FEE_RATIO_2 fee_ratio_2)
    (var-set FEE_RATIO_3 fee_ratio_3)
    (ok true)
  )
)
(define-read-only (GetFee)
  (begin
    (ok {
        FEE_UNIT: (var-get FEE_UNIT),
        FEE_FIX: (var-get FEE_FIX),
        FEE_FIX_AMT: (var-get FEE_FIX_AMT),
        FEE_RATIO_1: (var-get FEE_RATIO_1),
        FEE_RATIO_2: (var-get FEE_RATIO_2),
        FEE_RATIO_3: (var-get FEE_RATIO_3)
    })
  )
)


(define-public (WithdrawFee_FIX)
  (let 
    (
        (user contract-caller)
        (feeAmt (var-get FEE_FIX_AMT))
    )
    (asserts! (is-eq contract-caller ADMIN_PRINCIPAL) (err ERR_INVALID_CALLER))
    (asserts! (>= (getContractSTXBalance) feeAmt) (err ERR_TOKEN_BALANCE))
    
    (try! (as-contract (stx-transfer? feeAmt tx-sender user)))
    (var-set FEE_FIX_AMT u0)
    (ok feeAmt)
  )
)

(define-public (WithdrawFee_RATIO_1 (token <sip-010-token>) )
  (let 
    (
        (user contract-caller)
        (token_info (getETHToken (contract-of token)))
        (feeAmt (get FEE_RATIO_1_AMT token_info))
    )
    (asserts! (is-eq contract-caller ADMIN_PRINCIPAL) (err ERR_INVALID_CALLER))
    (asserts! (>= (getContractBalance token) feeAmt) (err ERR_TOKEN_BALANCE))
    (try! (as-contract (contract-call? token transfer feeAmt tx-sender user none)))
    (map-set ETHInfo (contract-of token) (merge token_info
        {
            FEE_RATIO_1_AMT: u0,
        }
    ))
    (ok feeAmt)
  )
)

(define-public (WithdrawFee_RATIO_2 (token <sip-010-token>) )
  (let 
    (
        (user contract-caller)
        (token_info (getETHToken (contract-of token)))
        (feeAmt (get FEE_RATIO_2_AMT token_info))
    )
    (asserts! (is-eq contract-caller ADMIN_PRINCIPAL) (err ERR_INVALID_CALLER))
    (asserts! (>= (getContractBalance token) feeAmt) (err ERR_TOKEN_BALANCE))
    (try! (as-contract (contract-call? token transfer feeAmt tx-sender user none)))
    (map-set ETHInfo (contract-of token) (merge token_info
        {
            FEE_RATIO_2_AMT:  u0,
        }
    ))
    (ok feeAmt)
  )
)

(define-public (WithdrawFee_RATIO_3 (token <sip-010-token>) )
  (let 
    (
        (user contract-caller)
        (token_info (getETHToken (contract-of token)))
        (feeAmt (get FEE_RATIO_3_AMT token_info))
    )
    (asserts! (is-eq contract-caller ADMIN_PRINCIPAL) (err ERR_INVALID_CALLER))
    (asserts! (>= (getContractBalance token) feeAmt) (err ERR_TOKEN_BALANCE))
    (try! (as-contract (contract-call? token transfer feeAmt tx-sender user none)))
    (map-set ETHInfo (contract-of token) (merge token_info
        {
            FEE_RATIO_3_AMT:  u0,
        }
    ))
    (ok feeAmt)
  )
)

(define-read-only (getTotalRatioFee (amount uint))
    (ok 
        (/ (* amount (+ (var-get FEE_RATIO_1) (+ (var-get FEE_RATIO_2) (var-get FEE_RATIO_3)))) (var-get FEE_UNIT))
    )
)


;; ;;//////////////////////////////////////////////////////////////////////////////////////
;; Multi Sig
;; Error codes
(define-constant ERR_NOT_OPERATOR u7770001)
(define-constant ERR_NOT_A_MEMBER u7770002)
(define-constant ERR_VOTING_RESULT_NOT_MET u7770003)

;; Variables
(define-data-var operator principal tx-sender)
(define-data-var vote_members (list 3 principal) (list))
(define-data-var vote_members_wo_operator (list 2 principal) (list))

(define-map vote_map_stop {member: principal, mode: uint} {decision: bool})

(define-constant VOTE_MODE u1001)
(define-constant VOTE_REQUIRE u2)

(begin
    (var-set
        vote_members
        (list (var-get operator) 'SP19M4SWJT0CGX7HX69XAWEVQNN5G5PT0KMG98HE7 'SP3Q5RYGZCQ1F4CZ2RTT6NDDVWDG5P7E48QASPNPA)
    )
    (var-set
        vote_members_wo_operator
        (list 'SP19M4SWJT0CGX7HX69XAWEVQNN5G5PT0KMG98HE7 'SP3Q5RYGZCQ1F4CZ2RTT6NDDVWDG5P7E48QASPNPA)
    )
)

;; Get functions
(define-read-only (get-operator)
  (var-get operator)
)
(define-read-only (get-voters)
  (var-get vote_members)
)

(define-read-only (getVote (member principal) (mode_id uint))
    (default-to false (get decision (map-get? vote_map_stop {member: member, mode: mode_id})))
)

(define-private (sumVote (member principal) (accumulator uint))
    (if (getVote member VOTE_MODE) (+ accumulator u1) accumulator)
)

(define-read-only (getVoteRes)
    (fold sumVote (var-get vote_members) u0)
)

;; Set functions
(define-public (setOperator (address principal))
  (begin
    (asserts! (is-eq contract-caller (var-get operator)) (err ERR_NOT_OPERATOR))

    (var-set operator address)
    (ok (var-set vote_members (unwrap-panic (as-max-len? (append  (var-get vote_members_wo_operator) (var-get operator)) u3))))

  )
)

(define-public (setVoters (new-members (list 2 principal)))
  (begin
        (asserts! (is-eq contract-caller (var-get operator)) (err ERR_NOT_OPERATOR))
        ;; (print {member_list :  (unwrap-panic (as-max-len? (append  new-members (var-get operator)) u4))})
        ;; (ok true)
        (var-set vote_members_wo_operator new-members)
        (ok (var-set vote_members (unwrap-panic (as-max-len? (append  new-members (var-get operator)) u3))))

        ;; (ok (var-set vote_members new-vote-members))
  )
)

;; Vote
(define-public (vote (decision bool))
    (begin
        (asserts! (is-some (index-of (var-get vote_members) contract-caller)) (err ERR_NOT_A_MEMBER))
        (ok (map-set vote_map_stop {member: contract-caller, mode: VOTE_MODE} {decision: decision}))
    )
)


;;//////////////////////////////////////////////////////////////////////////////////////

(define-read-only (getOrderIDInfo_From (orderID uint))
    (default-to 
        {STXWallet: BASIC_PRINCIPAL, STXToken: BASIC_PRINCIPAL, ETHWallet: "", ETHToken: "", TokenAmt: u0, BlockNumber: u0, MODE: false, STATUS: false}
        (map-get? OrderInfo_From {OrderID: orderID})
    )
)

(define-read-only (getOrderIDInfo_To (orderID uint))
    (default-to 
        {STXWallet: BASIC_PRINCIPAL, STXToken: BASIC_PRINCIPAL, ETHWallet: "", ETHToken: "", TokenAmt: u0, BlockNumber: u0, MODE: false, STATUS: false}
        (map-get? OrderInfo_To {OrderID: orderID})
    )
)

(define-read-only (getETHToken (sip10_token principal))
    (default-to 
        {  ;; ETH Token Address
            ETH_TOKEN_ADDRESS: "",
            FEE_RATIO_1_AMT: u0,
            FEE_RATIO_2_AMT: u0,
            FEE_RATIO_3_AMT: u0,
            MAX_AMT: u0,
            MIN_AMT: u0,
        }
        (map-get? ETHInfo sip10_token)
    )
)

;;//////////////////////////////////////////////////////////////////////////////////////
(define-private (getContractBalance
    (token <sip-010-token>) 
 )
    (unwrap-panic (contract-call? token get-balance (as-contract tx-sender)))
)

(define-private (getContractSTXBalance)
    (stx-get-balance (as-contract tx-sender))
)

;; STX -> ETH
(define-public (DepositForETH 
    (eth_wallet (string-ascii 64)) 
    (sip10_token <sip-010-token>)
    (amount uint)
    (fee uint)  
)
    (let 
        (
            (user contract-caller) ;; (user tx-sender)

            (eth_token (getETHToken (contract-of sip10_token)))

            (order_id (+ (var-get ORDERID_To) u1))

            (contractBalanceBefore (getContractBalance sip10_token))

        )

        (asserts! (not (var-get IS_STOP)) (err ERR_EMERGENCY_STOP))
        (asserts! (>= (getVoteRes) VOTE_REQUIRE ) (err ERR_VOTING_RESULT_NOT_MET))
        (asserts! (not (is-eq (get ETH_TOKEN_ADDRESS eth_token) "")) (err ERR_ETH_TOKEN_VALUE))
        (asserts! (> (get MAX_AMT eth_token) amount) (err ERR_MAX_AMT))
        (asserts! (< (get MIN_AMT eth_token) amount) (err ERR_MIN_AMT))

        (try! (contract-call? sip10_token transfer amount user (as-contract tx-sender) none))


        (begin
            (asserts! (is-eq (unwrap-panic (getTotalRatioFee amount)) fee) (err ERR_FEE_BALANCE))

            (try! (contract-call? sip10_token transfer fee user (as-contract tx-sender) none))
            (asserts! (>= (- (getContractBalance sip10_token) contractBalanceBefore) (+ amount fee)) (err ERR_TOKEN_BALANCE))
            (map-set ETHInfo (contract-of sip10_token) (merge eth_token
                {
                    FEE_RATIO_1_AMT: (+ (get FEE_RATIO_1_AMT eth_token) (/ (* amount (var-get FEE_RATIO_1)) (var-get FEE_UNIT))),
                    FEE_RATIO_2_AMT: (+ (get FEE_RATIO_2_AMT eth_token) (/ (* amount (var-get FEE_RATIO_2)) (var-get FEE_UNIT))),
                    FEE_RATIO_3_AMT: (+ (get FEE_RATIO_3_AMT eth_token) (/ (* amount (var-get FEE_RATIO_3)) (var-get FEE_UNIT)))
                }
            ))
        )
    

        (var-set ORDERID_To order_id)

        (map-set OrderInfo_To
            {
                OrderID: order_id
            }
            {
                STXWallet: user,
                STXToken: (contract-of sip10_token),
                ETHWallet: eth_wallet,
                ETHToken: (get ETH_TOKEN_ADDRESS eth_token),
                TokenAmt: amount,
                BlockNumber: block-height,
                MODE: false,
                STATUS: true
            }
        )

        (ok order_id)
    )
)

;; STX -> ETH
(define-public (Cancel_DepositForETH (OrderID uint) (sip10_token <sip-010-token>)) 
    (let 
        (
            (user contract-caller) ;; (user tx-sender)

            (orderInfo (getOrderIDInfo_To OrderID))
            (orderToken (get STXToken orderInfo))
            (orderAmt (get TokenAmt orderInfo))

            (contractBalance (getContractBalance sip10_token))
        )
        
        (asserts! (not (var-get IS_STOP)) (err ERR_EMERGENCY_STOP))
        (asserts! (>= (getVoteRes) VOTE_REQUIRE ) (err ERR_VOTING_RESULT_NOT_MET))
        
        (asserts! (is-eq (contract-of sip10_token) orderToken) (err ERR_STX_TOKEN_ADDRESS))
        (asserts! (is-eq (get STXWallet orderInfo) user) (err ERR_INVALID_ORDER_OWNER))
        (asserts! (is-eq (get MODE orderInfo) false) (err ERR_INVALID_ORDER_TYPE))
        (asserts! (is-eq (get STATUS orderInfo) true) (err ERR_INVALID_ORDER_STATUS))
        (asserts! (>= contractBalance orderAmt) (err ERR_TOKEN_BALANCE))

        (try! (as-contract (contract-call? sip10_token transfer orderAmt tx-sender user none)))
        
        (map-delete OrderInfo_To
            {
                OrderID: OrderID
            }
        )

        (ok true)
    )
)

;; [ONLY UPDATER] STX -> ETH 
(define-public (Update_DepositForETH
    (sip10_token <sip-010-token>)
    (orderList (list 200 uint))
) 
    (let 
        (
            (user contract-caller)
            (curr_block block-height)
        )
         
        (asserts! (not (var-get IS_STOP)) (err ERR_EMERGENCY_STOP))
        (asserts! (>= (getVoteRes) VOTE_REQUIRE ) (err ERR_VOTING_RESULT_NOT_MET))

        (try! (is-updater user))

        (updateOrderList_To orderList)

        (ok true)
    )
)

;;//////////////////////////////////////////////////////////////////////////////////////
;; ETH -> STX
(define-public (WithdrawFromETH (OrderID uint)  (sip10_token <sip-010-token>) ) 
    (let 
        (
            (user contract-caller) ;; (user tx-sender)


            (orderInfo (getOrderIDInfo_From OrderID))
            (orderCreator (get STXWallet orderInfo))
            (orderToken (get STXToken orderInfo))
            (orderAmt (get TokenAmt orderInfo))
            (contractBalance (getContractBalance sip10_token))
        )
         
        (asserts! (not (var-get IS_STOP)) (err ERR_EMERGENCY_STOP))
        (asserts! (>= (getVoteRes) VOTE_REQUIRE ) (err ERR_VOTING_RESULT_NOT_MET))

        (asserts! (not (is-eq orderToken BASIC_PRINCIPAL)) (err ERR_STX_TOKEN_ADDRESS))
        (asserts! (is-eq (contract-of sip10_token) orderToken) (err ERR_STX_TOKEN_ADDRESS))

        (asserts! (is-eq orderCreator user) (err ERR_INVALID_CALLER))
        (asserts! (is-eq (get MODE orderInfo) true) (err ERR_INVALID_ORDER_TYPE))
        (asserts! (is-eq (get STATUS orderInfo) true) (err ERR_INVALID_ORDER_STATUS))

        (asserts! (>= contractBalance orderAmt) (err ERR_TOKEN_BALANCE))

        (try! (as-contract (contract-call? sip10_token transfer orderAmt tx-sender user none)))
        (try! (stx-transfer? (var-get FEE_FIX) user (as-contract tx-sender)))
        (var-set FEE_FIX_AMT (+ (var-get FEE_FIX_AMT) (var-get FEE_FIX)))

        (map-set OrderInfo_From
            {
                OrderID: OrderID
            }
            (merge orderInfo
                {
                    STATUS: false
                }
            )
        )

        (ok true)
    )
)

;;  [ONLY UPDATER]  ETH->STX
(define-public (Register_WithdrawFromETH
    (order_id uint)
    (stx_wallet principal)
    (eth_wallet (string-ascii 64)) 
    (sip10_token <sip-010-token>)
    (amount uint)
    ) 
    (let 
        (
            (user contract-caller)

            (eth_token (getETHToken (contract-of sip10_token)))
        )
         
        (asserts! (not (var-get IS_STOP)) (err ERR_EMERGENCY_STOP))
        (asserts! (>= (getVoteRes) VOTE_REQUIRE ) (err ERR_VOTING_RESULT_NOT_MET))

        (try! (is-updater user))
        

        (map-set OrderInfo_From
            {
                OrderID: order_id
            }
            {
                STXWallet: stx_wallet,
                STXToken: (contract-of sip10_token),
                ETHWallet: eth_wallet,
                ETHToken: (get ETH_TOKEN_ADDRESS eth_token),
                TokenAmt: amount,
                BlockNumber: block-height,
                MODE: true,
                STATUS: true
            }
        )
        (ok order_id)
    )
)
;;  [ONLY UPDATER]  ETH->STX
(define-public (Cancel_WithdrawFromETH
    (Order_ID uint)
) 
    (let 
        (
            (user contract-caller)

            (orderInfo (getOrderIDInfo_From Order_ID))
            (orderCreator (get STXWallet orderInfo))
            (orderToken (get STXToken orderInfo))
        )
        
        (asserts! (not (var-get IS_STOP)) (err ERR_EMERGENCY_STOP))
        (asserts! (>= (getVoteRes) VOTE_REQUIRE ) (err ERR_VOTING_RESULT_NOT_MET)) 

        (try! (is-updater user))
        
        (map-delete OrderInfo_From
            {
                OrderID: Order_ID
            }
        )
        (ok true)
    )
)
