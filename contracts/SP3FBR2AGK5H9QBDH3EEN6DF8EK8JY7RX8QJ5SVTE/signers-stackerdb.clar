;; stacker DB
(define-read-only (stackerdb-get-signer-slots)
    (ok (list
        {
            signer: 'SP24GDPTR7D9G3GFRR233JMWSD9HA296EXW4KBJW0,
            num-slots: u10
        }
        {
            signer: 'SP1MR26HR7MMDE847BE2QC1CTNQY4WKN9XDR7VAP7,
            num-slots: u10
        }
        {
            signer: 'SP110M4DRDXX2RF3W8EY1HCRQ25CS24PGY104S5W0,
            num-slots: u10
        }
        {
            signer: 'SP69990VH3BVCV39QWT6CJAVVA9QPB1716546K1J,
            num-slots: u10
        }
        {
            signer: 'SPCZSBZJK6C3MMAAW9N9RHSDKRKB9AKGJ384BJ4B,
            num-slots: u10
        }
        )))

(define-read-only (stackerdb-get-config)
    (ok {
        chunk-size: u4096,
        write-freq: u0,
        max-writes: u4096,
        max-neighbors: u32,
        hint-replicas: (list )
    }))
