(define-constant actionAddress (as-contract tx-sender))

;; note the contract is always deployed by ardkon application: Why? because to make sure the donations are done through the application only 


 (define-map fund-indices {action_id: (string-utf8 256)} {index: uint}) ;; this will enable us to get length of each of the following fund allocations

(define-constant owner tx-sender)

(define-map fund-allocation { action_id: (string-utf8 256),  fund_id: (string-utf8 256)} { 
                                
                                fund_name: (string-utf8 256), 
                                fund_owner: (string-utf8 256), 
                                fund_reciever_principal: principal, 
                                fund_paid: bool,  
                                USD: uint, 
                                STX: uint})

(define-map fund_reciepts  { action_id: (string-utf8 256),  fund_id: (string-utf8 256)} { 
                                
                                fund_name: (string-utf8 256), 
                                reciept_id: (string-utf8 256), 
                                fund_reciever_principal: principal, 
                                reciept_approved: bool,  
                                USD: uint, 
                                STX: uint})

(define-map total_fund_usd  { action_id: (string-utf8 256)} { usd: uint})
(define-map total_fund_stx  { action_id: (string-utf8 256)} { stx: uint})

(define-constant account-contractor 'SP1R2J6JB94PMJ2DJNXV1FEHBM7CKR71W96NQKZB8) ;; change later so that it will be the same as the application


(define-map action-indices {action_id: (string-utf8 256)} {index: uint}) ;; this will enable us to get length of each of the following actions 

(define-map fund-registry { action_id: (string-utf8 256),  index: uint } { 
                                                                            donor-name: (string-utf8 256), 
                                                                            donation-type: (string-utf8 256),
                                                                            donor-country: (string-utf8 256), 
                                                                            donor-email: (string-utf8 256),  
                                                                            donation-currency: (string-utf8 256),
                                                                            amount: uint})


(define-data-var index uint u0)
(define-data-var is_valid uint u1)
(define-data-var validator uint u1)


(define-public (fund-stx-action (amount uint) (action_id (string-utf8 256)) (donation-type (string-utf8 256)) (donor-name (string-utf8 256)) (donor-country (string-utf8 256)) (donor-email (string-utf8 256))) 

    (let (
           (action-index (map-get? action-indices {action_id: action_id}))
          (a-index (get index action-index))
          (next-index (+ (default-to u0 a-index) u1))
          (action-amount (map-get? total_fund_stx { action_id: action_id}))
          (total-stx-fund (default-to u0 (get stx action-amount))))
        
        
        (begin 
            (map-set action-indices {action_id: action_id} {index: next-index})
            (map-insert fund-registry { action_id: action_id,  index: next-index } { 
                                    donor-name: donor-name,
                                    donation-type: donation-type,
                                    donor-country: donor-country, 
                                    donor-email: donor-email,  
                                    donation-currency: u"stx",
                                    amount: amount})
          (map-set total_fund_stx { action_id: action_id} {stx: (+  total-stx-fund  amount)})
            (unwrap!         (stx-transfer? amount tx-sender actionAddress) (err u32))
            
            
            
            
            )
            (ok "donation done")
            ))
           

(define-public (fund-action-usd  ( action_id (string-utf8 256)) (donor-name (string-utf8 256)) (donor-country (string-utf8 256)) (donor-email (string-utf8 256)) (donation-type (string-utf8 256)) (amount uint))

 (let (
     
     (action-index (map-get? action-indices {action_id: action_id}))
     (a-index (get index action-index))
     (next-index (+ (default-to u0 a-index) u1))
     (action-amount (map-get? total_fund_usd { action_id: action_id}))
     (total-usd-fund (default-to u0 (get usd action-amount)))
     ) 
     (begin 
       
        (asserts! (is-eq tx-sender account-contractor) (err u21)) ;; note when adding assertx error 
        (map-set action-indices {action_id: action_id} {index: next-index})
        (map-insert fund-registry { action_id: action_id,  index: next-index } { 
                                                                            donor-name: donor-name, 
                                                                            donor-country: donor-country, 
                                                                            donor-email: donor-email,  
                                                                            donation-currency: u"USD",
                                                                            donation-type: donation-type,
                                                                            amount: amount})
       (map-set total_fund_usd { action_id: action_id} {usd: (+  total-usd-fund  amount) })
        (unwrap! (contract-call? 'SP1R2J6JB94PMJ2DJNXV1FEHBM7CKR71W96NQKZB8.ard-usd-01 donate-to-action-guest amount actionAddress) (err u12))

       )
     (ok "donation added") )
        
)
 

(define-public (add-fund-allocation (fund_name (string-utf8 256)) (action_id (string-utf8 256)) (fund_owner (string-utf8 256)) (fund_id (string-utf8 256)) (fund_reciever_principal principal) (ardUSD uint) (ardSTX uint)) 
;; let the action-id owner add fund allocation to his action 
 
    
    (begin 
        
        (asserts! (is-eq tx-sender  account-contractor) (err u21))
        (map-set fund-allocation { action_id: action_id,  fund_id: fund_id} { 
                                fund_name: fund_name, 
                                fund_owner: fund_owner, 
                                fund_reciever_principal: fund_reciever_principal, 
                                fund_paid: false, 
                                STX: ardSTX,
                                USD: ardUSD})
       
     (ok "add fund allocation")
     )
)


(define-public (add-fund-reciepts (fund_name (string-utf8 256)) (action_id (string-utf8 256)) (reciept_id (string-utf8 256)) (fund_id (string-utf8 256))  (ardUSD uint) (ardSTX uint)) 
;; let the action-id owner add fund allocation to his action 
 
 (let (

   (fund_info (unwrap! (map-get? fund-allocation { action_id: action_id,  fund_id: fund_id}) (err 21) ))
    (reciever (get fund_reciever_principal fund_info))
     
        
 ) 
    
    
      (begin 
      
      

      
        (asserts! (is-eq reciever tx-sender ) (err 211))
        
        (map-set fund_reciepts { action_id: action_id,  fund_id: fund_id} { 
                               fund_name: fund_name, 
                                reciept_id: reciept_id, 
                                fund_reciever_principal: tx-sender, 
                                reciept_approved: false,  
                                USD: ardUSD, 
                                STX: ardSTX})
        (ok "add reciepts ")
      ) 
      
     )
     
)





(define-public (collect-funds (fund_id (string-utf8 256)) (action_id (string-utf8 256))) 

  (let (
    
    
     (fund_info (unwrap! (map-get? fund-allocation { action_id: action_id,  fund_id: fund_id}) (err 21) ))
      (reciever (get fund_reciever_principal fund_info))
      (fund_owner (get fund_owner fund_info))
      (fund_name (get fund_name fund_info))
      (USD (get USD fund_info))
      (STX (get STX fund_info))
      (usd_tuple (default-to {usd: u0}  (map-get? total_fund_usd { action_id: action_id}) ))
      (total_usd (get usd usd_tuple))
      (stx_tuple (default-to {stx: u0} (map-get? total_fund_stx { action_id: action_id}) ))
      (total_stx (get stx stx_tuple))
      (recipient tx-sender)
      (sender (as-contract tx-sender))
      (USD_TRANSFER (/ (* USD u95) u100))
      (USD_TRANSACTION (/ (* USD u5) u100) )
      (STX_TRANSFER (/ (* STX u95) u100) )
      (STX_TRANSACTION (/ (* STX u5) u100) )
    ) 
       (begin 
       (print reciever)
        
      
        
        (asserts! (>= total_stx  STX ) (err 222))
        (asserts! (>= total_usd  USD ) (err 333))
         
        (if (> total_stx u0)
                
                (begin
                (unwrap! (stx-transfer? STX_TRANSFER actionAddress reciever) (err 211))
                (unwrap! (stx-transfer? STX_TRANSACTION actionAddress account-contractor) (err 211))
                (map-set fund-allocation {action_id: action_id,  fund_id: fund_id} {
                                                                                    fund_name: fund_name, 
                                                                                    fund_owner: fund_owner, 
                                                                                    fund_reciever_principal: reciever, 
                                                                                    fund_paid: true, 
                                                                                    STX: STX,
                                                                                    USD: USD})
                
                (print "done")


                )
                
                (print "false")


            )
             (if (> total_usd u0)
             
             
            (begin
            
            (unwrap! (contract-call? 'SP1R2J6JB94PMJ2DJNXV1FEHBM7CKR71W96NQKZB8.ard-usd-01 transfer USD_TRANSFER actionAddress reciever) (err 21))
            (unwrap! (contract-call? 'SP1R2J6JB94PMJ2DJNXV1FEHBM7CKR71W96NQKZB8.ard-usd-01 transfer USD_TRANSACTION actionAddress account-contractor) (err 21))
            (map-set fund-allocation {action_id: action_id,  fund_id: fund_id} {
                                                                                    fund_name: fund_name, 
                                                                                    fund_owner: fund_owner, 
                                                                                    fund_reciever_principal: reciever, 
                                                                                    fund_paid: true, 
                                                                                    STX: STX,
                                                                                    USD: USD})
            (print "done")
            
            )
            
            (print "false")


        )
         
      
  
    

          (ok "Collection Done")
       )
         
       

    )

)


(define-map term-indices {action_id: (string-utf8 256)} {index: uint})


(define-map terms-indices-id {action_id: (string-utf8 256), index: uint } { term_id: (string-utf8 256)}) ;; this will enable us to get length of each of the following actions 


(define-map terms_and_conditions {action_id: (string-utf8 256), term_id: (string-utf8 256)} {term: (string-utf8 256),  votes: uint})


(define-public (add-terms (term (string-utf8 256)) (term_id (string-utf8 256)) (action_id (string-utf8 256)))

(let (
  
  (action-term-index (map-get? term-indices {action_id: action_id}))
  (a-index (get index action-term-index))
  (next-index (+ (default-to u0 a-index) u1))
  ) 
  (begin 
  
  
(asserts! (is-eq tx-sender  account-contractor) (err u21))
        (map-set terms_and_conditions { action_id: action_id,  term_id: term_id} { 
                                term: term, 
                              
                                votes: u0, 
                                })
        (map-set terms-indices-id { action_id: action_id,  index: next-index} { 
                                term_id: term_id 
                              
                              
                                })
        (map-set term-indices { action_id: action_id  } { 
                                index: next-index
                              
                              
                                })
       
     (ok next-index)
  )
  )
   
     
    

   

)

(define-map term-votes {user_id: (string-utf8 256) , term_id: (string-utf8 256)} {vote: bool})

     
(define-public (vote-on-term (item {term_id: (string-utf8 256),  vote: bool, action_id: (string-utf8 256), user_id: (string-utf8 256)})) 


  (let (
    (term_id (get term_id item))
    (vote (get vote item))
    (action_id (get action_id item))
    (user_id (get user_id item))
    (term_map (default-to { term: u"none", votes: u0} (map-get? terms_and_conditions {action_id: action_id, term_id: term_id})) )
    (term (get term term_map))
    (votes (get votes term_map))
    
    
    )
    
      (begin 
    
    
      
      (asserts! vote (err 21))
      (map-set terms_and_conditions {action_id: action_id, term_id: term_id} {

              term: term, 
              votes: (+ votes u1)
      
      }) 
      
    

       (map-set term-votes {user_id: user_id, term_id: term_id} {

              vote: vote
                 
      }) 
    (ok true)
    )
      
    )
    

)





(define-read-only (get-donor (item {action_id: (string-utf8 256), index: uint})) 
  (map-get? fund-registry item))

(define-read-only (get-fund-list (ids (list 180 {action_id: (string-utf8 256), index: uint})))
  (map get-donor ids))

(define-read-only (get-fund-list-index (action_id (string-utf8 256))) 

    (map-get? action-indices {action_id: action_id})

)

(define-read-only (get-fund-status (action_id (string-utf8 256)) (fund_id (string-utf8 256)) )

    (map-get? fund-allocation {action_id: action_id, fund_id: fund_id})

)

