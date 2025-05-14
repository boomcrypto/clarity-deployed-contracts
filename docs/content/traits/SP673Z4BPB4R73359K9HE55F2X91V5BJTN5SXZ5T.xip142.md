---
title: "Trait xip142"
draft: true
---
```
;; 'SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(use-trait ft-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-constant err-unauthorised (err u1000))
(define-constant err-paused (err u1001))
(define-constant err-peg-in-address-not-found (err u1002))
(define-constant err-invalid-amount (err u1003))
(define-constant err-invalid-tx (err u1004))
(define-constant err-already-sent (err u1005))
(define-constant err-bitcoin-tx-not-mined (err u1011))
(define-constant err-invalid-input (err u1012))
(define-constant err-token-mismatch (err u1015))
(define-constant err-slippage (err u1016))
(define-constant err-not-in-whitelist (err u1017))
(define-constant err-invalid-routing (err u1018))
(define-constant err-commit-tx-mismatch (err u1019))
(define-constant err-invalid-token (err u1020))

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin	

(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt, chain-id: u16 } u39781077000000))

		(try! (refund-meta-tx 
  (tuple (amt u1448777027190000000000) (bitcoin-tx 0x02000000000102ecb38e4ca614bcccd82f83056ab98cea5017cf3d928e0e6f0b7f214d8042d02e0000000000ffffffff40917544d4874429a9c66e451d22b649da16effa0e570a07f37d492d41abafbc0100000000ffffffff042202000000000000225120f77236aa6941bdc14944fb63b74084647f8986664ff01d28a0f09c10fac853c30a06000000000000225120ede2700062adecc82cbe9fa4ea244a910c49255c12f3fb3a8773ed205860f8f9220200000000000022512044569a49e988b03711b0be2af83287bd067cb251f5633e75adcb483b0b5323f8940e00000000000016001409b26eeb9b40373fab7dc5c4e9ae4e79ac51860201406e3e0ecb587bbd9d26f4d551da5a9a2bf2a22c8b16fcd2298260dca7e4a6cdc507e5dee732e007fe6e0ef711407b86d9ea42c218899115bbe5da60bf2437c62f02483045022100b2ca900dc40a559aa2f521fc36f1394b3c6bb8db7869a991d1fbeae23f067b2f02205cc046b77e6b4a6e14e28f2ff7dc71152ffc48ecfa647a7d463b1cb13b81563e01210332aaa50b5107a14fc078322aa8379fc0edc14bcdddf6d3d8b7d626f9115ccd3600000000) (decimals u18) (from 0x) (from-bal u0) (output u0) (tick u"$B20") (to 0x5120f77236aa6941bdc14944fb63b74084647f8986664ff01d28a0f09c10fac853c3) (to-bal u0))
  (tuple (header 0x00000034653bd173a790832b102e65600167933841c876d9681f010000000000000000008387bec299de52c8f11417727a62cf9fd1cc49bb94645360d6749ad35fd64e4d95afeb676c790217bbcbac89) (height u890373))
  (tuple (hashes (list 0x9d23680a7932f874f9f30e5163b743dcd269b488692f62931181055cbc70d300 0x4bd5ab41244b12b6e37464a43a563e2d35a2851e89aa4f9aa7513d477a86cf31 0x5a76720f71dfb147e537ce6a66587e589d619477c0c0d80883a322503bcfbf9b 0xfbdfa212823996271beb1c90f93f47b5913c52934a19fbe56dc0a6ffd98c5047 0x4cb40e006cfa736b9591c454d56f935f1e9678fc95adf9d74dc19124779717f6 0xe34c887068904992930a5f8fc367c488a81f90584bbeb77089fa135dffc7fce3 0xe96447f51da3b0b1bf9aead18146ebd90838d253747e35a81bc280dca3234d55 0xa1c17e35671db3cfaf11a7f484d9249e2b4258b5d78ff7b3f046f7b8900af361 0x4ac7642111d67be10629353158bdc831ae514d7fd176acc6a0ab919da9a67fe6 0x18effeaaa24a16368408cd613c6f70e2cac0c27da2b52a57aedc082ba8cc2c6b 0xc44f444e00a8b812bc2c9984046cc2d2a0e6172480b2325cf766545a6ef337fc 0x0e1c0c5eacb85956139765c095ceba9b3b80f20af08d5d1bb0d64dc7dceee060)) (tree-depth u12) (tx-index u1026))
  (list (tuple (signature 0x0702e77efc08425a078f0ae67d70e494ebd4be9a1d88f71bd116e550e3d099f3246aa622c0cdcd22a9b12e72b70b6b4446bc061cff832aafe5146da283d17a2000) (signer 'SP3TJ5YF08D4FSHM9ZYBBG3X76PW9257YE9SPFWA1) (tx-hash 0xdb591b94a03ff0423c30e275ad0ef69ae1c52bcdd15dc37c939021ac5f852f5c)))
  (tuple (order-idx u0) (tx 0x020000000001015847cb61a257cd899a3551d0508d4af368826c9e3a8e979c6b275d505f67abbe0100000000ffffffff014a01000000000000225120f77236aa6941bdc14944fb63b74084647f8986664ff01d28a0f09c10fac853c3034066d89b45449a6feda02e966a43839d444bbb6c826bc65dae3a1f5fdd353ce168ae94abf1b5cc1632a42f1aae32257054e8de300bb9fae428cf1894e5a46e1227c64ca10c0000000601630d000000013001660200000022512083e1e7a66bee89c7935b3e2eede91f21f88a63fad7b16da360c0ecf8d1dc9729016d0d000000053134333735016f0616bad390278c2d8d61d49bce446eaebd9b8c0314550a746f6b656e2d6162746301700b000000030d000000033131330d000000033132350d0000000331323401720200000016001409b26eeb9b40373fab7dc5c4e9ae4e79ac518602752070faf88fa6105c7bbd6f0cabe2e03a778ada80f8291699a8803574cc935946e7ac21c150929b74c1a04954b78b4b6035e97a5e078a5a0f28ec96d547bfee9ace803ac000000000))
  (tuple (header 0x00000034653bd173a790832b102e65600167933841c876d9681f010000000000000000008387bec299de52c8f11417727a62cf9fd1cc49bb94645360d6749ad35fd64e4d95afeb676c790217bbcbac89) (height u890373))
  (tuple (hashes (list 0x5847cb61a257cd899a3551d0508d4af368826c9e3a8e979c6b275d505f67abbe 0x4bd5ab41244b12b6e37464a43a563e2d35a2851e89aa4f9aa7513d477a86cf31 0x5a76720f71dfb147e537ce6a66587e589d619477c0c0d80883a322503bcfbf9b 0xfbdfa212823996271beb1c90f93f47b5913c52934a19fbe56dc0a6ffd98c5047 0x4cb40e006cfa736b9591c454d56f935f1e9678fc95adf9d74dc19124779717f6 0xe34c887068904992930a5f8fc367c488a81f90584bbeb77089fa135dffc7fce3 0xe96447f51da3b0b1bf9aead18146ebd90838d253747e35a81bc280dca3234d55 0xa1c17e35671db3cfaf11a7f484d9249e2b4258b5d78ff7b3f046f7b8900af361 0x4ac7642111d67be10629353158bdc831ae514d7fd176acc6a0ab919da9a67fe6 0x18effeaaa24a16368408cd613c6f70e2cac0c27da2b52a57aedc082ba8cc2c6b 0xc44f444e00a8b812bc2c9984046cc2d2a0e6172480b2325cf766545a6ef337fc 0x0e1c0c5eacb85956139765c095ceba9b3b80f20af08d5d1bb0d64dc7dceee060)) (tree-depth u12) (tx-index u1027))
  none
  (list 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-db20 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc)
  'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc))

		(try! (refund-meta-tx 
  (tuple (amt u9646328820000000000) (bitcoin-tx 0x02000000000102943f027194f58284c1f7897ea0a63111611fa657ff337577b8bb675081df2de50000000000ffffffffc25493dd472fdacca10008970ab01487fa2309e69653ec8b2dc614b9711a934c0100000000ffffffff042202000000000000225120f77236aa6941bdc14944fb63b74084647f8986664ff01d28a0f09c10fac853c30a06000000000000225120d33de7ee8ed7d361826e1647105a40188c6ef7d30ee7e392af9d9a64f0bf9a0d220200000000000022512044569a49e988b03711b0be2af83287bd067cb251f5633e75adcb483b0b5323f8d21901000000000016001409b26eeb9b40373fab7dc5c4e9ae4e79ac5186020140074d869a671df49ea1c4f3cf74da0e77ce5d3023cd2d7df8acf7774affb6ccfd6bb211b4db7c90af3818c1c1e0a6cd6b84b34f0703bdbeec34ec411c7bb267ba024730440220758e4563ce0994d9af15a96a3f64c928c55c4ce729d7d6c9589b39aca0b71cc00220157c0de43cea304b272097af50a1f6fd1d74d862e6c7964a1dfa42ba9cf5fcac01210332aaa50b5107a14fc078322aa8379fc0edc14bcdddf6d3d8b7d626f9115ccd3600000000) (decimals u18) (from 0x) (from-bal u0) (output u0) (tick u"AUSD$") (to 0x5120f77236aa6941bdc14944fb63b74084647f8986664ff01d28a0f09c10fac853c3) (to-bal u0))
  (tuple (header 0x0080e42536d357e18b9ab75dbb5e4ee3776e243fd7f47bac425a020000000000000000003be91f1fc1e398783e318c75c603612917b429e74ce3c6d4862eae66e0a11a11a4bbeb676c790217188bbc76) (height u890375))
  (tuple (hashes (list 0xf8f2cc675957143a61199f83770bb06019fe62ef7497f722cc6326cef3e0fbe9 0x1f466e0af42f5216e8462bb1f8614398ab8f83b3a8478e49a25a6f81ef67adb2 0x83c34e358d20d57997b9716b068221b5c191a7845ec2aa182e01b51aa28914f0 0x80e7bc7a6c25c5a1bb5cd826e4eb6efa405a35d7fb3e8f779cca5be647dc837d 0x1a9a95afe3e7151105a14fbae2f47f38d08996776d120f6d494eba476454a80b 0x4a900762d52bf4d0534f4f616217d83164e7bca44f90a676be553c1515bf6ce8 0xb02432617c343b6752492b3c5aca7b6765818821f90ff6d3b48ad73314f7f339 0xb42c0f25af595c7ca6dd6cab586e5ccba06c9eb50dcf76723b4d1505ca1cdb8f 0xb09d6c13c0d7dedd2f07acc7aa48e7501a20fae5a0c00761abd7b8a5a8aa4e3a 0x1a74b8df0686073004f6f2845e78f9c5919a0e34040eb617ec1da92e47049fc8 0x49784d82b49153e7cd9f51b016c4cac65d504d4d4154777ca23f0076fa3afd43 0x5eaad245127ac66e259b4e831c2d8819cd69797204b31800b227b886c17d77f8)) (tree-depth u12) (tx-index u3460))
  (list (tuple (signature 0x6125673aec0e128774ae45cfea8301716da5735144d2806fd3ab309f6248b1b024b8ab9e0dcaa78335c4785b009bd59769eab3aa16e563f0b453d04a289ca52501) (signer 'SP3TJ5YF08D4FSHM9ZYBBG3X76PW9257YE9SPFWA1) (tx-hash 0x36fdecf56ec0cb654d0c636d04bcf2d567ee55d14d965342024602eecf6699fc)))
  (tuple (order-idx u0) (tx 0x02000000000101adc9f48941faf42c420c90af197f439ef992c4355cb0cac6e51a5e48119f4c960100000000ffffffff014a01000000000000225120f77236aa6941bdc14944fb63b74084647f8986664ff01d28a0f09c10fac853c303407473bce3b5814e1df094f6cee13aa145bb5c07742a91bfc1bf5cb5e560a96b287b1428254f12b149381d69c684725031079db63978d3f80f1e2c1df30ae21f47e64cc10c0000000601630d000000043130303201660200000022512083e1e7a66bee89c7935b3e2eede91f21f88a63fad7b16da360c0ecf8d1dc9729016d0d00000012313537383735303439303735373431333936016f0616402da2c079e5d31d58b9cfc7286d1b1eb2f7834e0a746f6b656e2d776e6f7401700b000000040d0000000232310d0000000231350d0000000231330d00000002333401720200000022512083e1e7a66bee89c7935b3e2eede91f21f88a63fad7b16da360c0ecf8d1dc9729752070faf88fa6105c7bbd6f0cabe2e03a778ada80f8291699a8803574cc935946e7ac21c050929b74c1a04954b78b4b6035e97a5e078a5a0f28ec96d547bfee9ace803ac000000000))
  (tuple (header 0x0080e42536d357e18b9ab75dbb5e4ee3776e243fd7f47bac425a020000000000000000003be91f1fc1e398783e318c75c603612917b429e74ce3c6d4862eae66e0a11a11a4bbeb676c790217188bbc76) (height u890375))
  (tuple (hashes (list 0xadc9f48941faf42c420c90af197f439ef992c4355cb0cac6e51a5e48119f4c96 0x1f466e0af42f5216e8462bb1f8614398ab8f83b3a8478e49a25a6f81ef67adb2 0x83c34e358d20d57997b9716b068221b5c191a7845ec2aa182e01b51aa28914f0 0x80e7bc7a6c25c5a1bb5cd826e4eb6efa405a35d7fb3e8f779cca5be647dc837d 0x1a9a95afe3e7151105a14fbae2f47f38d08996776d120f6d494eba476454a80b 0x4a900762d52bf4d0534f4f616217d83164e7bca44f90a676be553c1515bf6ce8 0xb02432617c343b6752492b3c5aca7b6765818821f90ff6d3b48ad73314f7f339 0xb42c0f25af595c7ca6dd6cab586e5ccba06c9eb50dcf76723b4d1505ca1cdb8f 0xb09d6c13c0d7dedd2f07acc7aa48e7501a20fae5a0c00761abd7b8a5a8aa4e3a 0x1a74b8df0686073004f6f2845e78f9c5919a0e34040eb617ec1da92e47049fc8 0x49784d82b49153e7cd9f51b016c4cac65d504d4d4154777ca23f0076fa3afd43 0x5eaad245127ac66e259b4e831c2d8819cd69797204b31800b227b886c17d77f8)) (tree-depth u12) (tx-index u3461))
  none
  (list 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxusd 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnot)
  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnot))
(ok true)))

(define-private (refund-meta-tx
  (tx { bitcoin-tx: (buff 32768), output: uint, tick: (string-utf8 256), amt: uint, from: (buff 128), to: (buff 128), from-bal: uint, to-bal: uint, decimals: uint })
  (block { header: (buff 80), height: uint })
  (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
  (signature-packs (list 10 { signer: principal, tx-hash: (buff 32), signature: (buff 65) }))
  (reveal-tx { tx: (buff 32768), order-idx: uint }) 
  (reveal-block { header: (buff 80), height: uint })
  (reveal-proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })    
  (fee-idx (optional uint)) (routing-traits (list 5 <ft-trait>)) (token-out-trait <ft-trait>)) 
  (begin
    (try! (index-tx tx block proof signature-packs))
    (finalize-peg-in-cross-swap { tx: (get bitcoin-tx tx), output-idx: (get output tx), fee-idx: fee-idx } reveal-tx reveal-block reveal-proof routing-traits token-out-trait)))

(define-private (finalize-peg-in-cross-swap 
  (commit-tx { tx: (buff 32768), output-idx: uint, fee-idx: (optional uint) }) 
  (reveal-tx { tx: (buff 32768), order-idx: uint }) 
  (reveal-block { header: (buff 80), height: uint })
  (reveal-proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })    
  (routing-traits (list 5 <ft-trait>)) (token-out-trait <ft-trait>))
  (let (
      (is-reveal-tx-mined (try! (verify-mined (get tx reveal-tx) reveal-block reveal-proof)))
      (validation-data (try! (validate-tx-cross-swap-base commit-tx reveal-tx)))
			(token-trait (unwrap-panic (element-at? routing-traits u0)))
      (tx (get tx commit-tx))
      (order-details (get order-details validation-data))
			(token-details (get token-details validation-data))
      (fee (get fee validation-data))
      (amt-net (get amt-net validation-data))
      (pair-tuple { token: (get token-out order-details), chain-id: (get chain-id order-details) })
			(print-msg (merge (get tx-idxed validation-data) { type: "finalize-peg-in-cross-swap", order-details: order-details, fee: fee, amt-net: amt-net, tx-id: (try! (get-txid tx)), output-idx: (get output-idx commit-tx), offset-idx: u0 })))
    (asserts! (not (get peg-in-paused token-details)) err-paused)
    (match (get fee-idx commit-tx) some-value (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-bridge-registry-v2-01 set-peg-in-sent tx some-value true)) true)
    (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-in-sent { tx: tx, output: (get output-idx commit-tx), offset: u0 } true))
    (and (> fee u0) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc mint-fixed fee tx-sender)))
    (try! (check-trait token-trait (get token (get pair-details validation-data))))
    (and (> amt-net u0) (if (get no-burn token-details) 
      (let (
          (peg-out-balance (- (unwrap-panic (contract-call? token-trait get-balance-fixed .meta-peg-out-endpoint-v2-04)) amt-net))) 
        (try! (contract-call? .meta-peg-out-endpoint-v2-04 transfer-all-to tx-sender token-trait))
        (try! (contract-call? token-trait transfer-fixed peg-out-balance tx-sender .meta-peg-out-endpoint-v2-04 none)))
      (try! (contract-call? token-trait mint-fixed amt-net tx-sender))))
    (try! (refund fee amt-net (get from order-details) token-trait (get chain-id (get pair-details validation-data))))
		(print (merge print-msg { success: false }))
		(ok false)))

(define-private (validate-tx-cross-swap-base (commit-tx { tx: (buff 32768), output-idx: uint, fee-idx: (optional uint) }) (reveal-tx { tx: (buff 32768), order-idx: uint }))
  (let (
			(validation-data (try! (validate-drop-common commit-tx)))
			(reveal-tx-data (try! (contract-call? .meta-peg-in-v2-06d-swap decode-order-cross-swap-from-reveal-tx-or-fail (get tx reveal-tx) (get order-idx reveal-tx)))))
    (asserts! (is-eq (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.clarity-bitcoin-v1-08a get-segwit-txid (get tx commit-tx)) (get commit-txid reveal-tx-data)) err-commit-tx-mismatch)
    (ok (merge validation-data { order-details: (get order-details reveal-tx-data) }))))

(define-private (validate-drop-common (commit-tx { tx: (buff 32768), output-idx: uint, fee-idx: (optional uint) }))
	(let (
      (tx-idxed (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 get-bitcoin-tx-indexed-or-fail (get tx commit-tx) (get output-idx commit-tx) u0)))      
      (pair-details (try! (contract-call? .meta-peg-in-v2-06d-swap get-tick-to-pair-or-fail (get tick tx-idxed))))
      (token-details (try! (contract-call? .meta-peg-in-v2-06d-swap get-pair-details-or-fail pair-details)))
      (amt-in-fixed (decimals-to-fixed (get amt tx-idxed) (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 get-tick-decimals-or-default (get tick tx-idxed)))))    
    (asserts! (get approved token-details) err-unauthorised)
    (asserts! (not (contract-call? .meta-peg-in-v2-06d-swap get-peg-in-sent-or-default (get tx commit-tx) (get output-idx commit-tx) u0)) err-already-sent)
    (asserts! (contract-call? .meta-peg-in-v2-06d-swap is-peg-in-address-approved (get to tx-idxed)) err-peg-in-address-not-found)     	
    (ok { fee: u0, tx-idxed: tx-idxed, pair-details: pair-details, token-details: token-details, amt-net: amt-in-fixed } )))

(define-private (refund (btc-amount uint) (token-amount uint) (from (buff 128)) (token-trait <ft-trait>) (the-chain-id uint))
  (let (
      (pair-details { token: (contract-of token-trait), chain-id: the-chain-id })
	    (token-details (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 get-pair-details-or-fail pair-details)))
      (default-fee (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 get-peg-out-fee))
      (default-min-fee (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 get-peg-out-min-fee)))
    (and (> btc-amount u0) (begin
      (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-fee u0))
      (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-min-fee u0))
      (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 request-peg-out-0 from btc-amount))
      (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-fee default-fee))
      (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-min-fee default-min-fee))
      true))
    (and (> token-amount u0) (begin
      (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-out-fee pair-details u0))
      (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-out-gas-fee pair-details u0))
      (try! (contract-call? .meta-peg-out-endpoint-v2-04 request-peg-out token-amount from token-trait the-chain-id))
      (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-out-fee pair-details (get peg-out-fee token-details)))
      (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-out-gas-fee pair-details (get peg-out-gas-fee token-details)))
      true))
    (ok true))) 

(define-private (index-tx
  (tx { bitcoin-tx: (buff 32768), output: uint, tick: (string-utf8 256), amt: uint, from: (buff 128), to: (buff 128), from-bal: uint, to-bal: uint, decimals: uint })
  (block { header: (buff 80), height: uint })
  (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
  (signature-packs (list 10 { signer: principal, tx-hash: (buff 32), signature: (buff 65) })))
  (begin 
    (and 
      (not (is-ok (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 get-bitcoin-tx-indexed-or-fail (get bitcoin-tx tx) (get output tx) u0)))
      (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 index-tx-many (list { tx: (merge tx { offset: u0 }), block: block, proof: proof, signature-packs: signature-packs }))))
    (print { type: "indexed-tx", tx-id: (try! (get-txid (get bitcoin-tx tx))), block: block, proof: proof, signature-packs: signature-packs })
    (ok true)))

(define-private (decimals-to-fixed (amount uint) (decimals uint))
  (/ (* amount ONE_8) (pow u10 decimals)))

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value)))

(define-private (check-trait (token-trait <ft-trait>) (token principal))
  (ok (asserts! (is-eq (contract-of token-trait) token) err-token-mismatch)))

(define-private (decode-from-reveal-tx-or-fail (tx (buff 32768)) (order-idx uint))
  (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 decode-from-reveal-tx-or-fail tx order-idx))

(define-private (extract-tx-ins-outs (tx (buff 32768)))
  (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 extract-tx-ins-outs tx))

(define-private (get-txid (tx (buff 32768)))
	(contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 get-txid tx))

(define-private (verify-mined (tx (buff 32768)) (block { header: (buff 80), height: uint }) (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint }))
	(contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 verify-mined tx block proof))


```
