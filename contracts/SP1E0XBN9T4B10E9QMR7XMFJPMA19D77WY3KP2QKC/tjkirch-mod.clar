(impl-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-public (execute (sender principal))
	(begin
        (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age003-emergency-execute set-executive-team-member 'SPHFAXDZVFHMY8YR3P9J7ZCV6N89SBET203ZAY25 false))
        (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age003-emergency-execute set-executive-team-member 'SP3BQ65DRM8DMTYDD5HWMN60EYC0JFS5NC2V5CWW7 false))
        (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age003-emergency-execute set-executive-team-member 'SPEJJMSNMD1F74RKVJSGPXJ1839STT5EVY0C64KZ true))
        (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age003-emergency-execute set-executive-team-member 'SP3HK93RCBY54SBR9Z6DV03GG8ZFDMDP0RC6A5NKN true))		
		(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age003-emergency-execute set-executive-team-sunset-height u340282366920938463463374607431768211455))
		(ok true)	
	)
)