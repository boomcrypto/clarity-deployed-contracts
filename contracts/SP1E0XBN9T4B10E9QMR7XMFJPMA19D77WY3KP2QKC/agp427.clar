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

;; Helper function to sum up votes from a tuple
(define-private (sum-votes (entry {pool-id: uint, votes: uint}) (acc uint))
    (+ acc (get votes entry))
)

;; Helper function to set pool votes in the helper contract
(define-private (set-pool-vote (entry {pool-id: uint, votes: uint}))
    (contract-call? 
        'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-01-helper 
        set-campaign-pool-votes
        {campaign-id: u1, pool-id: (get pool-id entry)}
        (get votes entry)
    )
)

(define-public (execute (sender principal))
    (let 
        (
            (calculated-total (fold sum-votes pool-votes u0))
        )
        ;; Verify total votes
        (asserts! (is-eq calculated-total total-vote) (err u1))
        
        ;; Set the helper contract as an extension
        (try! (contract-call? 
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao 
            set-extensions 
            (list 
                {extension: 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-01-helper, enabled: true}
            )
        ))

        ;; Set the total vote for campaign 1
        (try! (contract-call? 
            'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-01-helper 
            set-campaign-total-vote 
            u1 
            total-vote
        ))

        ;; Set individual pool votes
        (map set-pool-vote pool-votes)
				
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPCY68ZS2FH37RQQ7FQD6VMK9QWVFK01CNRVV2MD))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1NQT9PMVBWHZHSM13RD6CYF86G4YA99JR5Q1NM5))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2NFRCR8XDRSR6KR5G5SR0K5TMXQGRECJBHHW2SC))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3EDGTJHXKMJTCTW863JDK1QJWEX77RWZK27YW9G))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP13XH8XSSM55GYS0S749HGWBSGNPKJGQVWTY3SH9))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3RX1DNH253886T72EQMGA0H5K8PPSGMCJJN2VJG))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3DV12F249YPTA3BFQ9QG0ZMS2P3X2V50KPBKQ5Q))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3RWHMXQBWM1BYH74SGVKTHN6X4SCVQ673WQQXG2))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1GQKBVX6TTP1NRGB5FZXBG9CTJ011N5H7HH19V6))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP232WT6ZW7E3FWBKPP0TD2MGGSEDNMF9GZ9AAM15))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP239C843TR7S2GEV704V13T51XSPN8EFQR2NR8HH))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2KE98PGDW1A5NKGSB4BBRJSFS7KD0K8KZNXCZW7))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3A5G45ZY5SZFSTGCJXM731RM8EJDAB672RHDBZQ))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP32XFMNYYQYEDRRVDBABMB17YEKMZ23C4K8JQ8SZ))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3V88PSZ9H7N72GT5XZVC882AR339YJQJYP0ZK61))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1RFCJWZAB84BHK9W1VM017K8NZD9MFHF2FTTCDY))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP83MH192Z1X1ERVVHZPZBANJ296VF78JNZK6CJ2))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1JTQ988GYBQKZARR03XNKQBGTTB181VNAQDEM1E))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1S47PTVDM2YARZVC68A3ZKHKBWS4RWKZTN60YSA))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3DCBEPB2C10FN0DV6S5KFJSHJHYNMM9W4MAV2KA))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPHQSRNGTFMSXYCMSBZYMRM9HCD6202TPST4APX3))

        (ok true)
    )
)
