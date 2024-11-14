;; (use-trait derupt-core-trait 'ST1ZK0A249B4SWAHVXD70R13P6B5HNKZAA0WNTJTR.derupt-core-trait.derupt-core-trait)
;; (use-trait derupt-ext-trait 'ST1ZK0A249B4SWAHVXD70R13P6B5HNKZAA0WNTJTR.derupt-ext-trait.derupt-ext)
;; (use-trait sip-010-trait 'ST3D8PX7ABNZ1DPP9MRRCYQKVTAC16WXJ7VCN3Z97.sip-010-trait-ft-standard.sip-010-trait)
(use-trait derupt-core-trait 'SP7MKPEA5DVQQ1PQNYPC1P5YRF14CY3CWZF70R01.derupt-core-trait.derupt-core-trait)
(use-trait derupt-ext-trait 'SP7MKPEA5DVQQ1PQNYPC1P5YRF14CY3CWZF70R01.derupt-ext-trait.derupt-ext)
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(define-trait derupt-profile-trait 
    (
        (registration-activation (principal) (response bool uint))
        (get-activation-status (principal) (response bool uint))         
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
                <derupt-core-trait>
            ) (response bool uint)
        ) 
        (like-message 
            (
                principal 
                (string-utf8 256)
                <sip-010-trait> 
                <derupt-core-trait>
                uint  
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
            ) (response bool uint)
        )
        (dislike-message 
            (
                principal 
                (string-utf8 256) 
                <sip-010-trait> 
                <derupt-core-trait>
                uint   
                uint
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
            ) (response bool uint)
        ) 
        (favorable-reply-message 
            (
                (string-utf8 256) 
                (optional (string-utf8 256))
                (optional (string-utf8 256)) 
                (string-utf8 256)
                principal 
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
                <derupt-core-trait>
                uint
            ) (response bool uint)
        )
        (unfavorable-reply-message 
            (
                (string-utf8 256) 
                (optional (string-utf8 256)) 
                (optional (string-utf8 256)) 
                (string-utf8 256)
                principal 
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
                <derupt-core-trait>
                uint
                uint
            ) (response bool uint)
        )
    )
)