
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
    (define-map users {id: principal} {id: uint, vote: (list 10 (string-ascii 36)), volume: (list 10 uint), voting-power: uint})
    (define-map register {id: uint} {user: principal, vote: (list 10 (string-ascii 36)), volume: (list 10 uint), voting-power: uint})
    (define-data-var total uint u0)
    (define-data-var total-votes uint u0)
    (define-data-var options (list 10 (string-ascii 36)) (list))
    (define-data-var temp-voting-power uint u0)
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; private functions
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    (define-private (get-voting-power-by-ft-holdings)
        (let
            (
                (ft-balance (unwrap-panic (contract-call? 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.fari-token-mn get-balance tx-sender)))
                (ft-decimals (unwrap-panic (contract-call? 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.fari-token-mn get-decimals)))
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

    (define-private (validate-vote-volume (volume (list 10 uint)))
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
    (define-public (cast-my-vote (vote (list 10 (string-ascii 36))) (volume (list 10 uint))
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
    (var-set title u"Which%20Conference%20Should%20the%20Bitfari%20Team%20Visit%20Next%3F")
    (var-set description u"Which%20Conference%20Should%20the%20Bitfari%20Team%20Visit%20Next%3F%20It%20could%20be%20anywhere%20in%20the%20world.")
    (var-set voting-system "fptp")
    (var-set options (list "b6bc9b60-6d11-426f-b873-785795b6eba3" "c51daa2f-e5cb-422f-8731-ec7bd729dac8" "ac6e7087-6944-435e-aa44-ce8ce520d06e" "8a35c537-9ad9-4d42-b0be-b3931085548a" "afda8bbc-70f4-4455-b505-dac523f28aff" "8d1e692c-2ed3-4e58-be44-8eeeeca6d187" "e73f9969-78ad-4f06-ab52-ec1bdafe77b9" "834d664f-6ed3-4662-aa1c-6e321c999a7e" "52688b91-cfa3-4ad9-bd80-56dc44e370ac" "62382a7f-15d7-4f6e-a5e0-05f301d9864f"))
    (var-set start u144783)
    (var-set end u153567)
    (map-set results {id: "b6bc9b60-6d11-426f-b873-785795b6eba3"} {count: u0, name: u"Bitcoin%20Conference"}) (map-set results {id: "c51daa2f-e5cb-422f-8731-ec7bd729dac8"} {count: u0, name: u"Consensus"}) (map-set results {id: "ac6e7087-6944-435e-aa44-ce8ce520d06e"} {count: u0, name: u"Eth%20Denver"}) (map-set results {id: "8a35c537-9ad9-4d42-b0be-b3931085548a"} {count: u0, name: u"Blockchain%20Africa"}) (map-set results {id: "afda8bbc-70f4-4455-b505-dac523f28aff"} {count: u0, name: u"Paris%20Blockchain%20Week"}) (map-set results {id: "8d1e692c-2ed3-4e58-be44-8eeeeca6d187"} {count: u0, name: u"WebX"}) (map-set results {id: "e73f9969-78ad-4f06-ab52-ec1bdafe77b9"} {count: u0, name: u"NexTech%20Week%20Tokyo"}) (map-set results {id: "834d664f-6ed3-4662-aa1c-6e321c999a7e"} {count: u0, name: u"Blockchance%2024"}) (map-set results {id: "52688b91-cfa3-4ad9-bd80-56dc44e370ac"} {count: u0, name: u"TOKEN2049%20in%20Singapore"}) (map-set results {id: "62382a7f-15d7-4f6e-a5e0-05f301d9864f"} {count: u0, name: u"Other"})