(define-trait core-trait
  (
    ;; Parse and Verify cryptographic validity of a VAA
    (parse-and-verify-vaa ((buff 8192)) (response {
      version: uint, 
      guardian-set-id: uint,
      signatures-len: uint ,
      signatures: (list 19 { guardian-id: uint, signature: (buff 65) }),
      timestamp: uint,
      nonce: uint,
      emitter-chain: uint,
      emitter-address: (buff 32),
      sequence: uint,
      consistency-level: uint,
      payload: (buff 8192),
    } uint))
  )
)