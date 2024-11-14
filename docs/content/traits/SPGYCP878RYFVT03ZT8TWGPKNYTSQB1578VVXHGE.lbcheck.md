---
title: "Trait lbcheck"
draft: true
---
```
;; Land Balance Checker

(define-public (get-land-balance (land-id uint))
  (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands get-balance land-id tx-sender))

(define-public (get-all-land-balances)
  (ok {
    land-4: (get-land-balance u4),   ;; Welsh
    land-5: (get-land-balance u5),   ;; Fam
    land-6: (get-land-balance u6),   ;; Leo
    land-7: (get-land-balance u7),   ;; Fair
    land-8: (get-land-balance u8),   ;; Edmund
    land-9: (get-land-balance u9),   ;; Rocks
    land-10: (get-land-balance u10), ;; Gyatt
    land-11: (get-land-balance u11), ;; Edel
    land-14: (get-land-balance u14), ;; Ten
    land-15: (get-land-balance u15), ;; Not
    land-16: (get-land-balance u16), ;; Booster
    land-17: (get-land-balance u17), ;; Earlycrows
    land-18: (get-land-balance u18), ;; Fskpi
    land-19: (get-land-balance u19), ;; Moist
    land-20: (get-land-balance u20), ;; Roo
    land-21: (get-land-balance u21), ;; Skull
    land-22: (get-land-balance u22), ;; Stone
    land-23: (get-land-balance u23), ;; Honeyb
    land-24: (get-land-balance u24), ;; Bitmap
    land-25: (get-land-balance u25), ;; Notlp
    land-26: (get-land-balance u26), ;; Fskpilp
    land-27: (get-land-balance u27), ;; Roolp
    land-28: (get-land-balance u28)  ;; Some
  }))
```
