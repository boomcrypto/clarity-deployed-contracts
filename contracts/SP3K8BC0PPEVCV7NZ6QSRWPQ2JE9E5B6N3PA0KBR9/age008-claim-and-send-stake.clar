(impl-trait .extension-trait.extension-trait)
(use-trait ft-trait .trait-sip-010.sip-010-trait)
(use-trait extension-trait .extension-trait.extension-trait)

(define-constant ONE_8 (pow u10 u8))

(define-constant err-get-balance-failed (err u6001))
(define-constant err-unauthorised (err u3000))

(define-data-var claim-and-send bool false)

(define-private (claim-staking-reward (token <ft-trait>) (reward-cycle uint))
	(contract-call? .alex-reserve-pool claim-staking-reward token reward-cycle)
)
(define-private (get-reward-cycle-or-default (token principal))
	(default-to u340282366920938463463374607431768211455 (contract-call? .alex-reserve-pool get-reward-cycle token block-height))
)

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .executor-dao) (contract-call? .executor-dao is-extension contract-caller)) err-unauthorised))
)

(define-public (claim-and-send-stake (claim-and-send-stake-trait <extension-trait>) (memo (buff 34)) (send bool))
	(begin
		(asserts! (is-eq (as-contract tx-sender) (contract-of claim-and-send-stake-trait)) err-unauthorised)
		(var-set claim-and-send send)
		(contract-call? .executor-dao request-extension-callback claim-and-send-stake-trait memo)
	)
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(let 
		(
			(memo-uint (buff-to-uint memo))
		) 
		(try! (is-dao-or-extension))		
    	(try! (claim-staking-reward .fwp-wstx-alex-50-50-v1-01 (- (get-reward-cycle-or-default .fwp-wstx-alex-50-50-v1-01) memo-uint)))
		(try! (claim-staking-reward .fwp-wstx-wbtc-50-50-v1-01 (- (get-reward-cycle-or-default .fwp-wstx-wbtc-50-50-v1-01) memo-uint)))
		(try! (claim-staking-reward .age000-governance-token (- (get-reward-cycle-or-default .age000-governance-token) memo-uint)))
		(try! (claim-staking-reward .fwp-alex-wban (- (get-reward-cycle-or-default .fwp-alex-wban) memo-uint)))
		(unwrap-panic (contract-call? .dual-farming-pool claim-staking-reward .fwp-alex-usda .dual-farm-diko-helper (list (- (get-reward-cycle-or-default .fwp-alex-usda) memo-uint))))
		(try! (claim-staking-reward .fwp-wstx-wxusd-50-50-v1-01 (- (get-reward-cycle-or-default .fwp-wstx-wxusd-50-50-v1-01) memo-uint)))
		(let 
      		(
        		(claimed (unwrap! (contract-call? .age000-governance-token get-balance-fixed tx-sender) err-get-balance-failed))
				(claimed-fwp-alex (unwrap! (contract-call? .fwp-wstx-alex-50-50-v1-01 get-balance-fixed tx-sender) err-get-balance-failed))
				(claimed-fwp-wbtc (unwrap! (contract-call? .fwp-wstx-wbtc-50-50-v1-01 get-balance-fixed tx-sender) err-get-balance-failed))
				(claimed-fwp-wban (unwrap! (contract-call? .fwp-alex-wban get-balance-fixed tx-sender) err-get-balance-failed))
				(claimed-fwp-usda (unwrap! (contract-call? .fwp-alex-usda get-balance-fixed tx-sender) err-get-balance-failed))
				(claimed-fwp-xusd (unwrap! (contract-call? .fwp-wstx-wxusd-50-50-v1-01 get-balance-fixed tx-sender) err-get-balance-failed))
      		)
      		(and
			  	(not (var-get claim-and-send)) 
        		(> claimed u0) 
        		(try! (contract-call? .alex-reserve-pool stake-tokens .age000-governance-token claimed u32))        
      		)
			(and 
				(var-get claim-and-send)
				(> claimed u0)
				(try! (contract-call? .age000-governance-token transfer-fixed claimed tx-sender 'SPSHEY24MHYHTNNZDSFV1YX18M8VH7GZSD5NS60G none))
			)
      		(and
        		(> claimed-fwp-alex u0) 
        		(try! (contract-call? .alex-reserve-pool stake-tokens .fwp-wstx-alex-50-50-v1-01 claimed-fwp-alex u32))        
      		)		
      		(and
        		(> claimed-fwp-wbtc u0) 
        		(try! (contract-call? .alex-reserve-pool stake-tokens .fwp-wstx-wbtc-50-50-v1-01 claimed-fwp-wbtc u32))        
      		)	
      		(and
        		(> claimed-fwp-wban u0) 
        		(try! (contract-call? .alex-reserve-pool stake-tokens .fwp-alex-wban claimed-fwp-wban u32))        
      		)	
      		(and
        		(> claimed-fwp-usda u0) 
        		(try! (contract-call? .alex-reserve-pool stake-tokens .fwp-alex-usda claimed-fwp-usda u32))        
      		)
      		(and
        		(> claimed-fwp-xusd u0) 
        		(try! (contract-call? .alex-reserve-pool stake-tokens .fwp-wstx-wxusd-50-50-v1-01 claimed-fwp-xusd u32))        
      		)			  			  		  		  	
      		(ok true)
    	)
  	)
)

(define-constant byte-list
	(list
		0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f
		0x10 0x11 0x12 0x13 0x14 0x15 0x16 0x17 0x18 0x19 0x1a 0x1b 0x1c 0x1d 0x1e 0x1f
		0x20 0x21 0x22 0x23 0x24 0x25 0x26 0x27 0x28 0x29 0x2a 0x2b 0x2c 0x2d 0x2e 0x2f
		0x30 0x31 0x32 0x33 0x34 0x35 0x36 0x37 0x38 0x39 0x3a 0x3b 0x3c 0x3d 0x3e 0x3f
		0x40 0x41 0x42 0x43 0x44 0x45 0x46 0x47 0x48 0x49 0x4a 0x4b 0x4c 0x4d 0x4e 0x4f
		0x50 0x51 0x52 0x53 0x54 0x55 0x56 0x57 0x58 0x59 0x5a 0x5b 0x5c 0x5d 0x5e 0x5f
		0x60 0x61 0x62 0x63 0x64 0x65 0x66 0x67 0x68 0x69 0x6a 0x6b 0x6c 0x6d 0x6e 0x6f
		0x70 0x71 0x72 0x73 0x74 0x75 0x76 0x77 0x78 0x79 0x7a 0x7b 0x7c 0x7d 0x7e 0x7f
		0x80 0x81 0x82 0x83 0x84 0x85 0x86 0x87 0x88 0x89 0x8a 0x8b 0x8c 0x8d 0x8e 0x8f
		0x90 0x91 0x92 0x93 0x94 0x95 0x96 0x97 0x98 0x99 0x9a 0x9b 0x9c 0x9d 0x9e 0x9f
		0xa0 0xa1 0xa2 0xa3 0xa4 0xa5 0xa6 0xa7 0xa8 0xa9 0xaa 0xab 0xac 0xad 0xae 0xaf
		0xb0 0xb1 0xb2 0xb3 0xb4 0xb5 0xb6 0xb7 0xb8 0xb9 0xba 0xbb 0xbc 0xbd 0xbe 0xbf
		0xc0 0xc1 0xc2 0xc3 0xc4 0xc5 0xc6 0xc7 0xc8 0xc9 0xca 0xcb 0xcc 0xcd 0xce 0xcf
		0xd0 0xd1 0xd2 0xd3 0xd4 0xd5 0xd6 0xd7 0xd8 0xd9 0xda 0xdb 0xdc 0xdd 0xde 0xdf
		0xe0 0xe1 0xe2 0xe3 0xe4 0xe5 0xe6 0xe7 0xe8 0xe9 0xea 0xeb 0xec 0xed 0xee 0xef
		0xf0 0xf1 0xf2 0xf3 0xf4 0xf5 0xf6 0xf7 0xf8 0xf9 0xfa 0xfb 0xfc 0xfd 0xfe 0xff
	)
)

(define-private (byte-to-uint (byte (buff 1)))
	(unwrap-panic (index-of byte-list byte))
)

(define-read-only (buff-to-uint (bytes (buff 34)))
	(+
		(match (element-at bytes u0) byte (byte-to-uint byte) u0)
		(match (element-at bytes u1) byte (* (byte-to-uint byte) u256) u0)
		(match (element-at bytes u2) byte (* (byte-to-uint byte) u65536) u0)
		(match (element-at bytes u3) byte (* (byte-to-uint byte) u16777216) u0)
		(match (element-at bytes u4) byte (* (byte-to-uint byte) u4294967296) u0)
		(match (element-at bytes u5) byte (* (byte-to-uint byte) u1099511627776) u0)
		(match (element-at bytes u6) byte (* (byte-to-uint byte) u281474976710656) u0)
		(match (element-at bytes u7) byte (* (byte-to-uint byte) u72057594037927936) u0)
	)
)