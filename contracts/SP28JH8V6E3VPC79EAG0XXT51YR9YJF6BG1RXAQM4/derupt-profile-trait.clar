(use-trait derupt-core-trait 'SP28JH8V6E3VPC79EAG0XXT51YR9YJF6BG1RXAQM4.derupt-core-trait.derupt-core-trait)
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
                (string-ascii 10) 
                (optional (string-utf8 256))
                (optional 
                    (tuple 
                        (arg0 (optional (string-utf8 256))) (arg1 (optional (string-utf8 256))) (arg2 (optional (string-utf8 256))) (arg3 (optional (string-utf8 256))) (arg4 (optional (string-utf8 256))) 
                        (arg5 (optional (string-utf8 256))) (arg6 (optional (string-utf8 256))) (arg7 (optional (string-utf8 256))) (arg8 (optional (string-utf8 256))) (arg9 (optional (string-utf8 256)))
                    )
                )
                <derupt-core-trait>
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
                <derupt-core-trait>
                bool
                bool
                uint
                uint
                (optional principal)
                (optional principal)
            ) (response bool uint)
        )
        (dislike-message 
            (
                principal 
                (string-utf8 256) 
                (string-ascii 10)
                <sip-010-trait> 
                <derupt-core-trait>
                bool
                bool
                uint
                uint
                (optional principal)
                (optional principal)
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
                (string-ascii 10) 
                (optional (string-utf8 256))
                (optional 
                    (tuple 
                        (arg0 (optional (string-utf8 256))) (arg1 (optional (string-utf8 256))) (arg2 (optional (string-utf8 256))) (arg3 (optional (string-utf8 256))) (arg4 (optional (string-utf8 256))) 
                        (arg5 (optional (string-utf8 256))) (arg6 (optional (string-utf8 256))) (arg7 (optional (string-utf8 256))) (arg8 (optional (string-utf8 256))) (arg9 (optional (string-utf8 256)))
                    )
                )
                <sip-010-trait> 
                <derupt-core-trait>
                bool
                bool
                uint
                uint
                (optional principal)
                (optional principal)
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
                (string-ascii 10) 
                (optional (string-utf8 256))
                (optional 
                    (tuple 
                        (arg0 (optional (string-utf8 256))) (arg1 (optional (string-utf8 256))) (arg2 (optional (string-utf8 256))) (arg3 (optional (string-utf8 256))) (arg4 (optional (string-utf8 256))) 
                        (arg5 (optional (string-utf8 256))) (arg6 (optional (string-utf8 256))) (arg7 (optional (string-utf8 256))) (arg8 (optional (string-utf8 256))) (arg9 (optional (string-utf8 256)))
                    )
                )
                <sip-010-trait> 
                <derupt-core-trait>
                bool
                bool
                uint
                uint
                (optional principal)
                (optional principal)
            ) (response bool uint)
        )
    )
)