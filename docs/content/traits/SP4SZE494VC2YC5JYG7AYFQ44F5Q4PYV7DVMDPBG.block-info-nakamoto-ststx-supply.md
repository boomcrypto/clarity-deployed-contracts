---
title: "Trait block-info-nakamoto-ststx-supply"
draft: true
---
```
;; @contract Block Info Nakamoto stSTX supply
;; @version 1
;;
;; Contract to get info at given block

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_BLOCK_INFO u42001)

;;-------------------------------------
;; stSTX info
;;-------------------------------------

(define-read-only (get-ststx-supply-at-block (block uint))
  (let (
    (block-hash (unwrap! (get-stacks-block-info? id-header-hash block) (err ERR_BLOCK_INFO)))
  )
    (at-block block-hash (contract-call? .ststx-token get-total-supply))
  )
)

```
