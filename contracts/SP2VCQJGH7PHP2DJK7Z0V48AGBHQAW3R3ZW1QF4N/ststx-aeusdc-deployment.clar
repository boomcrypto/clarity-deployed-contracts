
(define-constant max-value u340282366920938463463374607431768211455)

(define-constant aeusdc-supply-cap u5000000000000)
(define-constant aeusdc-borrow-cap u1000000000000)

(define-constant ststx-supply-cap u5000000000000)
(define-constant ststx-borrow-cap u1000000000000)

(try!
  (contract-call? .pool-borrow
    init
    'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx
    'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
    u6
    ststx-supply-cap
    ststx-borrow-cap
    'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.ststx-oracle-v1-2
    'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx
  )
)

(contract-call? .pool-borrow add-asset 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)

(try!
  (contract-call? .pool-borrow
    init
    'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zaeusdc
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    u6
    aeusdc-supply-cap
    aeusdc-borrow-cap
    'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.aeusdc-oracle-v1-0
    'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zaeusdc
  )
)

(contract-call? .pool-borrow add-asset 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)

(try! 
  (contract-call? .pool-borrow set-usage-as-collateral-enabled
    'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
    true
    u50000000
    u70000000
    u10000000
  )
)

(contract-call? .pool-borrow set-borrowing-enabled 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc true)

(contract-call? .pool-borrow add-isolated-asset 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token u100000000000000)

(contract-call? .pool-borrow set-borroweable-isolated 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)

;; Curve parameters
(contract-call? .pool-reserve-data set-base-variable-borrow-rate 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token u0)
(contract-call? .pool-reserve-data set-base-variable-borrow-rate 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc u0)

(contract-call? .pool-reserve-data set-variable-rate-slope-1 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token u4000000)
(contract-call? .pool-reserve-data set-variable-rate-slope-1 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc u4000000)

(contract-call? .pool-reserve-data set-variable-rate-slope-2 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token u300000000)
(contract-call? .pool-reserve-data set-variable-rate-slope-2 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc u60000000)

(contract-call? .pool-reserve-data set-optimal-utilization-rate 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token u90000000)
(contract-call? .pool-reserve-data set-optimal-utilization-rate 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc u90000000)

(contract-call? .pool-reserve-data set-liquidation-close-factor-percent 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token u50000000)
(contract-call? .pool-reserve-data set-liquidation-close-factor-percent 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc u50000000)

(contract-call? .pool-reserve-data set-origination-fee-prc 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token u0)
(contract-call? .pool-reserve-data set-origination-fee-prc 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc u0)

(contract-call? .pool-reserve-data set-reserve-factor 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token u10000000)
(contract-call? .pool-reserve-data set-reserve-factor 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc u10000000)
