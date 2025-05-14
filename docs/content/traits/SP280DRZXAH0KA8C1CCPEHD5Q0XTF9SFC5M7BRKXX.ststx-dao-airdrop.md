---
title: "Trait ststx-dao-airdrop"
draft: true
---
```

  (impl-trait 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.sip-010-trait-ft-standard.sip-010-trait)

  (define-fungible-token STSTX)
  (define-constant contract-owner tx-sender)

  (define-data-var token-uri (optional (string-utf8 256)) (some u"https://bafkreiexrmubtmt4aruefni24np7mfffglfogecbftnxe3occkrwexoqve.ipfs.dweb.link/"))

  (define-constant ERR_UNAUTHORIZED (err u100))

  (define-public (transfer
    (amount uint)
    (sender principal)
    (recipient principal)
    (memo (optional (buff 34)))
  )
    (begin
      (asserts! (is-eq tx-sender sender) ERR_UNAUTHORIZED)
      (try! (ft-transfer? STSTX amount sender recipient))
      (match memo to-print (print to-print) 0x)
      (ok true)
    )
  )

  (define-read-only (get-balance (owner principal))
    (ok (ft-get-balance STSTX owner))
  )

  (define-read-only (get-name)
    (ok "STSTX")
  )

  (define-read-only (get-symbol)
    (ok "stackingdao.com")
  )

  (define-read-only (get-decimals)
    (ok u0)
  )

  (define-read-only (get-total-supply)
    (ok (ft-get-supply STSTX))
  )

  (define-read-only (get-token-uri)
      (ok (var-get token-uri)
      )
  )

  (define-public (set-token-uri (value (string-utf8 256)))
    (if (is-eq tx-sender contract-owner)
      (ok (var-set token-uri (some value)))
      (err ERR_UNAUTHORIZED)
    )
  )

  (define-public (airdrop (recipients (list 1000 { to: principal, amount: uint, memo: (optional (buff 34)) })))
    (fold check-err (map send-token recipients) (ok true))
  )

  (define-private (check-err (result (response bool uint)) (prior (response bool uint)))
    (match prior ok-value result err-value (err err-value))
  )

  (define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
    (send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient))
  )

  (define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
    (let ((transferOk (try! (transfer amount tx-sender to memo))))
      (ok transferOk)
    )
  )

  (begin
    (try! (ft-mint? STSTX u10000000000000000 contract-owner)) 
  )
  
```
