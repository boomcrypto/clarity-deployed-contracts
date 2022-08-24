(use-trait crIpAPiuSDrgnkMMaRO 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.sip-010-v1a.sip-010-trait)
(use-trait BzRRJiMqNRBrrFSdK 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-trait-v4c.liquidity-token-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-constant ERR_INVALID_CALLER u111)
(define-constant ERR_NOT_AUTHORIZED u1111)
(define-constant ERR_START_AMT u4444)
(define-constant ERR_END_AMT u5555)
(define-constant ERR_END_ROUTER u5500)

(define-constant ADMIN_PRINCIPAL tx-sender)

(define-data-var SQOQESUEmkmWIoTBZ uint u0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-private (mzGLlZSVDKYSrFhwS
    (isSTX bool)
    (token <crIpAPiuSDrgnkMMaRO>) 
 )
    (if (is-eq isSTX true) 
        (stx-get-balance (as-contract tx-sender))
        (unwrap-panic (contract-call? token get-balance (as-contract tx-sender)))
    )
)

;; (unwrap-panic (contract-call? token_alex get-decimals))
;; (unwrap-panic (contract-call? token_basic get-decimals))
(define-private (gMUXJsOCSRPrUKpTQ
    (n uint)
    (b uint) 
    (a uint)
 )
    (/ (* n (pow u10 a)) (pow u10 b))
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-map fqGdJqOPSNqGvqdFGcNKD principal bool)
(map-set fqGdJqOPSNqGvqdFGcNKD tx-sender true)

