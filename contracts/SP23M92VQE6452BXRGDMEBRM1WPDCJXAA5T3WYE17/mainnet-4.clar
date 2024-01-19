        ;; stacker DB
        (define-read-only (stackerdb-get-signer-slots)
            (ok (list
                {
                    signer: 'SPB5XD8Q2C7FWFQPM327MA8QWR6QC7HJ650HK40T,
                    num-slots: u10
                }
                {
                    signer: 'SP5E2N1HSPWWK721A00DRGFZJK4G0EZN42H5SZB8,
                    num-slots: u10
                }
                {
                    signer: 'SPWBDB3R3VD9DF5T02J6A4RZSKK35J4E0CSECHRQ,
                    num-slots: u10
                }
                {
                    signer: 'SP1MHD673GWF5D9Q1V267557MQD67KZZQ58HRWYXN,
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
    