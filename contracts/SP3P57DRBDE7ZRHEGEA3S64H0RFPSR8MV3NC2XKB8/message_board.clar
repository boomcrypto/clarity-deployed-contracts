;; Simple Message Board Contract
;; This contract allows users to post and read messages

;; Define a map to store messages
;; Key: message ID (uint), Value: message content (string-utf8 280)
(define-map messages uint (string-utf8 280))

;; Define a map to store message authors
(define-map message-authors uint principal)

;; Counter for message IDs
(define-data-var message-count uint u0)

;; Public function to add a new message
(define-public (add-message (content (string-utf8 280)))
  (let ((id (+ (var-get message-count) u1)))
    (map-set messages id content)
    (map-set message-authors id tx-sender)
    (var-set message-count id)
    (ok id)))

;; Read-only function to get a message by ID
(define-read-only (get-message (id uint))
  (map-get? messages id))

;; Read-only function to get message author
(define-read-only (get-message-author (id uint))
  (map-get? message-authors id))

;; Read-only function to get total message count
(define-read-only (get-message-count)
  (var-get message-count))

;; Read-only function to get the last few messages
(define-read-only (get-recent-messages (count uint))
  (let ((total-count (var-get message-count)))
    (if (> count total-count)
      (map get-message (list u1 u2 u3 u4 u5))
      (map get-message (list
        (- total-count (- count u1))
        (- total-count (- count u2))
        (- total-count (- count u3))
        (- total-count (- count u4))
        (- total-count (- count u5)))))))
