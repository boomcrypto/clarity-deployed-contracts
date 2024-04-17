(define-read-only (get-token-details (tick (string-utf8 4)))
  (let ((resp-token-details (contract-call? .brc20-bridge-registry-v1-03
                              get-token-details-or-fail
                              tick)))
    (match resp-token-details
      details (some details)
      e none)))
(define-read-only (get-token-details-many (ticks (list 100 (string-utf8 4))))
  (map get-token-details ticks))
(define-read-only (get-token-details-by-address (token principal))
  (let ((token-details (contract-call? .brc20-bridge-registry-v1-03
                          get-token-details-or-fail-by-address
                          token)))
    (match token-details
      details (some details)
      e none)))
(define-read-only (get-token-details-by-address-many (tokens (list 100 principal)))
  (map get-token-details-by-address tokens))
(define-read-only (get-request (request-id uint))
  (let ((resp-request (contract-call? .brc20-bridge-registry-v1-03
                        get-request-or-fail
                        request-id)))
    (match resp-request
      request (some request)
      e none)))
(define-read-only (get-requests-many (requests-id (list 1000 uint)))
    (map get-request requests-id))
(define-read-only (get-request-by-tx-sender-many (requests-id (list 1000 uint)))
    (map get-request-by-tx-sender requests-id))
(define-read-only (get-request-by-user-many (user (list 1000 principal)) (requests-id (list 1000 uint)))
    (map get-request-by-user user requests-id))
(define-read-only (get-request-by-user (user principal) (request-id uint))
    (match (get-request request-id)
        request
        (if (is-eq (get requested-by request) user)
            (some request)
            none)
        none))
(define-read-only (get-request-by-tx-sender (request-id uint))
    (get-request-by-user tx-sender request-id))