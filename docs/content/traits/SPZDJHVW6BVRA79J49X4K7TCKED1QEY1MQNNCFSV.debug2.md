---
title: "Trait debug2"
draft: true
---
```
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

(define-public
  (swap
    (token-in  <ft-trait>)
    (token-out <ft-trait>)
    (amt-in    uint)
  )
  (let ((R    (try! (contract-call? 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-proxy-v1_0_0_ststx-0001 get-ratio)))
        (res  (try! (contract-call? 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-pool-v1_0_0_ststx-0001 swap
                    token-in token-out
                    'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-fees-v1_0_0_ststx-0001
                    'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-proxy-v1_0_0_ststx-0001
                    amt-in
                    u1)))
        )
  (print {
    R   : R,
    res: res,
  })
  (ok u1))
)

;;; eof

```
