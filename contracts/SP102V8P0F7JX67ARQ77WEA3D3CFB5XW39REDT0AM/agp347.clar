(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000)
(define-public (execute (sender principal))
  (let (
(amt-token-alex-token-wfast (get supply (try! (contract-call? .amm-pool-v2-01 create-pool .token-alex .token-wfast u100000000 .executor-dao u10507007845950 u339986863512980600))))
(approve-token-alex (try! (contract-call? .amm-vault-v2-01 set-approved-token .token-alex true)))
(approve-token-wfast (try! (contract-call? .amm-vault-v2-01 set-approved-token .token-wfast true)))
(oracle-enabled-0 (try! (contract-call? .amm-registry-v2-01 set-oracle-enabled .token-alex .token-wfast u100000000 true)))
(fee-rate-x-0 (try! (contract-call? .amm-registry-v2-01 set-fee-rate-x .token-alex .token-wfast u100000000 u500000)))
(fee-rate-y-0 (try! (contract-call? .amm-registry-v2-01 set-fee-rate-y .token-alex .token-wfast u100000000 u500000)))
(max-in-ratio-0 (try! (contract-call? .amm-registry-v2-01 set-max-in-ratio .token-alex .token-wfast u100000000 u60000000)))
(max-out-ratio-0 (try! (contract-call? .amm-registry-v2-01 set-max-out-ratio .token-alex .token-wfast u100000000 u60000000)))
(oracle-average-0 (try! (contract-call? .amm-registry-v2-01 set-oracle-average .token-alex .token-wfast u100000000 u99000000)))
(fee-rebate-0 (try! (contract-call? .amm-registry-v2-01 set-fee-rebate .token-alex .token-wfast u100000000 u50000000)))
(start-block-0 (try! (contract-call? .amm-registry-v2-01 set-start-block .token-alex .token-wfast u100000000 u0)))
(id-token-wmoon (get pool-id (try! (contract-call? .amm-pool-v2-01 get-pool-details .token-alex .token-wmoon u100000000))))
(add-token-1-token-wmoon (try! (contract-call? .alex-farming add-token .token-amm-pool-v2-01 id-token-wmoon)))
(set-activation-token-wmoon (try! (contract-call? .alex-farming set-activation-block .token-amm-pool-v2-01 id-token-wmoon u46601)))
(set-apower-token-wmoon (try! (contract-call? .alex-farming set-apower-multiplier-in-fixed .token-amm-pool-v2-01 id-token-wmoon u0)))
(set-coinbase-token-wmoon (try! (contract-call? .alex-farming set-coinbase-amount .token-amm-pool-v2-01 id-token-wmoon u100000000 u100000000 u100000000 u100000000 u0)))
(add-token-2-token-wmoon (try! (contract-call? .dual-farming add-token .token-amm-pool-v2-01 id-token-wmoon .token-wmoon u1960000000000000 u216 u225)))
(transfer-token-wmoon (try! (contract-call? .token-wmoon transfer-fixed u19600000000000000 tx-sender .dual-farming none)))
(id-token-wkiki (get pool-id (try! (contract-call? .amm-pool-v2-01 get-pool-details .token-alex .token-wkiki u100000000))))
(add-token-1-token-wkiki (try! (contract-call? .alex-farming add-token .token-amm-pool-v2-01 id-token-wkiki)))
(set-activation-token-wkiki (try! (contract-call? .alex-farming set-activation-block .token-amm-pool-v2-01 id-token-wkiki u46601)))
(set-apower-token-wkiki (try! (contract-call? .alex-farming set-apower-multiplier-in-fixed .token-amm-pool-v2-01 id-token-wkiki u0)))
(set-coinbase-token-wkiki (try! (contract-call? .alex-farming set-coinbase-amount .token-amm-pool-v2-01 id-token-wkiki u100000000 u100000000 u100000000 u100000000 u0)))
(add-token-2-token-wkiki (try! (contract-call? .dual-farming add-token .token-amm-pool-v2-01 id-token-wkiki .token-wkiki u333333300000000 u216 u245)))
(transfer-token-wkiki (try! (contract-call? .token-wkiki transfer-fixed u9999999000000000 tx-sender .dual-farming none))))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP3XZAF4DCZ64K8WZSAT5KGK8XXY10W210986W9FG))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP33K9XY95TBDWAVXTHE5JYBZ3Q07PV77W8SN2KJM))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP1A8EXQY32R966Z0WM5V9WJN8HADN4C3VZRZZCHM))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP2W2KXS4FTMFVSVCSV17BBXFWRJYPGPZZK9V5RPH))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP10GQZWNFSJECAGA1YXGC55EM3XMGMVMC0MQY1BE))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP2E4W8QJBKE85W4W5965GX13JB3G1PXVE9667G5R))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP18TXE53HRYQM1KW6961V4FS1C0VQ1JCABE09JCD))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP27W8CCZTPM8MPHGDJGSPHVFKQMJWPBVYF7QFGB7))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP28B2BA6TNEY2T5SD8PK1J6EW58VBR0PXSB5WJ81))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SPBQNXCXEFFQDDQSXD0RD93AHSVCQ76QJ3QFRFZ7))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP2ESAK4XZ56E6JQ2NE1YE7G6Q1YBVQHQ1E0DSEH2))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP262PDQ7VA401X7FSP8PHH3F0W6YTWA7YW9A6R4K))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP280WQWZT2MMNDKY5N39T7VEGQ24MR4R10MBEZC5))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP3PW2NHM9WAMJ9P1PESW7ZE5JMSCM75JZY3D19BE))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP3F1K2BAW03PQRVQJ84BAYM48Q36803Y3QM2HF0J))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP1T1G28F9V0FZ0W40H6XQ57T0PZC40KTA3V8BKTH))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP1K8HZBHMQBPP1EQT2BS40TEP9PA540RM97B637K))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP294VK3KVJJ3BAARMPDEJG9JAVXMAK0EX1C47361))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP22N9QPP8PH94XSCYJXTSP9ZYGWMVDDS5NQJZ3WN))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP3RDC4510FC9ES0XVM43TGWNNV48568TBFCVWQ2M))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP1EGMGWM8SK1RDJ79Y6DZE0MC113AJQ5JJAF551X))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP3FZGPCG30PTS8CFFBG8APSK8BHM29AA1BV6J5V6))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP32F6TEV4B91YHA77KMPJX0GZYAVF50N46CB6RWJ))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SPTWKQ6R4XWY32Q2WBZFK2D880GG6F75M11JA99D))
    (ok true)))