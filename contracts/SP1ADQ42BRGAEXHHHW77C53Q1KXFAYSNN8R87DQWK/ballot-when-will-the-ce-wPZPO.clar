
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
    (define-map users {id: principal} {id: uint, vote: (list 8 (string-ascii 36)), volume: (list 8 uint), voting-power: uint})
    (define-map register {id: uint} {user: principal, vote: (list 8 (string-ascii 36)), volume: (list 8 uint), voting-power: uint})
    (define-data-var total uint u0)
    (define-data-var total-votes uint u0)
    (define-data-var options (list 8 (string-ascii 36)) (list))
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

    (define-private (validate-vote-volume (volume (list 8 uint)))
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
    (define-public (cast-my-vote (vote (list 8 (string-ascii 36))) (volume (list 8 uint))
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
    (var-set title u"When%20will%20the%20Centers%20for%20Medicare%20and%20Medicaid%20Services%20issue%20new%20regulatory%20guidance%20or%20proposed%20rule%20on%20the%20use%20of%20AI%20for%20prior%20authorization%20of%20medical%20care%3F")
    (var-set description u"On%20April%204%202025%2C%20CMS%20published%20its%20final%20rule%20for%20the%20Medicare%20Advantage%20Program%2C%20Medicare%20Prescription%20Drug%20Benefit%20Program%2C%20Medicare%20Cost%20Plan%20Program%2C%20and%20Programs%20of%20All-Inclusive%20Care%20for%20the%20Elderly%20(CMS-4208-F).%20The%20final%20rule%20did%20not%20resolve%20the%20issue%20of%20the%20use%20of%20AI%20in%20prior%20authorization%20and%20the%20agency%20said%20it%20will%20put%20forth%20regulations%20related%20to%20AI%20in%20future%20rulema")
    (var-set voting-system "fptp")
    (var-set options (list "c8ccb470-ba9d-4941-bae9-b49584df215a" "5bbe027c-1d7b-4399-b27d-1c730bde5763" "3575a9d7-1072-4875-92f8-2d6628200a45" "761c620d-dc6b-4fac-a93c-e6ff8e6ad92c" "4364e9d8-be27-44af-97c0-ff519e396c8a" "5f8ab213-d466-4314-8e31-d0b72161a9a8" "7001e5d6-444f-4cf8-a735-0707baeea6ff" "13ec5762-c312-47bd-9ea8-15184590b864"))
    (var-set start u192736)
    (var-set end u283024)
    (map-set results {id: "c8ccb470-ba9d-4941-bae9-b49584df215a"} {count: u0, name: u"2nd%20quarter%20of%202025"}) (map-set results {id: "5bbe027c-1d7b-4399-b27d-1c730bde5763"} {count: u0, name: u"3rd%20quarter%20of%202025"}) (map-set results {id: "3575a9d7-1072-4875-92f8-2d6628200a45"} {count: u0, name: u"4th%20quarter%20of%202025"}) (map-set results {id: "761c620d-dc6b-4fac-a93c-e6ff8e6ad92c"} {count: u0, name: u"1st%20quarter%20of%202026"}) (map-set results {id: "4364e9d8-be27-44af-97c0-ff519e396c8a"} {count: u0, name: u"2nd%20quarter%20of%202026"}) (map-set results {id: "5f8ab213-d466-4314-8e31-d0b72161a9a8"} {count: u0, name: u"3rd%20quarter%20of%202026"}) (map-set results {id: "7001e5d6-444f-4cf8-a735-0707baeea6ff"} {count: u0, name: u"4th%20quarter%20of%202026"}) (map-set results {id: "13ec5762-c312-47bd-9ea8-15184590b864"} {count: u0, name: u"Not%20before%201st%20quarter%20of%202027"})