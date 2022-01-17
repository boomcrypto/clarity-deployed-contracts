(define-data-var blockChain_message (string-utf8 150) u"test String")
  (define-data-var blockChain_clinic_comment (string-utf8 150) u"test String")
 (define-data-var blockChain_Date (string-utf8 25) u"test String")
 (define-data-var blockChain_Time (string-utf8 25) u"test String")
 (define-data-var blockChain_clinic (string-utf8 60) u"test String")
 (define-constant ERR_INVALID_STRING u0)

(define-public (set-message (messageDate (string-utf8 25))  (messageTime (string-utf8 25))  (clinicName (string-utf8 60)) (message (string-utf8 150)) (clinicComment (string-utf8 150)))
        (if (var-set blockChain_message message) 
        (begin 
          (var-set blockChain_Date messageDate)
           (var-set blockChain_Time messageTime)
           (var-set blockChain_clinic clinicName)
           (var-set blockChain_clinic_comment clinicComment) 
     
          (ok message)
        )
        (err ERR_INVALID_STRING)
    )
    
    
 )