(define-read-only (xQhcYBiZAyamiSayMQ (user principal))
  (match (map-get? fqGdJqOPSNqGvqdFGcNKD user)
    value (ok true)
    (err ERR_INVALID_CALLER)
  )
)
(define-public (JFxsqyClPTjxbWaSd (user principal))
  (begin
    (asserts! (is-eq contract-caller ADMIN_PRINCIPAL) (err ERR_INVALID_CALLER))
    (ok (map-set fqGdJqOPSNqGvqdFGcNKD
      user true
    ))
  )
)
(define-public (jTlYyeRyYpkskJWRpq (user principal))
  (begin
    (asserts! (is-eq contract-caller ADMIN_PRINCIPAL) (err ERR_INVALID_CALLER))
    (ok (map-delete fqGdJqOPSNqGvqdFGcNKD
      user
    ))
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (FH190fINb21bPH
    (biqdMkSckelmBXREy uint)
    (IpgieJSoGSjpNAbZ bool)
    (cIftLagouhgLvwsdd bool)
    (FqnhLpawqkJ6HnXbV bool)
    (XbmzaSiibYQhZdQHA <crIpAPiuSDrgnkMMaRO>) 
    (FAKr3ux2X5TCTFCndbV3CJtGs <crIpAPiuSDrgnkMMaRO>) 
    (SXqfZSHCKT94R1KYtItVfeeOL <crIpAPiuSDrgnkMMaRO>) 
    (C2GzzjHaclUvcd1kOiv <BzRRJiMqNRBrrFSdK>) 
    (oSdyXdMudrkdOTPMsP <BzRRJiMqNRBrrFSdK>) 
    (DoipKCsRvMycIAswHft <BzRRJiMqNRBrrFSdK>) 
    (pZhMAukLhkENKikQlTZ uint)
    (tcEFLBGhYHDCTIAWR bool)
 )   
    
    (let 
        (
            (KTNuqeP7qrfZ68cHpzwd6sc (mzGLlZSVDKYSrFhwS tcEFLBGhYHDCTIAWR XbmzaSiibYQhZdQHA))
            (R4hg2hFNihSDLV2pKjNThj7 tx-sender)
            (DfAOHGcKbHbeSZE1zP5AthGtcY (as-contract tx-sender))
        )
        (try! (xQhcYBiZAyamiSayMQ contract-caller))

        ;; transfer
        (if (is-eq tcEFLBGhYHDCTIAWR true)
            (begin
                (try! (stx-transfer? pZhMAukLhkENKikQlTZ R4hg2hFNihSDLV2pKjNThj7 DfAOHGcKbHbeSZE1zP5AthGtcY))
            )
            (begin 
                (try! (contract-call? XbmzaSiibYQhZdQHA transfer pZhMAukLhkENKikQlTZ R4hg2hFNihSDLV2pKjNThj7 DfAOHGcKbHbeSZE1zP5AthGtcY none))
            )
        )
        (var-set SQOQESUEmkmWIoTBZ (- (mzGLlZSVDKYSrFhwS tcEFLBGhYHDCTIAWR XbmzaSiibYQhZdQHA) KTNuqeP7qrfZ68cHpzwd6sc))
        (asserts! (>= (var-get SQOQESUEmkmWIoTBZ) pZhMAukLhkENKikQlTZ) (err ERR_START_AMT))

        (try! (Uc5JtIHpXhJXePvfC2vABPZOnk XbmzaSiibYQhZdQHA FAKr3ux2X5TCTFCndbV3CJtGs SXqfZSHCKT94R1KYtItVfeeOL XbmzaSiibYQhZdQHA C2GzzjHaclUvcd1kOiv oSdyXdMudrkdOTPMsP DoipKCsRvMycIAswHft IpgieJSoGSjpNAbZ cIftLagouhgLvwsdd FqnhLpawqkJ6HnXbV pZhMAukLhkENKikQlTZ u0 u0 u0))

        (let 
            (  
                (afterStartAmt (mzGLlZSVDKYSrFhwS tcEFLBGhYHDCTIAWR XbmzaSiibYQhZdQHA))
                (deltaAmt (- afterStartAmt KTNuqeP7qrfZ68cHpzwd6sc))
            ) 
            (asserts! (>= deltaAmt (+ pZhMAukLhkENKikQlTZ biqdMkSckelmBXREy)) (err ERR_END_AMT))

            ;; transfer
            (if (is-eq tcEFLBGhYHDCTIAWR true)
                (begin
                    (try! (as-contract (stx-transfer? deltaAmt  tx-sender R4hg2hFNihSDLV2pKjNThj7)))
                )
                (begin 
                    (try! (as-contract (contract-call? XbmzaSiibYQhZdQHA transfer deltaAmt tx-sender R4hg2hFNihSDLV2pKjNThj7 none)))
                )
            )
            
            (ok (list KTNuqeP7qrfZ68cHpzwd6sc pZhMAukLhkENKikQlTZ biqdMkSckelmBXREy afterStartAmt deltaAmt))
        )    
    )
)

(define-private (Uc5JtIHpXhJXePvfC2vABPZOnk
  (GL5jCnzPikgn6qZlb01VuXh6X <crIpAPiuSDrgnkMMaRO>) 
  (FAKr3ux2X5TCTFCndbV3CJtGs <crIpAPiuSDrgnkMMaRO>)
  (SXqfZSHCKT94R1KYtItVfeeOL <crIpAPiuSDrgnkMMaRO>)
  (tJ6b06sZCizwVmcS7yuiYJZDW <crIpAPiuSDrgnkMMaRO>)
  (cky5kWCZhVwNAXaBKaZwJnLbx <BzRRJiMqNRBrrFSdK>)
  (ACONd2DzT2PMLV91dkxTQ7JQL <BzRRJiMqNRBrrFSdK>)
  (C2vEa1Pvw9WjFmXCd5BXWhVS7 <BzRRJiMqNRBrrFSdK>)
  (Vo9HEuFbVGmYhiGxg2WzYN3XH bool)
  (YLrT87AqUAW5ZoXTrJ52ezx bool)
  (yzsuEVcIyKE17GpDIzwZgObZ2 bool)
  (A9gR7hNS2PyEARASXQYzjV2C5 uint)
  (NsTZ7WP14miUfeE91Hc7zQVbj uint)
  (gvsbd9W6p3YkvxlH5bJ37d8gZ uint)
  (JXjtd5IOM0wq86A7QDImaqdOl uint)
)
  (let
    (
        (DfAOHGcKbHbeSZE1zP5AthGtcY (as-contract tx-sender))
        (vDyOTeeQqFzjPbmf7AoNB3g2jC (unwrap-panic (contract-call? GL5jCnzPikgn6qZlb01VuXh6X get-balance DfAOHGcKbHbeSZE1zP5AthGtcY)))
        (z0AdqHNg7xnuMsdQRaV2v488ar (unwrap-panic (contract-call? FAKr3ux2X5TCTFCndbV3CJtGs get-balance DfAOHGcKbHbeSZE1zP5AthGtcY)))
        (KMoa4ZZTI541AAkw6NEgnLGF7Q (unwrap-panic (contract-call? SXqfZSHCKT94R1KYtItVfeeOL get-balance DfAOHGcKbHbeSZE1zP5AthGtcY)))
        (n42BMuhzDqrazzBGuW7DP1Om5J (unwrap-panic (contract-call? tJ6b06sZCizwVmcS7yuiYJZDW get-balance DfAOHGcKbHbeSZE1zP5AthGtcY)))
    )
    (asserts! (>= (unwrap-panic (contract-call? GL5jCnzPikgn6qZlb01VuXh6X get-balance DfAOHGcKbHbeSZE1zP5AthGtcY)) A9gR7hNS2PyEARASXQYzjV2C5) (err ERR_START_AMT))
    (if (and Vo9HEuFbVGmYhiGxg2WzYN3XH true)
        (begin
            (try! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y GL5jCnzPikgn6qZlb01VuXh6X FAKr3ux2X5TCTFCndbV3CJtGs cky5kWCZhVwNAXaBKaZwJnLbx A9gR7hNS2PyEARASXQYzjV2C5 NsTZ7WP14miUfeE91Hc7zQVbj)))
        )
        (begin
            (try! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x FAKr3ux2X5TCTFCndbV3CJtGs GL5jCnzPikgn6qZlb01VuXh6X cky5kWCZhVwNAXaBKaZwJnLbx A9gR7hNS2PyEARASXQYzjV2C5 NsTZ7WP14miUfeE91Hc7zQVbj)))
        )
    )
    (let
        (
            (fSPKy9CLz9IPZrJf1wkEfKkxgf (unwrap-panic (contract-call? FAKr3ux2X5TCTFCndbV3CJtGs get-balance DfAOHGcKbHbeSZE1zP5AthGtcY)))
            (ceeKlOTGpn2vsQDCA2Bjm7z5nU (- fSPKy9CLz9IPZrJf1wkEfKkxgf z0AdqHNg7xnuMsdQRaV2v488ar))
        )
        (if (and YLrT87AqUAW5ZoXTrJ52ezx true)
            (begin
                (try! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y FAKr3ux2X5TCTFCndbV3CJtGs SXqfZSHCKT94R1KYtItVfeeOL ACONd2DzT2PMLV91dkxTQ7JQL ceeKlOTGpn2vsQDCA2Bjm7z5nU gvsbd9W6p3YkvxlH5bJ37d8gZ)))
            )
            (begin
                (try! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x SXqfZSHCKT94R1KYtItVfeeOL FAKr3ux2X5TCTFCndbV3CJtGs ACONd2DzT2PMLV91dkxTQ7JQL ceeKlOTGpn2vsQDCA2Bjm7z5nU gvsbd9W6p3YkvxlH5bJ37d8gZ)))
            )
        )
        (let
            (
                (Z3OTdKLR2aumjE48HXkvPISxEt (unwrap-panic (contract-call? SXqfZSHCKT94R1KYtItVfeeOL get-balance DfAOHGcKbHbeSZE1zP5AthGtcY)))
                (aLsByW4xJNFnbGrbguAPnPmXNQ (- Z3OTdKLR2aumjE48HXkvPISxEt KMoa4ZZTI541AAkw6NEgnLGF7Q))
            )
            (if (and yzsuEVcIyKE17GpDIzwZgObZ2 true)
                (begin
                    (try! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y SXqfZSHCKT94R1KYtItVfeeOL tJ6b06sZCizwVmcS7yuiYJZDW C2vEa1Pvw9WjFmXCd5BXWhVS7 aLsByW4xJNFnbGrbguAPnPmXNQ JXjtd5IOM0wq86A7QDImaqdOl)))
                )
                (begin
                    (try! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x tJ6b06sZCizwVmcS7yuiYJZDW SXqfZSHCKT94R1KYtItVfeeOL C2vEa1Pvw9WjFmXCd5BXWhVS7 aLsByW4xJNFnbGrbguAPnPmXNQ JXjtd5IOM0wq86A7QDImaqdOl)))
                )
            )
            (let
                (
                    (NoMENKLB1ijkt6YVwpB28osx0H (unwrap-panic (contract-call? tJ6b06sZCizwVmcS7yuiYJZDW get-balance DfAOHGcKbHbeSZE1zP5AthGtcY)))
                    (rhTdJxL9MAX9GZwuBww1suSoJQ (- NoMENKLB1ijkt6YVwpB28osx0H u0))
                )
                (asserts! (> rhTdJxL9MAX9GZwuBww1suSoJQ u0) (err ERR_END_ROUTER))
                (ok true)
            )
        ) 
    )     
  )
)