---
title: "Trait upgrade-v1-2_step_1"
draft: true
---
```
(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant updated-reserve-asset-1 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
(define-constant updated-reserve-asset-2 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)
(define-constant updated-reserve-asset-3 .wstx)

(define-constant asset-1_v0 .zststx)
(define-constant asset-1_v1-0 .zststx-v1-0)
(define-constant asset-1_v1-2 .zststx-v1-2)

(define-constant ststx-oracle .ststx-oracle-v1-4)

(define-constant asset-2_v0 .zaeusdc)
(define-constant asset-2_v1-0 .zaeusdc-v1-0)
(define-constant asset-2_v1-2 .zaeusdc-v1-2)

(define-constant asset-3_v0 .zwstx)
(define-constant asset-3_v1-0 .zwstx-v1)
(define-constant asset-3_v1-2 .zwstx-v1-2)

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    ;; clear erroneous state
    (try! (contract-call? .zwstx-v1 burn u8200000772 'SP3M742Y46SFSXHQD0WE31V60GMYP8KWTJWE5CY2B))
    (try! (contract-call? .zwstx-v1 burn u300000000 'SP1XSX76A3JS054PM65VBE718K049AEJSVRKWZP1Z))
    (try! (contract-call? .zwstx-v1 burn u4000000000 'SP2HDXKPHMMH5FP9NY542GBFJESXMN1P0SNM3MN0X))
    (try! (contract-call? .zwstx-v1 burn u2200000000 'SP22S1EVQ2A8ED2861TTKJJHHDCTRKP39H6R29WHN))
    (try! (contract-call? .zwstx-v1 burn u3000000000 'SP9DGFSPRX40H5BS19RHNCQXSFC1H6Z7PCFNW17C))

    (try! (contract-call? .pool-reserve-data delete-user-assets 'SP3M742Y46SFSXHQD0WE31V60GMYP8KWTJWE5CY2B))
    (try! (contract-call? .pool-reserve-data delete-user-assets 'SP1XSX76A3JS054PM65VBE718K049AEJSVRKWZP1Z))
    (try! (contract-call? .pool-reserve-data delete-user-assets 'SP2HDXKPHMMH5FP9NY542GBFJESXMN1P0SNM3MN0X))
    (try! (contract-call? .pool-reserve-data delete-user-assets 'SP22S1EVQ2A8ED2861TTKJJHHDCTRKP39H6R29WHN))
    (try! (contract-call? .pool-reserve-data delete-user-assets 'SP9DGFSPRX40H5BS19RHNCQXSFC1H6Z7PCFNW17C))

    (try! (contract-call? .pool-reserve-data delete-user-reserve-data 'SP3M742Y46SFSXHQD0WE31V60GMYP8KWTJWE5CY2B .wstx))
    (try! (contract-call? .pool-reserve-data delete-user-reserve-data 'SP1XSX76A3JS054PM65VBE718K049AEJSVRKWZP1Z .wstx))
    (try! (contract-call? .pool-reserve-data delete-user-reserve-data 'SP2HDXKPHMMH5FP9NY542GBFJESXMN1P0SNM3MN0X .wstx))
    (try! (contract-call? .pool-reserve-data delete-user-reserve-data 'SP22S1EVQ2A8ED2861TTKJJHHDCTRKP39H6R29WHN .wstx))
    (try! (contract-call? .pool-reserve-data delete-user-reserve-data 'SP9DGFSPRX40H5BS19RHNCQXSFC1H6Z7PCFNW17C .wstx))

    (try! (contract-call? .pool-reserve-data delete-user-index 'SP3M742Y46SFSXHQD0WE31V60GMYP8KWTJWE5CY2B .wstx))
    (try! (contract-call? .pool-reserve-data delete-user-index 'SP1XSX76A3JS054PM65VBE718K049AEJSVRKWZP1Z .wstx))
    (try! (contract-call? .pool-reserve-data delete-user-index 'SP2HDXKPHMMH5FP9NY542GBFJESXMN1P0SNM3MN0X .wstx))
    (try! (contract-call? .pool-reserve-data delete-user-index 'SP22S1EVQ2A8ED2861TTKJJHHDCTRKP39H6R29WHN .wstx))
    (try! (contract-call? .pool-reserve-data delete-user-index 'SP9DGFSPRX40H5BS19RHNCQXSFC1H6Z7PCFNW17C .wstx))

    (var-set executed true)
    (ok true)
  )
)

(define-read-only (can-execute)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (ok (not (var-get executed)))
  )
)

```
