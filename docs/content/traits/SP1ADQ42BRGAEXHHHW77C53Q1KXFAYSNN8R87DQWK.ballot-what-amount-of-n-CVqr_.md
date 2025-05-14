---
title: "Trait ballot-what-amount-of-n-CVqr_"
draft: true
---
```

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
    (define-map users {id: principal} {id: uint, vote: (list 18 (string-ascii 36)), volume: (list 18 uint), voting-power: uint})
    (define-map register {id: uint} {user: principal, vote: (list 18 (string-ascii 36)), volume: (list 18 uint), voting-power: uint})
    (define-data-var total uint u0)
    (define-data-var total-votes uint u0)
    (define-data-var options (list 18 (string-ascii 36)) (list))
    (define-data-var temp-voting-power uint u0)
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; private functions
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    (define-private (validate-nft-ownership (token-id uint))
        (let
            (
                (vote-id (+ u1 (var-get total)))
                (nft-owner-optional (unwrap-panic (contract-call? 'SP1ADQ42BRGAEXHHHW77C53Q1KXFAYSNN8R87DQWK.guessors get-owner token-id)))
            )

            (match nft-owner-optional
                nft-owner 
                    (if (is-eq tx-sender nft-owner)
                        (match (map-get? token-ids-map {token-id: token-id})
                            result
                                u0
                            (if (map-set token-ids-map {token-id: token-id} {user: tx-sender, vote-id: vote-id})                        
                                u1
                                u0
                            )
                        )
                        u0
                    )
                u0
            )
        )
    )

    (define-private (get-voting-power-by-nft-holdings (token-ids (list 60000 uint)))
        (fold + (map validate-nft-ownership token-ids) u0)
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

    (define-private (validate-vote-volume (volume (list 18 uint)))
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
    (define-public (cast-my-vote (vote (list 18 (string-ascii 36))) (volume (list 18 uint))
        (bns (string-ascii 256)) (domain (buff 20)) (namespace (buff 48)) (token-ids (list 60000 uint))
        )
        (let
            (
                (vote-id (+ u1 (var-get total)))
                (voting-power (get-voting-power-by-nft-holdings token-ids))
                
                ;; FPTP and Block voting
                (temp (var-set temp-voting-power voting-power))
                (volume-by-voting-power (map get-volume-by-voting-power volume))
            
                
                ;; FPTP and Block voting - Number of votes
                (my-votes voting-power)
            )
            ;; Validation
            (asserts! (and (> (len vote) u0) (is-eq (len vote) (len volume-by-voting-power)) (validate-vote-volume volume-by-voting-power)) ERR-NOT-VOTED)
            (asserts! (>= tenure-height (var-get start)) ERR-NOT-STARTED)
            (asserts! (<= tenure-height (var-get end)) ERR-ENDED)        
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
    (var-set title u"What%20amount%20of%20net%20savings%20will%20the%20Centers%20of%20Medicare%20and%20Medicaid%20Services%20report%20under%20the%20Medicare%20Shared%20Savings%20Program%3F")
    (var-set description u"Every%20year%20since%202012%2C%20CMS%20reports%20the%20total%20amount%20of%20Medicare%20savings%20under%20the%20MSSP.%0AThe%20options%20below%20are%20represented%20as%20%24%20billions.")
    (var-set voting-system "fptp")
    (var-set options (list "fe086bbb-05c7-412f-8ba1-2b78a314d226" "57329cd5-ad3b-4b7b-b655-83f91362ba8f" "14c4447f-5143-4132-bcc2-1d31465ac7b1" "d535a393-847b-46df-8092-b16f78246088" "fd8387e7-a964-473c-9519-446993d94216" "5b1618ba-b0ef-4ed4-8214-1fc55a5d5705" "c46d29eb-763a-4bd4-b51f-fadf3a04d81b" "627c288c-75ed-4a42-8519-9b75cd0ca58c" "24ac7b7c-c5fa-430d-8b21-8b71dd89a542" "0221640e-697f-42d3-93a2-79b8798f7e90" "d424999b-57d1-41d0-b705-970e12f71e4a" "00ef5eff-5d0b-4639-9a10-b3be8025c504" "2370c9fd-558c-4502-bd3e-c8b6ebb1dc56" "21a8bdce-4261-4c6a-b5e4-9d5a8c7ed092" "6d863d31-5493-4007-93ae-4294d704d231" "a131a237-81e8-4d51-b1e5-e7a28bad49fd" "94a8b298-1e1d-4192-8f8f-8d049a36197e" "e6f78afe-ecd6-4bcf-87dd-d24f023226c9"))
    (var-set start u194403)
    (var-set end u283018)
    (map-set results {id: "fe086bbb-05c7-412f-8ba1-2b78a314d226"} {count: u0, name: u"Less%20than%20%241B"}) (map-set results {id: "57329cd5-ad3b-4b7b-b655-83f91362ba8f"} {count: u0, name: u"%241.0%20-%20%241.1B"}) (map-set results {id: "14c4447f-5143-4132-bcc2-1d31465ac7b1"} {count: u0, name: u"%241.1%20-%20%241.2B"}) (map-set results {id: "d535a393-847b-46df-8092-b16f78246088"} {count: u0, name: u"%241.2%20-%20%241.3B"}) (map-set results {id: "fd8387e7-a964-473c-9519-446993d94216"} {count: u0, name: u"%241.3%20-%20%241.4B"}) (map-set results {id: "5b1618ba-b0ef-4ed4-8214-1fc55a5d5705"} {count: u0, name: u"%241.4%20-%20%241.5B"}) (map-set results {id: "c46d29eb-763a-4bd4-b51f-fadf3a04d81b"} {count: u0, name: u"%241.5%20-%20%241.6B"}) (map-set results {id: "627c288c-75ed-4a42-8519-9b75cd0ca58c"} {count: u0, name: u"%241.6%20-%20%241.7B"}) (map-set results {id: "24ac7b7c-c5fa-430d-8b21-8b71dd89a542"} {count: u0, name: u"%241.7%20-%20%241.8B"}) (map-set results {id: "0221640e-697f-42d3-93a2-79b8798f7e90"} {count: u0, name: u"%241.8%20-%20%241.9B"}) (map-set results {id: "d424999b-57d1-41d0-b705-970e12f71e4a"} {count: u0, name: u"%241.9%20-%20%242.0B"}) (map-set results {id: "00ef5eff-5d0b-4639-9a10-b3be8025c504"} {count: u0, name: u"%242.0%20-%20%242.1B"}) (map-set results {id: "2370c9fd-558c-4502-bd3e-c8b6ebb1dc56"} {count: u0, name: u"%242.1%20-%20%242.2B"}) (map-set results {id: "21a8bdce-4261-4c6a-b5e4-9d5a8c7ed092"} {count: u0, name: u"%242.2%20-%20%242.3B"}) (map-set results {id: "6d863d31-5493-4007-93ae-4294d704d231"} {count: u0, name: u"%242.3%20-%20%242.4B"}) (map-set results {id: "a131a237-81e8-4d51-b1e5-e7a28bad49fd"} {count: u0, name: u"%242.4%20-%20%242.5B"}) (map-set results {id: "94a8b298-1e1d-4192-8f8f-8d049a36197e"} {count: u0, name: u"%242.5%20-%20%242.6B"}) (map-set results {id: "e6f78afe-ecd6-4bcf-87dd-d24f023226c9"} {count: u0, name: u"%242.6%20-%20%242.7B"})
```
