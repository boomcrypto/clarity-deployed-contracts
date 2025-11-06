
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
    (define-map users {id: principal} {id: uint, vote: (list 2 (string-ascii 36)), volume: (list 2 uint), voting-power: uint})
    (define-map register {id: uint} {user: principal, vote: (list 2 (string-ascii 36)), volume: (list 2 uint), voting-power: uint})
    (define-data-var total uint u0)
    (define-data-var total-votes uint u0)
    (define-data-var options (list 2 (string-ascii 36)) (list))
    (define-data-var temp-voting-power uint u0)
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; private functions
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    
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
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; public functions for all
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (define-public (cast-my-vote (vote (list 2 (string-ascii 36))) (volume (list 2 uint))
        (bns (string-ascii 256)) (domain (buff 20)) (namespace (buff 48)) (token-ids (list 60000 uint))
        )
        (let
            (
                (vote-id (+ u1 (var-get total)))
                (voting-power (fold + volume u0))
                
                ;; Quadratic or Weighted voting
                (volume-by-voting-power volume)
                
                ;; Quadratic or Weighted voting - Number of votes
                (my-votes (fold + volume u0))
            )
            ;; Validation
            (asserts! (and (> (len vote) u0) (is-eq (len vote) (len volume-by-voting-power)) (validate-vote-volume volume-by-voting-power)) ERR-NOT-VOTED)
            (asserts! (>= tenure-height (var-get start)) ERR-NOT-STARTED)
            (asserts! (<= tenure-height (var-get end)) ERR-ENDED)        
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
    (var-set title u"SIP-031%3A%20Clarity%204")
    (var-set description u"here%20are%20several%20new%20Clarity%20features%20in%20demand%20by%20some%20vital%20ecosystem%20projects%2C%20including%20bridges%20and%20marketplaces.%20This%20proposal%2C%20for%20Clarity%204%2C%20adds%20four%20key%20features%3A%20(1)%20A%20new%20Clarity%20function%20to%20fetch%20the%20hash%20of%20a%20contract%E2%80%99s%20code%20body.%20(2)%20A%20new%20set%20of%20Clarity%20functions%20to%20allow%20a%20contract%20to%20set%20post-conditions%20to%20protect%20its%20assets.%20(3)%20A%20new%20Clarity%20function%")
    (var-set voting-system "weighted")
    (var-set options (list "4ce8e2b5-d307-4871-a594-603e05b4b32b" "d0c9f511-582e-400d-b9ea-2f0f6b20bb6a"))
    (var-set start u214419)
    (var-set end u215500)
    (map-set results {id: "4ce8e2b5-d307-4871-a594-603e05b4b32b"} {count: u0, name: u"Yes%2C%20approve%20upgrade%20to%20Clarity%204"}) (map-set results {id: "d0c9f511-582e-400d-b9ea-2f0f6b20bb6a"} {count: u0, name: u"No%2C%20deny%20upgrade%20to%20Clarity%204"})