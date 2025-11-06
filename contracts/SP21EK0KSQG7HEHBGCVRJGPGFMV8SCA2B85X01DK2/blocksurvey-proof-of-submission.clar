;; title: blocksurvey-proof-of-submission
;; version: V1.0.0
;; summary: Proof of Submission
;; description: This contract is used to submit proofs of submission for a survey.

;; traits
;;

;; constants
(define-constant CONTRACT-OWNER tx-sender)
;; Errors
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-INVALID-DATA (err u101))
(define-constant ERR-NO-DATA-FOUND (err u102))
(define-constant ERR-ALREADY-SUBMITTED (err u103))
(define-constant ERR-SURVEY-BLOCKED (err u104))
(define-constant ERR-LOW-GAS_FEE (err u105))

;; data vars
(define-data-var total-responses uint u0)

;; data maps
(define-map survey-responses { survey-id: (string-utf8 64) } { count: uint })
(define-map responses { response-id: (string-utf8 64) } { hash: (string-utf8 64) })
(define-map black-list-surveys (string-utf8 64) bool)

;; public functions
(define-public (proof-of-submission (survey-id (string-utf8 64)) (response-id (string-utf8 64)) (response-hash (string-utf8 64)) (gas-fee uint))
    (begin 
        ;; Validation
        (asserts! (validate-ownership) ERR-OWNER-ONLY)
        (asserts! (is-response-already-submitted response-id) ERR-ALREADY-SUBMITTED)
        (asserts! (is-survey-blocked survey-id) ERR-SURVEY-BLOCKED)
        (asserts! (>= gas-fee u1) ERR-LOW-GAS_FEE)
        
        ;; Mint BlockSurvey Token as equal to Stacks Gas Fee
        (try! (contract-call? .blocksurvey-token mint gas-fee tx-sender))

        ;; Increment the total
        (var-set total-responses (+ u1 (var-get total-responses)))

        ;; Increment the count for survey
        (map-set survey-responses { survey-id: survey-id } { count: (+ u1 (get-response-count-by-survey-id survey-id)) })

        ;; Store the response with hash
        (map-set responses { response-id: response-id } { hash: response-hash })

        (ok true)
    )
)

(define-public (add-to-black-list-survey (survey-id (string-utf8 64)))
    (begin 
        ;; Validation
        (asserts! (validate-ownership) ERR-OWNER-ONLY)

        ;; Add it to the black list
        (map-set black-list-surveys survey-id true)

        (ok true)
    )
)

;; read only functions
(define-read-only (get-total-responses) 
    (ok (var-get total-responses))
)

(define-read-only (get-survey-response-count (survey-id (string-utf8 64)))
    (ok (get-response-count-by-survey-id survey-id))
)

(define-read-only (get-response (response-id (string-utf8 64)))
    (ok (get-response-by-id response-id))
)

;; private functions
(define-private (validate-ownership)
    (is-eq tx-sender CONTRACT-OWNER)
)

(define-private (get-response-count-by-survey-id (survey-id (string-utf8 64)))
    (default-to u0 (get count (map-get? survey-responses { survey-id: survey-id})))
)

(define-private (get-response-by-id (response-id (string-utf8 64)))
    (default-to u"" (get hash (map-get? responses { response-id: response-id})))
)

(define-private (is-response-already-submitted (response-id (string-utf8 64))) 
    (default-to false (some (is-eq u"" (get-response-by-id response-id))))
)

(define-private (is-survey-blocked (survey-id (string-utf8 64)))
    (not (default-to false (map-get? black-list-surveys survey-id)))
)
