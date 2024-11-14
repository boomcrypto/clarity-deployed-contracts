---
title: "Trait derupt-core-trait"
draft: true
---
```
;; (use-trait sip-010-trait 'ST3D8PX7ABNZ1DPP9MRRCYQKVTAC16WXJ7VCN3Z97.sip-010-trait-ft-standard.sip-010-trait)
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
;; (use-trait derupt-ext-trait 'ST1ZK0A249B4SWAHVXD70R13P6B5HNKZAA0WNTJTR.derupt-ext-trait.derupt-ext)
(use-trait derupt-ext-trait 'SP7MKPEA5DVQQ1PQNYPC1P5YRF14CY3CWZF70R01.derupt-ext-trait.derupt-ext)
(define-trait derupt-core-trait 
    (
        (gift-message
            (
                principal 
                principal bool
                <sip-010-trait>
                uint
                (optional (buff 34))
                (optional <derupt-ext-trait>)
                (optional (list 10 
                    {
                        stringutf8: (optional (string-utf8 256)), 
                        stringascii: (optional (string-ascii 256)), 
                        uint: (optional uint), 
                        int: (optional int), 
                        principal: (optional principal), 
                        bool: (optional bool),
                        buff: (optional (buff 34)),
                        proxy: (optional (buff 2048))
                    }
                ))
            ) (response bool uint)
        )
        (send-message 
            (
                (string-utf8 256) 
                (optional (string-utf8 256))
                (optional (string-utf8 256)) 
                (optional (string-utf8 256))
                (list 200 uint) 
                (string-utf8 256)
                (optional <derupt-ext-trait>)
                (optional (list 10 
                    {
                        stringutf8: (optional (string-utf8 256)), 
                        stringascii: (optional (string-ascii 256)), 
                        uint: (optional uint), 
                        int: (optional int), 
                        principal: (optional principal), 
                        bool: (optional bool),
                        buff: (optional (buff 34)),
                        proxy: (optional (buff 2048))
                    }
                ))
                bool
                bool
                uint
                uint
                (optional principal)
                (optional principal)
            ) (response bool uint)
        )
        (like-message
            (
                principal 
                (string-utf8 256) 
                <sip-010-trait>
                uint
                bool
                bool
                uint
                uint
                (optional principal)
                (optional principal)
                (optional <derupt-ext-trait>)
                (optional (list 10 
                    {
                        stringutf8: (optional (string-utf8 256)), 
                        stringascii: (optional (string-ascii 256)), 
                        uint: (optional uint), 
                        int: (optional int), 
                        principal: (optional principal), 
                        bool: (optional bool),
                        buff: (optional (buff 34)),
                        proxy: (optional (buff 2048))
                    }
                ))
            ) (response bool uint)
        )
        (dislike-message
            (
                principal 
                (string-utf8 256) 
                <sip-010-trait>
                uint
                uint
                bool
                bool
                uint
                uint
                (optional principal)
                (optional principal)
                (optional <derupt-ext-trait>)
                (optional (list 10 
                    {
                        stringutf8: (optional (string-utf8 256)), 
                        stringascii: (optional (string-ascii 256)), 
                        uint: (optional uint), 
                        int: (optional int), 
                        principal: (optional principal), 
                        bool: (optional bool),
                        buff: (optional (buff 34)),
                        proxy: (optional (buff 2048))
                    }
                ))
            ) (response bool uint)
        )
        (favorable-reply-message
            (
                (string-utf8 256) 
                principal 
                (optional (string-utf8 256))
                (optional (string-utf8 256)) 
                (string-utf8 256)
                (string-utf8 256) 
                (list 200 uint)
                (string-utf8 256)
                (optional <derupt-ext-trait>)
                (optional (list 10 
                    {
                        stringutf8: (optional (string-utf8 256)), 
                        stringascii: (optional (string-ascii 256)), 
                        uint: (optional uint), 
                        int: (optional int), 
                        principal: (optional principal), 
                        bool: (optional bool),
                        buff: (optional (buff 34)),
                        proxy: (optional (buff 2048))
                    }
                ))
                <sip-010-trait> 
                uint
                bool
                bool
                uint
                uint
                uint
                uint
                (optional principal)
                (optional principal)
            ) (response bool uint)
        )
        (unfavorable-reply-message 
            (
                (string-utf8 256) 
                principal 
                (optional (string-utf8 256))
                (optional (string-utf8 256)) 
                (string-utf8 256)
                (string-utf8 256) 
                (list 200 uint)
                (string-utf8 256)
                (optional <derupt-ext-trait>)
                (optional (list 10 
                    {
                        stringutf8: (optional (string-utf8 256)), 
                        stringascii: (optional (string-ascii 256)), 
                        uint: (optional uint), 
                        int: (optional int), 
                        principal: (optional principal), 
                        bool: (optional bool),
                        buff: (optional (buff 34)),
                        proxy: (optional (buff 2048))
                    }
                ))
                <sip-010-trait>
                uint
                uint
                bool
                bool
                uint
                uint
                uint
                uint
                (optional principal)
                (optional principal)
            ) (response bool uint)
        )
    )
)
```
