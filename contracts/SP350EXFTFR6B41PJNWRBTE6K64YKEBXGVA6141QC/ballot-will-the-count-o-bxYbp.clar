
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
    (define-map results {id: (string-ascii 36)} {count: uint, name: (string-utf8 256), locked-stx: uint, unlocked-stx: uint} )
    (define-map users {id: principal} {id: uint, vote: (list 13 (string-ascii 36)), volume: (list 13 uint), voting-power: uint, locked-stx: uint, unlocked-stx: uint})
    (define-map register {id: uint} {user: principal, vote: (list 13 (string-ascii 36)), volume: (list 13 uint), voting-power: uint, locked-stx: uint, unlocked-stx: uint})
    (define-data-var total uint u0)
    (define-data-var total-votes uint u0)
    (define-data-var options (list 13 (string-ascii 36)) (list))
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

    (define-private (validate-vote-volume (volume (list 13 uint)))
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

    (define-private (get-single-result-with-locked-and-unlocked-stx (option-id (string-ascii 36)))
        (let 
            (
                (locked-stx (default-to u0 (get locked-stx (map-get? results {id: option-id}))))
                (unlocked-stx (default-to u0 (get unlocked-stx (map-get? results {id: option-id}))))
            )

            ;; Return locked-stx and unlocked-stx
            {locked-stx: locked-stx, unlocked-stx: unlocked-stx}
        )
    )

    
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; public functions for all
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (define-public (cast-my-vote (vote (list 13 (string-ascii 36))) (volume (list 13 uint))
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

                ;; Get the stx balance with locked and unlocked
                
            )
            ;; Validation
            (asserts! (and (> (len vote) u0) (is-eq (len vote) (len volume-by-voting-power)) (validate-vote-volume volume-by-voting-power)) ERR-NOT-VOTED)
            (asserts! (>= burn-block-height (var-get start)) ERR-NOT-STARTED)
            (asserts! (<= burn-block-height (var-get end)) ERR-ENDED)        
            (asserts! (not (have-i-voted)) ERR-ALREADY-VOTED)
            
                ;; FPTP and Block voting
                (asserts! (> voting-power u0) ERR-FAILED-STRATEGY)
            
            ;; Business logic
            ;; Process my vote
            (map process-my-vote vote volume-by-voting-power)

            
            
            ;; Register for reference
            (map-set users {id: tx-sender} {id: vote-id, vote: vote, volume: volume-by-voting-power, voting-power: voting-power , locked-stx: u0, unlocked-stx: u0})
            (map-set register {id: vote-id} {user: tx-sender, vote: vote, volume: volume-by-voting-power, voting-power: voting-power , locked-stx: u0, unlocked-stx: u0})

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
                    results: (map get-single-result (var-get options)),
                    results-with-locked-and-unlocked-stx: (map get-single-result-with-locked-and-unlocked-stx (var-get options))
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
    (var-set title u"Will%20the%20count%20of%20unconfirmed%20Bitcoin%20transactions%20reach%20500%2C000%20in%202026%3F")
    (var-set description u"%3Cp%3EThis%20question%20will%20resolve%20via%20data%20reported%20on%20the%20Bitcoin%20mempool.%3C%2Fp%3E")
    (var-set voting-system "fptp")
    (var-set options (list "3fd6eca3-b3a2-471c-bd2f-88a19616c39b" "a5d25e67-5b2e-4d85-a6c9-1a8901b2e166" "032b3dc8-b5a8-42db-b711-bd445dc26263" "24c3dcc4-afc8-462c-91fd-85145dd417eb" "a42b9a56-a360-482f-8721-8cb447a4f563" "7d0bff99-b2d5-42bc-8651-67dc2cc80259" "752a45e5-5b72-4910-879b-e6cd69aa4047" "ee219749-d612-4e45-9837-a8d92b17a72f" "1a42507d-15ed-4016-ad7f-18262bcff60d" "7fe33696-c824-4cdc-9b6f-4a078fd63a9f" "18e64638-2118-4503-95fa-bd63b3e5d8cc" "f51d79e5-379c-45ff-bc0c-8df394b95d41" "4b283b37-8009-4280-9878-cca803139893"))
    (var-set start u919221)
    (var-set end u978702)
    (map-set results {id: "3fd6eca3-b3a2-471c-bd2f-88a19616c39b"} {count: u0, name: u"Not%20happening%20in%202026", locked-stx: u0, unlocked-stx: u0}) (map-set results {id: "a5d25e67-5b2e-4d85-a6c9-1a8901b2e166"} {count: u0, name: u"January", locked-stx: u0, unlocked-stx: u0}) (map-set results {id: "032b3dc8-b5a8-42db-b711-bd445dc26263"} {count: u0, name: u"February", locked-stx: u0, unlocked-stx: u0}) (map-set results {id: "24c3dcc4-afc8-462c-91fd-85145dd417eb"} {count: u0, name: u"March", locked-stx: u0, unlocked-stx: u0}) (map-set results {id: "a42b9a56-a360-482f-8721-8cb447a4f563"} {count: u0, name: u"April", locked-stx: u0, unlocked-stx: u0}) (map-set results {id: "7d0bff99-b2d5-42bc-8651-67dc2cc80259"} {count: u0, name: u"May", locked-stx: u0, unlocked-stx: u0}) (map-set results {id: "752a45e5-5b72-4910-879b-e6cd69aa4047"} {count: u0, name: u"June", locked-stx: u0, unlocked-stx: u0}) (map-set results {id: "ee219749-d612-4e45-9837-a8d92b17a72f"} {count: u0, name: u"July", locked-stx: u0, unlocked-stx: u0}) (map-set results {id: "1a42507d-15ed-4016-ad7f-18262bcff60d"} {count: u0, name: u"August", locked-stx: u0, unlocked-stx: u0}) (map-set results {id: "7fe33696-c824-4cdc-9b6f-4a078fd63a9f"} {count: u0, name: u"September", locked-stx: u0, unlocked-stx: u0}) (map-set results {id: "18e64638-2118-4503-95fa-bd63b3e5d8cc"} {count: u0, name: u"October", locked-stx: u0, unlocked-stx: u0}) (map-set results {id: "f51d79e5-379c-45ff-bc0c-8df394b95d41"} {count: u0, name: u"November", locked-stx: u0, unlocked-stx: u0}) (map-set results {id: "4b283b37-8009-4280-9878-cca803139893"} {count: u0, name: u"December", locked-stx: u0, unlocked-stx: u0})