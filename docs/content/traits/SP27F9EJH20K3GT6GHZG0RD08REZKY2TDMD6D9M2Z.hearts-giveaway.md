---
title: "Trait hearts-giveaway"
draft: true
---
```
;; hearts give away
;; only call if you want to airdrop ~205 stx to badgers community
(define-public (hearts-giveaway)
  (begin
  (unwrap! (stx-transfer? u10000000 tx-sender 'SP247RS63PWW7ZQZ9EYYA9CXKKPWEP71M14W8N294) (err u1))
  (unwrap! (stx-transfer? u10000000 tx-sender 'SPX0FKCZ2QNS7AWYT95HQ89S1YGEEY89AYG8ASZ4) (err u2))
  (unwrap! (stx-transfer? u10000000 tx-sender 'SPFQX05AX2TCQZQFM138PST1F99NE6P1REHGQ9FT) (err u3))
  (unwrap! (stx-transfer? u10000000 tx-sender 'SP1CA9W3C35F6WH2MH1D5Z1XQG9595Q1C3P7Z2NYY) (err u4))
  (unwrap! (stx-transfer? u30000000 tx-sender 'SP247RS63PWW7ZQZ9EYYA9CXKKPWEP71M14W8N294) (err u5))
  (unwrap! (stx-transfer? u15000000 tx-sender 'SPJ6SFYTCJER9DQ6AWBM1T5JNW6AEM2X4T8JMN3C) (err u6))
  (unwrap! (stx-transfer? u15000000 tx-sender 'SP14ZVJSGEC4P7WGYCYC5P67WNGBVZ1K71DA75J13) (err u7))
  (unwrap! (stx-transfer? u15000000 tx-sender 'SP33SCE1F3J9N6D4ZFY9AA3GR05GS3112GS1VZDFC) (err u8))
  (unwrap! (stx-transfer? u15000000 tx-sender 'SP2AYJHP9H3JM3T26ZBW0SKBCXJ9S4JW03VQBP7K1) (err u9))
  (unwrap! (stx-transfer? u15000000 tx-sender 'SP2TW1D8YF5CE0NDP5VCR5NMTPHQ4PQR1KBB4NQ5Q) (err u10))
  (unwrap! (stx-transfer? u15000000 tx-sender 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G) (err u11))
  (unwrap! (stx-transfer? u15000000 tx-sender 'SP3MMG05H6T48W5NJEEST0RR3FTPGKPM7C19X5M16) (err u12))
  (unwrap! (stx-transfer? u15000000 tx-sender 'SP2DFX28F1S3CB46B5XH9M5JQ7N4SMCE7CQY1TNYS) (err u13))
  (ok (unwrap! (stx-transfer? u15000000 tx-sender 'SPR9FXRK4Y7BDDTMFV0THSKAN0H8NY7759K3RWHD) (err u14)))
  )
)

```