(define-fungible-token coco)
(define-data-var token-name (string-ascii 32) "Play my song")
(define-data-var token-symbol (string-ascii 10) "Song")
(define-public (set-name (new-name (string-ascii 32)))
  (begin
    (ok (var-set token-name new-name))))
(define-public (set-symbol (new-symbol (string-ascii 10)))
  (begin
    (ok (var-set token-symbol new-symbol))))
(define-read-only (get-name)
  (ok (var-get token-name)))
(define-read-only (get-symbol)
  (ok (var-get token-symbol)))
(ft-mint? coco u200 'SP30F77CBR0DSZAET7A5WYMGDHRNDQYDHCPK5SWMC)