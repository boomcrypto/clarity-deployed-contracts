(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
  (begin
	  ;; enable CityCoins extensions
    (try! (contract-call? .base-dao set-extensions
      (list
        {extension: .ccd001-direct-execute, enabled: true}
        {extension: .ccd002-treasury-mia-mining, enabled: true}
        {extension: .ccd002-treasury-mia-stacking, enabled: true}
        {extension: .ccd002-treasury-nyc-mining, enabled: true}
        {extension: .ccd002-treasury-nyc-stacking, enabled: true}
        {extension: .ccd003-user-registry, enabled: true}
        {extension: .ccd004-city-registry, enabled: true}
        {extension: .ccd005-city-data, enabled: true}
        {extension: .ccd006-citycoin-mining, enabled: true}
        {extension: .ccd007-citycoin-stacking, enabled: true}
        {extension: .ccd009-auth-v2-adapter, enabled: true}
        {extension: .ccd010-core-v2-adapter, enabled: true}
        {extension: .ccd011-stacking-payouts, enabled: true}
      )
    ))

    ;; set 3-of-5 signers
    (try! (contract-call? .ccd001-direct-execute set-approver 'SP372JVX6EWE2M0XPA84MWZYRRG2M6CAC4VVC12V1 true))
    (try! (contract-call? .ccd001-direct-execute set-approver 'SP2R0DQYR7XHD161SH2GK49QRP1YSV7HE9JSG7W6G true))
    (try! (contract-call? .ccd001-direct-execute set-approver 'SPN4Y5QPGQA8882ZXW90ADC2DHYXMSTN8VAR8C3X true))
    (try! (contract-call? .ccd001-direct-execute set-approver 'SP3YYGCGX1B62CYAH4QX7PQE63YXG7RDTXD8BQHJQ true))
    (try! (contract-call? .ccd001-direct-execute set-approver 'SP7DGES13508FHRWS1FB0J3SZA326FP6QRMB6JDE true))

    ;; set to 3-of-5 signals required
    (try! (contract-call? .ccd001-direct-execute set-signals-required u3))

    ;; delegate stack the STX in the mining treasuries (up to 50M STX each)
    (try! (contract-call? .ccd002-treasury-mia-mining delegate-stx u50000000000000 'SP700C57YJFD5RGHK0GN46478WBAM2KG3A4MN2QJ))
    (try! (contract-call? .ccd002-treasury-nyc-mining delegate-stx u50000000000000 'SP700C57YJFD5RGHK0GN46478WBAM2KG3A4MN2QJ))

    (print "CityCoins DAO has risen! Our mission is to empower people to take ownership in their city by transforming citizens into stakeholders with the ability to fund, build, and vote on meaningful upgrades to their communities.")

    (ok true)
  )
)
