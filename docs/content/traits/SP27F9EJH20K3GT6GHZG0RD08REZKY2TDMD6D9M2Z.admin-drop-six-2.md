---
title: "Trait admin-drop-six-2"
draft: true
---
```
(define-constant owner tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u101))
(define-public (admin-drop-six)
  (begin
    (asserts! (is-eq tx-sender owner) (err u101))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP319BYQW8B8Q05FSW5Z130H1KTFJ58XMP789NTNV u277))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP319BYQW8B8Q05FSW5Z130H1KTFJ58XMP789NTNV u276))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP319BYQW8B8Q05FSW5Z130H1KTFJ58XMP789NTNV u70))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP319BYQW8B8Q05FSW5Z130H1KTFJ58XMP789NTNV u69))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP319BYQW8B8Q05FSW5Z130H1KTFJ58XMP789NTNV u68))
    (ok (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP319BYQW8B8Q05FSW5Z130H1KTFJ58XMP789NTNV u67)))
  )
)
```