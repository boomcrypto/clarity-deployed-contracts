
    ;; ballot
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Constants
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (define-constant CONTRACT-OWNER tx-sender)
    ;; Errors
    (define-constant ERR-NOT-STARTED (err u1001))
    (define-constant ERR-ENDED (err u1002))
    (define-constant ERR-ALREADY-VOTED (err u1003))
    (define-constant ERR-FAILED-STRATEGY (err u1004))
    (define-constant ERR-NOT-VOTED (err u1005))
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; data maps and vars
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (define-data-var title (string-utf8 512) u"")
    (define-data-var description (string-utf8 512) u"")
    (define-data-var voting-system (string-ascii 512) "")
    (define-data-var start uint u0)
    (define-data-var end uint u0)
    (define-map token-ids-map {token-id: uint} {user: principal, vote-id: uint})
    (define-map btc-holder-map {domain: (buff 20), namespace: (buff 48)} {user: principal, vote-id: uint})
    (define-map results {id: (string-ascii 36)} {count: uint, name: (string-utf8 256)} )
    (define-map users {id: principal} {id: uint, vote: (list 3 (string-ascii 36)), volume: (list 3 uint), voting-power: uint})
    (define-map register {id: uint} {user: principal, vote: (list 3 (string-ascii 36)), volume: (list 3 uint), voting-power: uint})
    (define-data-var total uint u0)
    (define-data-var total-votes uint u0)
    (define-data-var options (list 3 (string-ascii 36)) (list))
    (define-data-var temp-voting-power uint u0)
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; private functions
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    (define-private (get-voting-power-by-ft-holdings)
        (let
            (
                (ft-balance (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3 get-balance tx-sender)))
                (ft-decimals (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3 get-decimals)))
            )

            (if (> ft-balance u0)
                (if (> ft-decimals u0)
                    (/ ft-balance (pow u10 ft-decimals))
                    ft-balance
                )
                ft-balance
            )
        )
    )
    
    (define-private (have-i-voted)
        (match (map-get? users {id: tx-sender})
            success true
            false
        )
    )
    
    (define-private (fold-boolean (left bool) (right bool))
        (and (is-eq left true) (is-eq right true))
    )

    (define-private (check-volume (each-volume uint))
        (> each-volume u0)
    )

    (define-private (validate-vote-volume (volume (list 3 uint)))
        (begin
            (fold fold-boolean (map check-volume volume) true)
        )
    )

    (define-private (get-volume-by-voting-power (volume uint))
        (var-get temp-voting-power)
    )

    (define-private (get-pow-value (volume uint))
        (pow volume u2)
    )
    
    (define-private (process-my-vote (option-id (string-ascii 36)) (volume uint))
        (match (map-get? results {id: option-id})
            result (let
                    (
                        (new-count-tuple {count: (+ volume (get count result))})
                    )

                    ;; Capture the vote
                    (map-set results {id: option-id} (merge result new-count-tuple))

                    ;; Return
                    true
                )
            false
        )
    )
    
    (define-private (get-single-result (option-id (string-ascii 36)))
        (let 
            (
                (volume (default-to u0 (get count (map-get? results {id: option-id}))))
            )
    
            ;; Return volume
            volume
        )
    )
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; public functions for all
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (define-public (cast-my-vote (vote (list 3 (string-ascii 36))) (volume (list 3 uint))
        (bns (string-ascii 256)) (domain (buff 20)) (namespace (buff 48)) (token-ids (list 60000 uint))
        )
        (let
            (
                (vote-id (+ u1 (var-get total)))
                (voting-power (get-voting-power-by-ft-holdings))
                
                ;; FPTP and Block voting
                (temp (var-set temp-voting-power voting-power))
                (volume-by-voting-power (map get-volume-by-voting-power volume))
            
                
                ;; FPTP and Block voting - Number of votes
                (my-votes voting-power)
            )
            ;; Validation
            (asserts! (and (> (len vote) u0) (is-eq (len vote) (len volume-by-voting-power)) (validate-vote-volume volume-by-voting-power)) ERR-NOT-VOTED)
            (asserts! (>= block-height (var-get start)) ERR-NOT-STARTED)
            (asserts! (<= block-height (var-get end)) ERR-ENDED)        
            (asserts! (not (have-i-voted)) ERR-ALREADY-VOTED)
            
                ;; FPTP and Block voting
                (asserts! (> voting-power u0) ERR-FAILED-STRATEGY)
            
            ;; Business logic
            ;; Process my vote
            (map process-my-vote vote volume-by-voting-power)
            
            ;; Register for reference
            (map-set users {id: tx-sender} {id: vote-id, vote: vote, volume: volume-by-voting-power, voting-power: voting-power})
            (map-set register {id: vote-id} {user: tx-sender, vote: vote, volume: volume-by-voting-power, voting-power: voting-power})

            ;; Increase the total votes
            (var-set total-votes (+ my-votes (var-get total-votes)))

            ;; Increase the total
            (var-set total vote-id)
    
            ;; Return
            (ok true)
        )
    )
    
    (define-read-only (get-results)
        (begin
            (ok {
                    total: (var-get total), 
                    total-votes: (var-get total-votes), 
                    options: (var-get options), 
                    results: (map get-single-result (var-get options))
                })
        )
    )
    
    (define-read-only (get-result-at-position (position uint))
        (ok (map-get? register {id: position}))
    )
        
    (define-read-only (get-result-by-user (user principal))
        (ok (map-get? users {id: user}))
    )
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Default assignments
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (var-set title u"(Vote%20with%20LiALEX)%20ALEX%20Governance%20Proposal%3A%20Utilize%20100%25%20of%20Protocol%20Revenue%20as%20an%20Additional%20Grant%20Distribution%20Toward%20Recovery%20Certificate%20Holders")
    (var-set description u"***Please%20note%3A%20%24ALEX%20must%20be%20migrated%20and%20%24atALEX%20migrated%20to%20%24LiALEX%20in%20order%20to%20participate%20in%20governance%20voting***%0A%0AProposal%20to%20Utilize%20100%25%20of%20Protocol%20Revenue%20as%20an%20Additional%20Grant%20Distribution%20Toward%20Recovery%20Certificate%20Holders%20%0A%0AIntroduction%3A%0A%0AThe%20ALEX%20Lab%20Foundation%20understands%20our%20community%20wants%20greater%20transparency%20on%20asset%20recovery%20for%20the%20affected%20users%2C%20so%20is%20cre")
    (var-set voting-system "fptp")
    (var-set options (list "75664df5-ba79-45a3-9989-791c6efb9184" "5f7ef103-70e6-4439-b8fa-bd3ef8082533" "1ebc53b2-284b-4054-8069-64edd5c2265d"))
    (var-set start u156119)
    (var-set end u157127)
    (map-set results {id: "75664df5-ba79-45a3-9989-791c6efb9184"} {count: u0, name: u"Choice%201%3A%20Approve%20Utilizing%20100%25%20of%20Protocol%20Revenue%20as%20an%20Additional%20Grant%20Distribution%20Toward%20Recovery%20Certificate%20Holders"}) (map-set results {id: "5f7ef103-70e6-4439-b8fa-bd3ef8082533"} {count: u0, name: u"Choice%202%3A%20Disapprove%20Utilizing%20100%25%20of%20Protocol%20Revenue%20as%20an%20Additional%20Grant%20Distribution%20Toward%20Recovery%20Certificate%20Holders"}) (map-set results {id: "1ebc53b2-284b-4054-8069-64edd5c2265d"} {count: u0, name: u"Choice%203%3A%20Abstain%20from%20the%20vote."})