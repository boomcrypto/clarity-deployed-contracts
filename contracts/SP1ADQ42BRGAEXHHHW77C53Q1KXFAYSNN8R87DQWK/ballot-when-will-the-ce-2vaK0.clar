
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
    (define-map users {id: principal} {id: uint, vote: (list 7 (string-ascii 36)), volume: (list 7 uint), voting-power: uint})
    (define-map register {id: uint} {user: principal, vote: (list 7 (string-ascii 36)), volume: (list 7 uint), voting-power: uint})
    (define-data-var total uint u0)
    (define-data-var total-votes uint u0)
    (define-data-var options (list 7 (string-ascii 36)) (list))
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

    (define-private (validate-vote-volume (volume (list 7 uint)))
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
    (define-public (cast-my-vote (vote (list 7 (string-ascii 36))) (volume (list 7 uint))
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
    (var-set title u"When%20will%20the%20Centers%20for%20Medicare%20and%20Medicaid%20Services%20issue%20new%20regulatory%20guidance%20or%20proposed%20rule%20to%20authorize%20coverage%20of%20GLP-1%20medications%20for%20weight%20loss%3F")
    (var-set description u"On%20April%204%202025%2C%20CMS%20published%20its%20final%20rule%20for%20the%20Medicare%20Advantage%20Program%2C%20Medicare%20Prescription%20Drug%20Benefit%20Program%2C%20Medicare%20Cost%20Plan%20Program%2C%20and%20Programs%20of%20All-Inclusive%20Care%20for%20the%20Elderly%20(CMS-4208-F).%20The%20final%20rule%20did%20not%20expand%20coverage%20of%20GLP-1%20medications%20for%20weight%20loss.%20CMS%20signaled%20the%20possibility%20of%20revisiting%20GLP-1%20coverage%20in%20future%20rulemaking.")
    (var-set voting-system "fptp")
    (var-set options (list "7064eff3-4435-4ebf-ab23-0140159eeada" "8587e661-d451-42ca-9d46-a6ffe8516f4e" "f6602655-17af-409f-b11c-390eacf01c44" "8c44adc2-67c2-41cd-940c-77330610fd23" "998d07e3-adbb-41d3-86c7-20b5145e7c89" "904c64ec-fcc0-48fe-868d-39d5f177da0f" "2b1ad262-3b09-415e-bb9d-95ede0a6bb23"))
    (var-set start u194400)
    (var-set end u283020)
    (map-set results {id: "7064eff3-4435-4ebf-ab23-0140159eeada"} {count: u0, name: u"2nd%20quarter%20of%202025"}) (map-set results {id: "8587e661-d451-42ca-9d46-a6ffe8516f4e"} {count: u0, name: u"3rd%20quarter%20of%202025"}) (map-set results {id: "f6602655-17af-409f-b11c-390eacf01c44"} {count: u0, name: u"4th%20quarter%20of%202025"}) (map-set results {id: "8c44adc2-67c2-41cd-940c-77330610fd23"} {count: u0, name: u"1st%20quarter%20of%202026"}) (map-set results {id: "998d07e3-adbb-41d3-86c7-20b5145e7c89"} {count: u0, name: u"2nd%20quarter%20of%202026"}) (map-set results {id: "904c64ec-fcc0-48fe-868d-39d5f177da0f"} {count: u0, name: u"3rd%20quarter%20of%202026"}) (map-set results {id: "2b1ad262-3b09-415e-bb9d-95ede0a6bb23"} {count: u0, name: u"4th%20quarter%20of%202026"})