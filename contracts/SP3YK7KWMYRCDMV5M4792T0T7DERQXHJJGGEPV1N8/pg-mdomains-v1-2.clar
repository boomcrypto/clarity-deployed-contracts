;; pg-mdomains-v1-2
;;
;; Decentralized domain names manager for Paradigma SpA 2021-2022-2023 (c) Chile did:web:support.xck.app
;; To facilitate acquisition of Stacks decentralized domain names DID
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait )
(use-trait token-trait 'SP3YK7KWMYRCDMV5M4792T0T7DERQXHJJGGEPV1N8.paradigma-token-trait-v1.paradigma-token-trait)
;;(use-trait token-trait 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.paradigma-token-trait-v1.paradigma-token-trait)
;;(use-trait sip-010-trait 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.sip-010-trait.sip-010-trait)

;; constants
(define-constant ERR_INSUFFICIENT_FUNDS 101)
(define-constant ERR_UNAUTHORIZED 109)
(define-constant ERR_NAME_PREORDER_FUNDS_INSUFFICIENT 203)
(define-constant ERR_BNS_PREORDER_ISSUE 205)
(define-constant ERR_DOMAINNAME_MANAGER_NOT_FOUND 501)

;; set constant for contract owner, used for updating token-uri
(define-constant CONTRACT_OWNER tx-sender)

;; initial value for domain wallet, set to this contract until initialized
(define-data-var domainWallet principal 'SP3YK7KWMYRCDMV5M4792T0T7DERQXHJJGGEPV1N8)
;;(define-data-var domainWallet principal 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)  
;;(define-data-var platformDomainWallet principal 'ST3NBRSFKX28FQ2ZJ1MAKX58HKHSDGNV5N7R21XCP)  ;; Wallet where to transfer share fee services
(define-data-var platformDomainWallet principal 'SPRK2JVQ988PYT19JSAJNR3K9YZAZGVY04XMC2Z7)  ;; Wallet where to transfer share fee services

;; Manage domain name service fees
;;  by accepted tokens
(define-map DomainServiceFeeIndex
   {
     serviceId: uint
   }
   {
     tokenSymbol: (string-ascii 32),
   }  
)

(define-read-only (get-domain-service-fee-index (id uint))
     (map-get? DomainServiceFeeIndex
        {
            serviceId: id
        }
     ) 
)

(define-map DomainServiceFee
   {
     tokenSymbol: (string-ascii 32),
   }
   {
     fee: uint
   }
)
(define-read-only (get-domain-service-fee (tokenSymbol (string-ascii 32)))
  (unwrap-panic (get fee 
                  (map-get? DomainServiceFee
                     {tokenSymbol: tokenSymbol}
                  )
                )
  )
)
(define-data-var domainServiceFeeCount uint u0)
(define-read-only (get-domain-service-fee-count)
  (var-get domainServiceFeeCount)
)

;; Set reference info for domain service fee
;; protected function to update domain service fee variable
(define-public (create-domain-service-fee 
                            (tokenSymbol (string-ascii 32))
                            (fee uint) 
                )
  (begin
    (if (is-authorized-domain) 
      (if
        (is-none 
          (map-get? DomainServiceFee
             {
                tokenSymbol: tokenSymbol
             }
          )       
        )
        (begin
          (var-set domainServiceFeeCount (+ (var-get domainServiceFeeCount) u1))
          (map-insert DomainServiceFeeIndex
          { 
            serviceId: (var-get domainServiceFeeCount)
          }
           {
            tokenSymbol: tokenSymbol
           } 
          )
          (map-insert DomainServiceFee 
           {
             tokenSymbol: tokenSymbol
           } 
           {
             fee: fee
           }
          ) 
         (ok true)
        )
        (begin
         (map-delete DomainServiceFee
           {
            tokenSymbol: tokenSymbol
           } 
         )
         (ok 
          (map-set DomainServiceFee 
           {
            tokenSymbol: tokenSymbol
           } 
           {
             fee: fee
           }
          )
         )
        )
      )
      (err ERR_UNAUTHORIZED)
    )
  )
)

;; check if contract caller is contract owner
(define-private (is-authorized-owner)
  (is-eq contract-caller CONTRACT_OWNER)
)

;; Token flow management

;; Stores participants DomainName service sell

(define-data-var domainNameManagerCount uint u0)

(define-read-only (get-domain-name-manager-count)
  (var-get domainNameManagerCount)
)
(define-map DomainNameManagersIndex
  { domainNMId: uint }
  {
   nameSpace: (buff 48),                  ;; domain namespace defined in Blockchain Name Service (BNS) like .app
   domainName: (buff 48)                  ;; domain name under a namespace like xck in xck.app
  }
)

(define-read-only (get-domain-name-managers-index (id uint))
     (map-get? DomainNameManagersIndex
        {
            domainNMId: id
        }
     ) 
)

(define-map DomainNameManagers
  {
   nameSpace: (buff 48),                  ;; domain namespace defined in Blockchain Name Service (BNS) like .app
   domainName: (buff 48)                  ;; domain name under a namespace like xck in xck.app
  }
  {
    domainNameWallet: principal,           ;; DomainName manager account - branding and domainName token
    domainNameFeePerc: uint,               ;; DomainName share percentage of fee (ie u10)
    domainNameFeeTokenMint: uint,          ;; Tokens considered reciprocity to domainName token
    domainNameTokenSymbol: (string-utf8 5), ;; Token Symbol used to mint domainName token
    sponsoredWallet: principal,            ;; Sponsored institution account
    sponsoredFeePerc: uint,                ;; Sponsored share percentage of fee (ie u10)
    sponsoredDID: (string-utf8 256),       ;; Sponsored Stacks ID
    sponsoredUri: (string-utf8 256),       ;; Sponsored website Uri
    referencerFeeTokenMint: uint           ;; Tokens for promoters references as reciprocity 
  }
)

;; returns set domain wallet principal
(define-read-only (get-domain-wallet)
  (var-get domainWallet)
)

;; checks if caller is Auth contract
(define-private (is-authorized-auth)   
  (is-eq contract-caller 'SP3YK7KWMYRCDMV5M4792T0T7DERQXHJJGGEPV1N8)
;;  (is-eq contract-caller 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
) 

;; protected function to update domain wallet variable
(define-public (set-domain-wallet (newDomainWallet principal))
  (begin
    (asserts! (is-authorized-auth) (err ERR_UNAUTHORIZED))  
    (ok (var-set domainWallet newDomainWallet))
  )
)

;; check if contract caller is domain wallet
(define-private (is-authorized-domain)
    (is-eq contract-caller (var-get domainWallet))
)

;; Set reference info for domainName managers
(define-public (create-domainname-manager 
                            (nameSpace (buff 48))
                            (domainName (buff 48)) 
                            (domainNameWallet principal) 
                            (domainNameFeePerc uint) 
                            (domainNameFeeTokenMint uint) 
                            (tokenSymbol (string-utf8 5))
                            (sponsoredWallet principal) 
                            (sponsoredFeePerc uint)
                            (sponsoredDID (string-utf8 256))
                            (sponsoredUri (string-utf8 256))
                            (referencerFeeTokenMint uint)
                )
  (begin
    (if (is-authorized-domain) 
      (if
        (is-none 
           (map-get? DomainNameManagers 
             {
                nameSpace: nameSpace,
                domainName: domainName
             }
           )       
        )
        (begin
          (var-set domainNameManagerCount (+ (var-get domainNameManagerCount) u1))
          (map-insert DomainNameManagersIndex
          { 
            domainNMId: (var-get domainNameManagerCount)
          }
           {
            nameSpace: nameSpace,
            domainName: domainName
           } 
          )
          (map-insert DomainNameManagers 
           {
            nameSpace: nameSpace,
            domainName: domainName
           } 
           {
            domainNameWallet:  domainNameWallet,
            domainNameFeePerc: domainNameFeePerc,
            domainNameFeeTokenMint: domainNameFeeTokenMint,
            domainNameTokenSymbol: tokenSymbol,
            sponsoredWallet: sponsoredWallet,
            sponsoredFeePerc: sponsoredFeePerc,
            sponsoredDID: sponsoredDID,
            sponsoredUri: sponsoredUri,
            referencerFeeTokenMint: referencerFeeTokenMint
           }
          ) 
         (ok true)
        )
        (begin
         (map-delete DomainNameManagers 
           {
            nameSpace: nameSpace,
            domainName: domainName
           } 
         )
         (ok 
          (map-set DomainNameManagers 
           {
            nameSpace: nameSpace,
            domainName: domainName
           } 
           {
            domainNameWallet:  domainNameWallet,
            domainNameFeePerc: domainNameFeePerc,
            domainNameFeeTokenMint: domainNameFeeTokenMint,
            domainNameTokenSymbol: tokenSymbol,
            sponsoredWallet: sponsoredWallet,
            sponsoredFeePerc: sponsoredFeePerc,
            sponsoredDID: sponsoredDID,
            sponsoredUri: sponsoredUri,
            referencerFeeTokenMint: referencerFeeTokenMint
           }
          )
         )
        )
      )
      (err ERR_UNAUTHORIZED)
    )
  )
)

;; Gets the principal for domainName managers
(define-read-only (get-ref-domainname-manager (nameSpace (buff 48)) (domainName (buff 48)))
   (ok (unwrap! (map-get? DomainNameManagers 
                        {
                         nameSpace: nameSpace,
                         domainName: domainName
                        }
               )
               (err ERR_DOMAINNAME_MANAGER_NOT_FOUND)
      )
   )
)


;; Makes the name-preorder
(define-public (bns-name-preorder (hashedSaltedFqn (buff 20)) (stxToBurn uint) (paymentSIP010Trait <sip-010-trait>) (reciprocityTokenTrait <token-trait>) (referencerWallet principal))
  (begin
    (asserts! (> (stx-get-balance tx-sender) stxToBurn) (err ERR_NAME_PREORDER_FUNDS_INSUFFICIENT))
    (let 
        (
          (symbol (unwrap-panic (contract-call? paymentSIP010Trait get-symbol)))
          (fee (get-domain-service-fee symbol))
          (toBurn (- stxToBurn fee))
          (expires (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-preorder hashedSaltedFqn toBurn)))
          (done (unwrap-panic (order-to-register-domain tx-sender fee 0x616c6c 0x616c6c 0x737461636b73 paymentSIP010Trait reciprocityTokenTrait referencerWallet)))  ;; Includes subdomain:all namespace:all name:stacks as domainnames
        )
        (ok expires) 
    )     
  )
)

;; Gives the order to register a domain and subdomain associated to a domainName and transfers to the domain managers
(define-public (order-to-register-domain (sender principal) (fee uint) (nameSpace (buff 48)) (domainName (buff 48)) (subDomain (buff 48)) 
                                         (paymentSIP010Trait <sip-010-trait>) (reciprocityTokenTrait <token-trait>) (referencerWallet principal))
   (begin
    (asserts! (is-eq tx-sender sender) (err ERR_UNAUTHORIZED))
    (asserts! (> (unwrap-panic (contract-call? paymentSIP010Trait get-balance tx-sender)) fee) (err ERR_INSUFFICIENT_FUNDS))
    (let 
    (
       (domainNameRef  
             (unwrap-panic (map-get? DomainNameManagers 
                        {
                         nameSpace: nameSpace,
                         domainName: domainName
                        }
               )
             )
       )
       (sponsoredFeePerc 
             (get sponsoredFeePerc domainNameRef)
       )
       (sponsoredWallet 
            (get sponsoredWallet domainNameRef)
       )
       (domainNameFeePerc 
          (get domainNameFeePerc domainNameRef)
       )    
      (domainNameWallet 
             (get domainNameWallet domainNameRef)
       )
      (domainNameFeeTokenMint 
              (get domainNameFeeTokenMint domainNameRef)
       )
      (referencerFeeTokenMint
               (get referencerFeeTokenMint domainNameRef))
       (transferToSponsored (/ (* sponsoredFeePerc  fee) u100) )
       (transferToDomainManager (/ (* domainNameFeePerc  fee) u100))
       (transferToPlatform (/ (* (- u100 (+ domainNameFeePerc sponsoredFeePerc ) ) fee) u100))
       (platformDWallet (get-platform-domain-wallet))
     )  
       ;; transfer to sponsored  
              ;; transfer to sponsored  
     (if (> transferToSponsored u0)
        (unwrap-panic (contract-call? paymentSIP010Trait transfer 
                             transferToSponsored 
                             sender 
                             sponsoredWallet
                             none
                      )
        )
        true
     )
         ;; transfer to domain name manager
      (if (> transferToDomainManager u0)
        (unwrap-panic (contract-call? paymentSIP010Trait transfer
                             transferToDomainManager
                             sender
                             domainNameWallet
                             none
                     )
        )
        true
      )
        ;; transfer to platform manager
      (if (> transferToPlatform u0)
         (unwrap-panic (contract-call? paymentSIP010Trait transfer
                              transferToPlatform
                              sender 
                              platformDWallet
                              none
                )
         )
          true
      )
         ;; mint token to sender as reciprocity
      (if (> domainNameFeeTokenMint u0)
        (unwrap-panic (as-contract (contract-call? reciprocityTokenTrait 
                            mint 
                            domainNameFeeTokenMint
                            sender
                                   )
                      )
        )
        true
      )
         ;; mint token for referencer (if there is) as reciprocity
      (if (> referencerFeeTokenMint u0)
        (unwrap-panic (as-contract (contract-call? reciprocityTokenTrait 
                            mint 
                            referencerFeeTokenMint
                            referencerWallet
                                   )
                      )
        )
        true
      )
    )
   (ok true)
  )
)

;; returns set domain wallet principal
(define-read-only (get-platform-domain-wallet)
  (var-get platformDomainWallet)
)
;; protected function to update domain wallet variable
(define-public (set-platform-domain-wallet (newPDomainWallet principal))
  (begin
    (asserts! (is-authorized-auth) (err ERR_UNAUTHORIZED))  
    (ok (var-set platformDomainWallet newPDomainWallet))
  )
)