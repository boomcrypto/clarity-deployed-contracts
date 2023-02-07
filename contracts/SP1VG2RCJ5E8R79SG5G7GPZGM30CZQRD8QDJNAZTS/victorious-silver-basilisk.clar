;; hello-world contract

(define-constant sender 'SP16MYYYH4Z51EAS76K55JMJ182629JNWSHK5NWM)
(define-constant recipient 'SP1VG2RCJ5E8R79SG5G7GPZGM30CZQRD8QDJNAZTS)

(define-non-fungible-token soco-nft uint)
(begin (nft-mint? soco-nft u1 sender))
(begin (nft-mint? soco-nft u2 sender))
(begin (nft-transfer? soco-nft u1 sender recipient))

(define-public (test-emit-event)
    (begin
        (print "Event! Hello world")
        (ok u1)))
(begin (test-emit-event))

(define-map store {key: (buff 32)} {value: (buff 32)})
(define-public (get-value (key (buff 32)))
    (begin
        (match (map-get? store {key: key})
            entry (ok (get value entry))
            (err 0))))
			
(define-public (set-value (key (buff 32)) (value (buff 32)))
    (begin
        (map-set store {key: key} {value: value})
        (ok u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some "https://ipfs.io/ipfs/bafybeicvnaqeyxqkqf7vuih3222hk6pcd5poo2qew7gsni52curv7ccpce/soco1.json")))