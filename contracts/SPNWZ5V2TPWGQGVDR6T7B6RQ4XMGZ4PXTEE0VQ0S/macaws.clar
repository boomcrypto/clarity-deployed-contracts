;; macaws

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token macaws uint)

;; Constants
(define-constant err-no-more-nfts u300)
(define-constant err-invalid-user u500)
(define-constant mint-limit u99)
(define-constant commission-address tx-sender)
(define-data-var last-id uint u0)

(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmWWoGiJYRYmcs8sjvM7Ee9p9ueSMbM9LgKFJW2tjs8DWb/")

(define-private (mint (new-owner principal) (next-id uint))
    (match (nft-mint? macaws next-id new-owner)
            success
              (begin
                (var-set last-id next-id)
                (ok true))
            error (err error)))

(define-public (claim-for (user principal) (id uint))
  (if (and (is-eq tx-sender commission-address) (<= id mint-limit))
    (mint user id)
    (err err-invalid-user))
)

(define-public (set-ipfs-root (new-ipfs-root (string-ascii 80)))
  (if (is-eq tx-sender commission-address)
    (begin 
      (var-set ipfs-root new-ipfs-root)
      (ok true)
    )
    (err err-invalid-user)))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      (match (nft-transfer? macaws token-id sender recipient)
        success (ok success)
        error (err error))
      (err err-invalid-user)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? macaws token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
    (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))

(begin
(try! (claim-for 'SP29C7GQZ5NSP404KNZZYKAX8KBJCV6Z01YDKNVX0 u1))
(try! (claim-for 'SP5JMWT45ZF0RHJZSR4XPAEW8MS7J3DFQS5FAJ0X u2))
(try! (claim-for 'SPDBJFES0MCQRFDD3RAATRYYBXM6738TJQEZG3MQ u3))
(try! (claim-for 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD u4))
(try! (claim-for 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P u5))
(try! (claim-for 'SP26C9TWJYK6DTCD4T6HKBC76DPMK2DXXRNWS3E2D u6))
(try! (claim-for 'SP2FHRXHTZBFGPFKSNWFGYPNBQXKSXC2JFJZ7BY7D u7))
(try! (claim-for 'SP32KNBCPDS2M6CGYNHVFRR855GQVQ340AJ24PETF u8))
(try! (claim-for 'SP3PPBWF44PSCFN9BPVFZYZD6R8JJNQW0CPDPYB6D u9))
(try! (claim-for 'SPWJ630P1F6WQ7AWW50P7W4E4AM9FBJ1QBT9KQTX u10))
(try! (claim-for 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7 u11))
(try! (claim-for 'SP3T7WAB5DMJ3JSRMCQF6SC7CG50DYYJVS4C303CN u12))
(try! (claim-for 'SP3VMNHZRPSXM8ANWBMGZ8FN17SNVT1MXXNY0SCFR u13))
(try! (claim-for 'SP14R7S7497PS3VMH3WQ1S6NPNXR47G3RRC1G2K0G u14))
(try! (claim-for 'SP2EJMPGZKE983KP58VRZZVTYV6Q99HHZ0WYEKGZR u15))
(try! (claim-for 'SPW05PZKP6CXKF0YAKBAMHV5XY2VXFVSCVKJCDVE u16))
(try! (claim-for 'SP3766HJFN7ZRB6708Y2EZ367H4M3PWBJTNVCYV6G u17))
(try! (claim-for 'SP3QD9EVZB3E7E7Z3FWH7KBDH5RZWA4PYHSQ0FGTQ u18))
(try! (claim-for 'SP36NC0KX6RZGPQXR73AMW8R0CXXHS06DRM487A5G u19))
(try! (claim-for 'SPNW3S0YAPDY63D8HGBXEV03SS231HZX208KBG1Q u20))
(try! (claim-for 'SP1NBTER2WYFWC9ZMY2RJH784MN98B6XTHY1RB395 u21))
(try! (claim-for 'SP3VQM46NM7Z41VP3ZR80M1YRZC92QWK6SSV1EEHG u22))
(try! (claim-for 'SPPT6DNNC9KQW9MXNYTX4FH3CJXWQP90E5B6K64G u23))
(try! (claim-for 'SP2ZA7GC9H00VM4AEKB50AZFEP7T36X1VD8M9Y2DV u24))
(try! (claim-for 'SP33G7CYV2ACDVKEK3HV5Q2M1EPJ4T2111HBVMD1T u25))
(try! (claim-for 'SP3YQ6YDBG7YC2FM4RKA4A5GMZSKZWYSWYZSH9K0P u26))
(try! (claim-for 'SP16W7S76K0A7HAM176B73RQ8MD75E9VJ8VM256WH u27))
(try! (claim-for 'SP20Q2Q6HZ7R7FMY7WX9XQG8KJ79J79EEYG69JE6H u28))
(try! (claim-for 'SP36WZAANJF0DBV7D7487SMAX8TJ1EEGKMTX1ZRV6 u29))
(try! (claim-for 'SP2HVP68NY5BD2RDFX0JNXSYRS8AA6R7S30N08NJZ u30))
(try! (claim-for 'SP36WZAANJF0DBV7D7487SMAX8TJ1EEGKMTX1ZRV6 u31))
(try! (claim-for 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR u32))
(try! (claim-for 'SPTYWR4YW4G0R6ZM53QYTDP1NA3P2CNEJMCKVV81 u33))
(try! (claim-for 'SP3E545ADCKY56EVCXZPA87525VM0ZA8DQQAEP77Z u34))
(try! (claim-for 'SP6VV2AFXM7ZMT5V3ZAE8M6JXK9EA5N1GPFHJC4M u35))
(try! (claim-for 'SP16YA5N2VE52JRDYXKFZ2TF7T2CBRB4SH8NYKJX1 u36))
(try! (claim-for 'SPNZJ9DXN2HGNJDV1NWGPKHVW02ZS6DTJV8WEKF2 u37))
(try! (claim-for 'SP3XQZJQ87Q6G70PSM0PPVE9MCFP29EJ5CVP3568K u38))
(try! (claim-for 'SP2309D9HJ50P7YBDFC2JFM9C11Z8DNYC40D6ZJQW u39))
(try! (claim-for 'SPR52K2MQQR7B3RKFHE8WDG97G0PRPH21PXYR6VB u40))
(try! (claim-for 'SPJ81C2WPQHFB6XTG518JKPABWM639R2X0B331XE u41))
(try! (claim-for 'SP1F934ZWR42NBC8W7YKRXJR3KYZBTMY66A9SF8T3 u42))
(try! (claim-for 'SP1WYHPJJVN3P0PS32BMF33P6WVVK1SNRRS28ZF0G u43))
(try! (claim-for 'SP3XMYSS7VHPQV9YP2083D3VN8VDH8ZYZYD7XAR6E u44))
(try! (claim-for 'SP3SF0PSD7KYVJQPKKRBYJFF7NENGFHZSBVHM3B27 u45))
(try! (claim-for 'SP2R4DNJXP7M340BBK6G3GEBVFBC3D7HK8743F17K u46))
(try! (claim-for 'SP2KZ24AM4X9HGTG8314MS4VSY1CVAFH0G1KBZZ1D u47))
(try! (claim-for 'SP2C8P3MM137K1A48D1SRENG67KHEVPZV4K36G3JY u48))
(try! (claim-for 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH u49))
(try! (claim-for 'SPV4GYHQ2B7R831M3F7ZNN22RDDHEKQ52ZN50CDE u50))
)