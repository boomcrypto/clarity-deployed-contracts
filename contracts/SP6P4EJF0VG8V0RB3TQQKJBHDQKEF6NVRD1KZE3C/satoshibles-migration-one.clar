;; Bridge Migration
;; (transfer-nft-token (address principal) (id uint) (token <nft-trait>)
(contract-call? .stacksbridge-satoshibles transfer-nft-token .stacksbridge-satoshibles-v2 u1330 .satoshibles)