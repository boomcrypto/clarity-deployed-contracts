
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
    (define-map users {id: principal} {id: uint, vote: (list 12 (string-ascii 36)), volume: (list 12 uint), voting-power: uint})
    (define-map register {id: uint} {user: principal, vote: (list 12 (string-ascii 36)), volume: (list 12 uint), voting-power: uint})
    (define-data-var total uint u0)
    (define-data-var total-votes uint u0)
    (define-data-var options (list 12 (string-ascii 36)) (list))
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

    (define-private (validate-vote-volume (volume (list 12 uint)))
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
    (define-public (cast-my-vote (vote (list 12 (string-ascii 36))) (volume (list 12 uint))
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
    (var-set title u"Over%20the%20next%2012%20months%2C%20when%20will%20the%20count%20of%20unconfirmed%20transactions%20on%20the%20Bitcoin%20network%20exceed%20100%2C000%3F")
    (var-set description u"This%20question%20will%20resolve%20via%20data%20reported%20on%20the%20Bitcoin%20mempool.")
    (var-set voting-system "fptp")
    (var-set options (list "dacdd0ca-3696-44b2-ba08-55480f0f66f1" "11053c15-dd14-49f7-907d-9b98e2287b41" "8a0e82ce-48f0-4c36-afe7-cacf6cbb72de" "ad8d813a-1aab-4727-a541-cfa203484d28" "269b1e47-8637-4aa3-8034-3fd89983dbb6" "c2b19a5e-39e8-44f3-898c-48e70680c05d" "a34f52ba-ad00-4263-8b86-a3008e976b65" "efec97ea-0ec8-4e5a-b053-f8f4f290f229" "ad6cfcd8-a277-4bc5-a199-00265f7692ee" "092b5609-38e9-4db7-b8b1-8bcf943ed7e6" "b3e61170-ede2-4caa-80b7-6a812b096626" "401e5eaa-0cd5-4dcc-a39e-9b895e6b438a"))
    (var-set start u195866)
    (var-set end u247274)
    (map-set results {id: "dacdd0ca-3696-44b2-ba08-55480f0f66f1"} {count: u0, name: u"May%202025"}) (map-set results {id: "11053c15-dd14-49f7-907d-9b98e2287b41"} {count: u0, name: u"June%202025"}) (map-set results {id: "8a0e82ce-48f0-4c36-afe7-cacf6cbb72de"} {count: u0, name: u"July%202025"}) (map-set results {id: "ad8d813a-1aab-4727-a541-cfa203484d28"} {count: u0, name: u"August%202025"}) (map-set results {id: "269b1e47-8637-4aa3-8034-3fd89983dbb6"} {count: u0, name: u"September%202025"}) (map-set results {id: "c2b19a5e-39e8-44f3-898c-48e70680c05d"} {count: u0, name: u"October%202025"}) (map-set results {id: "a34f52ba-ad00-4263-8b86-a3008e976b65"} {count: u0, name: u"November%202025"}) (map-set results {id: "efec97ea-0ec8-4e5a-b053-f8f4f290f229"} {count: u0, name: u"December%202025"}) (map-set results {id: "ad6cfcd8-a277-4bc5-a199-00265f7692ee"} {count: u0, name: u"January%202026"}) (map-set results {id: "092b5609-38e9-4db7-b8b1-8bcf943ed7e6"} {count: u0, name: u"February%202026"}) (map-set results {id: "b3e61170-ede2-4caa-80b7-6a812b096626"} {count: u0, name: u"March%202026"}) (map-set results {id: "401e5eaa-0cd5-4dcc-a39e-9b895e6b438a"} {count: u0, name: u"April%202026"})