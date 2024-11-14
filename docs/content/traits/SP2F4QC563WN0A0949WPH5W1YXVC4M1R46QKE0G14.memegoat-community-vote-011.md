---
title: "Trait memegoat-community-vote-011"
draft: true
---
```
;;
;; MEMEGOAT PROPOSALS
;;
(impl-trait .proposal-trait.proposal-trait)

;; ERRS
(define-constant ERR-UNAUTHORISED (err u1000))
(define-constant ERR-NOT-QUALIFIED (err u1001))
(define-constant ERR-ALREADY-ACTIVATED (err u1002))
(define-constant ERR-NOT-ACTIVATED (err u1003))
(define-constant ERR-BELOW-MIN-PERIOD (err u2001))
(define-constant ERR-INVALID-OPTION (err u2002))
(define-constant ERR-HAS-VOTED (err u3002))

;; STORAGE
(define-data-var activated bool false)
(define-data-var duration uint u0)
(define-data-var start-block uint u0)
(define-data-var end-block uint u0)
(define-map votes {option: uint} uint)
(define-map vote-record principal bool)

;; READ-ONLY CALLS
(define-read-only (get-votes-by-op (op uint))
  (default-to u0 (map-get? votes {option: op}))
)

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .memegoat-community-dao) (contract-call? .memegoat-community-dao is-extension contract-caller)) ERR-UNAUTHORISED))
)

(define-read-only (get-proposal-data)
  (ok {
    start-block: (var-get start-block),
    end-block: (var-get end-block),
    duration: (var-get duration)
  })
)

(define-read-only (get-votes)
  (ok {
    op1: {id: u0, votes: (get-votes-by-op u0)},
    op2: {id: u1, votes: (get-votes-by-op u1)},
    op3: {id: u2, votes: (get-votes-by-op u2)},
    op4: {id: u3, votes: (get-votes-by-op u3)}
  })
)

(define-read-only (get-total-votes)
  (let
    (
      (vote-opts (list u0 u1 u2 u3))
    )
    (ok (fold get-votes-by-op-iter vote-opts u0))
  )
)

(define-read-only (check-has-voted (addr principal))
 (default-to false (map-get? vote-record addr))
)

;; PUBLIC CALLS
(define-public (activate (duration_ uint))
  (begin
    (try! (is-dao-or-extension))
    (asserts! (not (var-get activated)) ERR-ALREADY-ACTIVATED)
    (asserts! (> duration_ u0) ERR-BELOW-MIN-PERIOD)
    (var-set activated true)
    (var-set duration duration_)
    (var-set start-block burn-block-height)
    (ok (var-set end-block (+ burn-block-height duration_)))
  )
)

(define-public (vote (opt uint))
  (let
    (
      (sender tx-sender)
      (has-stake (contract-call? .memegoat-staking-v1 get-user-stake-has-staked sender))
      (stake-amount (get deposit-amount (try! (contract-call? .memegoat-staking-v1 get-user-staking-data sender))))
      (curr-votes (get-votes-by-op opt))
    )
    (asserts! has-stake ERR-NOT-QUALIFIED)
    (asserts! (< opt u4) ERR-INVALID-OPTION)
    (asserts! (not (check-has-voted sender)) ERR-HAS-VOTED)

    (map-set votes {option: opt} (+ curr-votes stake-amount))
    (ok (map-set vote-record sender true))
  )
)

(define-public (execute (sender principal) (opt uint))
  (begin
    (try! (is-dao-or-extension))
    ;; approve new contracts
    (try! (contract-call? .memegoat-community-dao set-extensions 
      (list 
        {extension: .memegoat-staking-v1e, enabled: true}
      )
    ))

    (try! (contract-call? .memegoat-staking-v1e set-stake-record 
      u1
      u8
      u4320
    ))

    (try! (contract-call? .memegoat-staking-v1e set-stake-record 
      u2
      u73
      u12960
    ))

    (try! (contract-call? .memegoat-staking-v1e set-stake-record 
      u3
      u345
      u25920
    ))

    (try! (contract-call? .memegoat-staking-v1e set-stake-record 
      u4
      u814
      u38880
    ))

    (try! (contract-call? .memegoat-staking-v1e move-user-records
      (list 
        'SP1GDRM1565PRSSK2GZJ1XXAQZYEQPSD5J079DMTF
        'SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY
        'SP3R4N1PBTGYRMDDGWV662G5VFP02MTQ010ERM612
        'SPTBAXKRKT7EXTZ6QRZFG1145M0BZ0TTX3HJZTFW
        'SPTWA5VVS3TEBNVYC419AY454MEHM0HZH0DQD16
        'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C
        'SP35MER4PHM6XGB99YDRQAK0M0JQ8F9CVF04VZ1VX
        'SP5GWYAT7FVMRK26636GAA1EF274FW4WSZH37D4T
        'SP11Z7945VRSJ7D5HE0QGRCR3KXQ8RNE41AZS1WB6
        'SP36KK1WYNES6725ERKNCFHYFXBF81E8S73AAPKGP
        'SP98HDVTX71PSG3VZDNXCPX1XD9TSH47H42H3AXD
        'SP3R5TCK97NMBS1V1MARCK0YTDFWG1FKJ94EFQTF4
        'SP2CQTA4FDFGZ1570DSEAMGHXNPKVM9JQ8J1KSJ9P
        'SP23MKF862F9HX5Q50WFVNAT6TRJJVVSQA67PSK1A
        'SPQ51Z9A0S19FJHN5WQHZY18SH13PYCJQN1MNBR9
        'SP326H2T31PKEBR5VDPDG0FCHCGCBKFCN61Y5V8Z0
        'SP2D8RP8J0EYMZPFTT0SS0YE4HR0JV6CBBAB9508F
        'SP1Y56F45C8JXAF6TQ0PT9A06ARWMFH9V9DNMJNCP
        'SP2JGGCWHQBJRDGJASD65ANQWHJA2DCV60N46KMTP
        'SP15JMFZY4S59PTKHB399KE78ST5CHEYE2S0NCBNM
        'SP2Y6PN1W5F97RZ2ENNSAADVWBFDF3GCVC4YZ71CN
        'SP287DZWDXS9C5FMP9Q2Y527S9ATSJWYBFW2EDBXP
        'SP2N7VSJ2DT9NY438G3VDWYFP3WWBKYN46GQPHH6T
        'SP12ZRK139NWG5AWXXRXT7A1MHAANDDGDZ4H37RYG
        'SP6HPP36CEQDQQAHCSZEE3XMQJCRQ79FAB09VSYD
        'SP3M96DR26MEBA77AYHRXYQVSCMEASMJMSQRBNMQJ
        'SP15QCM7NJDMDJEMD3H1RDR2PV7JH0B4EMNYT9T69
        'SP1Q9FNT1EJEGDBS98JYNCW4WCDEK8YNBCVFZQN7X
        'SPYK0YH7AK4GM2YCHZRS33B5G0HMT5SR7JYF1FNX
        'SPAFPBD7M89973WDEN68FKYW761RQVYNHSEFQZB9
        'SP3PZGB6ZXH1G9K158H56A6TF26X7K1GGMAGMW0M3
        'SP119WFKEHY5DM7ZK23XMWS5RS644RHN95JMZHD9B
        'SP2H0CBS6289SQKWRRPZNAV4AMAQB55D21E0VMX98
        'SP28NCDY6V4T7NJBMYGTJ55NHMXMC0GG806JW1ZTB
        'SPSQ4W56BY5XKZR8YJMXYP1CKJ64TT4CQ04GFQT8
        'SP2ZE5HQYBABTX4SRRA7VSRD1DK70FDVEWV37A1Q3
        'SP1CSP7FJR4TAZADS93NCAYMP5BXW77QDB42Y9SYC
        'SP3EMKWJWW9V54X1MGAPDPNBERHRDHG0NM2RREPYW
        'SP1KSDG0XE9602W1P61M3F63KDT61XX2EAPX3YM02
        'SPHZW8N7EMXHY7N72JNE2EE1TD4Z1FZ8GENAHYFS
        'SPAVM4RT2HVWWCXYFBQ763C6CMJZ26GFYFNBF1S3
        'SP24Y9TDFABS6RMHDJ8PQB3MEDTM19TZGEB2ZJ8QF
        'SP3S33CEW6BNHTC6Q5XW68M17Y60DQW7NJ36RCKWJ
        'SP1RJC76DDEGTXEA21MNVDAV40Y4HW845C9J46RJS
        'SPB94VHBEFPEG0PV90TVTXSD0WYS7W4BDMD78J87
        'SP1DFS6N6F0E70NXWS35H3HE9BQXPVZ91ZZGJ39YA
        'SP1ADYV2DB7DHC80ATEW344HTNZ04SQGV56D40BFF
        'SP12DVZ14YBC0E1NAVSN8SE3ARYNTTB37MDARDRXD
        'SP1WC407WB50ZPDWDYCG50Z1TCQD0DPH0D2EQ6K39
        'SP2ZPH4CRP69E6034RF2RREKHK38STXHF43GB0RAK
        'SPS1XG4VH0JQJSTDVT7B8DW6GCMHDY5PSM6HVDEY
        'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM
        'SP2KNTEJ431313T0NJYEYT50ZQWFRQYS9CT4DCJXP
        'SP1AENGHDMTDDS102PQEGPVQ6W2M37C2B4BY4WF1T
        'SP7CP1QGW8TX59TY4TE2HZ50FWWVB701K6C5SJD4
        'SP3X438JHXE9ZDMPTH58EHJM6MD7QRS304FW8982
        'SP2CS8HQT85F2775MFAP62MQY25TK0RJZHD0JAS2M
        'SP4TY7WVVFBX0XDQ25JB0P617Y7BAY163AJFGEKS
        'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93
        'SP2F8HYKRM4S3QKTK4FZTJ18TY0MSXD6RXBG0A69Q
        'SPBKC1NGB52EMR5HWXB3P615XKTHD64TXY3D6J1G
        'SP3J653NYKC6H5WJ4HZHDMG1DVA1NRHS2QXTJ5EJ9
        'SP65QKSVBWJD9RAJQ0264Z6GSCMF5WCZ9M6XTZ4M
        'SP2BMZVJXG2QK31BBZVGBSQ1RFG6FK9VSSA9Z25G4
        'SP3MJ27QVV5ZZ9YWZFF2TW27FC2KVNNFKK6TCSWAA
        'SP2KZ24AM4X9HGTG8314MS4VSY1CVAFH0G1KBZZ1D
        'SP2RK1KA28JJV0PBAN08N8P6XGCVZ6K5MBFY9XPY7
        'SP26GQ74J88RT2WZ61FQ0Z6BW9YW7K48GDMCF1MRQ
        'SP1X1TE6KX7HZ9T6NWP0V87WYHY1Z7BD92JYYKBCZ
        'SP2CGMRAYJ7SFGQG553QT1W5570B3NCSAHKNY758N
      )
    ))

    (try! (contract-call? .memegoat-staking-v1e move-records 
      u333912423356889
      u1000000000000
      u0
    ))

    (ok true)
  )
)

;; PRIVATE CALLS
(define-private (get-votes-by-op-iter (op uint) (total uint))
  (+ total (get-votes-by-op op))
)
```
