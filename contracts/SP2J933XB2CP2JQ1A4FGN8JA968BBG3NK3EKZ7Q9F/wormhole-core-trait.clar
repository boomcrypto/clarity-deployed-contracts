(define-trait wormhole-core-trait
  (
    ;; Parse and Verify cryptographic validity of a VAA
    (parse-and-verify-vaa ((buff 2048)) (response {
        version: uint, 
        guardian-set-id: uint,
        signatures-len: uint ,
        signatures: (list 19 { guardian-id: uint, signature: (buff 65) }),
        timestamp: uint,
        nonce: uint,
        emitter-chain: uint,
        sequence: uint,
        consistency-level: uint,
        payload: (buff 2048),
        guardians-public-keys: (list 19 { recovered-compressed-public-key: (response (buff 33) uint), guardian-id: uint }),
        vaa-body-hash: (buff 32),
    } uint))
  )
)
