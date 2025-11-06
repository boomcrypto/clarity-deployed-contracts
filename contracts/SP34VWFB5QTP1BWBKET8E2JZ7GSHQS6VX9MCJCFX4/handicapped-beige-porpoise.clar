;; Simple contract to call request-peg-out 10 times in one transaction

(define-public (call-peg-out-10x)
  (begin
    ;; Call 1
    (try! (contract-call? 
      'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-out-endpoint-v2-04
      request-peg-out
      u10000
      0x512024a5bb98f30b34479ad1b524fc602ace6011072ef884ba49b1e2cfa33d995b98
      'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
      u1002))
    
    ;; Call 2
    (try! (contract-call? 
      'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-out-endpoint-v2-04
      request-peg-out
      u10000
      0x512024a5bb98f30b34479ad1b524fc602ace6011072ef884ba49b1e2cfa33d995b98
      'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
      u1002))
    
    ;; Call 3
    (try! (contract-call? 
      'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-out-endpoint-v2-04
      request-peg-out
      u10000
      0x512024a5bb98f30b34479ad1b524fc602ace6011072ef884ba49b1e2cfa33d995b98
      'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
      u1002))
    
    ;; Call 4
    (try! (contract-call? 
      'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-out-endpoint-v2-04
      request-peg-out
      u10000
      0x512024a5bb98f30b34479ad1b524fc602ace6011072ef884ba49b1e2cfa33d995b98
      'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
      u1002))
    
    ;; Call 5
    (try! (contract-call? 
      'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-out-endpoint-v2-04
      request-peg-out
      u10000
      0x512024a5bb98f30b34479ad1b524fc602ace6011072ef884ba49b1e2cfa33d995b98
      'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
      u1002))
    
    ;; Call 6
    (try! (contract-call? 
      'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-out-endpoint-v2-04
      request-peg-out
      u10000
      0x512024a5bb98f30b34479ad1b524fc602ace6011072ef884ba49b1e2cfa33d995b98
      'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
      u1002))
    
    ;; Call 7
    (try! (contract-call? 
      'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-out-endpoint-v2-04
      request-peg-out
      u10000
      0x512024a5bb98f30b34479ad1b524fc602ace6011072ef884ba49b1e2cfa33d995b98
      'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
      u1002))
    
    ;; Call 8
    (try! (contract-call? 
      'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-out-endpoint-v2-04
      request-peg-out
      u10000
      0x512024a5bb98f30b34479ad1b524fc602ace6011072ef884ba49b1e2cfa33d995b98
      'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
      u1002))
    
    ;; Call 9
    (try! (contract-call? 
      'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-out-endpoint-v2-04
      request-peg-out
      u10000
      0x512024a5bb98f30b34479ad1b524fc602ace6011072ef884ba49b1e2cfa33d995b98
      'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
      u1002))
    
    ;; Call 10
    (try! (contract-call? 
      'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-out-endpoint-v2-04
      request-peg-out
      u10000
      0x512024a5bb98f30b34479ad1b524fc602ace6011072ef884ba49b1e2cfa33d995b98
      'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
      u1002))
    
    (ok "10 peg-out requests completed successfully")
  )
)