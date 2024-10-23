(define-trait derupt-ext
    (
        (update-ext-owner
            (principal)
            (response bool uint)
        )

        (update-ext-metadata
            (
                (optional (string-ascii 24))
                (optional (string-ascii 256))
                (optional (string-ascii 256))
            )
            (response bool uint)
        )

        (exec-ext-func 
            (
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
            )            
            (response bool uint)
        )
    )
)