
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
    (define-map users {id: principal} {id: uint, vote: (list 5 (string-ascii 36)), volume: (list 5 uint), voting-power: uint})
    (define-map register {id: uint} {user: principal, vote: (list 5 (string-ascii 36)), volume: (list 5 uint), voting-power: uint})
    (define-data-var total uint u0)
    (define-data-var total-votes uint u0)
    (define-data-var options (list 5 (string-ascii 36)) (list))
    (define-data-var temp-voting-power uint u0)
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; private functions
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    (define-private (get-voting-power-by-ft-holdings)
        (let
            (
                (ft-balance (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-special-vote get-balance tx-sender)))
                (ft-decimals (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-special-vote get-decimals)))
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

    (define-private (validate-vote-volume (volume (list 5 uint)))
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
    (define-public (cast-my-vote (vote (list 5 (string-ascii 36))) (volume (list 5 uint))
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
    (var-set title u"Treasury%20Grant%20Program")
    (var-set description u"Based%20on%20the%20community%20feedbacks%20and%20suggestions%2C%20as%20summarized%20in%20our%20recent%20announcement%20(https%3A%2F%2Fx.com%2FALEXLabBTC%2Fstatus%2F1794681669179310507)%2C%20the%20Foundation%20selected%20four%20feasible%20and%20immediately%20actionable%20proposals%20for%20a%20governance%20vote%20by%20the%20community%20to%20decide%20on%20the%20Treasury%20Grant%20Program.%0A%0A%3E%3E%20Vote%20Conditions%20%3C%3C%0A%0A-%20At%20least%2050%25%20of%20the%20vote%20token%20must%20participate%20and%2")
    (var-set voting-system "fptp")
    (var-set options (list "213957c1-d0c8-4fc0-a5ca-d882cf700415" "3d9d1488-8c09-47e3-bbcf-eb4d7dc101df" "ae746a8e-9763-4d29-a747-a92a4ac467ef" "c06193ad-a83b-4716-9719-72f7898722de" "5c3f30c8-36d9-4196-8e11-0beb3c3a713b"))
    (var-set start u151853)
    (var-set end u152570)
    (map-set results {id: "213957c1-d0c8-4fc0-a5ca-d882cf700415"} {count: u0, name: u"Choice%201%3A%20Abstain%20"}) (map-set results {id: "3d9d1488-8c09-47e3-bbcf-eb4d7dc101df"} {count: u0, name: u"Choice%202%3A%20Distribution%20of%20the%20Recovered%20Assets%20to%20LP%20holders%20and%20Minting%20of%20NFTs%20for%20non-recovered%20STX"}) (map-set results {id: "ae746a8e-9763-4d29-a747-a92a4ac467ef"} {count: u0, name: u"Choice%203%3A%20Synthetic%20STX%20(14%20million%20STX)"}) (map-set results {id: "c06193ad-a83b-4716-9719-72f7898722de"} {count: u0, name: u"Choice%204%3A%20Synthetic%20USDC%20(28%20million%20USDC)"}) (map-set results {id: "5c3f30c8-36d9-4196-8e11-0beb3c3a713b"} {count: u0, name: u"Choice%205%3A%20Fairly%20Distribute%20the%20Remaining%20STX%20in%20the%20Vault%20to%20Cover%20LP%20Loss"})