;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-constant OWNER 'SP1ESCTF9029MH550RKNE8R4D62G5HBY8PBBAF2N8)
(define-constant LAUNCH_OWNER { address: (get hash-bytes (unwrap-panic (principal-destruct? OWNER))), chain-id: none })

(define-constant LAUNCH_TOKEN { address: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: (some u0) })
(define-constant PAYMENT_TOKEN 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc)

(define-constant PRICE_PER_TICKET u2000) ;; 0.00002 BTC or $2

(define-constant START_DELAY u432) ;; 3 days
(define-constant REGISTRATION_PERIOD u4320) ;; 30 day
(define-constant TOKENS_PER_TICKET u102000) ;; 0.00102 BTC or $102
(define-constant FEE_PER_TICKET u0)

(define-constant MAX_REGISTRATION u1)
(define-constant MAX_TICKETS MAX_UINT)
(define-constant SUPPLY_TICKETS u200)

(define-constant WHITELIST (list
{ owner: { address: 0x0055797647eA5aE4977bB8CB444E8D7ac1b20fB3, chain-id: (some u3) }, whitelisted: u1 }
{ owner: { address: 0x62C457CD468383993c38b5739D09f6825DBDebA1, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2J1K2BX0HNTP8JEZ23MR3Z38JFPQA49X0BJ45AF), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x321f7d116f980fac4415262e50f674effd5ff58d, chain-id: (some u3) }, whitelisted: u1 }
{ owner: { address: 0xA7a010c543C6D6eaaB6eef5CB4a64671Da43d9BC, chain-id: (some u3) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1R0R6DC3K9E1N7FW8K0C78KE2QBGXRRK80KTBFN), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP31000NRKV6AGRAW21CP22X67E5C1M2W51ARF8P5), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x962a0facac11022114dde2a86b3a5f605cf3929b, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3TJ5YF08D4FSHM9ZYBBG3X76PW9257YE9SPFWA1), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xebf6d047effda8665bf0006a960790b09ac1d433, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0xb1F3Eb67d313dd496C441ffb1953e12ceca762F2, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: 0xa91465092016d0c9d6cc5095a8e66d027d1869430c1387, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0xf289Bbc3207322bb5531B041540Ad2119c01ADc2, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1ESCTF9029MH550RKNE8R4D62G5HBY8PBBAF2N8), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x0000005C7Dc69D405F09AaAdcA29068D4f88cde8, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0x1b0Ec6A050e011dfC7C0f936571D475986f9e320, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: 0x226fdBa3816d2137ab77cd4Bf21bA49b476960A4, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3RYGTCPHMMD2MSJ7VHX7AZWQHHXF4JZP7BQW0G0), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x2031fF308A6A35E125ff51F1F69eAEe58B48086d, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0x3e8ad2710f8e424dbae5d5f8efcf872abdc88d9b, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3RQY2KAMTAAZWMAVEMFKC9QBX0MH91010MNBZ9E), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP4VABPD37KFE2R0M1SABFVNN20W48Z6540ZREF2), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x15aB09d29c374AC0c1b97D18c3888F0156C62D77, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPV2YDN4RZ506655KZK493YKM31JQPKJ9NN3QCX9), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xa8ebdD9e323032a5dbEe2beB3719d71E69050871, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2KYETPPVN7Q0FKNA74T1EK8PKB83V989446VBFD), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x1fbd7535f61b075c5c3ec7d5dccb2c36f93aaafc, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP35G0C2NHXFP1ATJW17YYTFKNEF1DY73R0XB2KG9), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3MQMZXH6F2PG5NRBQW3SG4E8E0FE8D5M2320WM5), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1BBWBS456KX16K19XRV62CR5226QT3S8P4R38YG), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x05AFe96E1A2825190c288C086A309E8A2f083909, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2XHGP0P45WDJ1XZPZZT2Q0MV3WBAP7SN7ZWCGN5), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xa9143296e74bc290c39c68baea9a22857c2ee0c9f08187, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0x904fb665aa6b4bbfaaaa0d5d1860b902f60be499, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0x88324D2Bc04CbfAf1457A41dBeAbc6C7c600E572, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0xd0c8b6025789aa6ab05d171ab0a6776feaa6d1fc, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0x566632eeCd46C7A7C49F6Db558dFe79a9e88AC5D, chain-id: (some u3) }, whitelisted: u1 }
{ owner: { address: 0x9def60442bcd29a7e289a4e1378d2019d1186b3e, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPN6PP6AWX1QXY86M6XT9PY6AF9SRM6RK9GXZ7F7), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xf97e11588062206099E48BC5B4094894f8bfc901, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1J5PS54EC4M9WN7CVNFRP5J88DB9K0MS06PZ7R6), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP153SXX8T85ACQ96HGWARS3S2FP92HYSEPAY39H6), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x0014e49e48737834a0505be9bca7cb607776ece5adaf, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3EJTGSV1W7D7HT47D3QNEAZGXK1G6P7NDP4RWJ8), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x0014b8883c8aaa237d2b9bf82a9df2ed1a7d3c5bad25, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP12M48BAG78F6E9W1X3GTF90PQCQ6NY56KCQ1HFV), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2BFSG4NNFPARWH43Q6A3FC4JEYESH462KVGAG3X), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP235T4QMFY3SEFMEMFTXF36G840QFBVTJJYJZYEF), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x62c7Db45d5A36Bc329AAc7F9316A088FF5f76219, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1YNFAAGY02F784AAR10TW3AQPEK4Y74S4RADD12), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x00145d743f5a3261fe403860caaa64d6e7a37e2d9831, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP26EXFYYXB9D5X1D095A6HJDRCWYZFD41TYVX8CX), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xa9148227faf09c0609e00873a3a78d814294ce189c8387, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP33YVGF9QZAX4KEZTZW219T7HCVKJ0N32AMYB9TQ), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP346YQ1533YXQ8ZCKM6D97CFKCTVPP6V0VWT4PV9), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1P2XGDSVYHXZ6GQAM4N7CX89GTZKBRP2BQF0G15), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x0014c5fcdc158dd1b3fa8b86035507dbe9029478b8fc, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3NZYE2BYESG18ZMV02SWT2YYPTEA3PJZVWF611M), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP28J3QJRX9MQCE7J2GPFEBPQC8M2Z1S1YGMX28YK), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3YJHE2FZ5PZDMAWZFN4EGSCT7WB3E90V2PHPG1R), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3E78FMN893FJNRGDCD2B04F34NTJJBY2ZE478RN), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPHFE6N86GH7JGP978ADGA95P4SGKGVPSCPG5Z6H), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x1a4d921e62e1d0057ba61a1df7dc5f6b2fffff81, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP99B9SNEY20XZ5PDCR30VC520QPWCEAAVHHEC2W), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPRYBMPFT75XBFAH6YJ2YKTGC5P2E3KM6Y1F6NYK), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x39413CCc5859eA776E9fb18ac3CC97417821b45c, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2FR9T99JYCJN6YKP7KQN20RG3Y5JFFPEWEVSJJ5), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xcD46C4D553649DC957Ac4564E751238937E8142b, chain-id: (some u3) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP27K275273DF3BZHD4S1BFJDEZ6EKH747NTRM7PS), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP26ABBRK1AQZ0EN4ST8NR8XSDE00HXP8BCJ7AFBZ), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xED89eA2f0465352aFE2E958A0C043C137a257ab4, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2T9E1MHVY7K2FBZSVQRM069B9B267EKQVCRKHRA), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPREPHTHWP49E7TAF59G3X7D1P7VVBNFYHP7P0SP), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x354DF0e2c51C28dCBE3D77e79b207441dC8ab771, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: 0x41a37161d3beee923504007fdd18bf7b3ba11c30, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: 0x1bb86f936c1b3f33c72cf9023793bebe01fb9631, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP11PV2N9FB02KJQJAQ29GJ4T73AT8TZKGJWMSXPK), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP64WXTTY50HF3YEFPB4XT4B8ZFKS0QXSHFM0K1J), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2MAE1ARW7SACWKFJT49895752EBWHFWRMT08K1T), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1149RQG9J743KQV773X4CXNYEN8WMHF1DGCSCC), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x54B74Cbcda72607E2463bb075eD6E46323ba5dF2, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP98HDVTX71PSG3VZDNXCPX1XD9TSH47H42H3AXD), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x588F6ccb39f3d474C5B3736483589e2BBC8E0847, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3K6XATZ91SVQBFSVQRZW6Z27AKAFT5NV0FWF128), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1KYTMXK5SWD4NYTFMPBXASAW1CMJFNWPAYHE72A), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP26JANC54SG8Q1JKVZK5R89Z35S60J2AF8ZJKGMR), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x0014a5b161237cb8aebde97e68e065ad141f1d0750d1, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0x6ee62Fb521531b587e79262d759dEc8CE4FEF341, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP22TYSCADAKM5K57E949HFP5ZVQ06PRAVJ700X3), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP04HWKVEN63VC4DQGW93199306N9T6JJD32M35M), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x302bae0f197745aAD8298030b2701c3D0e8547f8, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: 0xb0c6071582e9Eb0e3125B6CE85Ff6d57077CCf71, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0x1496E92B5E39695926a7eC68C9d7FA74fb2fC840, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0x8B9De20CAAe14b6712734D6c0fF542d9A5707Ca3, chain-id: (some u15) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPMWCPXZJRDW3RP3NVQYAJHM71V2FMV9CMKR6GBR), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3Z3RAFPPGZ0XHQBZSGN86JJK3C469BXV2ZHTXYX), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x866a0bee421ce4f430ad29cbbcd9a6f2b299bb2e, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2GRRJ18NHCHPDHJ8KCS09PJKR2HMK7Q26R9XMAQ), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x001423db8b5e60df8c3f762faebbe1b0bbfcbafe3863, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3ARGD9CC5SPJE62YGVYSRKXBQ8S4AFT81CAGJFQ), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xa91481b2aa644eb5b8e21b4c09433231337c3ea3e35987, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0x6d4829856f8d195A71Ee854A76D08286FE8bed01, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0x692CAd9F0EC6Def28498072ac58d128EDAdcE2fd, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPPYHFWFHSG0QQYYQNTQH9K4D67KEMSN5XCADGCP), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP10P47YQFS0CMSBDCSMX4G1K2RHT5D0Q91YSN1ZD), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP34HJYT3A01QR17TVB79JRKFWQ870D68C44BC4PY), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x00142232f5f279142c13877d43cc274919930a52fd54, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0x3efd5cdb46c700481f40058341aa220ac2552660, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPF9M816Y6A8DZHE562B05201HZAS7NAPAMJN1WH), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1Y5BX9QNS4VTS6F4GS9AHD7PMNSH8Z11W52T3B5), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xc68c9d7993cafe2a749e83b61f3c8d1a1ec4c0bf, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0xa0E192203258c852005e2A8B46937423fCBAe965, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0xa914e79067b31a84db3c83e412407abb14b0ead2a93c87, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2M7K3YM8813404G1R7AXV106CPWH0Z5ZA80JVAV), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1Y4M4VR1116A7CT847AF6RJZSVM0JBRJH5Y2FY5), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x1F6c4C570F7aF3e8C286326fA075DE2e5f597a6D, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: 0x0014a44bc87b81669fe5c79e0ff716335b8960049f14, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP295QANJTGHJJ9TSHJ4WH28Z52VDKWDW68VT8KAH), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1VA9HEH5VJFBCGJ6F8VF9BGS8WF6DJE9AD7856), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPQBYJV4GG99E6AH97JKX760D39CBR0FZ7G3H670), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x2503E84fee97f2304d8A1B44b0e02BFb2B973794, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP15SC7G0PBTS0WPDC0ZX96X1CXE76Y22E9XFH4G3), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1PWKZ3BX7S3EDPWMQN2DQTHVHVC0Q26RF09MFYP), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xB210d7e0572e73C3A95c9433808C523219aD9678, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP31R72B1YG883PCBTJ552ASE4T8J45QBC72TM453), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1NGMS9Z48PRXFAG2MKBSP0PWERF07C0KV9SPJ66), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPWDK0ZT02XCPW1YFAB1Y471ZDEEVD3CXD5HKKZE), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xE29b507128fB0bb9464854d9f365b3d24deA07d1, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1GFK7WJCSGP3NGTW28J7N0897X83NA5VM2S78KT), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xa9143fb1291c0368eb005f42a15980bef6eddee6d15e87, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2YADQRAJ4468KEX4CYD4MQPF0S6QYFT5BRA22J0), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xC0225f37F8645d1153b566077F49b109D3156d0B, chain-id: (some u10) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3NXCB6WJTHDT4ZSWYW5Q8GDYC29FZAVM94TAA1V), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP24K07AQQR9ZXSYD3W6B2NA07TB85YB01S5TQH79), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x1187314FBA102a55712C4467CB85b05F8d3712e8, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2YZTJNXHBWXNFF644EH4GZ4S7CQ01CVSD2PEA49), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xF8d8a00DDab0583EB91cbed6B95292B78D39E1B4, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0x4d85770fd4d42060d3a8075ef781830954b5c93f, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1MKF97NKPDWPM2D3HE0VTTSM0RTN4GPZYXX4ZHX), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPYR934SMNWYSM11M00HJNWA259Q2K4V1X7DP9BD), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x84F76a7bB926077cEE7A897Cc649223cB807D770, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2SGGGMQKEW665ZG4ZXDVTKG5JJ03P5MZJ9MFB48), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2FXF04ZPYG4W48FJNW82SMRS8FKT5E76TMXXRJ1), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xBCbeAc56eeF250E8a4859be46c6cBFd93aAe5d2F, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2FPJ3AM1ARVMXJ1MBFQJKX16KYQFW6392NVWGXS), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP14T3JAMD0KQP2JRR5XHAH2CKFEQ4HY3TT40QZMJ), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xc5f769ba238e959846bb7761d397161bddfce2f2, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPYZ5M97SBBD58ZH3GT8R96PPPW3Q6HXFMNQT91T), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xB47e7CdFB753CE4dd33CEaed0cAbBdb747B74eD3, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: 0xa9149f787e9e320d024c10a4e7f8965ef4f89fc8bc0287, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0x6E1Ef354C72ad81373eC64a276da112e4e1e3935, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2KNDNZVWPXNSWM90MB50TYHEG78D4GRB4FDNWH2), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x47A761bb9e970AC93Cb571c4614C4cA643714e4F, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPT479DPJ7QHEZCWMEJ32BFEXJ4G41W803BFVCSF), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xd4679493270b244e5398fcf5e0473542c8906527, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: 0xa9140ca3bf5d9859a0465c182c44486564d6358c663687, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1HXT635AVD4MWFGNYEC79YG4TXS5QJE9NTB3T2A), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1X1EG0Z7N0J4GVQNYG02H8JR93V20W59J3EGVJB), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x9bFfa173717556966590ABc28241340dFe844b5E, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3J7Y4C6XGJ5DAWMAKVDT4YTSH5FJP1THCZ2NYY4), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP17DFTKTG7V2FN002875G0XDN9SMNE7RKYKBK4GM), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPZ1C3F03J6X1618V01RVK1JRFDKD8KF1YTZSDWK), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPX9QPAB1WBJK2FHCENK8GVK05W0PNEN9JVQWZAJ), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2N8EM3C6WTZXAR19DPWKV78224EK85HB75Y8M84), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP12C6V7SMTTM4DK87FX4FDAA9WPCV7P83EP4EMD1), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPA8T1RE1KZY1GNAZFERD55WMBNVW9PXFZA4TZE6), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP25DPJSCSWRNC6586S7KDVBM998NXETKSCWXRDH8), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x61ea0aF61BaCBd9cC887f48cA57fCfE10A393879, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3W7TKRDGKTK41M7Z99D8P2EJ724VEWEN5880386), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x50f565aa87669574294645df2e0000fb440ea3be, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3CMTKSJQDEPDA735FWTZS517AMHQ13WTQM4CT1A), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP208CG7T6B6QAZ5NE8ACPV6B0K18WF1W83YD4J7), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1VV0X7M75EY32K81TADWZX872JBZPH20TD2MYG8), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xE6cEa605Be9425872C00AAf0b1029a871131E410, chain-id: (some u3) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP6GNE89QMQVFE628BCHBFNABD6GYYF85EH4RZYQ), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP15E4HHHS8WSPQNQPT2P42P82H0CPZ79CNF7D56E), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x6d0708f7a4fc7d9f89d021a3a6adc2b9873ae45c, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1N0WD91ZXGN3554J2YRJD2W0BWDY58DV60KZ69Q), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2S0EVJDJNY436KRVFS9GW8ZRCEJEE14WEW68V2), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2Q7A2E08G2XD5YPVGTWHAB4TXPNE1CWB2M2JTS), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP302XJ73NXBRVYH445V2G8WS2PBA60C39E7ME6ZP), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x0014837e77023a7128f1952a5d8183f25f8420fafc99, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPHX8HEAAAJTKFMR267QNHP6KZA8PN86BRCGHFX1), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xa914fe34f4fda53a6a21f9ac3151ca10a5047e4b544987, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0x66b3e42b4c9b9dd4639a7a05e55a16da04b4fbc2, chain-id: (some u10) }, whitelisted: u1 }
{ owner: { address: 0xa91458c454aaa61bed93840a6160f5edac312920099a87, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3M8EXTREBJKHGCA0WHRGHK4ZXVN72EE40XJ83B), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x0014a73c2fbd434a61f182f72791210d17a95b502eb3, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPMYQNVKGNDB546707TS069X49HV605N0BJSR7KJ), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xd3A01097a7cb063942AAbfBE406b3F6d86E52A39, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP31CTGCZ2HQ4HW11EXRFGTXZDRXCC493JWXEMCV1), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPY61MF42XT81KB36J3ZA7EXB1M2VRYQM9AZ0MYA), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3M6D6M2BS7FNEFV111ZF6WQYATNJZ89Q7MXSPAE), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2MZ3ZGP28VEV311AV1BVGF9NJRSSTEPPT8Y2R36), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2T4SJRBCF63HJVZBMXEK1SZTGKHY4NZSXE3TF9Y), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x0014a30e01d3e974ab4406a9b92d87ec4b96810df61c, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0x04774dAD9Baf61EFAb218E7d06f8f52bb7b37168, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3JAYXB8D4DH95SDDK0W7YCK4XTJH4GK7F3YKJSV), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2WCGD4T8V432VF1866PKN7B313FMRKX795BCME9), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2ZQDT6PPNW8FVAW44JKQ4DX2XTPR5KQPFHZV3NP), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x03679B3c61EA787b7db021EE2Ad6a6a754Ea53E6, chain-id: (some u3) }, whitelisted: u1 }
{ owner: { address: 0x001418a7e884a7e09fff7a94fbb379728f9fc6ecfc2f, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0xa914459582fe331e8843677fa9542758ea056d13749287, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2G84P6SMV6NQ4E3EGAWHAE886HHZ0Y8J42338QA), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x001426f79cbed5152c1675e50a4ac482fae8751309fc, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0xa9142a14c399dd56208fe98b552c5118c9ce12a5d48a87, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1XXQWMZRNXFAD1K3K4TM7G0B88CWZ12G9RHXBBQ), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP16JVMRMK0ZNRMMRMQ1CFD08P5XCYB44VJ74GJKP), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP13G16F89CXQ950ZNY22XMFD65HCFEXEQC4YQFNE), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3Y6Z03A5TPK4AK5RYKS1JNWEDQ0H4JBQB3188PE), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP33YV1AR5H9M7YPWYNR6FHFHG49MP8MEF49JPHQX), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3Y9RZ6BRK0Y7DWDM3PD6CRNPJQX19C5AK5Y3HHS), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPKZD017GPPC4ZGA335WT2YEPD25DGN10Z823C7V), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2MPJ82D9NRH7Z1T7RFR46BSKMAR58KC8ZK9KXYZ), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPYA4ZBYACWVZGSY9Z8WZ3R1JY46GHS7K3J5Q4XW), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP209VR5F2K0J8Y4DXPFR9XQHWE5B91HSSRA9S75Y), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2HJVJQS0TRBTQ1WAWWN9H9W2HKGDZ7H5EZCEAQC), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPZ3E9A7VBFGBEB15N23AAWGC3DPSSJJQ4Y7RNB1), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x275B2eDbC7C4413dbECFf9Ef37ba9214758e3B13, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2JDHMK8521CKYJ7F2YCVSD621YH2BT0E0A1PCQ1), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x3dF12A511c90b9E7F60292f673968424303940F2, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3XZ00Q2Q6NYGXBBY2AXKXMGBKY9E2BYGBXY76F6), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP36WDFMR29ESER722D4V39C8YJKDR43V1288DK23), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x2bCd9232aFA3b0F7cAC2f3fAaB6e797b596AC6e6, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP23TN9ER9166NMFJ3P4294N30NBRM6M24AVKXFN2), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xa91427a6c149821bf6f8e00e4a66937e0a508303fe0f87, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0x1AE1Ac5C107E583750cd0E0E8F982f82c55e1852, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2V6C4JVXTT5A599BE56HFXNEWT4Z345VTT0FFE1), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xD8b822b3c35339f56327a880a54cEfD75a051E36, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: 0xe4Bc96b24e0bDF87b4b92Ed39C1AEf8839b090dd, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1YK1VXJXD2RWTZ6M8TNB99KQZX0EXJ9RJ591E15), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xD2fB35bAdbBb7982d3096F8aC01F3Cc963652F06, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3AJATW7TWKV8ZWEXSV3JEHQ02FWWEA2HNCGVPE4), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x0014213c255c95bdb274ebc2a3d73d1535ebee7bffe9, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0x34F31ff69B15fd77edD04eDB8d2af96eEa259252, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3N8ZJBY5R6V4QNW7GR7GA6VG73WAYXAFPEMF69X), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x001412bf2a55eff37a64c65aee53b495c257c44bec59, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP30A13XJEHMK81JVEHMS0FEHFENS1W5KEEFYJDVM), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPEM6EBEMN87Y24RE3Y35AF8F25AZRSNWDBHG1WN), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPK752G0EKKQFTEVSEJK6AFNN501RMEMHHQ6KWJC), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xa9147971a5ba8c321e10adda89a8deda791b3d72b0dc87, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0xa914efd3e74075b9ec043001516892e22659ecde42ae87, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP39VVS8NN6CZ59CJBA14DXH2TNAJ9G2SSKM2QV2S), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3X5SP03ET3G9DNK50GTD3RGFYNS92831SZ2256S), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2W7ZPFYH538SGPZ9E8NNS73P723KGDSN3FJA6KE), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPF54B05KSEZE69CYJ7NDADK0FYPYP3DVQQ8ANFG), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x1FcED74016fD4B250b54223B39A749B907afC9Ce, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPG5X4RDXFR3N2HHJACJZNCCPTW4TSMP15QHBZSY), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xa91481c5d7ebe4d83b6c61c6d465af48954d57f4f59987, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0xEad5B7d86C681C036C59Cd00A0390541061c69F2, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1FY57XAKV1Q81JD6TDJQR0R25HEP0Q23RHWVK5P), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x4b38414db64c04466ff3b44a40d00b91875b0729, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP30AF1XADY530B2MTQRNP1NFDE22A4X51QZ056KV), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP16KM2MMCPAKQWA5CX9YH6QBS30W37RWFXWVGJA6), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3SJ8S0B8FCV6GD9PMQKV4D3ACJBA8M7D6Y2N9P2), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xa9149f2679f0bc9ba0828568fa4ef75d38fce18d90b887, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2KYXHKHESK04HRXXY8X14FGKQBMH13X3HQ2HM84), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x1F9B1b84fe59fCE1DBA1ac2542C725bF23215F22, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1GQKBVX6TTP1NRGB5FZXBG9CTJ011N5H7HH19V6), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3D04T02235C22B661JA0V58NZYD4GB3C88V29CJ), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x541576E03d0774f1b0B728DFE77578Df5564B3F6, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPQR47EGQ3ZPK7N5YAPVHJXJCCQP0YE6TYWW6QC6), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x04bF59b19bc6C9f3aC3e37612869009937805E89, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: 0xAE35B4BbC3A0d6BED834D2508071dFA3007a44e5, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3AQKHV52YE61VYFBS8N6QHV830NXMWATNMH99AX), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xA118e662e144c47a8513d07Ca471730678369791, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0x00146b099d7411e4236fbceb15af2bf743a00eed3086, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1G6XSM7Y9Y9JFKBMEJ663D3H16MW096J2QFKQ0B), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x001411719506ff00da86d329fef82a77fa65490701dd, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1T5Q45P74BD1YX55X45Q5727TZFQF005KWMSBQ6), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP13AC1JF3RVH4PMB3CDM8Y6AK9K24XRY20XYCRZT), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1BMP0HBVPHSXQG2XCBE6PRH8ZBPQ36YZJMG3KKQ), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x41C10200D24988aed43921eE8f7F5dd849cBddaf, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: 0x0014b52e387e0db4449a40d0e4dc2b56fc74c9b9ffe9, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0xFfc25afe766D0CDf605b91ccc553EA3Bf29Fe527, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP4XNJ46PSB9Y2A9042SX509Q6XRSXPTQ3JMB25H), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1Z2XZZSSXGDP8VY9TN65PX0P91EYVP307HS3P0K), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x66342CDb636aba7b1CcC2F95EFABbC7bA3B1947D, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP8RWJXXBPM7DZEPF15EA0TNGKVNR5QRY73GHEAA), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP35MYDF0EPJXVA05TNVT5GKY75VFDFKB1NY9DM4P), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2EPWC56S4HRSRCCD5Q3J6QSH2GWQ80JJ3PET820), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPNSX52H79HVKKSD5Q70GHW4WQWSVTTPPR3QBXT2), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP37SE3P6RHC8FKDZC46E8C2A39S7ZSFKS569AJV4), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x0014e42da1e245114f469dce62b55278b9b2c807dcfc, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3A14HTDRY90SP681FS18B2BQ0XF6TY1WE5X4JGM), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP35ZV5KJJ7PDS9ESF19Z0K263WE596F4GFJX64PK), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xa91479fc8a8a61c7108e9caacbd680d3c2dedb04a9fe87, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0x0014c27dd68dc49f1447ae071213b02f6dfdc00128f7, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0x28453A3a16bd927f094F0d55A61cbb4333724B08, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1SHXFCWQ04JA1EBCF62E05FN9B21KEA5TH180RD), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x6402D0ce702FC0522E229CCe66943F3DCF1e1bEf, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0xebE8298dFFB309BF58809AC267F99a81A1BE4dCD, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1F8NSQNN9CAD06ZKH690V1RXRXW6G4RDB61BK38), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1MAVN1K5D9JJDVFK6RMJABE6NAV4K67G2SG34ZN), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPZ6XY3B0G2Y8V5JWN9M43SJ2ZV7Q7YETA650JM7), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x58C1C6A484ef2d6b0F8d93B2DBEb72F3C3e9cEb5, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP9HG5ZR3677T3MAA7WYDFD3J7A9EH2JC2N4PJJJ), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP17A9K8Z4P4BSY5VMVA01KP4M1WDETPRFX11XBHN), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2VDBEKNKMQCYCGYPS59P3KJY5DEJ4GHV0CNCSY0), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2HDXKPHMMH5FP9NY542GBFJESXMN1P0SNM3MN0X), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP19T53VENTQMM2C1Z4JREKX6DXRT582Z9B0E5JF7), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPEFCW4DY382E1YGJFZD4DQARNWASE5CT9P3V6YV), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x00147d68be06cb1722521b3d02cbad8d02aa0ac77e03, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPJJWWPV30ZXMGV2TM92VD8DRJ2RJ0T3FB6F3ZHE), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x31EA045Fbf5AE02dE5Cb6f9B9B51d2d38A7C724C, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2JTYHTT81Z1KCMBEW21VA98FCNVS2JB5BWNPB0R), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x51200b309afe52b9fbe6943499de1a688e8bfd1c7ab6dd98e06e4eb42eb097e95a95, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPKE4NDPE66BDM97QPR8FWNHFDJ8BCY8HKHH314H), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xa91408bea5bf824bbbdda25023ab8d90706a68131c7e87, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0x3A238952e78A3a9D6B43ea25D18Cb44abF868644, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: 0x5120d2924fcd266c944de0daacfb799fa0a2c89790fe7f0ed0afe159019366645805, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPF8A5H0MZZGDDTRF19CQX0K6C0FHQ7H84RG4RMJ), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3BZHG88721DS6GV6WKGMJ1SQW3482C6MN4V46M1), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPNFF5TR083QHCG5KD0AJ44G0XBCDEB3WDK12B3H), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP35CY2JJRNBDGR7AV4RJ23HG46PM1Q6NWH6TFNK6), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xa9146965285a1730fa2f99e7f2e1d4526e7f44f42b8587, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0xD6cb436B1634d9c4DEe2D6967b8A6aDABC2f89Ac, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP7S0VEJ4FW96NEJPQ7ME36CZVKQQZ2AWVK45GTD), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP4M6QQTGFBJ94B3QVNEX783HDXD6R09VS4G63K2), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x0014d494e0167cba46e0405bb28e772a3b215cac4258, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0x337e822EdBA7954E514B8c1276367564538C4920, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0x00149b157523aef3dcaa0f17ec0c526a06c4c80aa30e, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0xa914e225bb7f3ec325faa8ee6292fcdc9c5f5f72610687, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0x73831e7c600F48cebBbfF957b466be8e5c087F34, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPRS9Y30VC2A7H5ZAP44R9VJFB5VHAFY9204YYMV), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3WV7W60ATCSRAY8941JT789A0DYVFQWNT1N6NYH), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP36WZV3YE1YHYSTBR8BJGMF8VTSN3J9F8XPS3E6N), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x5120e85e2890520a2cc3e02b270ce9aa7ba507e3d76334d067921ce912216d9a7a04, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPRP4AGEMDEA034SP5RVDQPT10YWZS4E27A0NQPT), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP39SJHDYPXDN7WX7GS9ZK3J4P545F1KB0ETZYPX7), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x51201dd21e179ec1777bb0209a2836f8ef9febf43731cb99ddd6fdfc2a426a6f4207, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0x0014d1996c91e37925bda8af80cbdb172ff538642f22, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0xfffB92fb89AE51C421018E42A5Ca6E7336314438, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0x00140c930c717916a7bee6a19d6e2c58f558df35fc6e, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0xf913EB51DE6A79245995DF5adaC2373BFF08CE1c, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0xa914dfa55bccee47f913b91c09599aeb30ed3f60b00c87, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0x001401dfe61fbf41f67aaef24f33e379e9d4e179ee3f, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1H77M0XSN0MTRBJCJS20QRXSQRDF6H5R5DS9C4T), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x245a4a574604036299E499A7f995B2B132b70eDD, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP9GVRQ4H9181E0RK20C4GMGQ9GEV7RZ8552BZWJ), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2E1TG741D5M6R9ATZ1PV3SFX4C7YAS666ZX7G1D), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x822e631F2e956bB678077379f195dC569bDF4Eb4, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1KH4ZK5G7VXFC7E3QQKMKJV4X2X715SYET8PTTA), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3VV72CHJFRDVC0V4C41JF6NVMVAD1JFBX24CQM4), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xe5C463242c3D165B41DDd330A4a3926F385dA4A5, chain-id: (some u3) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1PTCWS3JHQW9R171W7HX4301D9A7GWEQ34BYTPM), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xe00A8842517b583858eBd3D327295cbaccB7156b, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1WHXE0DJ3AMZ83GK88R1B9VXM455ZQKF42WPWY9), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPPBRHTZ7MM896Q5YRT8PZDPMZHV7Q0PHS8T0B2Z), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP15CS9BDGKTJFXYY2F7Q0J03P2EPNGW36VWT6S9A), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2NCQM8JEMC4P9VEV8CKCCPENECYGD4A6MJ2DD4G), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP322JVDRC4490J9E5S242QDV7Y734DG18J4ATE2Z), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP111G0S42TY2TY3QSATH2KZMMRJYY00Q0WA1A1CR), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x0Bd40fd13192381620596B97000296287EE3c559, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: 0x7503c52b84B17dbaA24Dd9D82f8B689C0C4253aa, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0x26d5148548f8d5b050c5c6f6762e6dd75f2eb84a, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1HN8G7ZF7E34EN6JCDS46Q3KX2WAXBN43SPDR8H), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1PSTA73FRSRK0KZAWBCM9KRXHVE3RY255E3VZ3N), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x1752C976f74C9825dd212c622Aae638CE0df51c3, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1GDA6DQ953AFSX06SZBZ5CRT1Y1YKD7RQ3MY9TM), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPE2G85PGHBFRHX0AZBQ7JPTQK3F8HNWMMXG4HCH), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xBB1C344dEC35cDaE4F0CaEc00FB1C83b08343816, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: 0x001437a127ed82a5b8d00d47724119b369fda9617f51, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0xa91440b29e9395e0edd25acc5f788894f6232a1d578c87, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0x42EcAbFBDb1480682e821C3bADABD9fFD3f8A940, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP35DES4NN9H875PAR1DKZAVKRKJDVAMSAAAH1NVW), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xe6a6eE4196D361ec4F6D587C7EbE20C50667fB39, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP21K1RWW54ZTYJB3ANR580NVY787CHTTXF7PDF5K), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPPC0SHNQW3VTV1J35NENP68D026C0N15NEKARVQ), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x00149374e6518b0677cc143222a42713f325a93ca791, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP151AZ30XEB4KHZTBD1BXS375PRYYTAZK3AG229T), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x968fDd41f5C2674EBD32E25156D39BC4aF19264F, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP34ZW8B5PZWJVYQ5V8D49XQ4GH3XBR11AYCTS50C), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xeC5fDc2356F092bA20Bc98f98925889E62F8289D, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1CFPXVKBMQXJ6YW9VACC85Y4BRN4YJ0YAJSV9QH), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP38QN0RS6Q6FJZ70CCYZZN8W1B2EC4XAPXKV24FA), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP20AMF5TTH0XGTBNATXCA1RXZDJ1DG400CY2G282), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP13Q4T2CDGSSCEG3G49XZYMBGJGGB6A7HPBXK47N), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x62A8fA898f6f58A0c59f67B0c2684849dE68bF12, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: 0x51202715cc005adfe3767abf90d9355bfda8da2f9323a2b51f54702c2690d5e87305, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0x13283F05c087FB8d36Ef87939692d8718f5aa258, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPTKWPQKKNF2SKXZHX98SJ0PVP1AS2ZVXXE5BH06), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP16DEV7V7NR0BBTS4APDYX4257FPFT1YZZZXWWXX), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x0014195952478e537d465357ff965bd7b83352b01f7c, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3Z319KEJJAGAFSED4NSFMZS5PSACS4XGT26Z9VY), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2E0BGKYVPX1MVNECTKM6J7VP2JYH4TRN3KXA950), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3F0PMG8EV8PDFR73SHMF6J2SQWHMYTPMCMDFX7X), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x5531FE42B49b593a1080e246F308417742Da1836, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2A2R9ND16QARYA27RF03M5A3FYG5X59NPT4E8V0), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2CJJPCQ97CNTEW9TS5MHJAE4B31AP91C7F202VM), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3KN75N4CCACXAM1RHCW1QP4G3N9DW1VZXT9TMJ9), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3Y2WWB569PE5KZDZRS702WQRJ94HEBK72BSF6QR), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP27HEQDBXNTQSWFEXXKRYM8JM6C0ANPXPBRP8QMZ), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xf5C8Ca8383E538E462f16388362e4062899c9221, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0x62CB4be8DFD60F22D6B1dB2b512449cCfc7229A7, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0xe9dC0C1508619557bE43c79Ec867cb1d6b25aeFa, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: 0x9ae452e5bd703f0fe1afc79776137b38024d4f2e, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP13QC2G49PXXA84H083Y1PMFS2PGXM583HQ8TQ9F), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP23EYRDHD9GSB804TMZHPZ77H3Y51MEP0BT13SPA), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x00149f0771ba2841d42819128b205dae43a3a4eb6cb9, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0xa914229d788ba31661cf51b3145c7c4e7f0edc82578887, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0x350dedCc07acc2b3A430037435451b8d17Fe3248, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0xf6b02a7Fc3EE3979B6f4a824628DDDE4E6e7B311, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP34HPBVR4SZE0R6EFY2QY64X5TF9SJ1T0V73AKPX), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xa9148a69972ff6fc96b4090fd69a9c0d3e6ced39a50287, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3ZG74QSXXV4RJ4HWQ5M54V6EE08Y5KYDR07VXEC), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xBD47d3F6842edbEe6499529d755A8B230c262678, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0xa9140312de3fffbd3e945fa59ca1e401ae446129cfba87, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP7CSX0Z6TV54AP7J399ZWKEP8H62CJJJ638GKDP), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPXTHXY4TVKG9TPZJEFZXB2DZJQZ2RH81VNXAP05), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3B5NZ9T7MF80WJ4WGMM2AHC5KH0D160Y036MRRT), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPX570SAQYT6NDQZK25ZZBXWW6E6XRMTP5SNSHN4), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPK3EG816V3DC1RW8HVEQJ814XA3MFT8YC2AXGB5), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xa49c88cA2f55cc50ED0962808dD719cE925E8154, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP27BYYMF34FEC0PKY9HS0Y1YH48N91PZM59521MS), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP172QQY5W9WPA4YF9YBD9VETDKCN09Z05MJ7KXCV), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x0C8AA570a1dfEEE5258F3c13e2e967da24Bbb505, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2JJ3HXS8G2MYFQXYA7XTVJM7HJF9W6GHRG8BDKC), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3TA2HA0N9YNWHWW1EDDQKKE90EMYDW2X5XE6XA5), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x2DdCD9cAdE0a3D1742C71577f7c66b718Ca5BeBD, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3S3X4WCNPTDZW0623D5MGFK6K8WR8PSQAXTY505), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP10BNR7CT6KD00B9T42CPWXW25G6DDVSWHRJ3CR0), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x00149a8cb85206a778fdaa40ca4ad929a5631eb4b7f5, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1Y5PP22DETZ2ZS1KN8NB158Z7B3NH2FY48JM2RG), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xa9142d214c12623793c0123a2ae24d9d3114a69d036287, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2KEQPSEYH92J537WQT28SZJSB7DZYENP57R6ZVN), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP182CYQZSRPA664B16NVT1CP7FAE15B47PGJPT2C), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3N31KSKGTG6S3AESCYHE9N3RDKSQNZZG6MB434M), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPM2BGGS3EZVPSKFGWHGNE3QDJQNKMAKJSC1TFQF), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3188CJTN5YDY77KPT90AJJKHJKDSSMZ5T1PFF4D), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP71RCRSMFPQ1CYS9H46CC7FYHBMR293PBTXDXD9), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xe85152b8789bE63b27F5F14e55e358AcC09CFA63, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2FTADP4T7KM160MX0M2E52WKYJ8EZQWXHZGG8YJ), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1D8PQE10XR8MA1EM21MV6X0AS5HSEJ145311HPY), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPZ5DT0JRVWYHMT98WF9HZQFV5MRG06N6A8DPD4Y), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1FSX9QG8K0ZBFM104737ZN8KMB5S6PCM8J7TGMP), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1ZPTP0PDFHNA351JR02JDC8DTA6Y5Y9M91NACCX), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xa914c7e10e30cd7e76b1bc7d42c01cd60b2360e4d51d87, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0x815c1009eDb338CABA7B7E20B29055880FA85E3B, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: 0x680867357276030dEf3b9f9d0372697d2b7F9746, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3HJ9SQJ85TQS3ZBAJP26WHZFJ74PK30G4RJX7KF), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3NGDQX5YFV5DZ3HM27Y2CX9DJJAXS9B3HV75Y8H), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xe80284CE7F9841D36F8BfF0A10cBBc232D34Ab12, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP34ACMGARJ9X53BPF1AGZ5DDAX14KZE849KWNNAA), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x60E7f01BeC0fdEb04403CC4e6762015Db4A704dB, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: 0x5B78ace197872A4C90bb137D0643aA3755DBC1A0, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP23DZ9XYT3YNF70MHAV9Y3622H8B3DX10WMWT2T9), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2ZKPN8ZH7RH5BQZBB0CM1HFCGJ9KBF5S12ASE88), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x87751244E114B0769775319a0AB78d1846AB6214, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0xe7A18f9144e9433B056cDA56e07d6d602B8d5e22, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: 0x2FD44c06d31dB3d77df068a6072cf0bfF01a30a4, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0xa914741741fc49d9c2424348c386b4fac8b1afd4063c87, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPNXFZ7B52GMPGPGET9BF25HEE2G5BG3HRV5CKK5), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP7D58ZKRF90Z6SQH7CHEJVY7R89KHY0X534VM1J), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP238NQTX1DJXMNJ7EM398D34DSHMJ1PQM9Z9XZW8), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3CQEAZN2A4C056JHE7W7QSZ2VJ244NMHFAETQ56), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2JCF3ME5QC779DQ2X1CM9S62VNJF44GC23MKQXK), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP11TKRDTY5DAMDSSH832QZSBNF63PECT1FQKGG60), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPR6K4VQ0JQN677W4GGCN5JTPN7XF7YTP7WKAJXH), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1FGW6TBJGXS6J5MWBY8MV1TCB7TH55GJNRJJK1), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2W6YP0Z5P9N8E22HKJHEHJ37S0HJP7MQ95QW1XA), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP207VG4FKAHJZ0J0SYEDBEKSYMQXRX02TJWR1N4G), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xc330E99C16420ad690fC2ca47FF608a72410aA23, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: 0xcE38a8dbDf841f72b73cE2B5785c8cc7549f4078, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0xa9146122706ff20bdc3cd71fb8f1657c9db2bbf9c68a87, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0xa9144bc2c98ad1ffa1432c89d9f0f1782a585a60c75287, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: 0xa9142809d37fc70be6376b3de12e74c039c1c95df25887, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3EERYYETAH3DM910S9MPXNY245FV189QZECC4TC), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3TF26QFS3YMYHC9N3ZZTZQKCM4AFYMVW1WMFRTT), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SPGXNQSF2QJ9KQA0HHVSA64WBE4SG1AXMDYVN1GJ), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x8a26c81b8f643fa8de03a8c216dc059d8d4ca7f2, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0xa732AE5D358Be8F56bC72e0165ad2f19ad6AE94D, chain-id: (some u1) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1QYM4B2ANC2K5SR56FNAS9X6FSS0JARAGP14NSY), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP22N6G1K66SHMFRH3HJ9BK6XTG6K2ZA1FM5KQ1XQ), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xa91422c40254cadf87ced0ea71de8ba599909059748887, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP28RESB6X2ZV9E85AEA666T5JY9YE6XFP9EF919Q), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2V655KJ5MV324VAD1DMQX1PMP4QQ8FPZFKQHFHJ), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3QB8DWAWXHJZCV9A5882Y2QY4ZM8Y3QZNEN5189), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP288GQY0J08V8NPE0E7JDYDV6WT9P3MZSKKKG0N1), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xC476267c64C2a0f383Fb14cE77eCeF555071dd36, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0x53695fAE79A11f1E91AacB73eA37E36a8C09Baba, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0x5120e9e2075efac4a5fa23b303f3822fa0000ba4be617d2ef90234a81e3f8e771bb8, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP38D1YS5M28RQW2JRF6FMDNSGRZPDGKVTDX6DBFR), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x27b4eDe5BE315E85347170c7Da8477B6757B2cD7, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2RSV8RE5J2KVTJ3FJTAFPKB8E6AMACVS9MBEWNH), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP2ERR437ENM9JPXDNBM3CNBZV1F68D6RWDSYY2BN), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP34VN50ZVG2BG9TKNH2318SYXY2MRKZJXATA43RF), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1DMSN4Y3WQVSFPS8S2Z4SEHAQGDKGZSRR5QA7Y3), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xa166b3b33c0b39416591580275fe94c02e25b837, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0x001428f8ca9c998cd4397fb2eacb987ff4fa119d65bd, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3MZS9AAYTMERCCE7JA69QCFB79H9A2S24B41EEY), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3TWESD0X5GNNFYRW1887E0DB0TGMJNS59F92QK9), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x1dC5b6AE820cb1649536FAa899404786305B7117, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1H29CT68V9B5R7Q3Z4HDX7BY6T7D4YT87DX3JWE), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP3FEHJMZ7S5EVCS1GVD68JZC1CYKREMVNC9866TN), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0x51209a6fb414445ddaf09dd1444f955e6f35d634c2a9a0da5b94952536db46847c2c, chain-id: (some u0) }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP1PNPW60G2Z0VR02WCZ79BH1VCD0APQKFS5E8668), chain-id: none }, whitelisted: u1 }
{ owner: { address: (encode-principal 'SP23ZJ3CS12S27XK879BCHJSJ4P4YJYTPAS2PMR6R), chain-id: none }, whitelisted: u1 }
{ owner: { address: 0xcCd9a677d03418dC79826cdbA5fD85570924f58E, chain-id: (some u2) }, whitelisted: u1 }
{ owner: { address: 0xc355c2230F42224C1AE0cFeAC3d7773a8ea8a268, chain-id: (some u3) }, whitelisted: u1 }
))

(define-public (execute (sender principal))
	(let (
		(pool-details (try! (contract-call? .alex-launchpad-v2-03f get-launch-or-fail u2)))
		(distribution-id (try! (contract-call? .alex-launchpad-v2-03f create-pool 
	{
		launch-token: LAUNCH_TOKEN,
		payment-token: PAYMENT_TOKEN,
		launch-owner: LAUNCH_OWNER,
		launch-tokens-per-ticket-in-fixed: TOKENS_PER_TICKET,
		price-per-ticket-in-fixed: PRICE_PER_TICKET,
		activation-threshold: u0,
		registration-start-height: (get registration-start-height pool-details),
		registration-end-height: (get registration-end-height pool-details),
		claim-end-height: (get claim-end-height pool-details),
		apower-per-ticket-in-fixed: (list { apower-per-ticket-in-fixed: u0, tier-threshold: MAX_UINT }),
		registration-max-tickets: MAX_REGISTRATION,
		fee-per-ticket-in-fixed: FEE_PER_TICKET,
		total-registration-max: MAX_TICKETS,
		memo: none
	}))))
(try! (contract-call? .alex-launchpad-v2-03f set-use-whitelist distribution-id true))
(try! (contract-call? .alex-launchpad-v2-03f add-to-position distribution-id SUPPLY_TICKETS 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc))			

(try! (contract-call? .alex-launchpad-v2-03f set-whitelisted distribution-id (unwrap-panic (as-max-len? (unwrap-panic (slice? WHITELIST u0 u200)) u200))))
(try! (contract-call? .alex-launchpad-v2-03f set-whitelisted distribution-id (unwrap-panic (as-max-len? (unwrap-panic (slice? WHITELIST u200 u400)) u200))))
(try! (contract-call? .alex-launchpad-v2-03f set-whitelisted distribution-id (unwrap-panic (as-max-len? (unwrap-panic (slice? WHITELIST u400 u500)) u200))))
		(ok true)))

(define-private (encode-principal (address principal))
	(get hash-bytes (unwrap-panic (principal-destruct? address))))
