;; shorten
;; link shortener built on stacks

(define-constant owner 'ST3AA33M8SS15A30ETXE134ZXD8TNEDHT8Q955G40)

(define-constant ERR_PANIC 0)

(define-constant ERR_LINK_DOES_NOT_EXIST 1)
(define-constant ERR_LINK_ALREADY_EXISTS 2)

(define-constant ERR_COULD_NOT_FUND 3)

(define-map links
	(string-ascii 5)
  	{ url: (string-ascii 1000), owner: principal })

(define-public (create-link (code (string-ascii 5)) (url (string-ascii 1000)))
(begin 
	(unwrap! 
		(stx-transfer? u100 tx-sender owner)
	(err ERR_COULD_NOT_FUND))
				
	(map-insert links code { 
		url: url, 
		owner: tx-sender 
	})
(ok true)))

(define-read-only (get-link (code (string-ascii 5)))
	(match (map-get? links code)
		link
		(ok link)
	(err ERR_LINK_DOES_NOT_EXIST)))
