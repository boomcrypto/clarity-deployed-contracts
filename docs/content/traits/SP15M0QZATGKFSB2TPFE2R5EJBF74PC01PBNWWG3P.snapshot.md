---
title: "Trait snapshot"
draft: true
---
```
(define-read-only (get_owners1 (ids (list 1000 uint)))
  (at-block (unwrap-panic (get-block-info? id-header-hash u171555))
    (map get_owner1 ids)
  )
)

(define-read-only (get_owner1 (id uint))
  (default-to 'SP000000000000000000002Q6VF78 (unwrap-panic (contract-call? 'SP2N959SER36FZ5QT1CX9BR63W3E8X35WQCMBYYWC.leo-cats get-owner id)))
)

(define-read-only (get_owners2 (ids (list 1000 uint)))
  (at-block (unwrap-panic (get-block-info? id-header-hash u171555))
    (map get_owner2 ids)
  )
)

(define-read-only (get_owner2 (id uint))
  (default-to 'SP000000000000000000002Q6VF78 (unwrap-panic (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-ape-club-nft get-owner id)))
)

(define-read-only (get_owners3 (ids (list 1000 uint)))
  (at-block (unwrap-panic (get-block-info? id-header-hash u171555))
    (map get_owner3 ids)
  )
)

(define-read-only (get_owner3 (id uint))
  (default-to 'SP000000000000000000002Q6VF78 (unwrap-panic (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.mojo get-owner id)))
)

(define-read-only (get_owners4 (ids (list 1000 uint)))
  (at-block (unwrap-panic (get-block-info? id-header-hash u171555))
    (map get_owner4 ids)
  )
)

(define-read-only (get_owner4 (id uint))
  (default-to 'SP000000000000000000002Q6VF78 (unwrap-panic (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.stacking-dao-genesis-nft get-owner id)))
)

```
