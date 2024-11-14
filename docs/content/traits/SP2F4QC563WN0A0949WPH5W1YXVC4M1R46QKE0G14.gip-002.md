---
title: "Trait gip-002"
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
    (asserts! (var-get activated) ERR-NOT-ACTIVATED)
    (asserts! has-stake ERR-NOT-QUALIFIED)
    (asserts! (< opt u4) ERR-INVALID-OPTION)
    (asserts! (check-has-voted sender) ERR-HAS-VOTED)

    (map-set votes {option: opt} (+ curr-votes stake-amount))
    (ok (map-set vote-record sender true))
  )
)

(define-public (execute (sender principal) (opt uint))
  (begin
    (try! (is-dao-or-extension))

    (try! (contract-call? .memegoat-community-dao set-extensions 
      (list 
        {extension: .memegoat-stake-pools, enabled: true}
        {extension: .memegoat-community-pools, enabled: false}
      )
    ))

    ;; MOVE POOL DATA
    (try! (contract-call? .memegoat-stake-pools move-pools 
      (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18)
    ))

    (try! (contract-call? .memegoat-stake-pools move-user-records
      u3 
      (list 
        {user: 'SP2JF2SWRRYAQKZ9A130RW02EWHEH78YNTWBACXD4, old-id: u3}
        {user: 'SP301D8E6XYWA05DX8F8HSD73NT2XB376R47G0STV, old-id: u3}
        {user: 'SPSQ4W56BY5XKZR8YJMXYP1CKJ64TT4CQ04GFQT8, old-id: u3}
        {user: 'SP2CYW85YW03WX0XMSFGMJ3HZQ30X8NKFA6TXVNRX, old-id: u3}
        {user: 'SP23MKF862F9HX5Q50WFVNAT6TRJJVVSQA67PSK1A, old-id: u3}
        {user: 'SPNQPRN7Z49HNMW4T5EF952ZR7FX9FV5WNSBHXTY, old-id: u3}
        {user: 'SPC6WE6W9S7Y1S4XVPENC5G9C4SZQWH9TVTBJEHZ, old-id: u3}
      )
    ))

    (try! (contract-call? .memegoat-stake-pools move-user-records
      u4
      (list 
        {user: 'SP99B9SNEY20XZ5PDCR30VC520QPWCEAAVHHEC2W, old-id: u4}
        {user: 'SP98HDVTX71PSG3VZDNXCPX1XD9TSH47H42H3AXD, old-id: u4}
        {user: 'SP2XHGP0P45WDJ1XZPZZT2Q0MV3WBAP7SN7ZWCGN5, old-id: u4}
        {user: 'SP30SW3H0TEAQW5YMJYAEQW20GK1JZNYCV1M3XPD2, old-id: u4}
        {user: 'SPH1ZAHN998PFH9A2CBNQ5EM3HKXG08FA0CKF4MB, old-id: u4}
        {user: 'SP1KSDG0XE9602W1P61M3F63KDT61XX2EAPX3YM02, old-id: u4}
        {user: 'SPTWA5VVS3TEBNVYC419AY454MEHM0HZH0DQD16, old-id: u4}
        {user: 'SP3GDZ84WVJ0XSXWAC0W0XMSZCHJSQTBTC7JCB10A, old-id: u4}
        {user: 'SP2JGGCWHQBJRDGJASD65ANQWHJA2DCV60N46KMTP, old-id: u4}
        {user: 'SP3B93RAWESWW8M5ZP8P71SXNMJEG6T4DZG1HQ1BK, old-id: u4}
        {user: 'SPNQPRN7Z49HNMW4T5EF952ZR7FX9FV5WNSBHXTY, old-id: u4}
        {user: 'SP2T5ZS0WA4BP31E3CTK5GDAY3VKJ1JXSGHDQZD66, old-id: u4}
        {user: 'SP3DYP99Z4RPX11G384JR7GAN9RQD6WWKGKW9TC4E, old-id: u4}
        {user: 'SP26STSDW5X5YY5N5DRPR4VDJY86FPMB4NZ0RNBW, old-id: u4}
        {user: 'SP2JF2SWRRYAQKZ9A130RW02EWHEH78YNTWBACXD4, old-id: u4}
        {user: 'SP3R5TCK97NMBS1V1MARCK0YTDFWG1FKJ94EFQTF4, old-id: u4}
        {user: 'SP1HGP6E8ZHZBRA91NME5MPCC1ZQA6VTREQD723GP, old-id: u4}
        {user: 'SP2BWEQA5B8P0TXBP3AR00Z8QDKDPBPGSV6BP8KB7, old-id: u4}
        {user: 'SP2MDEE7BMXWTNST6PKE8MGP2EWD6412ZNPTYMQ5S, old-id: u4}
        {user: 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C, old-id: u4}
        {user: 'SP27Z14XMV6GJX8DKKV531TRB9WNPDAEG6GCK8PHZ, old-id: u4}
        {user: 'SP1Y4JRP20R2TBX40QPH6M5DY9STC5BXEBRYB054C, old-id: u4}
        {user: 'SP1ETDE9Q8SMA5BAZNHX5TRZ6Y4QQKB26VRFRBB4Z, old-id: u4}
        {user: 'SP3MJ27QVV5ZZ9YWZFF2TW27FC2KVNNFKK6TCSWAA, old-id: u4}
        {user: 'SP1EEASZG7WCDQ8SFX9X24PG86DPFSM6VEXXH487W, old-id: u4}
        {user: 'SP12MDYKG67C4VEXBEEMPD2HWNAXTZ60NZV2HWWAX, old-id: u4}
        {user: 'SP1AWVYG9Y93EAR9KKQS6EQ2ZR6HF2QWZHCW3S36N, old-id: u4}
        {user: 'SPVHHRF0SWTFZHGWJSXC0QXRFH45CH56EMSB2PK9, old-id: u4}
        {user: 'SP3XFKGYTD6WD97DHHKVWS6HCJ7ZX08DMVP2R7FAC, old-id: u4}
        {user: 'SP36KK1WYNES6725ERKNCFHYFXBF81E8S73AAPKGP, old-id: u4}
        {user: 'SP2J1EX6Y8ZANKZ68ZK3FCPNDDRHT447C1RY7FZTW, old-id: u4}
        {user: 'SP3S33CEW6BNHTC6Q5XW68M17Y60DQW7NJ36RCKWJ, old-id: u4}
        {user: 'SP1KC8SY7KD6G55WVVC24GE4PH5NRNHSZK45ND0CH, old-id: u4}
        {user: 'SPPTQ6GQ4ARKZN6H0WB8K8Z7555NMH2DKT93Z6K0, old-id: u4}
        {user: 'SP24Y9TDFABS6RMHDJ8PQB3MEDTM19TZGEB2ZJ8QF, old-id: u4}
        {user: 'SP1AENGHDMTDDS102PQEGPVQ6W2M37C2B4BY4WF1T, old-id: u4}
      )
    ))

    (try! (contract-call? .memegoat-stake-pools move-user-records
      u5
      (list 
        {user: 'SP326H2T31PKEBR5VDPDG0FCHCGCBKFCN61Y5V8Z0, old-id: u5}
        {user: 'SP2T5ZS0WA4BP31E3CTK5GDAY3VKJ1JXSGHDQZD66, old-id: u5}
        {user: 'SP3DYP99Z4RPX11G384JR7GAN9RQD6WWKGKW9TC4E, old-id: u5}
        {user: 'SP99B9SNEY20XZ5PDCR30VC520QPWCEAAVHHEC2W, old-id: u5}
        {user: 'SP1DZ6CVX4TYYNRV39WBPSH18EMA5C6S6TZHBZT75, old-id: u5}
        {user: 'SPTBAXKRKT7EXTZ6QRZFG1145M0BZ0TTX3HJZTFW, old-id: u5}
        {user: 'SP9469CHQ3SZB16XX7YNM0QFEQCD3WA3D85CP6C0, old-id: u5}
        {user: 'SP3B93RAWESWW8M5ZP8P71SXNMJEG6T4DZG1HQ1BK, old-id: u5}
        {user: 'SP301D8E6XYWA05DX8F8HSD73NT2XB376R47G0STV, old-id: u5}
        {user: 'SP2JF2SWRRYAQKZ9A130RW02EWHEH78YNTWBACXD4, old-id: u5}
        {user: 'SP2BWEQA5B8P0TXBP3AR00Z8QDKDPBPGSV6BP8KB7, old-id: u5}
        {user: 'SP30DS0EZEE8H0DVSTAP5W2HPG70VEYXM6C1FRAZ6, old-id: u5}
        {user: 'SPNQPRN7Z49HNMW4T5EF952ZR7FX9FV5WNSBHXTY, old-id: u5}
        {user: 'SP2MDEE7BMXWTNST6PKE8MGP2EWD6412ZNPTYMQ5S, old-id: u5}
        {user: 'SP372RK3G7A7WNYH52AEYQ63B1XPRVPNYWCGHXFX6, old-id: u5}
        {user: 'SP1Y4JRP20R2TBX40QPH6M5DY9STC5BXEBRYB054C, old-id: u5}
        {user: 'SP3R5TCK97NMBS1V1MARCK0YTDFWG1FKJ94EFQTF4, old-id: u5}
        {user: 'SP36KK1WYNES6725ERKNCFHYFXBF81E8S73AAPKGP, old-id: u5}
        {user: 'SP6HPP36CEQDQQAHCSZEE3XMQJCRQ79FAB09VSYD, old-id: u5}
        {user: 'SP1ETDE9Q8SMA5BAZNHX5TRZ6Y4QQKB26VRFRBB4Z, old-id: u5}
        {user: 'SP2J1EX6Y8ZANKZ68ZK3FCPNDDRHT447C1RY7FZTW, old-id: u5}
        {user: 'SP12MDYKG67C4VEXBEEMPD2HWNAXTZ60NZV2HWWAX, old-id: u5}
        {user: 'SPC6WE6W9S7Y1S4XVPENC5G9C4SZQWH9TVTBJEHZ, old-id: u5}
        {user: 'SP1XBRF5Y408KCVCWNMEAB6NQZ6NDF1JWBJQKMVZJ, old-id: u5}
        {user: 'SP3XFKGYTD6WD97DHHKVWS6HCJ7ZX08DMVP2R7FAC, old-id: u5}
        {user: 'SP24Y9TDFABS6RMHDJ8PQB3MEDTM19TZGEB2ZJ8QF, old-id: u5}
        {user: 'SP3MJ27QVV5ZZ9YWZFF2TW27FC2KVNNFKK6TCSWAA, old-id: u5}
        {user: 'SP30Y7Z13N2H2RW0NAQNVZT6261QA6JJ7KR9578BE, old-id: u5}
        {user: 'SPSQ4W56BY5XKZR8YJMXYP1CKJ64TT4CQ04GFQT8, old-id: u5}
        {user: 'SP2F4QC563WN0A0949WPH5W1YXVC4M1R46QKE0G14, old-id: u5}
        {user: 'SP3S33CEW6BNHTC6Q5XW68M17Y60DQW7NJ36RCKWJ, old-id: u5}
        {user: 'SP23MKF862F9HX5Q50WFVNAT6TRJJVVSQA67PSK1A, old-id: u5}
      )
    ))

    (try! (contract-call? .memegoat-stake-pools move-user-records
      u6
      (list 
        {user: 'SP2T5ZS0WA4BP31E3CTK5GDAY3VKJ1JXSGHDQZD66, old-id: u6}
        {user: 'SP301D8E6XYWA05DX8F8HSD73NT2XB376R47G0STV, old-id: u6}
        {user: 'SPTBAXKRKT7EXTZ6QRZFG1145M0BZ0TTX3HJZTFW, old-id: u6}
        {user: 'SP3S33CEW6BNHTC6Q5XW68M17Y60DQW7NJ36RCKWJ, old-id: u6}
        {user: 'SP2J1EX6Y8ZANKZ68ZK3FCPNDDRHT447C1RY7FZTW, old-id: u6}
        {user: 'SPAQ795G2DT2XQWBA295KYYQA6TKBM2K9JC2HWWJ, old-id: u6}
        {user: 'SP1KC8SY7KD6G55WVVC24GE4PH5NRNHSZK45ND0CH, old-id: u6}
        {user: 'SP2XHGP0P45WDJ1XZPZZT2Q0MV3WBAP7SN7ZWCGN5, old-id: u6}
        {user: 'SP3PMHDXDDDJ3PXEGK90E8MXJDDHP90FZCM99MG0G, old-id: u6}
        {user: 'SP26STSDW5X5YY5N5DRPR4VDJY86FPMB4NZ0RNBW, old-id: u6}
        {user: 'SP32S3A9PN4GEJ2NAP2WFQHAZCC2XPNTN38VG7078, old-id: u6}
        {user: 'SP30GN0876VKPZD1T8FY5FWQB18G8W6SM5JDCC2GG, old-id: u6}
        {user: 'SPTWA5VVS3TEBNVYC419AY454MEHM0HZH0DQD16, old-id: u6}
        {user: 'SP2P0QX0C70S8SJ8VYP530JFMNPHNVJBQY3KEZ9ZC, old-id: u6}
        {user: 'SPSQ4W56BY5XKZR8YJMXYP1CKJ64TT4CQ04GFQT8, old-id: u6}
        {user: 'SP3M5KVNF7RV8F0H2XSZ1TRSWFVTQ1FJQ89X4DJ72, old-id: u6}
        {user: 'SP1WC407WB50ZPDWDYCG50Z1TCQD0DPH0D2EQ6K39, old-id: u6}
        {user: 'SP753DM4YTCETNZC2AV9BF26XW61SFD8MDTQDE13, old-id: u6}
        {user: 'SP1ETDE9Q8SMA5BAZNHX5TRZ6Y4QQKB26VRFRBB4Z, old-id: u6}
        {user: 'SP12MDYKG67C4VEXBEEMPD2HWNAXTZ60NZV2HWWAX, old-id: u6}
        {user: 'SP3PMM5Z7J3G2TN05T5RTYVCSHFFQPVH4N5A78GPC, old-id: u6}
        {user: 'SP1XBRF5Y408KCVCWNMEAB6NQZ6NDF1JWBJQKMVZJ, old-id: u6}
        {user: 'SP28T024V6W0768F0D0RJSNSGH104PGEQM36CJXW2, old-id: u6}
        {user: 'SP2QWSZETA3T9RYSQ9QFRZGWWY62TSFJEZZDXES7G, old-id: u6}
        {user: 'SP3XFKGYTD6WD97DHHKVWS6HCJ7ZX08DMVP2R7FAC, old-id: u6}
        {user: 'SP2EC3HNZZ8V7J9FC52VMRX3TQ3ASAY57K0FPAMEN, old-id: u6}
        {user: 'SP1EHG5M8H61ACV1JYRD9Z9TC8BKSW519YZ4WE5Z4, old-id: u6}
        {user: 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C, old-id: u6}
        {user: 'SPXNQ1SMYST5PQ88XJ3DBF2J20CM7FSVZ2M7ETRX, old-id: u6}
        {user: 'SP2FZMQQT0FG9GNFVT04YA5QCG7NE4ECKANJ2QNVZ, old-id: u6}
        {user: 'SPC2ST1E89RZTN3YJHVDK77EGSJN323Q2YVQ3M62, old-id: u6}
        {user: 'SP8SHCQXZJZN6TS58MTX6M4PBN5PQ110F0PAEG9T, old-id: u6}
        {user: 'SP2MA89CBESAEKC0KNZS1JQQ2M19JX44J7V8D9BKG, old-id: u6}
        {user: 'SP1CSK89KJ79A399MVQ19B2EXVTDQSMB32S2J89NT, old-id: u6}
        {user: 'SPHZW8N7EMXHY7N72JNE2EE1TD4Z1FZ8GENAHYFS, old-id: u6}
        {user: 'SP3KVRE3RDYYSJ3JDGXKA0K15CC4JEA2ZGX4TJ5EC, old-id: u6}
        {user: 'SP2SFZX1WJSKT1GA2STDT6E5NWDX44GW4BB8DW4DJ, old-id: u6}
        {user: 'SP363NCTT1W21JC3JT3417XV8K1XJQNQZY1MX4FH, old-id: u6}
        {user: 'SP38K9RHDW3KXWCB4W2CQX9BMKKKW6P87CPGM2A4J, old-id: u6}
        {user: 'SP16HZNCDBVR0TTJKFW7AF0AY8W9E853M8B49Z9JM, old-id: u6}
      )
    ))

    (try! (contract-call? .memegoat-stake-pools move-user-records
      u7
      (list 
        {user: 'SP2SNQHT55ZM0TBF7DD0TA39XM652QZ97E3CXN2SJ, old-id: u7}
        {user: 'SP9469CHQ3SZB16XX7YNM0QFEQCD3WA3D85CP6C0, old-id: u7}
        {user: 'SP372B3QPFAC65VY7R68GK4Z8WNRZ74NRWGWM9W4F, old-id: u7}
        {user: 'SP26QMFEDRBGVNMANH5XJ7KX0NG9QDP2KAJVBGZD0, old-id: u7}
        {user: 'SP3NEWV1EPV1Y9KKSGDSC63CFE5ASA9QHAHWGTPS6, old-id: u7}
        {user: 'SP2BRGBD7RR0T5TDSKBD4AWVZND07P5T8NRYFA7NJ, old-id: u7}
        {user: 'SP1H45JS07GWQWMT57JE20X17AQCNVYAS7NHW2HVR, old-id: u7}
        {user: 'SP3R5TCK97NMBS1V1MARCK0YTDFWG1FKJ94EFQTF4, old-id: u7}
        {user: 'SP301D8E6XYWA05DX8F8HSD73NT2XB376R47G0STV, old-id: u7}
        {user: 'SP3ZM63ZJENSXSZZYQ632TWDJC3K526DS8N5BHHFP, old-id: u7}
        {user: 'SP27QJ2NDKXET6NH3BW5KC7EKKJK0JF66MCTS0DN6, old-id: u7}
        {user: 'SP1Y4JRP20R2TBX40QPH6M5DY9STC5BXEBRYB054C, old-id: u7}
        {user: 'SP1EHG5M8H61ACV1JYRD9Z9TC8BKSW519YZ4WE5Z4, old-id: u7}
        {user: 'SP2QWSZETA3T9RYSQ9QFRZGWWY62TSFJEZZDXES7G, old-id: u7}
        {user: 'SP2P0QX0C70S8SJ8VYP530JFMNPHNVJBQY3KEZ9ZC, old-id: u7}
        {user: 'SPTWA5VVS3TEBNVYC419AY454MEHM0HZH0DQD16, old-id: u7}
        {user: 'SP1ETDE9Q8SMA5BAZNHX5TRZ6Y4QQKB26VRFRBB4Z, old-id: u7}
        {user: 'SPAQ795G2DT2XQWBA295KYYQA6TKBM2K9JC2HWWJ, old-id: u7}
        {user: 'SP16HZNCDBVR0TTJKFW7AF0AY8W9E853M8B49Z9JM, old-id: u7}
        {user: 'SP1XBRF5Y408KCVCWNMEAB6NQZ6NDF1JWBJQKMVZJ, old-id: u7}
        {user: 'SP12MDYKG67C4VEXBEEMPD2HWNAXTZ60NZV2HWWAX, old-id: u7}
        {user: 'SP1G18KGVMP2RF5S2387DBC4VRZGK2T9ETMMVT7BB, old-id: u7}
        {user: 'SP2MA89CBESAEKC0KNZS1JQQ2M19JX44J7V8D9BKG, old-id: u7}
        {user: 'SP36KK1WYNES6725ERKNCFHYFXBF81E8S73AAPKGP, old-id: u7}
        {user: 'SP3PMM5Z7J3G2TN05T5RTYVCSHFFQPVH4N5A78GPC, old-id: u7}
        {user: 'SP3XFKGYTD6WD97DHHKVWS6HCJ7ZX08DMVP2R7FAC, old-id: u7}
        {user: 'SP1CSK89KJ79A399MVQ19B2EXVTDQSMB32S2J89NT, old-id: u7}
        {user: 'SP2HRBN4RHATYCQYH7CY25B82HBS2B3GSXANPJQKX, old-id: u7}
        {user: 'SP20W8F3AY6KY8DKYZ24RBWRZZ9PVS64J9Y9A1SY9, old-id: u7}
        {user: 'SP29AR7Z3C3C4GQ0K9S03H4S4ACE27E7AK94JP376, old-id: u7}
        {user: 'SP1HGP6E8ZHZBRA91NME5MPCC1ZQA6VTREQD723GP, old-id: u7}
        {user: 'SP2SFZX1WJSKT1GA2STDT6E5NWDX44GW4BB8DW4DJ, old-id: u7}
        {user: 'SPKZT8CFR5DNTKDR2BCWQA9WR32GP3GT0CPV8V24, old-id: u7}
        {user: 'SP3S33CEW6BNHTC6Q5XW68M17Y60DQW7NJ36RCKWJ, old-id: u7}
        {user: 'SP2Z1GBP0RD8NZ2596V37KM80CJCQ80SH1YTERERY, old-id: u7}
      )
    ))
    (try! (contract-call? .memegoat-stake-pools move-user-records
      u8
      (list 
        {user: 'SP2SNQHT55ZM0TBF7DD0TA39XM652QZ97E3CXN2SJ, old-id: u8}
        {user: 'SP9469CHQ3SZB16XX7YNM0QFEQCD3WA3D85CP6C0, old-id: u8}
        {user: 'SPH1ZAHN998PFH9A2CBNQ5EM3HKXG08FA0CKF4MB, old-id: u8}
        {user: 'SP2T5ZS0WA4BP31E3CTK5GDAY3VKJ1JXSGHDQZD66, old-id: u8}
        {user: 'SP326H2T31PKEBR5VDPDG0FCHCGCBKFCN61Y5V8Z0, old-id: u8}
        {user: 'SP3DYP99Z4RPX11G384JR7GAN9RQD6WWKGKW9TC4E, old-id: u8}
        {user: 'SP3XFKGYTD6WD97DHHKVWS6HCJ7ZX08DMVP2R7FAC, old-id: u8}
        {user: 'SP12MDYKG67C4VEXBEEMPD2HWNAXTZ60NZV2HWWAX, old-id: u8}
        {user: 'SP37S6ASV5A45JJ9MQWD1GG53W0CYMKXQZ6D9BR2P, old-id: u8}
        {user: 'SP3ZKZJARSF2Q7Z2MX5Z3KRGCFKZKWW7TGHE3MQY2, old-id: u8}
        {user: 'SP3S33CEW6BNHTC6Q5XW68M17Y60DQW7NJ36RCKWJ, old-id: u8}
        {user: 'SP301D8E6XYWA05DX8F8HSD73NT2XB376R47G0STV, old-id: u8}
        {user: 'SP2J1EX6Y8ZANKZ68ZK3FCPNDDRHT447C1RY7FZTW, old-id: u8}
        {user: 'SPTWA5VVS3TEBNVYC419AY454MEHM0HZH0DQD16, old-id: u8}
        {user: 'SP1HGP6E8ZHZBRA91NME5MPCC1ZQA6VTREQD723GP, old-id: u8}
        {user: 'SP3R5TCK97NMBS1V1MARCK0YTDFWG1FKJ94EFQTF4, old-id: u8}
        {user: 'SPPTQ6GQ4ARKZN6H0WB8K8Z7555NMH2DKT93Z6K0, old-id: u8}
        {user: 'SP2FZMQQT0FG9GNFVT04YA5QCG7NE4ECKANJ2QNVZ, old-id: u8}
        {user: 'SP3MJ27QVV5ZZ9YWZFF2TW27FC2KVNNFKK6TCSWAA, old-id: u8}
        {user: 'SP2VQCMVPWE5KK3K0YP8XAP8Z84VNTWA9FJ1ZHJSZ, old-id: u8}
        {user: 'SP25DP4A9QDM42KC40EXTYQPMQCT1P0R5243GWEGS, old-id: u8}
        {user: 'SP2ZE5HQYBABTX4SRRA7VSRD1DK70FDVEWV37A1Q3, old-id: u8}
        {user: 'SP2CYW85YW03WX0XMSFGMJ3HZQ30X8NKFA6TXVNRX, old-id: u8}
        {user: 'SP2HSR382SJCAX4PRPV6CKH2EF81KC78NFSYBM8Z6, old-id: u8}
        {user: 'SPMSK5CMKVS2Z0F817CCJYSXM6F7R7EQRMWBHSDH, old-id: u8}
        {user: 'SP31DFRJ0QZ07AK7JHH5P47KNRETMV0W564Y8VB2C, old-id: u8}
        {user: 'SP3NEWV1EPV1Y9KKSGDSC63CFE5ASA9QHAHWGTPS6, old-id: u8}
        {user: 'SP24GR653MKKY5K68JBMWCP9ZS3P502MTQ4Y3DE27, old-id: u8}
        {user: 'SP1EHG5M8H61ACV1JYRD9Z9TC8BKSW519YZ4WE5Z4, old-id: u8}
        {user: 'SP2P0QX0C70S8SJ8VYP530JFMNPHNVJBQY3KEZ9ZC, old-id: u8}
        {user: 'SP1Y4JRP20R2TBX40QPH6M5DY9STC5BXEBRYB054C, old-id: u8}
        {user: 'SP1WC407WB50ZPDWDYCG50Z1TCQD0DPH0D2EQ6K39, old-id: u8}
        {user: 'SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY, old-id: u8}
        {user: 'SP1CSK89KJ79A399MVQ19B2EXVTDQSMB32S2J89NT, old-id: u8}
        {user: 'SP3PMM5Z7J3G2TN05T5RTYVCSHFFQPVH4N5A78GPC, old-id: u8}
        {user: 'SP2HRBN4RHATYCQYH7CY25B82HBS2B3GSXANPJQKX, old-id: u8}
        {user: 'SPAFPBD7M89973WDEN68FKYW761RQVYNHSEFQZB9, old-id: u8}
        {user: 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C, old-id: u8}
        {user: 'SP2F4QC563WN0A0949WPH5W1YXVC4M1R46QKE0G14, old-id: u8}
        {user: 'SP2EC3HNZZ8V7J9FC52VMRX3TQ3ASAY57K0FPAMEN, old-id: u8}
        {user: 'SP8SHCQXZJZN6TS58MTX6M4PBN5PQ110F0PAEG9T, old-id: u8}
        {user: 'SPC2ST1E89RZTN3YJHVDK77EGSJN323Q2YVQ3M62, old-id: u8}
        {user: 'SP1KC8SY7KD6G55WVVC24GE4PH5NRNHSZK45ND0CH, old-id: u8}
        {user: 'SP82JBHR7F1CVKZQC52Q1FYG9KA83VV9W1N1RWGE, old-id: u8}
        {user: 'SP3EMKWJWW9V54X1MGAPDPNBERHRDHG0NM2RREPYW, old-id: u8}
        {user: 'SP2SFZX1WJSKT1GA2STDT6E5NWDX44GW4BB8DW4DJ, old-id: u8}
        {user: 'SP2KZ24AM4X9HGTG8314MS4VSY1CVAFH0G1KBZZ1D, old-id: u8}
      )
    ))

    (try! (contract-call? .memegoat-stake-pools move-user-records
      u11
      (list 
        {user: 'SP99B9SNEY20XZ5PDCR30VC520QPWCEAAVHHEC2W, old-id: u11}
        {user: 'SPTBAXKRKT7EXTZ6QRZFG1145M0BZ0TTX3HJZTFW, old-id: u11}
        {user: 'SP1FHC2XXJW3CQFNFZX60633E5WPWST4DBW8JFP66, old-id: u11}
        {user: 'SPTWA5VVS3TEBNVYC419AY454MEHM0HZH0DQD16, old-id: u11}
        {user: 'SP2T5ZS0WA4BP31E3CTK5GDAY3VKJ1JXSGHDQZD66, old-id: u11}
        {user: 'SP1DZ6CVX4TYYNRV39WBPSH18EMA5C6S6TZHBZT75, old-id: u11}
        {user: 'SP3NEWV1EPV1Y9KKSGDSC63CFE5ASA9QHAHWGTPS6, old-id: u11}
        {user: 'SPVHHRF0SWTFZHGWJSXC0QXRFH45CH56EMSB2PK9, old-id: u11}
        {user: 'SP2TCFBF793T3PZPMCKQ3478ZS9JR0GMN5WRKX94Z, old-id: u11}
        {user: 'SP2GE29FQHYCF2W3R4CTG7TNK6W15ZC20FDWQB4J4, old-id: u11}
        {user: 'SP2J1EX6Y8ZANKZ68ZK3FCPNDDRHT447C1RY7FZTW, old-id: u11}
        {user: 'SP12DVZ14YBC0E1NAVSN8SE3ARYNTTB37MDARDRXD, old-id: u11}
        {user: 'SP11EBWRDRHWHWBM8XMNTD45VM5Z41XM29TBV7ECD, old-id: u11}
      )
    ))

    (try! (contract-call? .memegoat-stake-pools move-user-records
      u12
      (list 
        {user: 'SP9469CHQ3SZB16XX7YNM0QFEQCD3WA3D85CP6C0, old-id: u12}
        {user: 'SP1DZ6CVX4TYYNRV39WBPSH18EMA5C6S6TZHBZT75, old-id: u12}
        {user: 'SP2T5ZS0WA4BP31E3CTK5GDAY3VKJ1JXSGHDQZD66, old-id: u12}
        {user: 'SP1HGP6E8ZHZBRA91NME5MPCC1ZQA6VTREQD723GP, old-id: u12}
        {user: 'SP2GYXR37WGDP11A2CT9T4HBXDPS8SA6YTHQ8A2NH, old-id: u12}
        {user: 'SPTWA5VVS3TEBNVYC419AY454MEHM0HZH0DQD16, old-id: u12}
        {user: 'SP16HZNCDBVR0TTJKFW7AF0AY8W9E853M8B49Z9JM, old-id: u12}
        {user: 'SP301D8E6XYWA05DX8F8HSD73NT2XB376R47G0STV, old-id: u12}
        {user: 'SP3MJ27QVV5ZZ9YWZFF2TW27FC2KVNNFKK6TCSWAA, old-id: u12}
        {user: 'SP1FHC2XXJW3CQFNFZX60633E5WPWST4DBW8JFP66, old-id: u12}
        {user: 'SPPTQ6GQ4ARKZN6H0WB8K8Z7555NMH2DKT93Z6K0, old-id: u12}
        {user: 'SP1J0AJW43QK3SX82ECZ7407YN0Z7EZZPD9JN5ZPY, old-id: u12}
        {user: 'SP99B9SNEY20XZ5PDCR30VC520QPWCEAAVHHEC2W, old-id: u12}
      )
    ))

    (try! (contract-call? .memegoat-stake-pools move-user-records
      u13
      (list 
        {user: 'SP9469CHQ3SZB16XX7YNM0QFEQCD3WA3D85CP6C0, old-id: u13}
        {user: 'SP1Q9FNT1EJEGDBS98JYNCW4WCDEK8YNBCVFZQN7X, old-id: u13}
        {user: 'SP11EBWRDRHWHWBM8XMNTD45VM5Z41XM29TBV7ECD, old-id: u13}
        {user: 'SPVHHRF0SWTFZHGWJSXC0QXRFH45CH56EMSB2PK9, old-id: u13}
        {user: 'SP99B9SNEY20XZ5PDCR30VC520QPWCEAAVHHEC2W, old-id: u13}
        {user: 'SP2T5ZS0WA4BP31E3CTK5GDAY3VKJ1JXSGHDQZD66, old-id: u13}
        {user: 'SP3SRVNS46ZNFPN3WP9VBGWBGKQRJFX5VVZ6TT2NQ, old-id: u13}
        {user: 'SP2GYXR37WGDP11A2CT9T4HBXDPS8SA6YTHQ8A2NH, old-id: u13}
      )
    ))

    (try! (contract-call? .memegoat-stake-pools move-user-records
      u14
      (list 
        {user: 'SP3MJ27QVV5ZZ9YWZFF2TW27FC2KVNNFKK6TCSWAA, old-id: u14}
        {user: 'SPSQ4W56BY5XKZR8YJMXYP1CKJ64TT4CQ04GFQT8, old-id: u14}
        {user: 'SP2J1EX6Y8ZANKZ68ZK3FCPNDDRHT447C1RY7FZTW, old-id: u14}
        {user: 'SP1DZ6CVX4TYYNRV39WBPSH18EMA5C6S6TZHBZT75, old-id: u14}
        {user: 'SP3E8DBPXWV15PR41J863ZVB3GW0CG6KZ7SDKZ43S, old-id: u14}
        {user: 'SP2T5ZS0WA4BP31E3CTK5GDAY3VKJ1JXSGHDQZD66, old-id: u14}
        {user: 'SPTBAXKRKT7EXTZ6QRZFG1145M0BZ0TTX3HJZTFW, old-id: u14}
        {user: 'SP1J5A19QEDEEY3342W53RVWRZCMMHKZCVX3FQ2Y7, old-id: u14}
        {user: 'SP37S6ASV5A45JJ9MQWD1GG53W0CYMKXQZ6D9BR2P, old-id: u14}
        {user: 'SP2GYXR37WGDP11A2CT9T4HBXDPS8SA6YTHQ8A2NH, old-id: u14}
      )
    ))

    (try! (contract-call? .memegoat-stake-pools move-user-records
      u15
      (list 
        {user: 'SP99B9SNEY20XZ5PDCR30VC520QPWCEAAVHHEC2W, old-id: u15}
        {user: 'SP1HGP6E8ZHZBRA91NME5MPCC1ZQA6VTREQD723GP, old-id: u15}
        {user: 'SP26QMFEDRBGVNMANH5XJ7KX0NG9QDP2KAJVBGZD0, old-id: u15}
        {user: 'SP2T5ZS0WA4BP31E3CTK5GDAY3VKJ1JXSGHDQZD66, old-id: u15}
      )
    ))

    (try! (contract-call? .memegoat-stake-pools move-user-records
      u16
      (list 
        {user: 'SP2EAW0J3EW0G80KQW9MFKJMD5E20EFG2YMKTEGJG, old-id: u16}
        {user: 'SP2J1EX6Y8ZANKZ68ZK3FCPNDDRHT447C1RY7FZTW, old-id: u16}
        {user: 'SP99B9SNEY20XZ5PDCR30VC520QPWCEAAVHHEC2W, old-id: u16}
        {user: 'SP2T5ZS0WA4BP31E3CTK5GDAY3VKJ1JXSGHDQZD66, old-id: u16}
      )
    ))


    (ok true)
  )
)

;; PRIVATE CALLS
(define-private (get-votes-by-op-iter (op uint) (total uint))
  (+ total (get-votes-by-op op))
)

```
