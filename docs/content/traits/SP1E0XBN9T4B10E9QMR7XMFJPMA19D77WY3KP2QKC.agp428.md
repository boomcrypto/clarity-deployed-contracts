---
title: "Trait agp428"
draft: true
---
```
(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

;; Define the total vote constant
(define-constant total-vote u2821095342675391)

;; Define the list of (pool-id, votes) tuples (excluding zero votes)
(define-constant pool-votes (list 
    {pool-id: u74, votes: u304056183}
    {pool-id: u29, votes: u13415293544}
    {pool-id: u51, votes: u34954141196}
    {pool-id: u54, votes: u555400000000}
    {pool-id: u34, votes: u403684937492683}
    {pool-id: u83, votes: u29094238344860}
    {pool-id: u112, votes: u1262745963929}
    {pool-id: u31, votes: u9023800000000}
    {pool-id: u10, votes: u22877806608895}
    {pool-id: u89, votes: u10007400000000}
    {pool-id: u35, votes: u2101331000000}
    {pool-id: u63, votes: u20000000000}
    {pool-id: u52, votes: u1000000000}
    {pool-id: u114, votes: u44461600000000}
    {pool-id: u109, votes: u3374540711800}
    {pool-id: u107, votes: u400200000000}
    {pool-id: u39, votes: u1258700000000}
    {pool-id: u69, votes: u6491511227615}
    {pool-id: u50, votes: u148324977156}
    {pool-id: u65, votes: u46479063715408}
    {pool-id: u16, votes: u657962862012}
    {pool-id: u38, votes: u105562389789041}
    {pool-id: u42, votes: u7322911187}
    {pool-id: u12, votes: u9442267144440}
    {pool-id: u98, votes: u248461520093142}
    {pool-id: u61, votes: u8000000000}
    {pool-id: u79, votes: u20115700000000}
    {pool-id: u43, votes: u369250650062472}
    {pool-id: u7, votes: u230594067304555}
    {pool-id: u103, votes: u12250800000000}
    {pool-id: u82, votes: u114616701832248}
    {pool-id: u41, votes: u519900000000}
    {pool-id: u57, votes: u1000000000}
    {pool-id: u113, votes: u257688766150107}
    {pool-id: u99, votes: u276228100942611}
    {pool-id: u18, votes: u456542356900773}
    {pool-id: u100, votes: u10872541252506}
    {pool-id: u30, votes: u1100000000}
    {pool-id: u48, votes: u14083000000}
    {pool-id: u17, votes: u2823000000000}
    {pool-id: u33, votes: u122405114248077}
    {pool-id: u37, votes: u511389386458}
    {pool-id: u58, votes: u148852130597}
    {pool-id: u23, votes: u1078483131896}
    {pool-id: u64, votes: u2000000000}
))

;; Define helper claimed records
(define-constant helper-claimed-records (list 
    {sender: 'SP2XE79SP3TQK67M50C44G1N021RJCMG0PPHFXWPN, pool-id: u113}
    {sender: 'SPVZB7A41TMC654VEKGN8YF5SH6THP4CYHZDHW10, pool-id: u113}
    {sender: 'SP1QSYZ0TY2SM6GKNF7SKN0BRD5GFM4HN5KXZNHG5, pool-id: u113}
    {sender: 'SPH1ZAHN998PFH9A2CBNQ5EM3HKXG08FA0CKF4MB, pool-id: u34}
    {sender: 'SP1AXD41X9ZGANAJYY88XBQTZB7PZQ2FDNC0W9X28, pool-id: u83}
    {sender: 'SP1AXD41X9ZGANAJYY88XBQTZB7PZQ2FDNC0W9X28, pool-id: u63}
    {sender: 'SP1AXD41X9ZGANAJYY88XBQTZB7PZQ2FDNC0W9X28, pool-id: u58}
    {sender: 'SP3RRGMNH6NVP2NNKTN9QQBVXWZJ2H9XDP6Y38GMG, pool-id: u34}
    {sender: 'SP3RRGMNH6NVP2NNKTN9QQBVXWZJ2H9XDP6Y38GMG, pool-id: u18}
    {sender: 'SP13F0C8HFJC9H1FR7S7WFZ9FEMNV1PBEG3GWS5N0, pool-id: u113}
    {sender: 'SP3RRGMNH6NVP2NNKTN9QQBVXWZJ2H9XDP6Y38GMG, pool-id: u43}
    {sender: 'SP1AXD41X9ZGANAJYY88XBQTZB7PZQ2FDNC0W9X28, pool-id: u96}
    {sender: 'SP1AXD41X9ZGANAJYY88XBQTZB7PZQ2FDNC0W9X28, pool-id: u32}
    {sender: 'SP1AXD41X9ZGANAJYY88XBQTZB7PZQ2FDNC0W9X28, pool-id: u34}
    {sender: 'SP1AXD41X9ZGANAJYY88XBQTZB7PZQ2FDNC0W9X28, pool-id: u22}
    {sender: 'SP1AXD41X9ZGANAJYY88XBQTZB7PZQ2FDNC0W9X28, pool-id: u17}
    {sender: 'SP1AXD41X9ZGANAJYY88XBQTZB7PZQ2FDNC0W9X28, pool-id: u46}
    {sender: 'SP1AXD41X9ZGANAJYY88XBQTZB7PZQ2FDNC0W9X28, pool-id: u66}
    {sender: 'SPHFAXDZVFHMY8YR3P9J7ZCV6N89SBET203ZAY25, pool-id: u100}
    {sender: 'SP2HJ0N3STP3T9A0CXBATW9WZD0APWB932W4P67K4, pool-id: u65}
    {sender: 'SP1V4BWKPD559WP67GWCV8VR0VRKJ7ESS8WHKYEJP, pool-id: u34}
    {sender: 'SPBNMD07T0WD2WJAH6JZJG07GYSF0X413V69J3T9, pool-id: u65}
    {sender: 'SPN3AV2KQ8HYFHGKC34SGVSS9TNMJXG56GXRSR70, pool-id: u34}
    {sender: 'SP36VJT9YM4XQW7PTWMY8B823QNZEVMR1KEQH5J75, pool-id: u33}
    {sender: 'SP36VJT9YM4XQW7PTWMY8B823QNZEVMR1KEQH5J75, pool-id: u65}
    {sender: 'SP2PM6DZ9HT5PWRE2GZZ19NERXPN9RBED8RQESHNV, pool-id: u65}
    {sender: 'SP1NTYFH1RYT2Y38VKA7JHP7C09PW3ZEF1QG765YF, pool-id: u10}
    {sender: 'SP36VJT9YM4XQW7PTWMY8B823QNZEVMR1KEQH5J75, pool-id: u38}
    {sender: 'SP1NTYFH1RYT2Y38VKA7JHP7C09PW3ZEF1QG765YF, pool-id: u83}
    {sender: 'SP1NTYFH1RYT2Y38VKA7JHP7C09PW3ZEF1QG765YF, pool-id: u65}
    {sender: 'SPED2H1PRKSQCP737XY19WEBMY28F2GSK49YD0SK, pool-id: u113}
    {sender: 'SPED2H1PRKSQCP737XY19WEBMY28F2GSK49YD0SK, pool-id: u65}
    {sender: 'SP1NTYFH1RYT2Y38VKA7JHP7C09PW3ZEF1QG765YF, pool-id: u113}
    {sender: 'SPED2H1PRKSQCP737XY19WEBMY28F2GSK49YD0SK, pool-id: u99}
    {sender: 'SP1NTYFH1RYT2Y38VKA7JHP7C09PW3ZEF1QG765YF, pool-id: u33}
    {sender: 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT, pool-id: u34}
))

;; Helper function to sum up votes from a tuple
(define-private (sum-votes (entry {pool-id: uint, votes: uint}) (acc uint))
    (+ acc (get votes entry))
)

;; Helper function to set pool votes in the helper contract
(define-private (set-pool-vote (entry {pool-id: uint, votes: uint}))
    (contract-call? 
        'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-01-helper-b 
        set-campaign-pool-votes
        {campaign-id: u1, pool-id: (get pool-id entry)}
        (get votes entry)
    )
)

;; Helper function to distribute alex rewards
(define-private (distribute-reward (entry {sender: principal, pool-id: uint}))
    (contract-call? 
        'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-01-helper-b 
        distribute-alex-reward
        (get pool-id entry)
        u1
        (get sender entry)
    )
)

(define-public (execute (sender principal))
    (let 
        (
            (calculated-total (fold sum-votes pool-votes u0))
						(bal-125 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 get-balance-fixed u125 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.self-listing-helper-v2-04)))
						(bal-126 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 get-balance-fixed u126 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.self-listing-helper-v2-04)))
        )
        ;; Verify total votes
        (asserts! (is-eq calculated-total total-vote) (err u1))
        
        ;; Set the helper contract as an extension
        (try! (contract-call? 
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao 
            set-extensions
            (list 
                {extension: 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-01-helper, enabled: false}
                {extension: 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-01-helper-b, enabled: true}
            )
        ))

        ;; Set the total vote for campaign 1
        (try! (contract-call? 
            'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-01-helper-b 
            set-campaign-total-vote 
            u1 
            total-vote
        ))

        ;; Set individual pool votes
        (map set-pool-vote pool-votes)

        ;; Distribute alex rewards for each record
        (map distribute-reward helper-claimed-records)

				(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 burn-fixed u125 bal-125 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.self-listing-helper-v2-04))
				(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 burn-fixed u126 bal-126 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.self-listing-helper-v2-04))
				(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 mint-fixed u125 bal-125 'SP1ESCTF9029MH550RKNE8R4D62G5HBY8PBBAF2N8))
				(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 mint-fixed u126 bal-126 'SP1ESCTF9029MH550RKNE8R4D62G5HBY8PBBAF2N8))
        (ok true)
    )
)

```
