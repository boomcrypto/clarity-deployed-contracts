---
title: "Trait Messenger"
draft: true
---
```
;; Composite key Approach for storing messages between two users
(define-map messages-map { sender: (string-ascii 20), reciever: (string-ascii 20) } {message:  (list 100 (string-ascii 100)) })

;; For Storing Username of each account
(define-map usernames-map { wallet-address: principal  } { username: (string-ascii 20) } )

;; For Storing address of each username 
(define-map address-map { username: (string-ascii 20) } { wallet-address: principal  } )

;; For Storing Friends List of each user
(define-map friends-map { username: (string-ascii 20) } { friends: (list 100 (string-ascii 20)) } )

;; For Storing pending friend request List of each user
(define-map requests-map { username: (string-ascii 20) } { requests: (list 100 (string-ascii 20)) } )

;; For Storing Friend request Status
(define-map request-status-map { sender: (string-ascii 20), reciever: (string-ascii 20) } { accepted: bool } )

;; Default message for first-time
(define-data-var default-message (list 100 (string-ascii 100)) (list ""))

;; Default friends list / pending list
(define-data-var default-friends (list 100 (string-ascii 20)) (list ""))

;; Must be smaller than messages list size
(define-data-var NUMBER_LRU_TO_REMOVE uint u20)
(define-data-var removed-message-index uint u0)
(define-data-var accepted-pending-request-user (string-ascii 20) "")
(define-data-var remove-friend-user (string-ascii 20) "")

;; ----------------------------------------Public Functions-------------------------------------

(define-public (send-message (sender (string-ascii 20)) (reciever (string-ascii 20)) (text (string-ascii 100)))
    (let 
        (
            ;; if sending message for the first time then default to first-message else get list of previously sent messages
            (messages (default-to (var-get default-message) ( get message (map-get? messages-map { sender: sender, reciever: reciever }))))
        )

        ;; if both users are not friends then return err false else send message
        (asserts!
        (or
            (is-eq (are-friends sender reciever) (some true))
            (is-eq (are-friends reciever sender) (some true))
        )
        (err false)
        )
        
        ;; (print messages)
        (var-set removed-message-index u0)

        ;; check if list is not full
        (if (< (len messages) u100)
        (ok (map-set messages-map { sender: sender, reciever: reciever }  {message:  (unwrap-panic (as-max-len? (append messages text) u100)) } ))
        (ok (map-set messages-map { sender: sender, reciever: reciever }  {message:  (unwrap-panic (as-max-len? (append (filter remove-least-recent-messages messages) text) u100)) } ))
        )
    )
)

(define-public (add-new-username (wallet-address principal) (username (string-ascii 20) ) )
   (begin
    (asserts! (check-username username) (err false))
    (map-insert address-map { username: username} { wallet-address: wallet-address  } ) 
    (ok (map-insert usernames-map {wallet-address: wallet-address} { username: username } ))
   )
)

(define-public (send-friend-request (sender (string-ascii 20)) (reciever (string-ascii 20)))
    (let
        (
            ;; get pending requests list 
            (pending-requests (default-to (var-get default-friends) ( get requests (map-get? requests-map { username: reciever }))))
        )

        ;; if both users are friends then return err false else send request
        (asserts!
        (not
        (or
        (is-eq (are-friends sender reciever) (some true))
        (is-eq (are-friends reciever sender) (some true))
        ) 
        )
        (err false)
        )
        (map-set requests-map { username: reciever } {requests: (unwrap-panic (as-max-len? (append pending-requests sender) u100))})
        (ok (map-set request-status-map { sender: sender, reciever: reciever } { accepted: false }))
    )
)

(define-public (accept-friend-request (sender (string-ascii 20)) (reciever (string-ascii 20)))
    (let
        (
            ;; get pending requests list 
            (pending-requests (default-to (var-get default-friends) ( get requests (map-get? requests-map { username: reciever }))))
            (sender-friends (default-to (var-get default-friends) ( get friends (map-get? friends-map { username: sender }))))
            (reciever-friends (default-to (var-get default-friends) ( get friends (map-get? friends-map { username: reciever }))))
        )
        
        ;; remove user from pending request list
        (var-set accepted-pending-request-user sender)
        (map-set requests-map { username: reciever } {requests: (unwrap-panic (as-max-len? (filter remove-pending-request pending-requests) u100))})
        
        (map-set request-status-map { sender: sender, reciever: reciever } { accepted: true })
        (map-set friends-map { username: sender } {friends: (unwrap-panic (as-max-len? (append sender-friends reciever) u100))})
        (map-set friends-map { username: reciever } {friends: (unwrap-panic (as-max-len? (append reciever-friends sender) u100))})
        (ok true)
    )
)

(define-public (reject-friend-request (sender (string-ascii 20)) (reciever (string-ascii 20)))
    (let
        (
            ;; get pending requests list 
            (pending-requests (default-to (var-get default-friends) ( get requests (map-get? requests-map { username: reciever }))))
        )
        
        ;; remove user from pending request list
        (var-set accepted-pending-request-user sender)
        (map-set requests-map { username: reciever } {requests: (unwrap-panic (as-max-len? (filter remove-pending-request pending-requests) u100))})
        
        (map-set request-status-map { sender: sender, reciever: reciever } { accepted: false })
        (ok true)
    )
)

(define-public (remove-friend (user1 (string-ascii 20)) (user2 (string-ascii 20)))
   (let
        (
            (user1-friends (default-to (var-get default-friends) ( get friends (map-get? friends-map { username: user1 }))))
            (user2-friends (default-to (var-get default-friends) ( get friends (map-get? friends-map { username: user2 }))))
        )
        
        ;; remove user1 from user 2 friend list
        (var-set remove-friend-user user1)
        (map-set friends-map { username: user2 } {friends: (unwrap-panic (as-max-len? (filter remove-user-from-friend-list user2-friends) u100))})
        
        ;; remove user2 from user 1 friend list
        (var-set remove-friend-user user2)
        (map-set friends-map { username: user1 } {friends: (unwrap-panic (as-max-len? (filter remove-user-from-friend-list user1-friends) u100))})
        
        ;; remove friend request status of both users
        (map-delete request-status-map { sender: user1, reciever: user2 })
        (map-delete request-status-map { sender: user2, reciever: user1 })

        ;; remove messages of both users
        (map-delete messages-map { sender: user1, reciever: user2  })
        (map-delete messages-map { sender: user2, reciever: user1  })

        (ok true)
    )
)

;; ----------------------------------------Private Functions-------------------------------------

(define-private (are-friends (sender (string-ascii 20)) (reciever (string-ascii 20)))
    (get accepted (map-get? request-status-map { sender: sender, reciever: reciever }))
)

(define-private (get-address (username (string-ascii 20)))
    (get wallet-address (map-get? address-map {username: username} ))
)

(define-private (remove-least-recent-messages (message (string-ascii 100)))
    (begin
        (var-set removed-message-index (+ (var-get removed-message-index) u1))
        (>= (var-get removed-message-index) (var-get NUMBER_LRU_TO_REMOVE))
    )
)

(define-private (remove-pending-request (user (string-ascii 20)))
    (not (is-eq (var-get accepted-pending-request-user) user))
)

(define-private (remove-user-from-friend-list (user (string-ascii 20)))
    (not (is-eq (var-get remove-friend-user) user))
)


;; ----------------------------------------Read-Only Functions-------------------------------------

(define-read-only (get-messages (sender (string-ascii 20)) (reciever (string-ascii 20)))
    (get message (unwrap! (map-get? messages-map { sender: sender, reciever: reciever }) (var-get default-message)))
)

(define-read-only (is-new-user (wallet-address principal))
    (is-none (map-get? usernames-map {wallet-address: wallet-address} ))
)

(define-read-only (get-friends-list (username (string-ascii 20)))
    (get friends (unwrap! (map-get? friends-map  { username: username }) (var-get default-friends)))
)

(define-read-only (check-username (username (string-ascii 20)))
     (is-none (map-get? address-map { username: username} ))
)

(define-read-only (get-pending-friend-requests (username (string-ascii 20)))
    (get requests (unwrap! (map-get? requests-map { username: username }) (var-get default-friends)))
)

(define-read-only (get-username (wallet-address principal))
    (get username (map-get? usernames-map {wallet-address: wallet-address} ))
)
```
