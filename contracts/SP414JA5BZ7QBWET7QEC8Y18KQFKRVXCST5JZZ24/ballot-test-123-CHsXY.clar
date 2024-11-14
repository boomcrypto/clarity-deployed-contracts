
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
    (define-map users {id: principal} {id: uint, vote: (list 14 (string-ascii 36)), volume: (list 14 uint), voting-power: uint})
    (define-map register {id: uint} {user: principal, vote: (list 14 (string-ascii 36)), volume: (list 14 uint), voting-power: uint})
    (define-data-var total uint u0)
    (define-data-var total-votes uint u0)
    (define-data-var options (list 14 (string-ascii 36)) (list))
    (define-data-var temp-voting-power uint u0)
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; private functions
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    (define-private (get-voting-power-by-ft-holdings)
        (let
            (
                (ft-balance (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token get-balance tx-sender)))
                (ft-decimals (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token get-decimals)))
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

    (define-private (validate-vote-volume (volume (list 14 uint)))
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
    (define-public (cast-my-vote (vote (list 14 (string-ascii 36))) (volume (list 14 uint))
        (bns (string-ascii 256)) (domain (buff 20)) (namespace (buff 48)) (token-ids (list 60000 uint))
        )
        (let
            (
                (vote-id (+ u1 (var-get total)))
                (voting-power (get-voting-power-by-ft-holdings))
                
                ;; Quadratic or Weighted voting
                (volume-by-voting-power volume)
                
                ;; Quadratic or Weighted voting - Number of votes
                (my-votes (fold + volume u0))
            )
            ;; Validation
            (asserts! (and (> (len vote) u0) (is-eq (len vote) (len volume-by-voting-power)) (validate-vote-volume volume-by-voting-power)) ERR-NOT-VOTED)
            (asserts! (>= block-height (var-get start)) ERR-NOT-STARTED)
            (asserts! (<= block-height (var-get end)) ERR-ENDED)        
            (asserts! (not (have-i-voted)) ERR-ALREADY-VOTED)
            
                ;; Weigted voting
                (asserts! (>= voting-power (fold + volume-by-voting-power u0)) ERR-FAILED-STRATEGY)
            
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
    (var-set title u"Test%20123")
    (var-set description u"This%20is%20the%20test%20voting")
    (var-set voting-system "weighted")
    (var-set options (list "5db1037e-924d-4882-9427-c2df6f9e1be9" "c1562ad6-6a82-4f1e-94c7-59a2cf8b8f2f" "e420373a-7605-425d-9fb6-dda9407510de" "f0f8f1e2-2888-4b55-b40c-fe503c55a22b" "8306ba5a-3a28-4250-8b0a-11957233ee54" "731decb9-4508-4569-928d-63865733cebd" "76790d19-a6cb-49d1-847e-ab8d18999705" "f33529b4-b567-4e23-abaf-45898379ca5b" "b171ca22-4655-423e-b3d0-d522a765561c" "9f3ae573-8a50-4013-9c9d-12d3d583307c" "04b1858a-9237-49f8-a1b0-74f5c58391b7" "bf7b38e5-bef8-4018-931c-85b29c2495df" "898d4c96-3b14-4aec-8ae7-462da647b281" "a1112717-eb24-49bb-b879-12123a37b0d0"))
    (var-set start u167512)
    (var-set end u167652)
    (map-set results {id: "5db1037e-924d-4882-9427-c2df6f9e1be9"} {count: u0, name: u"%231%20STX-MEME"}) (map-set results {id: "c1562ad6-6a82-4f1e-94c7-59a2cf8b8f2f"} {count: u0, name: u"%232%20STX-MEME2"}) (map-set results {id: "e420373a-7605-425d-9fb6-dda9407510de"} {count: u0, name: u"%233%20STX-MEME3"}) (map-set results {id: "f0f8f1e2-2888-4b55-b40c-fe503c55a22b"} {count: u0, name: u"%234%20STX-MEME4"}) (map-set results {id: "8306ba5a-3a28-4250-8b0a-11957233ee54"} {count: u0, name: u"%235%20STX-MEME5"}) (map-set results {id: "731decb9-4508-4569-928d-63865733cebd"} {count: u0, name: u"%236%20STX-MEME6"}) (map-set results {id: "76790d19-a6cb-49d1-847e-ab8d18999705"} {count: u0, name: u"%237%20STX-MEME7"}) (map-set results {id: "f33529b4-b567-4e23-abaf-45898379ca5b"} {count: u0, name: u"%238%20STX-MEME8"}) (map-set results {id: "b171ca22-4655-423e-b3d0-d522a765561c"} {count: u0, name: u"%239%20STX-MEME9"}) (map-set results {id: "9f3ae573-8a50-4013-9c9d-12d3d583307c"} {count: u0, name: u"%2310%20STX-MEME10"}) (map-set results {id: "04b1858a-9237-49f8-a1b0-74f5c58391b7"} {count: u0, name: u"%2311%20STX-MEME11"}) (map-set results {id: "bf7b38e5-bef8-4018-931c-85b29c2495df"} {count: u0, name: u"%2312%20STX-MEME12"}) (map-set results {id: "898d4c96-3b14-4aec-8ae7-462da647b281"} {count: u0, name: u"%2313%20STX-MEME13"}) (map-set results {id: "a1112717-eb24-49bb-b879-12123a37b0d0"} {count: u0, name: u"%2314%20STX-MEME14"})