
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
    (define-map users {id: principal} {id: uint, vote: (list 4 (string-ascii 36)), volume: (list 4 uint), voting-power: uint, locked-stx: uint, unlocked-stx: uint})
    (define-map register {id: uint} {user: principal, vote: (list 4 (string-ascii 36)), volume: (list 4 uint), voting-power: uint, locked-stx: uint, unlocked-stx: uint})
    (define-data-var total uint u0)
    (define-data-var total-votes uint u0)
    (define-data-var options (list 4 (string-ascii 36)) (list))
    (define-data-var temp-voting-power uint u0)
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; private functions
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    (define-private (validate-nft-ownership (token-id uint))
        (let
            (
                (vote-id (+ u1 (var-get total)))
                (nft-owner-optional (unwrap-panic (contract-call? 'SP1T0VY3DNXRVP6HBM75DFWW0199CR0X15PC1D81B.teiko-labs get-owner token-id)))
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

    (define-private (validate-vote-volume (volume (list 4 uint)))
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
    (define-public (cast-my-vote (vote (list 4 (string-ascii 36))) (volume (list 4 uint))
        (bns (string-ascii 256)) (domain (buff 20)) (namespace (buff 48)) (token-ids (list 60000 uint))
        )
        (let
            (
                (vote-id (+ u1 (var-get total)))
                (voting-power (get-voting-power-by-nft-holdings token-ids))
                
                ;; Quadratic or Weighted voting
                (volume-by-voting-power volume)
                
                ;; Quadratic or Weighted voting - Number of votes
                (my-votes (fold + volume u0))

                ;; Get the stx balance with locked and unlocked
                
            )
            ;; Validation
            (asserts! (and (> (len vote) u0) (is-eq (len vote) (len volume-by-voting-power)) (validate-vote-volume volume-by-voting-power)) ERR-NOT-VOTED)
            (asserts! (>= burn-block-height (var-get start)) ERR-NOT-STARTED)
            (asserts! (<= burn-block-height (var-get end)) ERR-ENDED)        
            (asserts! (not (have-i-voted)) ERR-ALREADY-VOTED)
            
                ;; Weigted voting
                (asserts! (>= voting-power (fold + volume-by-voting-power u0)) ERR-FAILED-STRATEGY)
            
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
    (var-set title u"%F0%9F%9A%80%20Community%20Vote%3A%201%20Million%20TEIKO%20Airdrop%20Allocation!")
    (var-set description u"%3Cp%3E%3Cstrong%3E%F0%9F%AA%82%20TEIKO%20Community%20Airdrop%20Vote!%3C%2Fstrong%3E%3C%2Fp%3E%3Cp%3EWe%E2%80%99re%20dropping%20%3Cstrong%3E1%2C000%2C000%20TEIKO%20tokens%3C%2Fstrong%3E%2C%20but%20it%E2%80%99s%20up%20to%20the%20community%20to%20decide%20%3Cstrong%3Ewho%20gets%20rewarded%3C%2Fstrong%3E.%20Cast%20your%20vote%20below%20%F0%9F%91%87%3C%2Fp%3E%3Cp%3E%F0%9F%92%A0%20%3Cstrong%3EAirdrop%20Date%3A%3C%2Fstrong%3E%20%3Cstrong%3EFriday%2C%20November%207th%3C%2Fstrong%3E%3C%2Fp%3E%3Cp%3E%3Cstrong%3EWho%")
    (var-set voting-system "weighted")
    (var-set options (list "d4c8f297-b6d8-4cd5-b42c-4341574a87f4" "c7ed1882-7446-437e-b5c8-d6c7001162b4" "7c60aa7e-c8f0-4165-a2a9-55272d3cef13" "0466c98e-2a3b-4e0a-83e3-20f826ba76b9"))
    (var-set start u921395)
    (var-set end u922680)
    (map-set results {id: "d4c8f297-b6d8-4cd5-b42c-4341574a87f4"} {count: u0, name: u"Top%2010%20%24MAS%20Holders%20", locked-stx: u0, unlocked-stx: u0}) (map-set results {id: "c7ed1882-7446-437e-b5c8-d6c7001162b4"} {count: u0, name: u"%24LEO%20Holders", locked-stx: u0, unlocked-stx: u0}) (map-set results {id: "7c60aa7e-c8f0-4165-a2a9-55272d3cef13"} {count: u0, name: u"muneeb.btc%20wallet", locked-stx: u0, unlocked-stx: u0}) (map-set results {id: "0466c98e-2a3b-4e0a-83e3-20f826ba76b9"} {count: u0, name: u"%24sbtc%20Holders%20", locked-stx: u0, unlocked-stx: u0})