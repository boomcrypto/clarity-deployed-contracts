;; SPDX-License-Identifier: BUSL-1.1

;; alex-voting-v1-01
;; A voting contract that uses voting power to weight votes

(use-trait alex-voting-power .alex-voting-power-trait.alex-voting-power)

;; Error codes
(define-constant err-not-found (err u1000))
(define-constant err-voting-ended (err u1001))
(define-constant err-already-voted (err u1002))
(define-constant err-invalid-option (err u1003))
(define-constant err-get-block-info (err u1005))
(define-constant err-no-options (err u1008))
(define-constant err-not-authorized (err u1009))
(define-constant err-invalid-snapshot (err u1010))
(define-constant err-invalid-voting-power-contract (err u1011))
(define-constant err-not-vote-creator (err u1012))
(define-constant err-invalid-timestamps (err u1013))

;; Data vars
(define-data-var vote-nonce uint u0)
(define-data-var voting-power-contract principal 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-voting-power-v1-01)

;; Authorization check
(define-read-only (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao) 
                    (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao is-extension contract-caller)) 
                err-not-authorized)))

;; Governance functions
(define-public (set-voting-power-contract (new-contract principal))
  (begin
    (try! (is-dao-or-extension))
    (ok (var-set voting-power-contract new-contract))))

;; Read-only functions
(define-read-only (get-voting-power-contract)
  (ok (var-get voting-power-contract)))

;; Data maps
(define-map votes uint {
    creator: principal,
    title: (string-utf8 256),
    description: (string-utf8 4096),
    start-timestamp: uint,
    end-timestamp: uint,
    snapshot-block: uint,
    options: (list 20 (string-utf8 256))
})

(define-map vote-results { vote-id: uint, option-index: uint } {
    vote-count: uint,
    vote-weight: uint
})

(define-map user-votes { vote-id: uint, voter: principal } {
    option-index: uint,
    weight: uint
})

;; __IF_MAINNET__				
(define-read-only (block-timestamp)
  (ok (unwrap! (get-stacks-block-info? time (- stacks-block-height u1)) err-get-block-info)))
;; (define-data-var custom-timestamp (optional uint) none)
;; (define-public (set-custom-timestamp (new-timestamp (optional uint)))
;;     (begin
;;         (var-set custom-timestamp new-timestamp)
;;         (ok true)))
;; (define-read-only (block-timestamp)
;;     (match (var-get custom-timestamp)
;;         timestamp (ok timestamp)
;;         (ok (unwrap! (get-stacks-block-info? time (- stacks-block-height u1)) err-get-block-info))))
;; __ENDIF__

(define-read-only (get-vote-result (vote-id uint) (option-index uint))
    (ok (default-to { vote-count: u0, vote-weight: u0 } (map-get? vote-results { vote-id: vote-id, option-index: option-index }))))

(define-read-only (get-user-vote (vote-id uint) (voter principal))
    (ok (map-get? user-votes { vote-id: vote-id, voter: voter })))

(define-read-only (get-vote-nonce)
    (ok (var-get vote-nonce)))

;; Public functions
(define-public (create-vote (title (string-utf8 256)) (description (string-utf8 4096)) (start-timestamp uint) (end-timestamp uint) (options (list 20 (string-utf8 256))) (snapshot-block-height (optional uint)))
    (let ((vote-id (+ (var-get vote-nonce) u1))
          (current-timestamp (try! (block-timestamp)))
          (options-length (len options))
          (snapshot (match snapshot-block-height
            snapshot-height (begin
              (asserts! (<= snapshot-height stacks-block-height) err-invalid-snapshot)
              snapshot-height)
            stacks-block-height))
          (vote-data {
            creator: tx-sender,
            title: title,
            description: description,
            start-timestamp: start-timestamp,
            end-timestamp: end-timestamp,
            snapshot-block: snapshot,
            options: options
        }))
        
        (try! (is-dao-or-extension))
        ;; Validate inputs
        (asserts! (> end-timestamp start-timestamp) err-invalid-timestamps)
        (asserts! (> options-length u0) err-no-options)
        
        ;; Create the vote with specified or current block as snapshot
        (map-set votes vote-id vote-data)
        (print { type: "create-vote", vote-data: vote-data, vote-id: vote-id })
        ;; Increment nonce and return vote ID
        (var-set vote-nonce vote-id)
        (ok vote-id)))

(define-public (update-vote (vote-id uint) (title (string-utf8 256)) (description (string-utf8 4096)) (start-timestamp uint) (end-timestamp uint) (options (list 20 (string-utf8 256))))
    (let ((vote (unwrap! (map-get? votes vote-id) err-not-found))
          (current-timestamp (try! (block-timestamp)))
          (vote-data {
            creator: (get creator vote),  ;; Keep the original creator
            title: title,
            description: description,
            start-timestamp: start-timestamp,
            end-timestamp: end-timestamp,
            snapshot-block: (get snapshot-block vote),  ;; Keep the original snapshot block
            options: options
        }))
        
        ;; Check authorization
        (try! (is-dao-or-extension))
        
        ;; Validate inputs
        (asserts! (> end-timestamp start-timestamp) err-invalid-timestamps)
        (asserts! (> (len options) u0) err-no-options)
        (print { type: "update-vote", vote-data: vote-data, vote-id: vote-id })
        ;; Update the vote
        (ok (map-set votes vote-id vote-data))))

(define-public (cast-vote (vote-id uint) (option-index uint) (voting-power-trait <alex-voting-power>))
    (let ((vote (unwrap! (map-get? votes vote-id) err-not-found))
          (current-timestamp (try! (block-timestamp)))
          (options (get options vote))
          (user-previous-vote (map-get? user-votes { vote-id: vote-id, voter: tx-sender })))
        
        ;; Verify the voting power contract
        (asserts! (is-eq (contract-of voting-power-trait) (var-get voting-power-contract)) err-invalid-voting-power-contract)
        
        ;; Check if voting is active
        (asserts! (>= current-timestamp (get start-timestamp vote)) err-voting-ended)
        (asserts! (< current-timestamp (get end-timestamp vote)) err-voting-ended)
        
        ;; Get voting power at snapshot block using the trait
        (let ((voting-weight (try! (contract-call? voting-power-trait get-voting-power (get snapshot-block vote) tx-sender))))
            
            ;; Check if user hasn't voted before
            (asserts! (is-none user-previous-vote) err-already-voted)
            ;; Check if option exists
            (asserts! (< option-index (len options)) err-invalid-option)
            (print { type: "cast-vote", vote-id: vote-id, option-index: option-index, voting-weight: voting-weight, voter: tx-sender })
            ;; Record the weighted vote
            (record-vote vote-id option-index voting-weight))))

;; Private functions
(define-private (record-vote (vote-id uint) (option-index uint) (weight uint))
    (let ((current-result (default-to { vote-count: u0, vote-weight: u0 } (map-get? vote-results { vote-id: vote-id, option-index: option-index }))))
        ;; Record the user's vote with weight
        (map-set user-votes 
            { vote-id: vote-id, voter: tx-sender }
            { option-index: option-index, weight: weight })
        
        ;; Update the vote count and weight
        (map-set vote-results
            { vote-id: vote-id, option-index: option-index }
            { 
                vote-count: (+ (get vote-count current-result) u1),
                vote-weight: (+ (get vote-weight current-result) weight)
            })
        
        (ok true)))
