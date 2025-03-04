
(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP3QFV7FJ2HRQNKFDTDYNTQSZ3RQAPJD7T66WEJYE.staciks-stxcity send-many (list {to: 'SP256DPEE354ZGC5R8MF06A0JSX46JRT0VRFXERGM, amount: u100000000, memo: none} {to: 'SPTXD4GBSCPA1ZTETYS9C9QEFVYGHFZDP30JGFN5, amount: u100000000, memo: none} {to: 'SP2FA1H3K9FMY2CQ80WWT2JYMHZ5Z2B810AT41APW, amount: u100000000, memo: none} {to: 'SP2EQP7X0WCJ70ZMQYGPXAD0S9T76JH1CDZMEMQES, amount: u100000000, memo: none} {to: 'SPK42JR8Q2VNVBC8SAM1M2BQ5SEZC0JPZ295Z62Z, amount: u100000000, memo: none} {to: 'SP1YH7RS8EJMJYZW0RAPJH4N7GRS2DFDZXXFVZZ08, amount: u100000000, memo: none} {to: 'SP2C609CVJP3Y7B28MPPR8JTQ5C3MZK220KMX227K, amount: u100000000, memo: none} {to: 'SPQRJEBEVBY8K90QQ42JX71YFVX8Y6YGQ09RXJS9, amount: u100000000, memo: none} {to: 'SP1Y7CZMK5EPXPCGTGWAW7BYPHKRWZ810CFKY51TD, amount: u100000000, memo: none} {to: 'SP2C72R5ZP035N7F6EC72P4AM314H8EJNB2R3B70J, amount: u100000000, memo: none} {to: 'SPFFH36C7REYVJBBYS7GRNZYDYT40247F7GW07E7, amount: u100000000, memo: none} {to: 'SP24816ZF3R02B704RYHT1612YW7R9K7Z1JV4J2JJ, amount: u100000000, memo: none} {to: 'SP35DJDPDNCYRPMTDW10YCQFA29HWXK2S3W5FKFA7, amount: u100000000, memo: none} {to: 'SP2A0AHSWNYPAS1KRNMEFQMV8WQ2KZRRW8DZC8Z3K, amount: u100000000, memo: none} {to: 'SP2K1QW076PZT0VT9M3DX7GPJ088XYB5GH0G5V2QY, amount: u100000000, memo: none} {to: 'SPVR9PDHJHGJT59GE10E8QE2433YAZY6Z47EY13P, amount: u100000000, memo: none} {to: 'SP7SHEREY1MWFRGB2WB3QQMBP4HJ9AJ8Q9ZB1YJM, amount: u100000000, memo: none} {to: 'SP14Q44DPTBA079BHN627B8JR2PJYXV8866ADT765, amount: u100000000, memo: none} {to: 'SP3A3MD8G3H40BA0TTFNVKSNSG0NG2TS5Q1H65381, amount: u100000000, memo: none} {to: 'SPNF6V2Z7SZ6NXSPQK3R5SSR3BKCBWQ6E029VZG5, amount: u100000000, memo: none} {to: 'SP1JG8REQVYP93NC3WN417CFYJ8E1V1E1C1NXAYEW, amount: u100000000, memo: none} {to: 'SP35PHQ261K17EN4VY25JSDAEJKK2SMDAFKSRDT2J, amount: u100000000, memo: none} {to: 'SP277VXTHQ3E283BGBPFC148T2TH5ZRXA9HR1TJ30, amount: u100000000, memo: none} {to: 'SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D, amount: u100000000, memo: none} {to: 'SPNHHXG9Y6C4WCC0SS874ZQ3HK1QJA91NBX6M2EP, amount: u100000000, memo: none} {to: 'SM3TEMP49YAYPY6GX5AEC6QB9223Q061B52XXSJ31, amount: u100000000, memo: none} {to: 'SP1983XRW15MDPPHV02HX172HEGV6GC8B6HMX01FV, amount: u100000000, memo: none} {to: 'SP22JQRHFN2DFE15ANN47P6FM40SF8B3K2JJTC6JZ, amount: u100000000, memo: none} {to: 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP, amount: u100000000, memo: none} {to: 'SP390ATGDGQFHE5YEWKXHCGQVXNAQP25JAXXZMWSC, amount: u100000000, memo: none} {to: 'SP3F2HRF1DQ8B0DSRBE8ETVQ8CRBWRSX5GZS2KBC4, amount: u100000000, memo: none} {to: 'SP2N58D7RDC6N3HASYST9R6AX9DM8M8FS6JTPS46N, amount: u100000000, memo: none} {to: 'SP2TTVRSPJX5QXMAPRXJAYFWGEZ5PSS6A19G5KFES, amount: u100000000, memo: none} {to: 'SP238X3JD22HJBMWR8E7CKTF4JCBQ73BG9YS1DBH8, amount: u100000000, memo: none} {to: 'SP24GNHM3315KYXEAETEPSYKRRXK8WRQ6T09TYNDG, amount: u100000000, memo: none} {to: 'SP3SB0Y72DXRJK2J9RGJYGKGPC0T94GY5M7G6X15F, amount: u100000000, memo: none} {to: 'SP3VGRCZDRG8JBGX0H0P340DZC7C3FWCA80S9TT3D, amount: u100000000, memo: none} {to: 'SPQRH49JM9YA39R21KHN49M5S947ETH2QFAW3F02, amount: u100000000, memo: none} {to: 'SP20D70Z0QD2A1MDTWZVWCD9YEJSY85CFB1K95GYC, amount: u100000000, memo: none} {to: 'SPS1V0TA8RC4BNY60HEHAGN77NP5YCCTKFNKZ3C0, amount: u100000000, memo: none} {to: 'SP2SKMAR9WMD9DBJHC4XTQXPZCDNV1258PSJTRGTV, amount: u100000000, memo: none} {to: 'SP22ZJRC926622B5PZCP0PCJ3Z913VRH27AAEFCJF, amount: u100000000, memo: none} {to: 'SP3KVRE3RDYYSJ3JDGXKA0K15CC4JEA2ZGX4TJ5EC, amount: u100000000, memo: none} {to: 'SPH5EGVRXQAN9DN2H88WHNRST4DVY8GM8GDD68A0, amount: u100000000, memo: none} {to: 'SP1BZXABNDK1KNRADQ2EZFW8Z0V5GZCP6P2NF64QW, amount: u100000000, memo: none} {to: 'SP1B38V9K4MW4AR3C7MP44SHGPMBYHP2A7PJDJ2Z2, amount: u100000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)
