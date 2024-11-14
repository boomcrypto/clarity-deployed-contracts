
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.proposal-trait.proposal-trait)

(define-constant intrinsic-234 u101564196)

(define-public (execute (sender principal))
	(begin
    (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-registry set-shares-to-tokens-per-cycle u234 intrinsic-234))                              
		(try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lisa-dao set-extensions (list 
      { extension: 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.auto-alex-v3-endpoint-v2-01, enabled: false }
      { extension: .auto-alex-v3-endpoint-v2-02, enabled: true } )))
    (try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.auto-alex-v3-endpoint-v2-01 pause-create true))
    (try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.auto-alex-v3-endpoint-v2-01 pause-redeem true))
    (try! (contract-call? .auto-alex-v3-endpoint-v2-02 pause-create false))
    (try! (contract-call? .auto-alex-v3-endpoint-v2-02 pause-redeem false))    
    (try! (contract-call? .auto-alex-v3-endpoint-v2-02 rebase))
		(ok true)))