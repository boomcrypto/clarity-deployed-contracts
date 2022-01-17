
;; Title: AGP000 Bootstrap
;; Author: Marvin Janssen / ALEX Dev Team
;; Synopsis:
;; Boot proposal that sets the governance token, DAO parameters, and extensions, and
;; mints the initial governance tokens.
;; Description:
;; Mints the initial supply of governance tokens and enables the the following 
;; extensions: "age000 Governance Token", "age001 Proposal Voting",
;; "age002 Emergency Proposals",
;; "age003 Emergency Execute".

(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		;; Enable genesis extensions.
		(try! (contract-call? .executor-dao set-extensions
			(list
				{extension: .age000-governance-token, enabled: true}
				{extension: .age001-proposal-voting, enabled: true}
				{extension: .age002-emergency-proposals, enabled: true}
				{extension: .age003-emergency-execute, enabled: true}
			)
		))

		;; Set emergency team members.
        (try! (contract-call? .age002-emergency-proposals set-emergency-team-member 'SP3N9GSEWX710RE5PSD110APZGKSD1EFMBEWSBZJC true))
        (try! (contract-call? .age002-emergency-proposals set-emergency-team-member 'SPHFAXDZVFHMY8YR3P9J7ZCV6N89SBET203ZAY25 true))
        (try! (contract-call? .age002-emergency-proposals set-emergency-team-member 'SP3BQ65DRM8DMTYDD5HWMN60EYC0JFS5NC2V5CWW7 true))
        (try! (contract-call? .age002-emergency-proposals set-emergency-team-member 'SP1EF1PKR40XW37GDC0BP7SN4V4JCVSHSDVG71YTH true))
        (try! (contract-call? .age002-emergency-proposals set-emergency-team-member 'SPYVNBH68KH10N3Q115VBRQW4E2F6TQVXTWCWNJC true))
		(try! (contract-call? .age002-emergency-proposals set-emergency-team-sunset-height (+ block-height u26280))) ;; ~6 months
		(try! (contract-call? .age002-emergency-proposals set-emergency-proposal-duration u1440)) ;; ~10 days

		;; Set executive team members.
		(try! (contract-call? .age003-emergency-execute set-executive-team-member 'SP3N9GSEWX710RE5PSD110APZGKSD1EFMBEWSBZJC true))
        (try! (contract-call? .age003-emergency-execute set-executive-team-member 'SPHFAXDZVFHMY8YR3P9J7ZCV6N89SBET203ZAY25 true))
        (try! (contract-call? .age003-emergency-execute set-executive-team-member 'SP3BQ65DRM8DMTYDD5HWMN60EYC0JFS5NC2V5CWW7 true))
        (try! (contract-call? .age003-emergency-execute set-executive-team-member 'SP1EF1PKR40XW37GDC0BP7SN4V4JCVSHSDVG71YTH true))
        (try! (contract-call? .age003-emergency-execute set-executive-team-member 'SPYVNBH68KH10N3Q115VBRQW4E2F6TQVXTWCWNJC true))		
		(try! (contract-call? .age003-emergency-execute set-signals-required u3)) ;; 3 out of 5 members must approve
		(try! (contract-call? .age003-emergency-execute set-executive-team-sunset-height (+ block-height u13140))) ;; ~3 months

		;; Set approved-contracts to governance token
		(try! (contract-call? .age000-governance-token edg-add-approved-contract .alex-reserve-pool))
	
		(print "ALEX DAO has risen.")
		(ok true)
	)
)
