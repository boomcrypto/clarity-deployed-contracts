(define-non-fungible-token participation (string-ascii 256))

(define-constant participants
  (list 
    {
      name: "Vladimir Novachki aka Vlad, Stornest",
      address: (some 'SP2T0QC6JP2DS0N3YQYNW8V9BZNTHJCW3A56ZB5KK),
    }
    {
      name: "Simon Semaan aka planet9, ardkon.com",
      address: (some 'SP1BBF4MY50BJW4YT1NVQPZMG20S52S2C71TRK5B6),
    }
    {
      name: "Roland Naddour aka TMDR11, Blockvote",
      address: (some 'SPAFTX8TJ51M4PAN62BMXFYTGCRKXTEQ0B70ZX9S),
    }
    {
      name: "Ibrahim Shedid strong, bypa-ss.com",
      address: (some 'SP2MYW78H7ZM0SSKETJJKJG54YBANW4GKG2FBKJA1),
    }
    {
      name: "Mario Nassef, tandasmart.com",
      address: none,
    }
    {
      name: "Hany Boraie, PassApp",
      address: none,
    }
    {
      name: "Bishoy Moussa, valify.me",
      address: (some 'SP5T0BR3GXMYWR3AH8A7AM70V6QY0BFDD0XWH3H6),
    }
    {
      name: "Ahmed Abdelmalek, TOGO",
      address: (some 'SP1QA3R2MD6ZC4KCYYFFSDCZHE5DWN9JZG4PMMN3S),
    }
  ))


(map say-name participants)





(define-private (say-name (participant {name: (string-ascii 50), address: (optional principal)})) 
  (let (
    (name (get name participant))
    (address (get address participant))
  )
    (print name)
    (if (is-some address)
      (nft-mint? participation name (unwrap-panic address))
      (ok true))))
