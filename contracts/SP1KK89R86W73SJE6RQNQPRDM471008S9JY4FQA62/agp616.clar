;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places

(define-constant revenue-list (list
{ token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex, amount: u66436312965203 }
{ token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2, amount: u504612982954 }
{ token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi, amount: u367147357151755 }
{ token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wleo, amount: u404583280694031 }
{ token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt, amount: u17292420058 }
{ token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, amount: u128012 }
{ token: 'SP1KK89R86W73SJE6RQNQPRDM471008S9JY4FQA62.token-wbfaktory, amount: u84715136290299 }
{ token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnot, amount: u1443050748509860000 }
{ token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wlialex, amount: u508965900593 }
{ token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wmia, amount: u2831434041262 }
{ token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wplay, amount: u950973021298526 }
{ token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wkiki, amount: u1888704083406810 }
{ token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wpepe, amount: u111599064495000 }
{ token: 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wjindo, amount: u202705450976613 }
{ token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstxoshi, amount: u42326933906271 }
{ token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wgus, amount: u168721377061207 }
{ token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wmega, amount: u16219087500 }
{ token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvibes, amount: u990570675905 }
{ token: 'SPRYBMPFT75XBFAH6YJ2YKTGC5P2E3KM6Y1F6NYK.ssl-DROID-62c6f, amount: u2267952578495 }
{ token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wlong, amount: u5678017874560790 }
{ token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-whashiko, amount: u2822926372396230000 }
{ token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wmoon, amount: u195298572291966 }
{ token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wall, amount: u134730845366799000 }
{ token: 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wliabtc, amount: u275 }
{ token: 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wkapt, amount: u39250140601479 }
{ token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wmick, amount: u25145734498924600 }
{ token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnakamoto, amount: u5119647546118480000 }
{ token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wmax, amount: u31756285258536 }
{ token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wwif, amount: u60115954812651 }
{ token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wwsbtc, amount: u9460500046 }
))

(define-public (execute (sender principal))
	(begin
		(try! (fold check-err (collect-revenue revenue-list) (ok true)))
		(ok true)))

(define-private (collect-revenue (details (list 500 { token: <ft-trait>, amount: uint })))
	(map collect-revenue-iter details))

(define-private (collect-revenue-iter (details { token: <ft-trait>, amount: uint }))
	(let (
			(token-trait (get token details))
			(token-reserve (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01 get-reserve (contract-of token-trait)))
			(token-amount (min token-reserve (get amount details))))
	(print { token: (contract-of token-trait), token-amount: token-amount, token-reserve: token-reserve, shortfall: (- (get amount details) token-amount) })			
	(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01 transfer-ft token-trait token-amount 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao))	
	(contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01 remove-from-reserve (contract-of token-trait) token-amount)))

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value)))

(define-private (min (a uint) (b uint))
	(if (< a b) a b))
