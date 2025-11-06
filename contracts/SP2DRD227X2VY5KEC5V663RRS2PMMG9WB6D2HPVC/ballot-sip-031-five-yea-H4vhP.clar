
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
    (define-map users {id: principal} {id: uint, vote: (list 2 (string-ascii 36)), volume: (list 2 uint), voting-power: uint, locked-stx: uint, unlocked-stx: uint})
    (define-map register {id: uint} {user: principal, vote: (list 2 (string-ascii 36)), volume: (list 2 uint), voting-power: uint, locked-stx: uint, unlocked-stx: uint})
    (define-data-var total uint u0)
    (define-data-var total-votes uint u0)
    (define-data-var options (list 2 (string-ascii 36)) (list))
    (define-data-var temp-voting-power uint u0)
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; private functions
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
        (define-private (get-voting-power-by-stx-holdings)
            (at-block (unwrap-panic (get-stacks-block-info? id-header-hash u4165832))
                (let
                    (
                        (acct (stx-account tx-sender))
                        (locked (get locked acct))
                        (unlocked (get unlocked acct))
                        (stx-balance (+ (get unlocked acct) (get locked acct)))
                    )
                    (if (> stx-balance u0)
                        (/ stx-balance u1000000)
                        stx-balance
                    )
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

    (define-private (validate-vote-volume (volume (list 2 uint)))
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

    
        (define-private (get-stx-balance-with-locked-and-unlocked)
            (at-block (unwrap-panic (get-stacks-block-info? id-header-hash u4165832))
                (let
                    (
                        (account (stx-account tx-sender))
                        (locked-stx (get locked account))
                        (unlocked-stx (get unlocked account))
                        (total-stx (+ locked-stx unlocked-stx))
                    )
    
                    ;; Return the stx balance with locked and unlocked
                    {
                        locked-stx: (if (> locked-stx u0) (/ locked-stx u1000000) locked-stx), 
                        unlocked-stx: (if (> unlocked-stx u0) (/ unlocked-stx u1000000) unlocked-stx), 
                        total-stx: (if (> total-stx u0) (/ total-stx u1000000) total-stx)
                    }
                )
            )
        )
    
        (define-private (register-stx-with-locked-and-unlocked (option-id (string-ascii 36)) (volume uint))
            (match (map-get? results {id: option-id})
                result (let
                        (
                            (stx-balance-with-locked-and-unlocked (get-stx-balance-with-locked-and-unlocked))
                            (new-count-tuple {
                                locked-stx: (+ (get locked-stx stx-balance-with-locked-and-unlocked) (get locked-stx result)), 
                                unlocked-stx: (+ (get unlocked-stx stx-balance-with-locked-and-unlocked) (get unlocked-stx result))
                            })
                        )
    
                        ;; If the volume is greater than zero, then register the stx
                        (if (> volume u0)
                            (map-set results {id: option-id} (merge result new-count-tuple))
                            true
                        )
    
                        ;; Return
                        true
                    )
                true
            )
        )
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; public functions for all
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (define-public (cast-my-vote (vote (list 2 (string-ascii 36))) (volume (list 2 uint))
        (bns (string-ascii 256)) (domain (buff 20)) (namespace (buff 48)) (token-ids (list 60000 uint))
        )
        (let
            (
                (vote-id (+ u1 (var-get total)))
                (voting-power (get-voting-power-by-stx-holdings))
                
                ;; FPTP and Block voting
                (temp (var-set temp-voting-power voting-power))
                (volume-by-voting-power (map get-volume-by-voting-power volume))
            
                
                ;; FPTP and Block voting - Number of votes
                (my-votes voting-power)

                ;; Get the stx balance with locked and unlocked
                (stx-balance-with-locked-and-unlocked (get-stx-balance-with-locked-and-unlocked))
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

            
        ;; Register stx with locked and unlocked
        (map register-stx-with-locked-and-unlocked vote volume-by-voting-power)
            
            ;; Register for reference
            (map-set users {id: tx-sender} {id: vote-id, vote: vote, volume: volume-by-voting-power, voting-power: voting-power , locked-stx: (get locked-stx stx-balance-with-locked-and-unlocked), unlocked-stx: (get unlocked-stx stx-balance-with-locked-and-unlocked)})
            (map-set register {id: vote-id} {user: tx-sender, vote: vote, volume: volume-by-voting-power, voting-power: voting-power , locked-stx: (get locked-stx stx-balance-with-locked-and-unlocked), unlocked-stx: (get unlocked-stx stx-balance-with-locked-and-unlocked)})

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
    (var-set title u"SIP-031%3A%20Five-Year%20Stacks%20Growth%20Emissions")
    (var-set description u"%3Cp%3ESIP-031%20proposed%20the%20creation%20of%20a%20growth-focused%20Stacks%20Endowment%20and%20streamlined%20ecosystem%20structure.%3C%2Fp%3E%3Cul%3E%3Cli%3E%3Ca%20href%3D%22https%3A%2F%2Fgithub.com%2Fstacksgov%2Fsips%2Fblob%2F52da2c4c92f5f325f5c82e6a54c7d2adbf576e52%2Fsips%2Fsip-031%2Fsip-031.md%22%20rel%3D%22noopener%20noreferrer%22%20target%3D%22_blank%22%20style%3D%22color%3A%20inherit%3B%22%3Esip031-stacks-growth-emissions%3C%2Fa%3E%3C%2Fli%3E%3C%2Ful%3E")
    (var-set voting-system "fptp")
    (var-set options (list "16ffa061-fc9b-4e80-b198-98e5842bafeb" "11c9d342-a798-4f49-81df-6e1e57fc01f2"))
    (var-set start u918941)
    (var-set end u919941)
    (map-set results {id: "16ffa061-fc9b-4e80-b198-98e5842bafeb"} {count: u0, name: u"For", locked-stx: u0, unlocked-stx: u0}) (map-set results {id: "11c9d342-a798-4f49-81df-6e1e57fc01f2"} {count: u0, name: u"Against", locked-stx: u0, unlocked-stx: u0})