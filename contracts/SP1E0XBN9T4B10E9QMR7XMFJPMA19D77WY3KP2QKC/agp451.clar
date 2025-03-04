(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

;; Define the total vote constant
(define-constant total-vote u11146855651712551)														

;; Define the list of (pool-id, votes) tuples (excluding zero votes)
(define-constant pool-votes (list 
{pool-id: u18, votes: u2106788103127160}
{pool-id: u43, votes: u481359165337999}
{pool-id: u124, votes: u1809804267882938}
{pool-id: u31, votes: u10351100000000}
{pool-id: u33, votes: u47721335644887}
{pool-id: u7, votes: u205681516359203}
{pool-id: u34, votes: u130093444147445}
{pool-id: u38, votes: u402550858239057}
{pool-id: u114, votes: u20027054390607}
{pool-id: u35, votes: u851100000000}
{pool-id: u10, votes: u9814057237336}
{pool-id: u65, votes: u64920192712106}
{pool-id: u82, votes: u120448390955814}
{pool-id: u99, votes: u578574149450332}
{pool-id: u122, votes: u75000000000000}
{pool-id: u16, votes: u2500000000000}
{pool-id: u116, votes: u75756784443373}
{pool-id: u22, votes: u50000000000}
{pool-id: u11, votes: u1639265387090}

{pool-id: u23, votes: u481638219166}
{pool-id: u32, votes: u50000000000}
{pool-id: u37, votes: u250000000000}
{pool-id: u53, votes: u51000000000}
{pool-id: u66, votes: u298247432529}
{pool-id: u58, votes: u150000000000}
{pool-id: u112, votes: u2500000000}
{pool-id: u109, votes: u115445212759594}

{pool-id: u100, votes: u14533246953549}


{pool-id: u28, votes: u50000000000}

{pool-id: u39, votes: u950000000000}
{pool-id: u79, votes: u80548159955213}
{pool-id: u98, votes: u1248472128620829}
{pool-id: u51, votes: u372794454030368}
{pool-id: u25, votes: u23614855561679}

{pool-id: u48, votes: u50000000000}
{pool-id: u120, votes: u50000000000}
{pool-id: u83, votes: u6781628737664}
{pool-id: u68, votes: u37281574904596}

{pool-id: u12, votes: u9787200000000}
{pool-id: u46, votes: u3010610000000}
{pool-id: u27, votes: u130000000000}
{pool-id: u113, votes: u86741158097597}
{pool-id: u54, votes: u207652256547510}
{pool-id: u41, votes: u230000000000}
{pool-id: u74, votes: u1000000000}

{pool-id: u70, votes: u31000000000}
{pool-id: u125, votes: u2393992407433125}
{pool-id: u126, votes: u279347991111470}
{pool-id: u127, votes: u118684914011402}
{pool-id: u121, votes: u30000000000}




{pool-id: u42, votes: u933182020913}




{pool-id: u64, votes: u30000000000}

{pool-id: u49, votes: u30000000000}



{pool-id: u56, votes: u230000000000}







{pool-id: u89, votes: u208500000000}
))

;; Helper function to sum up votes from a tuple
(define-private (sum-votes (entry {pool-id: uint, votes: uint}) (acc uint))
    (+ acc (get votes entry))
)

;; Helper function to set pool votes in the helper contract
(define-private (set-pool-vote (entry {pool-id: uint, votes: uint}))
  (contract-call? .farming-campaign-v2-02-helper set-campaign-pool-votes-for-alex-reward u2 (get pool-id entry) (get votes entry)))

(define-public (execute (sender principal))
    (let (
        	(calculated-total (fold sum-votes pool-votes u0)))
        
				;; Verify total votes
        (asserts! (is-eq calculated-total total-vote) (err u1))
        
        ;; Set the helper contract as an extension
        (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao set-extensions
          (list {extension: .farming-campaign-v2-02-helper, enabled: true})))

        ;; Set the total vote for campaign 2
        (try! (contract-call? .farming-campaign-v2-02-helper set-campaign-total-vote u2 total-vote))

        ;; Set individual pool votes
        (map set-pool-vote pool-votes)

(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2SKCS1H9JDDEDH0ZNPK8A8HMGA399G2JQ3X4232))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPTGXPJ8ER6YK7D4RZ7755JJA1FEP41FD6WBX5HF))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP23CK419ER1CPD7VRK5ZD07ZXPCKWKN9MM7X8C2K))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2A2GE9ZV2BWHBVM5MJ2J21AX8BRXEGX4TDP5DJ2))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2XSH77HP616VKM6SV83KAV0G5D3M6ZTM3WM7PFZ))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3ERB3CKV60Z4SW5R2RZGF6Z0A93AJTN1ATJ3T7P))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1C9VHDNE5CJAN7FN45ERZWP5X9AST6A3M7JNC6G))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPDB5FSSZEKFBKYSSF2PEJT64N41S2S23Y20XW6F))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP23G2SPTY7J74XD203J2TQM7DNEW8JT3DG5E6RE0))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2Y738VAEMGCMJ8BR4Q94A74EY7DHQEEG31KH078))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPKX3MMWS6B5W0A68VWJ1S2FRC9A91549C3WDEB6))
        (ok true)
    )
)
