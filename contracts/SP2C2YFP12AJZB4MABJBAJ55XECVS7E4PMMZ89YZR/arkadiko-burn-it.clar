
(define-constant ERR-NOT-AUTHORIZED u12345)


(define-constant DAO-OWNER tx-sender)



(define-public (burn-usda-1)
  (let (
    (balance-1 (unwrap-panic (contract-call? .usda-token get-balance 'SP11ETHNJKZRF8N4VMMK62FM322HKVQPRAN8JM1R6)))
    (balance-2 (unwrap-panic (contract-call? .usda-token get-balance 'SP3TMT5AV7D73EWWMR898PXN4H8JTCSWAAXY39N2A)))
    (balance-3 (unwrap-panic (contract-call? .usda-token get-balance 'SPRAHKK7E6HZ159H4PV1QPZ685QXCXER6S4MZR7W)))
    (balance-4 (unwrap-panic (contract-call? .usda-token get-balance 'SP3EYT7KF5ERWQFTWW3SWHS8QRYBNSMRZ7JW73YXR)))
    (balance-5 (unwrap-panic (contract-call? .usda-token get-balance 'SP2W2C90TKDHRAFXRVH5DHHCADNM24Q9ZM7T1HP1P)))
    (balance-6 (unwrap-panic (contract-call? .usda-token get-balance 'SP3D37B82DX7JJ38GZVR2X5400QR1DHHXTKAP7Q1A)))
    (balance-7 (unwrap-panic (contract-call? .usda-token get-balance 'SP9R38DHK2DKQ8QV4ESZY14R66AHMPXS2NJRFW48)))
    (balance-8 (unwrap-panic (contract-call? .usda-token get-balance 'SP1JPKH64TWH1EW9K88A16FJRRXRNMY2J9JSAF086)))
    (balance-9 (unwrap-panic (contract-call? .usda-token get-balance 'SPP62V4HY4KBC344RSPQMP1MKV8S60ZAJ3Q5SV9G)))
    (balance-10 (unwrap-panic (contract-call? .usda-token get-balance 'SPE39HZGRQ45ZSDJXY5JEG483VC8B8J0DEEDDTT5)))
  )
    (asserts! (is-eq tx-sender DAO-OWNER) (err ERR-NOT-AUTHORIZED))

    (try! (as-contract (contract-call? .arkadiko-dao burn-token .usda-token balance-1 'SP11ETHNJKZRF8N4VMMK62FM322HKVQPRAN8JM1R6)))
    (try! (as-contract (contract-call? .arkadiko-dao burn-token .usda-token balance-2 'SP3TMT5AV7D73EWWMR898PXN4H8JTCSWAAXY39N2A)))
    (try! (as-contract (contract-call? .arkadiko-dao burn-token .usda-token balance-3 'SPRAHKK7E6HZ159H4PV1QPZ685QXCXER6S4MZR7W)))
    (try! (as-contract (contract-call? .arkadiko-dao burn-token .usda-token balance-4 'SP3EYT7KF5ERWQFTWW3SWHS8QRYBNSMRZ7JW73YXR)))
    (try! (as-contract (contract-call? .arkadiko-dao burn-token .usda-token balance-5 'SP2W2C90TKDHRAFXRVH5DHHCADNM24Q9ZM7T1HP1P)))
    (try! (as-contract (contract-call? .arkadiko-dao burn-token .usda-token balance-6 'SP3D37B82DX7JJ38GZVR2X5400QR1DHHXTKAP7Q1A)))
    (try! (as-contract (contract-call? .arkadiko-dao burn-token .usda-token balance-7 'SP9R38DHK2DKQ8QV4ESZY14R66AHMPXS2NJRFW48)))
    (try! (as-contract (contract-call? .arkadiko-dao burn-token .usda-token balance-8 'SP1JPKH64TWH1EW9K88A16FJRRXRNMY2J9JSAF086)))
    (try! (as-contract (contract-call? .arkadiko-dao burn-token .usda-token balance-9 'SPP62V4HY4KBC344RSPQMP1MKV8S60ZAJ3Q5SV9G)))
    (try! (as-contract (contract-call? .arkadiko-dao burn-token .usda-token balance-10 'SPE39HZGRQ45ZSDJXY5JEG483VC8B8J0DEEDDTT5)))
    (ok true)
  )
)

(define-public (burn-usda-2)
  (let (
    (balance-1 (unwrap-panic (contract-call? .usda-token get-balance 'SP11ETHNJKZRF8N4VMMK62FM322HKVQPRAN8JM1R6)))
    (balance-2 (unwrap-panic (contract-call? .usda-token get-balance 'SP3TMT5AV7D73EWWMR898PXN4H8JTCSWAAXY39N2A)))
    (balance-3 (unwrap-panic (contract-call? .usda-token get-balance 'SPRAHKK7E6HZ159H4PV1QPZ685QXCXER6S4MZR7W)))
    (balance-4 (unwrap-panic (contract-call? .usda-token get-balance 'SP3EYT7KF5ERWQFTWW3SWHS8QRYBNSMRZ7JW73YXR)))
    (balance-5 (unwrap-panic (contract-call? .usda-token get-balance 'SP2W2C90TKDHRAFXRVH5DHHCADNM24Q9ZM7T1HP1P)))
  )
    (asserts! (is-eq tx-sender DAO-OWNER) (err ERR-NOT-AUTHORIZED))

    (try! (as-contract (contract-call? .arkadiko-dao burn-token .usda-token balance-1 'SP11ETHNJKZRF8N4VMMK62FM322HKVQPRAN8JM1R6)))
    (try! (as-contract (contract-call? .arkadiko-dao burn-token .usda-token balance-2 'SP3TMT5AV7D73EWWMR898PXN4H8JTCSWAAXY39N2A)))
    (try! (as-contract (contract-call? .arkadiko-dao burn-token .usda-token balance-3 'SPRAHKK7E6HZ159H4PV1QPZ685QXCXER6S4MZR7W)))
    (try! (as-contract (contract-call? .arkadiko-dao burn-token .usda-token balance-4 'SP3EYT7KF5ERWQFTWW3SWHS8QRYBNSMRZ7JW73YXR)))
    (try! (as-contract (contract-call? .arkadiko-dao burn-token .usda-token balance-5 'SP2W2C90TKDHRAFXRVH5DHHCADNM24Q9ZM7T1HP1P)))
    (ok true)
  )
)

(define-public (burn-usda-3)
  (let (
    (balance-6 (unwrap-panic (contract-call? .usda-token get-balance 'SP3D37B82DX7JJ38GZVR2X5400QR1DHHXTKAP7Q1A)))
    (balance-7 (unwrap-panic (contract-call? .usda-token get-balance 'SP9R38DHK2DKQ8QV4ESZY14R66AHMPXS2NJRFW48)))
    (balance-8 (unwrap-panic (contract-call? .usda-token get-balance 'SP1JPKH64TWH1EW9K88A16FJRRXRNMY2J9JSAF086)))
    (balance-9 (unwrap-panic (contract-call? .usda-token get-balance 'SPP62V4HY4KBC344RSPQMP1MKV8S60ZAJ3Q5SV9G)))
    (balance-10 (unwrap-panic (contract-call? .usda-token get-balance 'SPE39HZGRQ45ZSDJXY5JEG483VC8B8J0DEEDDTT5)))
  )
    (asserts! (is-eq tx-sender DAO-OWNER) (err ERR-NOT-AUTHORIZED))

    (try! (as-contract (contract-call? .arkadiko-dao burn-token .usda-token balance-6 'SP3D37B82DX7JJ38GZVR2X5400QR1DHHXTKAP7Q1A)))
    (try! (as-contract (contract-call? .arkadiko-dao burn-token .usda-token balance-7 'SP9R38DHK2DKQ8QV4ESZY14R66AHMPXS2NJRFW48)))
    (try! (as-contract (contract-call? .arkadiko-dao burn-token .usda-token balance-8 'SP1JPKH64TWH1EW9K88A16FJRRXRNMY2J9JSAF086)))
    (try! (as-contract (contract-call? .arkadiko-dao burn-token .usda-token balance-9 'SPP62V4HY4KBC344RSPQMP1MKV8S60ZAJ3Q5SV9G)))
    (try! (as-contract (contract-call? .arkadiko-dao burn-token .usda-token balance-10 'SPE39HZGRQ45ZSDJXY5JEG483VC8B8J0DEEDDTT5)))
    (ok true)
  )
)