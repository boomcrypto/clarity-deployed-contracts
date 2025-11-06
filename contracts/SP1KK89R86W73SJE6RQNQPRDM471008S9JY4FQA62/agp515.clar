;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant MAX_UINT u18446744073709551615)
(define-constant ONE_8 u100000000) ;; 8 decimal places

(define-constant pool-ids (list u1	u2	u3	u4	u5	u6	u7	u8	u9	u10	u11	u12	u13	u14	u15	u16	u17	u18	u19	u20	u21	u22	u23	u24	u25	u26	u27	u28	u29	u30	u31	u32	u33	u34	u35	u36	u37	u38	u39	u40	u41	u42	u43	u44	u45	u46	u47	u48	u49	u50	u51	u52	u53	u54	u55	u56	u57	u58	u59	u60	u61	u62	u63	u64	u65	u66	u67	u68	u69	u70	u71	u72	u73	u74	u75	u76	u77	u78	u79	u80	u81	u82	u83	u84	u85	u86	u87	u88	u89	u90	u91	u92	u93	u94	u95	u96	u97	u98	u99	u100	u101	u102	u103	u104	u105	u106	u107	u108	u109	u110	u111	u112	u113	u114	u115	u116	u117	u118	u119	u120	u121	u122	u123	u124	u125	u126	u127	u128	u129	u130	u131	u132	u133	u134	u135	u136	u137	u138	u139	u140	u141	u142	u143	u144	u145	u146	u147	u148	u149	u150	u151	u152	u153))

(define-public (execute (sender principal))
	(begin
		(map set-start-block-iter pool-ids)
		(ok true)))

(define-private (set-start-block-iter (pool-id uint))
	(let (
			(pool-details (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details-by-id pool-id))))
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-start-block (get token-x pool-details) (get token-y pool-details) (get factor pool-details) MAX_UINT))
		(print { notification: "set-start-block", payload: { pool-id: pool-id, start-block: MAX_UINT }})
		(ok true)))
