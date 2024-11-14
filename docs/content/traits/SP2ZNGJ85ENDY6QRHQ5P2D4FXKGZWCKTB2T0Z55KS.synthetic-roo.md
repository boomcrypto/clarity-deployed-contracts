---
title: "Trait synthetic-roo"
draft: true
---
```
;; This contract implements the SIP-010 community-standard Fungible Token trait.
(impl-trait .dao-traits-v4.sip010-ft-trait)

;; Define errors
(define-constant ERR_NOT_MINTER (err u200))
(define-constant ERR_AMOUNT_ZERO (err u201))
(define-constant ERR_NOT_TOKEN_OWNER (err u203))

;; Define constants for contract
(define-constant MINTER tx-sender) ;;central wallet
(define-constant TOKEN_NAME "Synthetic Roo")
(define-constant TOKEN_SYMBOL "iouROO")
(define-constant TOKEN_DECIMALS u6) ;; 6 units displayed past decimal, e.g. 1.000_000 = 1 token

;; Define the FT, with maximum supply
(define-fungible-token synthetic-roo)

(define-data-var TOKEN_URI (optional (string-utf8 256)) (some u"https://charisma.rocks/api/v0/tokens/SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.synthetic-roo"))

;; SIP-010 function: Get the token balance of a specified principal
(define-read-only (get-balance (user principal))
  (ok (ft-get-balance synthetic-roo user))
)

;; SIP-010 function: Returns the total supply of fungible token
(define-read-only (get-total-supply)
  (ok (ft-get-supply synthetic-roo))
)

;; SIP-010 function: Returns the human-readable token name
(define-read-only (get-name)
  (ok TOKEN_NAME)
)

;; SIP-010 function: Returns the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL)
)

;; SIP-010 function: Returns number of decimals to display
(define-read-only (get-decimals)
  (ok TOKEN_DECIMALS)
)

(define-read-only (get-token-uri)
  (ok (var-get TOKEN_URI))
)

(define-public (transfer (amount uint) (sender principal) (receiver principal) (memo (optional (buff 34)))) 
    (begin
    ;; #[allow(unchecked_data)]
        (asserts! (is-eq tx-sender sender) ERR_NOT_TOKEN_OWNER)
        (try! (ft-transfer? synthetic-roo amount sender receiver))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)

(define-public (set-token-uri (value (string-utf8 256)))
  (if
    (is-eq tx-sender MINTER)
    (ok (var-set TOKEN_URI (some value)))
    (err ERR_NOT_MINTER)
  )
)

;; To be used later [synthetic-roo -> *** -> ***]
(define-public (burn (amount uint))
  (ft-burn? synthetic-roo amount tx-sender)
)


(begin
  ;; mint 140k for dex lp
  (try! (ft-mint? synthetic-roo u140000000000 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS)) 
  ;; mint ious for those who lost in the exploit
  (try! (ft-mint? synthetic-roo u530983159897 'SP3WAAYXPC6WZNEC7SHGR36D32RJPZVXRR1BG0QSY))
  (try! (ft-mint? synthetic-roo u141000000000 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE))
  (try! (ft-mint? synthetic-roo u127071999749 'SP3KVRE3RDYYSJ3JDGXKA0K15CC4JEA2ZGX4TJ5EC))
  (try! (ft-mint? synthetic-roo u49684999180 'SP308TTPX0XTY1TQ7DPDD45DEHRNDPG1DCJHJ6RR8))
  (try! (ft-mint? synthetic-roo u35319869800 'SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D))
  (try! (ft-mint? synthetic-roo u34519276978 'SPHXVP64Z6K49BH92G83BFBHA8NQG93QGCD79N4C))
  (try! (ft-mint? synthetic-roo u20945086634 'SP25DP4A9QDM42KC40EXTYQPMQCT1P0R5243GWEGS))
  (try! (ft-mint? synthetic-roo u17989641948 'SPAFPBD7M89973WDEN68FKYW761RQVYNHSEFQZB9))
  (try! (ft-mint? synthetic-roo u14069497064 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C))
  (try! (ft-mint? synthetic-roo u12690729754 'SP1FHC2XXJW3CQFNFZX60633E5WPWST4DBW8JFP66))
  (try! (ft-mint? synthetic-roo u9994707390 'SP23S4KHTBQADHS6Q0EQVHTC7Q9YRGBSD0F3X6QY))
  (try! (ft-mint? synthetic-roo u9947857610 'SP1HAQ4NW6HH98PMJP55CY0FXCT3XWZ95KY0Y731R))
  (try! (ft-mint? synthetic-roo u7585317506 'SP2XPZZQTER4936FS9ZE5JF4J4DFZD2XHADWE0FWN))
  (try! (ft-mint? synthetic-roo u5897527469 'SP1ERZZ0G7KERNCXQDJF4GTHCF8DGZB8001YCNPQG))
  (try! (ft-mint? synthetic-roo u4504955712 'SP1953PHRF5Y4VJ4C47SP8DQKEW0TZ2ANAW4XN8R4))
  (try! (ft-mint? synthetic-roo u4075358023 'SPWC45P8JQP1VG9NDNPJ6ZXPVZ4XXGK06GXR5XN3))
  (try! (ft-mint? synthetic-roo u3344583035 'SP2CYW85YW03WX0XMSFGMJ3HZQ30X8NKFA6TXVNRX))
  (try! (ft-mint? synthetic-roo u2010813147 'SP2GYXR37WGDP11A2CT9T4HBXDPS8SA6YTHQ8A2NH))
  (try! (ft-mint? synthetic-roo u1653811143 'SPENXM9Q8CKQGJF9DBRF12WR0SQXFQMYJKRAZG3F))
  (try! (ft-mint? synthetic-roo u1032905062 'SPBNZD0NMBJVRYJZ3SJ4MTRSZ3FEMGGTV2YM5MFV))
  (try! (ft-mint? synthetic-roo u1000089965 'SP10ECZKBTMVGV9Z41A9QQP80TQFZK2QRSV5BWNMX))
  (try! (ft-mint? synthetic-roo u598317506 'SPHZW8N7EMXHY7N72JNE2EE1TD4Z1FZ8GENAHYFS))
  (try! (ft-mint? synthetic-roo u90647233 'SP34V64PNDN1535R0DP60EBSXASJHKJ5NH8JPHBQH))
  (try! (ft-mint? synthetic-roo u45024764 'SP1KMAA7TPZ5AZZ4W67X74MJNFKMN576604CWNBQS))
)
```
