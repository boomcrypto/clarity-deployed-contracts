(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(define-trait derupt-core-trait 
    (
        (stack-citycoin ((string-ascii 10) uint uint) (response bool uint))
        (transfer-citycoin (uint principal <sip-010-trait>) (response bool uint))
        (mine-citycoin ((string-ascii 10) (list 200 uint)) (response bool uint))
        (send-message 
            (
                (string-utf8 256) (optional (string-utf8 256))
                (optional (string-utf8 256)) (optional (string-utf8 256))
                (string-ascii 10) (optional (string-utf8 256))
                (optional 
                    {
                        arg0: (optional (string-utf8 256)),
                        arg1: (optional (string-utf8 256)),
                        arg2: (optional (string-utf8 256)),
                        arg3: (optional (string-utf8 256)),
                        arg4: (optional (string-utf8 256)),
                        arg5: (optional (string-utf8 256)),
                        arg6: (optional (string-utf8 256)),
                        arg7: (optional (string-utf8 256)),
                        arg8: (optional (string-utf8 256)),
                        arg9: (optional (string-utf8 256))
                    }
                )
            ) (response bool uint)
        )
        (like-message
            (
                principal (string-utf8 256) <sip-010-trait>
            ) (response bool uint)
        )
        (dislike-message
            (
                principal (string-utf8 256) (string-ascii 10) <sip-010-trait>
            ) (response bool uint)
        )
        (favorable-reply-message
            (
                (string-utf8 256) principal (optional (string-utf8 256))
                (optional (string-utf8 256)) (optional (string-utf8 256))
                (string-utf8 256) (string-ascii 10) (optional (string-utf8 256))
                <sip-010-trait> 
                (optional 
                    {
                        arg0: (optional (string-utf8 256)),
                        arg1: (optional (string-utf8 256)),
                        arg2: (optional (string-utf8 256)),
                        arg3: (optional (string-utf8 256)),
                        arg4: (optional (string-utf8 256)),
                        arg5: (optional (string-utf8 256)),
                        arg6: (optional (string-utf8 256)),
                        arg7: (optional (string-utf8 256)),
                        arg8: (optional (string-utf8 256)),
                        arg9: (optional (string-utf8 256))
                    }
                )
            ) (response bool uint)
        )
        (unfavorable-reply-message 
            (
                (string-utf8 256) principal (optional (string-utf8 256))
                (optional (string-utf8 256)) (optional (string-utf8 256))
                (string-utf8 256) (string-ascii 10) (optional (string-utf8 256))
                <sip-010-trait>
                (optional 
                    {
                        arg0: (optional (string-utf8 256)),
                        arg1: (optional (string-utf8 256)),
                        arg2: (optional (string-utf8 256)),
                        arg3: (optional (string-utf8 256)),
                        arg4: (optional (string-utf8 256)),
                        arg5: (optional (string-utf8 256)),
                        arg6: (optional (string-utf8 256)),
                        arg7: (optional (string-utf8 256)),
                        arg8: (optional (string-utf8 256)),
                        arg9: (optional (string-utf8 256))
                    }
                )
            ) (response bool uint)
        )
    )
)