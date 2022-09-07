;; ballot

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Constants
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (define-constant CONTRACT-OWNER tx-sender)
    ;; Errors
    (define-constant ERR-NOT-OWNER (err u1403))
    (define-constant ERR-NOT-STARTED (err u1001))
    (define-constant ERR-ENDED (err u1002))
    (define-constant ERR-ALREADY-VOTED (err u1003))
    (define-constant ERR-INVALID-VOTING-SYSTEM (err u1004))
    (define-constant ERR-NOT-HOLDING-BTC-DNS (err u1005))
    (define-constant ERR-FAILED-STRATEGY (err u1006))
    (define-constant ERR-NOT-VOTED (err u1007))
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; data maps and vars
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (define-data-var title (string-utf8 512) u"")
    (define-data-var description (string-utf8 512) u"")
    (define-data-var voting-system (string-ascii 10) "")
    (define-data-var start uint u0)
    (define-data-var end uint u0)
    (define-data-var should-be-a-bns-holder bool false)
    (define-map results {id: (string-ascii 36)} {count: uint, name: (string-utf8 512)} )
    (define-map users {id: principal} {count: uint, vote: (list 2 (string-ascii 36)), volume: (list 2 uint)})
    (define-map register {id: uint} {user: principal, bns: (string-ascii 256), vote: (list 2 (string-ascii 36)), volume: (list 2 uint)})
    (define-data-var total uint u0)
    (define-data-var options (list 2 (string-ascii 36)) (list))
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; private functions
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    
    (define-private (have-i-voted)
        (match (map-get? users {id: tx-sender})
            success true
            false
        )
    )
    
    (define-private (voting-system-validation (length uint))
        (if (is-eq (var-get voting-system) "single")
            (if (is-eq length u1)
                true
                false
            )
            true
        )
    )
    
    (define-private (am-i-btc-dns-holder (domain (buff 20)) (namespace (buff 48)))
    (let 
        (
            (dns-owner (get owner (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve domain namespace))))
        )

        (if (and (is-eq domain 0x627463) (is-eq tx-sender dns-owner))
            true
            false
        )
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
            (begin
                (map-set results {id: option-id} {count: u1, name: u""})
    
                ;; Return
                true
            )
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
        (bns (string-ascii 256)) (domain (buff 20)) (namespace (buff 48)) (token-id uint)
        )
        (let
            (
                (next-total (+ u1 (var-get total)))
            )
            ;; Validation
            (asserts! (and (> (len vote) u0) (is-eq (len vote) (len volume)) (validate-vote-volume volume)) ERR-NOT-VOTED)        
            (asserts! (voting-system-validation (len vote)) ERR-INVALID-VOTING-SYSTEM)
            (asserts! (>= block-height (var-get start)) ERR-NOT-STARTED)
            (asserts! (<= block-height (var-get end)) ERR-ENDED)
            (asserts! (not (have-i-voted)) ERR-ALREADY-VOTED)
            (asserts! (am-i-btc-dns-holder domain namespace) ERR-NOT-HOLDING-BTC-DNS)
            
    
            ;; Register the vote
            (map process-my-vote vote volume)
            (map-set users {id: tx-sender} {count: u1, vote: vote, volume: volume})
            (map-set register {id: next-total} {user: tx-sender, bns: bns, vote: vote, volume: volume})
    
            ;; Increase the total
            (var-set total next-total)
    
            ;; Return
            (ok true)
        )
    )
    
    (define-read-only (get-results)
        (begin
            (ok {total: (var-get total),options: (var-get options), results: (map get-single-result (var-get options))})
        )
    )
    
    (define-read-only (get-result-at-position (position uint))
        (ok (map-get? register {id: position}))
    )
    
    (define-read-only (get-result-by-user (user principal))
        (ok (map-get? users {id: user}))
    )
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; public functions for contract owner
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Default assignments
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (var-set title u"Do you hold .btc?")
    (var-set description u"Just testing gated .btc holders for voting")
    (var-set voting-system "single")
    (var-set options (list "37a9230b-e929-46e3-bc9e-267fd06405d4" "9a931a14-d099-495a-a565-301c6fdc366a"))
    (var-set start u74730)
    (var-set end u74872)
    (map-set results {id: "37a9230b-e929-46e3-bc9e-267fd06405d4"} {count: u0, name: u"Choice 1"}) (map-set results {id: "9a931a14-d099-495a-a565-301c6fdc366a"} {count: u0, name: u"Choice 2"})