;;     _____________  _______ _________  ___  ___  ____  ____
;;     / __/_  __/ _ |/ ___/ //_/ __/ _ \/ _ \/ _ |/ __ \/ __/
;;     _\ \  / / / __ / /__/ ,< / _// , _/ // / __ / /_/ /\ \  
;;    /___/ /_/ /_/ |_\___/_/|_/___/_/|_/____/_/ |_\____/___/  
;;                                                          
;;     ___  ___  ____  ___  ____  _______   __               
;;    / _ \/ _ \/ __ \/ _ \/ __ \/ __/ _ | / /               
;;   / ___/ , _/ /_/ / ___/ /_/ /\ \/ __ |/ /__              
;;  /_/  /_/|_|\____/_/   \____/___/_/ |_/____/              

;; Initialize MegaDAO

(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		;; Enable extensions.
		(try! (contract-call? 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mega-dao set-extensions
			(list
				{extension: 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mega-vault, enabled: true}
                {extension: 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mega-submission, enabled: true}
                {extension: 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mega-voting, enabled: true}
                {extension: 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mde-emergency-proposals, enabled: true}
                {extension: 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mde-emergency-execute, enabled: true}
			)
		))

		;; Whitelist fungible tokens for the vault.
		(try! (contract-call? 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mega-vault set-whitelists
			(list
				{token: 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega, enabled: true}
                {token: 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token, enabled: true}
                {token: 'SP2TZK01NKDC89J6TA56SA47SDF7RTHYEQ79AAB9A.Wrapped-USD, enabled: true}
                {token: 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin, enabled: true}
                {token: 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token, enabled: true}
                {token: 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token, enabled: true}
                {token: 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2, enabled: true}
                {token: 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2, enabled: true}
                {token: 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas, enabled: true}
			)
		))

        ;; Whitelist NFTs for the vault.
		(try! (contract-call? 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mega-vault set-whitelists
			(list
                {token: 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-ape-club-nft, enabled: true}
                {token: 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-nft, enabled: true}
                {token: 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-component-nft, enabled: true}
                {token: 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-expansion-nft, enabled: true}
                {token: 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-exquisite-robot-nft, enabled: true}
				{token: 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads, enabled: true}
                {token: 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft, enabled: true}
			)
		))

        ;; Set threshold for proposing to 250 MEGA.
        (try! (contract-call? 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mega-submission set-parameter "proposeThreshold" u250))

        ;; Set emergency team members.
        (try! (contract-call? 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mde-emergency-proposals set-emergency-team-member 'SP2E03GHWY145XMFDTHX4Z913EADP4RMZ0P0DCTE9 true))
        (try! (contract-call? 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mde-emergency-proposals set-emergency-team-member 'SP1C39PEYB976REP9B19QMFDJHHF27A63WANDGTX4 true))

        ;; Set emergency signers.
        (try! (contract-call? 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mde-emergency-execute set-executive-team-member 'SP2E03GHWY145XMFDTHX4Z913EADP4RMZ0P0DCTE9 true))
        (try! (contract-call? 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mde-emergency-execute set-executive-team-member 'SP1C39PEYB976REP9B19QMFDJHHF27A63WANDGTX4 true))
        (try! (contract-call? 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mde-emergency-execute set-executive-team-member 'SP69MS8W17WWT6MNH8AB4A7BMY5AX6MAMWD89CCR true))
        (try! (contract-call? 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mde-emergency-execute set-executive-team-member 'SP1JX2RYKPR0G7H81SQHZQ187H50RR6QSM8GX839X true))
        (try! (contract-call? 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mde-emergency-execute set-executive-team-member 'SP143YHR805B8S834BWJTMZVFR1WP5FFC03WZE4BF true))

        ;; Set emergency proposal sunset to ~6 months
        (try! (contract-call? 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mde-emergency-proposals set-emergency-team-sunset-height (+ block-height u26280)))
        (try! (contract-call? 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mde-emergency-execute set-executive-team-sunset-height (+ block-height u26280)))

		(print {message: "...to be a completely separate network and separate block chain, yet share CPU power with Bitcoin.", sender: sender})
		(ok true)
	)
)