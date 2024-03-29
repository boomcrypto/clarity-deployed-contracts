;; use the SIP090 interface
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token stacks-roots uint)

;; Constants
(define-constant ERR-ALL-MINTED u101)
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant MINT-LIMIT u100)

;; Store the last issues token ID
(define-data-var last-id uint u0)
(define-data-var cost-per-mint uint u50000000)

;; Claim a new NFT
(define-public (claim)
  (mint tx-sender))

;; SIP009: Transfer token to a specified principal
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      (match (nft-transfer? stacks-roots token-id sender recipient)
        success (ok success)
        error (err error))
      (err u500)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? stacks-roots token-id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (token-id uint))
  (ok (some (unwrap! (get-map token-id) (err u10))))
)

;; Internal - Mint new NFT
(define-private (mint (new-owner principal))
  (let (
        (next-id (+ u1 (var-get last-id)))  
        (count (var-get last-id))
      )
      (asserts! (< count MINT-LIMIT) (err ERR-ALL-MINTED))
        (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
          success (begin
            (try! (nft-mint? stacks-roots next-id new-owner))
            (var-set last-id next-id)
            (ok next-id)
          ) 
          error (err error)
          )
          )
        )

;; Allows contract owner to change mint price
(define-public (set-cost-per-mint (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set cost-per-mint value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Transfers stx from contract to contract owner
(define-public (transfer-stx (address principal) (amount uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (as-contract (stx-transfer? amount (as-contract tx-sender) address))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; metadata mapping
(define-map uri uint (string-ascii 209))
(map-set uri u1 "QmSpZTfb1BZwEzooyVg5w263kRoUcJjHMTN2NSixdh1cbW")
(map-set uri u2 "Qmez1MvLyuepMAdGRUg1DkssmqKDyciHZJHpdVLoFCYo7T")
(map-set uri u3 "QmVUAgAzS6upqahHwypCXAsMzSpWu8yLPBE3PKac48NgEq")
(map-set uri u4 "QmbvZG5BiCRW4zWoCRFijnXof8Xe5FQi1krnGPhJNgBqkv")
(map-set uri u5 "QmUCJhYqgPiEXHqvCZ8vwGydwqyGgh257VbjiDn21aPcQn")
(map-set uri u6 "QmPY9Q4mfBkgE8xKMM3kNJyRqeUN8SKxRCpVsvrPuHgRuk")
(map-set uri u7 "QmXpZ9Tm1QK4ryij8zF3rQrWNUJ1rgwXGms6qcbJ9nvQrx")
(map-set uri u8 "QmcK4HfAMcs7ZD69d5gycjrFx4VEUwRfKeKhqjMnZ7Pg4K")
(map-set uri u9 "QmYWg91BQGcZEcWmWCfWuUwJj68wj4rVjAF4wC6XYmqdKz")
(map-set uri u10 "QmdJeB27ysuGudqM2EVzogFtVRuJEiwDzuiJtK8gZxoZ2A")
(map-set uri u11 "QmZRjPwRcgKh1aqooRpwaDd1SCRhRY9hDwed8wfhNcP6RE")
(map-set uri u12 "QmZvYLYzifX7CAm3sih3Z8ae85HtaHhZzbYQ2GambXyYtV")
(map-set uri u13 "QmP8Siadp1SNtEhntaYfPGjJpAJ6dGfudKq8Lzed7qonHZ")
(map-set uri u14 "QmfKgZsAEyteiPSq8g6N95cbBXFU7bJN6212RfoU5THpC6")
(map-set uri u15 "QmYdf2u6MaudMWWQLKaWRmYfQYNX67D61fi8VW3nfRnHct")
(map-set uri u16 "QmYCYNrDGvaMxXv6bnAabgH19Z65UNMByqJdcspgK3yydi")
(map-set uri u17 "QmcYpHpFoznpfZofQgx1VpP2JEwirUxaPoM2dD9R4QJTqZ")
(map-set uri u18 "QmbGuoUuSZasvNt1jDUtDyHbJ9Dod2dLN2aykzvZz7qYkx")
(map-set uri u19 "QmZCnYMZdfM36MEUb2LdXwJzZYPLdmDTCCNod2gUWJsLYH")
(map-set uri u20 "QmZFvbBVtXbyJdpTQSzFp1jwtk5LA8oYnAYK5LzXmy61vL")
(map-set uri u21 "QmUKWjq3P4tonbQob5ERZZituBGDVRRyNzCo77cNnuoveC")
(map-set uri u22 "QmSFK2yDMmYK5jocdkY1rPnUriw1mJWqtM4hwcXS2R7qZV")
(map-set uri u23 "QmXPcNSSxgkMydNQ4T7XVc6N1CTmtMBGkDRfeQyF36HiSZ")
(map-set uri u24 "QmTCgWNgG7G65BA4vupYiHzVvGEQ3N7GSzujDoydugKCfR")
(map-set uri u25 "QmRuvZt3bLerTnncPX7nMEQe4WQ2o9hLzqf8WaRVryNHT1")
(map-set uri u26 "Qmf9fuBNBuiPPtv8jtmKeyaQTprxtXUSTP7BBXDjZyktGF")
(map-set uri u27 "QmRdakL66aEgCQQHW8nY1arvHLc6KL3veqYULtf7vDQXQ3")
(map-set uri u28 "QmZUuRw9gfu2yrwasgjFWqrvFy7wLzGPV3xgRjiFTeB9a2")
(map-set uri u29 "QmWmiQ9qvDKzSu4WKKZet24qxjiQjdYkotVehT48TTKQuB")
(map-set uri u30 "QmZ67Ycyp1WtgTLDCny5qfzuGQjX2jDDJrDGe8wwzmCYCc")
(map-set uri u31 "QmVmaeMj9vyTHbTtcJVUWs9aLLaWKRg3RynsaMBknVxpzm")
(map-set uri u32 "QmPegbSFauL2AqQEocMW65q74P6TZWEmTJsTVGW6a4HyVC")
(map-set uri u33 "QmcYkXijuLEdwDXw2Bqv4yEPLDYmXc21144D7uiT37GTjP")
(map-set uri u34 "QmVbBmo3Frj37v9i7Bo7dGVEjaQhFHsJzwrqGP61swgV7s")
(map-set uri u35 "QmWiKkiHCR7x4TNKBBeAQdmzDQvLrFwS1SegUekorGjYgq")
(map-set uri u36 "QmNjMAe8kdqbB8VBDWftgD9g2JprGgTrqWURXK6nPY91W7")
(map-set uri u37 "QmcqeqWrdBEK2vJhWWxsPiCqxos3cCrrwpJGZsZ1JRttDb")
(map-set uri u38 "QmWTR5eMGQQYYEJJf9zYvA64iH1tJPrxPZpLpc5XZrdJjT")
(map-set uri u39 "QmNu2x6qTgvLyx4o1AxTbiXon3STVeETv8CZZiRHwNtDwn")
(map-set uri u40 "QmY7M6RW9Lq1uGD9rXe5PFz36is4Nv5EkUYGsWA9LXaorW")
(map-set uri u41 "QmTauUYcrmjwCHb71e6z8qwHRjZ5q4yJV5JK3sm5F8ZEq7")
(map-set uri u42 "QmaqaT593QkGoPNbufhcre6kFMktVqctQ4X8AHo16ReAde")
(map-set uri u43 "QmUMP5jKi1X6XFxykoCeqaY5SbPtgg6aTBCgx4auuef7Az")
(map-set uri u44 "QmRgMHQoETU6yBdeyVzdw5Rx3DcLtVSk9kQCSK3TvRW23D")
(map-set uri u45 "QmVfZHbQi7umkKBam78472JHS7oyfHebGcdvQVXs4ChLGb")
(map-set uri u46 "QmdXc3Mxh2GwiZ1bYH95YnRxEwmyBGNmwwEibfMAVsRWbn")
(map-set uri u47 "Qmd5n6HMRaNfd9Uh6aUL1zn6GF5Sy32AdVkojuKiun6Pd3")
(map-set uri u48 "QmZJyXjb5KrX5ft4sKR9oegNpnc1VWgHoweChTnhM9f1Us")
(map-set uri u49 "QmZED7cYA72BTtE7mVSeBVq1wJyrq8m24XipJdZ1817xeg")
(map-set uri u50 "QmXwrTRZjxtM9QiSESDrwCpCQ7wkvXnnFXc6S5H6K1t6iD")
(map-set uri u51 "Qmaywn9RM5FdZt3dW7n3SiAsmGxsD1TVffxo99k6enV6m9")
(map-set uri u52 "QmRdH58zNBiG2eXL8ygDQiHJYbMAYhAucKcuPh2DYSV2eY")
(map-set uri u53 "QmbAG5RaHDzorni8ov77neoSu36jYHUS8fS6JJGg8zgFdZ")
(map-set uri u54 "QmVrJZp5xWia5wRxX2kkvz322XNUq9tW5ezDHduFddVhLN")
(map-set uri u55 "QmVsfFSeku3mb84NhPzqTZqkCpranN9H9JQLKHi1XGaoYm")
(map-set uri u56 "QmTSpUuuw2NGtKcB7JTNdsKWdGAsoN9ojTQvKtk7vswAho")
(map-set uri u57 "QmVZKjgiL5eYpYykAEGsMTJdpEqyXPhxDtQ8xz8DxDnkqo")
(map-set uri u58 "QmVxZagnvpARJmGPKJD32dTCyvbUxi26BNnFeefkZeDa6W")
(map-set uri u59 "QmP7LFCvzbZTp6nYdtsNhLw8kckp2mXt4w9MxDupTS84Ct")
(map-set uri u60 "QmNz4xinUthWPhrtJd7VAcnTUkgDwLKau1P9gUPvuu2BFU")
(map-set uri u61 "QmbYfVSVvV3wTdYnPDWnMsZ5XAkhyHRqT6goMn45UqzLep")
(map-set uri u62 "QmVkLhobj4hUeGZzHtFnoG2ztYsdYfyS5yVm8VdFxuvK2K")
(map-set uri u63 "QmRhXimh5z61cimzyzLSsfAHd6yfQbUpEK94TMoBxGsDod")
(map-set uri u64 "QmTH1wmdvq2PuoTnSgRCNUzh4inf7Vh7ahkwAAbE9UtHto")
(map-set uri u65 "QmNM6tJ6gE6QqAY5e59u6BJmoHX9dJvv27sWbzv6wxo1tS")
(map-set uri u66 "QmWwZZzNK7oUGBgfEER5W4Per3BQ8wu2f9GPfUtywCE49S")
(map-set uri u67 "QmSiZ3NnXgJ4fZ1nMF9jJFV5h5UT6nwX96vGu8uXm86tBZ")
(map-set uri u68 "QmStUuSEP4kmWh6pvScJHo5iT5EFh1Y7cR4dqWUHmCjeb9")
(map-set uri u69 "QmQp8ibJWx6327xtu8n4ozJRFiHMmNkPLQ8d2RXRbTEcQF")
(map-set uri u70 "QmRhQ4VAwVJnDF245XQkwGxz2EEx2FWagzmPEQoQWxwXPQ")
(map-set uri u71 "QmXubLvwh3Jr5VF6VcyuV38TEyCUh2k6tC7M2wZS5pDotQ")
(map-set uri u72 "QmTN78AbYPqETGFdCf1VF9MSjr2zMaVRjj8jGoY5tVgtPz")
(map-set uri u73 "QmUBpMC9xrqXvPFHjXeJwKgCvaLWbxHjbyA6WD2d1G6QRV")
(map-set uri u74 "QmQiJrgUd2MpRLf3RFx6VMd2bYYHCn1uugpbYCMmk7JKP8")
(map-set uri u75 "QmU2xgHybVgB9mneT1KKbZbumveDXu9UFnU4VBdvSaJBew")
(map-set uri u76 "QmRjPEPheD6FYBTsxkPbsmqG6sJrcuANReZS5oQffeG5TJ")
(map-set uri u77 "QmUWNihGSEg4f4igoWSnb4o1J1JwW53AfZLL2GudRoAWeF")
(map-set uri u78 "QmXrBLoVp3QCetGe5WJoJp65RqAuVQrHwPTfgHJK3oTapm")
(map-set uri u79 "QmRGUr7TVu1N7ssKe7HHmZW5CLL3MafqQJsk5bph35GrJD")
(map-set uri u80 "QmNfFLEaAfRJzMMk3hp43tFLmAbh5Edk3gDPg4VgjYdGaP")
(map-set uri u81 "QmboPGjmhX3jPNUuPDWm6exYmqmWzUwN12Q2ZFVPwvX29H")
(map-set uri u82 "QmNQmpf55H9Ak34ZZsTSFgBMEQc7nxK2FZrNnM1xUTkKLy")
(map-set uri u83 "QmdSnj5E6J18BHoqvQxneVvqcdWDUfMX7aFAsmCkz6NzX7")
(map-set uri u84 "QmSkz9JDHzxijvWCrDPmuRs3nz8qnUnTGUy5mmbypRJhcu")
(map-set uri u85 "QmRc1So1RW8A3YJjpagdHabZPepwpiHQu2Rhrb1pYLTNUx")
(map-set uri u86 "QmPKdUwcsZELB9i8zGnk74Baj58NuzhgnyuyykRc3j6jJb")
(map-set uri u87 "QmPM7FeJPnH22p6A8hg9LgdYpAJnZe8VrQTmJCQqXSmRip")
(map-set uri u88 "QmUTxBcevw9oFgdTby2hc6d1A2qTJQ2y7N5jPDfdDMcuPx")
(map-set uri u89 "QmR5kvmQ1XXhUpmVojzSQovE1Pai1izPe821vpQnpDKEHk")
(map-set uri u90 "QmfAYs8ZXhvjZMhKMWsx5WJidTLKjXvkg77v8TPqP6RsU6")
(map-set uri u91 "QmVD8GgVNV4zPWw6HnJbbyYcdBFtGrwAqhNemSSBNiKhrK")
(map-set uri u92 "QmfCtzgXTYyLEoAmZevcoP6ftFCRCZmyvThtJWWHwTum64")
(map-set uri u93 "QmUc1tE9hU1F1auWRCh4EaJBUxmWv8ke5wY7ChHTSnEQeK")
(map-set uri u94 "QmR4E2pArZWmRyCSqArA86u1Z4BX9ZB4zJJcKy2MGEtUcB")
(map-set uri u95 "QmdyYKH92BbTYRdk1vGHmKYboox8VCii5gQGF6JA2uvbdK")
(map-set uri u96 "QmTUM2T6KEnRgsFaSYQnwCaa9UT7AR3L56Dpd4EyQ24R96")
(map-set uri u97 "QmTxiry9ycK2BTj9bDdVGjdSVThrrcZ47d65CUiDLae8EF")
(map-set uri u98 "QmNd8d2jReB2MEE19oatqgaN11DFm2sovq18pdjHkEmFqn")
(map-set uri u99 "Qmf7DxfbqXv5LxKA1xDnVNkzPoLHFXuHxBs8N8RyEPchvP")
(map-set uri u100 "QmcLFS3JFHXgLVjwd8Crw7WE9FLcDQb8MtMG6pram3a1yW")

(define-read-only (get-map (token-id uint))
  (ok (concat "https://cloudflare-ipfs.com/ipfs/" (unwrap-panic (map-get? uri token-id)))))