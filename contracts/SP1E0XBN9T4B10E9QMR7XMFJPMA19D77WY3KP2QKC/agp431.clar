;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places

(define-constant REMOVED (list
'SPBNMD07T0WD2WJAH6JZJG07GYSF0X413V69J3T9
'SP1M2A0JQ2DZJM67NTYM8XYG92Y6CDAR4HZME104Z
'SP2ZYR2314Z50MZF2K5N0266R1JX6VDZR9P501Z9B
'SP5BDPA6AJEVER227D8H8EMX5MXKKV5FT5C0YX6M
'SP25JXH48YHJPE8R48S3AWVYPSB3N3ZG9PRKQZHSF
'SP327J3J6RK88KGRQSMSWDRCP53EDHGJKHSNNGR4P
'SP3BGZAZKBS475T9FS18VH1NANWV4ERSGZWJKSRTF
'SP3YB4JCE0H9QCE63MQ199BM8GXWV24E13G9J381F
'SP3SJSNPJXXHY7RJM48ZT6G1BXYZADAC5YAXZA3ZC
'SP11XNH1DR40PYSN8P3BCBNFY356TDFHS64XSRVPB
'SPQT2PNZVZVYT4JV8CDY014HT3PN0YJT0T6GVQJ0
'SP2HH1X2KVS1M0BS15ZE42JXJFWNBVPH7C672XEKP
'SP26PZG61DH667XCX51TZNBHXM4HG4M6B2HWVM47V
'SP8CFZ1ZQM71Y1E17G9SWFP1D0RNE1KSPKZ306ZC
'SP2F4QC563WN0A0949WPH5W1YXVC4M1R46QKE0G14
'SPJTC4M0P9A78RKDHRVWFYJDV7WZYK35DMD6RK2G
'SP1T6PKFK93RETHWSJ0MGNQNCZD6CGTS10V5YX3PX
'SP1JF39JN759PYZTE8DC9FFYKTT7AJWA6CFGDSM61
'SP21GFF36XR94BVB8MA9T5DY3Z19A5YVGPBGZADJC
'SP3FV0AZPHECVFXP3GTYJ0KQHMY0SB9CNFJ41KHVF
'SPEYPQK80Z96XAVKHZGK26VAHB1P3XA4HHTN54T4
'SP3FBA193WQJA9DYE5BG03PGXJ7NQD69H399ZZYHN
'SP2G5HQM4VPHH3EK6KVK9625WQ5153F4ZKW4WJX3C
'SP3SEJEBV9V6ZVS8AVSSGZ3X1ZEK163HX3HPHYDDP
'SPQPSQ8MAEX8198N8D8QWPCX0XQ6AC2YSGGAAKX0
'SP36S9HTB265RBT1TCKW1QHHAQ967VNE3RH6W5C3Z
'SP192VGXSNJN6PFCQ1J93SQN6E8E2EAV8TDDCWVWF
'SPNYKTT61QNHRYTPYVH4V28Z2WSDG6JNJBBW0RH7
'SP1GVVQTJ2E7FN4H7HR5HRCC11NRNHM3RZVE8DYGM
'SP1YT7HPD025ZMY9Q5NYHZ6V7MN6J8BMHVXKD3NJJ
'SP00000000000003SCNSJTCSE62ZF4MSE
'SP36VJT9YM4XQW7PTWMY8B823QNZEVMR1KEQH5J75
'SP3KWRG8T56H8GY291EHATAX095XXMTWQA01SR2MP
'SP22C9ZWGSKV5H99RS6R12GS2H0Y7Z0JTSB3WV286
))

(define-public (execute (sender principal))
	(begin
(try! (contract-call? 'SP2SF8P7AKN8NYHD57T96C51RRV9M0GKRN02BNHD2.blocklist remove-from-blocklist-many REMOVED))

		(ok true)))

