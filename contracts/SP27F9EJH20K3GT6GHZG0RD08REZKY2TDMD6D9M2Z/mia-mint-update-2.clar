(define-constant contract-owner tx-sender)
(define-constant NOT-OWNER (err u101))

(define-public (test-transfer-to-contract (v1-id uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) NOT-OWNER)
    (ok (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 v1-id)))
  )
)

(define-public (admin-update-mint-1049-1074)
  (begin
    (asserts! (is-eq tx-sender contract-owner) NOT-OWNER)
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1049))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1050))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1051))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1052))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1053))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1054))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1055))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1056))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1057))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1058))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1059))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1060))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1061))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1062))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1063))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1064))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1065))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1066))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1067))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1068))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1069))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1070))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1071))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1072))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1073))
    (ok (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1074)))
  )
)

(define-public (admin-update-mint-1075-1100)
  (begin
    (asserts! (is-eq tx-sender contract-owner) NOT-OWNER)
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1075))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1076))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1077))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1078))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1079))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1080))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1081))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1082))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1083))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1084))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1085))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1086))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1087))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1088))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1089))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1090))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1091))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1092))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1093))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1094))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1095))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1096))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1097))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1098))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1099))
    (ok (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1100)))
  )
)

(define-public (admin-update-mint-1101-1125)
  (begin
    (asserts! (is-eq tx-sender contract-owner) NOT-OWNER)
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1101))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1102))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1103))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1104))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1105))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1106))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1107))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1108))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1109))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1110))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1111))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1112))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1113))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1114))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1115))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1116))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1117))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1118))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1119))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1120))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1121))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1122))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1123))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1124))
    (ok (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1125)))
  )
)

(define-public (admin-update-mint-1126-1150)
  (begin
    (asserts! (is-eq tx-sender contract-owner) NOT-OWNER)
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1126))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1127))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1128))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1129))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1130))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1131))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1132))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1133))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1134))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1135))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1136))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1137))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1138))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1139))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1140))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1141))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1142))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1143))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1144))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1145))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1146))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1147))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1148))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1149))
    (ok (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.updated-mia-mint-v3 u1150)))
  )
)
