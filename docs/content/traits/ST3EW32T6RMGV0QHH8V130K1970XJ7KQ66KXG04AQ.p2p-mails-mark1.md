---
title: "Trait p2p-mails-mark1"
draft: true
---
```
(define-constant contract-owner tx-sender) 

(define-data-var msg-list (list 100 {
    sender: principal,
    receiver: principal,
    text: (string-ascii 240),
    block_height: uint
} ) (list ) )

(define-public (send-msg (receiver principal) (text (string-ascii 240) ) )
    (begin
        (var-set msg-list (unwrap-panic (as-max-len? (append (var-get msg-list) 
            {
                sender: tx-sender,
                receiver: receiver,
                text: text,
                block_height: block-height
            }
         ) u4)))
        (ok true)
    )
)

(define-private  (check-receiver ( msg {
    sender: principal,
    receiver: principal,
    text: (string-ascii 240),
    block_height: uint
}) )
    (if (is-eq tx-sender (get receiver msg) ) (ok msg) (ok {
                sender: tx-sender,
                receiver: tx-sender,
                text: "no text",
                block_height: u0
            } )  )
  )

(define-public (get-my-msgs) 
    (begin
        ;; from the msg-list list, get the tuples where the receiver is the tx-sender
        (print (map check-receiver (var-get msg-list)))
        (ok true)   
    )
)
```
