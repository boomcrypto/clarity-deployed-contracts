;; BlockEdu Contract v1

;; ;; ;; ;; ;; Errors ;; ;; ;; ;; ;;

(define-constant FAILED-TO-MINT-ERROR (err u1))
(define-constant NOT-OWNER-ERROR (err u2))
(define-constant NOT-AUTH-UNI (err u3))
(define-constant NOT-STUDENT (err u4))
(define-constant CALLER-DOES-NOT-OWN-TOKEN (err u5))
(define-constant ACCESS-DENIED (err u6))

;; ;; ;; ;; ;; Constants ;; ;; ;; ;; ;;

(define-constant contract-owner tx-sender)

;; ;; ;; ;; ;; Data Maps and Vars ;; ;; ;; ;; ;;

;; Number of tokens a particular university owns
(define-map tokens-count { owner: principal } { count: int })

;; Data map to store information about the degree: university-name, student-name, degree
(define-map degree-data 
    {token-id: uint}
    {data-hash: (buff 32), token-uri: (string-ascii 64)}
)

;; Authorised Universities pricipals
(define-map auth-universities { uni-principal: principal } { data-hash: (buff 32), token-uri: (string-ascii 64) })

;; Authorised Students pricipals
(define-map auth-students { student-principal: principal } { data-hash: (buff 32), token-uri: (string-ascii 64) })

;; Authorised Employers pricipals
(define-map auth-employers { employer-principal: principal, student-principal: principal } {access-allowed: bool})

;; NFT Variable
(define-non-fungible-token blockedu-token uint)

;; The counter for the issued NFTs
(define-data-var curr-token-index uint u100)

;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;;
;; ;; ;; ;; ;; Public Functions  ;; ;; ;; ;; ;;
;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;;

;; Allow deployer to populate auth-universities map with verified universies
(define-public (add-auth-university (new-uni principal) (data-hash (buff 32)) (token-uri (string-ascii 64)) )
  (begin
    (asserts! (is-eq contract-owner tx-sender) NOT-OWNER-ERROR)
    (ok (map-set auth-universities { uni-principal: new-uni } { data-hash: data-hash, token-uri: token-uri }))
  )
)

;; Allow authenticated universities to populate auth-students map with it's students
(define-public (add-auth-student (new-student principal) (data-hash (buff 32)) (token-uri (string-ascii 64)) )
  (begin
    (asserts! (is-principal-university tx-sender) NOT-AUTH-UNI)
    (ok (map-set auth-students { student-principal: new-student } { data-hash: data-hash, token-uri: token-uri }))  
  )
)

;; Allow students to add authenticated employers who can see their degree data
(define-public (add-auth-employer (employer-principal principal))
  (begin
    ;; Only the student can add new map elements 
    (asserts! (is-principal-student tx-sender) NOT-STUDENT)
    (ok (map-set auth-employers {employer-principal: employer-principal, student-principal: tx-sender} {access-allowed: true}))
  )
)

;; Allow students to remove authenticated employers who can no longer see their degree data
(define-public (remove-auth-employer (employer-principal principal))
  (begin
    ;; Only the student can remove map elements 
    (asserts! (is-principal-student tx-sender) NOT-STUDENT)
    ;; Only the student can remove it's respective employers whom he has given to permission earlier
    (asserts! (is-eq (get access-allowed (map-get? auth-employers {employer-principal: employer-principal, student-principal: tx-sender})) (some true) ) ACCESS-DENIED)
    (ok (map-delete auth-employers {employer-principal: employer-principal, student-principal: tx-sender}))
  )
)

;; Mint new tokens
(define-public (mint!
  (owner principal)
  (data-hash (buff 32))
  (token-uri (string-ascii 64)))

    (let ((token-id (+ (var-get curr-token-index) u1)))
      ;; Access Rights Implementation 
      ;;  - only verified universities can mint tokens
      (asserts! (is-principal-university tx-sender) NOT-AUTH-UNI)
      ;;  - only students whose wallets exist can have tokens minted for them
      (asserts! (is-principal-student owner) NOT-STUDENT)

      ;; Check if the token is successfully minted
      (asserts! (register-token owner token-id) FAILED-TO-MINT-ERROR)
      (map-set degree-data
        {token-id: token-id}
        {data-hash: data-hash, token-uri: token-uri}
      )
      (var-set curr-token-index token-id)
      (ok token-id)
      
    )
)

;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;;
;; ;; ;; ;; ;; Read only Functions  ;; ;; ;; ;; ;;
;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;;

;; Gets the owner of the specified token ID.
(define-read-only (owner-of? (token-id uint))
  (nft-get-owner? blockedu-token token-id)
)

(define-read-only (get-auth-universities (uni-principal principal))
  (map-get? auth-universities (tuple (uni-principal uni-principal)))
)

(define-read-only (get-auth-students (student-principal principal))
  (map-get? auth-students (tuple (student-principal student-principal)))
)

(define-read-only (get-auth-employers (employer-principal principal) (student-principal principal))
  (map-get? auth-employers (tuple (employer-principal employer-principal) (student-principal student-principal)))
)

;; Get map information
(define-read-only (get-info (token-id uint))
  (begin
    (asserts!
      (or
        ;; Anyone one of the below conditions should be true: 
        ;; 1- The caller can either be a employer who have access to 
        ;;    this degree data can see the information of this NFT OR
        ;; 2- Only student (degree owners) can see the information of their tokens
        (is-eq (owner-of? token-id) (some tx-sender))
        (is-eq 
          (get access-allowed 
            (map-get? auth-employers 
              {employer-principal: tx-sender, student-principal: (default-to tx-sender (owner-of? token-id))})) 
          (some true)
        )
      ) 
      ACCESS-DENIED
    )
    ;; Return the NFT information
    (ok (map-get? degree-data (tuple (token-id token-id))))
  )
)

;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;;
;; ;; ;; ;; ;; Private Functions ;; ;; ;; ;; ;;
;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;; ;;

;; function to see whether a principal is in the auth-universities map
(define-private (is-principal-university (incoming-principal principal)) 
  (is-some (map-get? auth-universities (tuple (uni-principal incoming-principal))))
)

;; function to see whether a principal is in the auth-students map
(define-private (is-principal-student (incoming-principal principal)) 
  (is-some (map-get? auth-students (tuple (student-principal incoming-principal))))
)

;; Gets the amount of tokens owned by the specified address.
(define-private (balance-of (account principal))
  (default-to 0
    (get count
         (map-get? tokens-count (tuple (owner account))))))

;; Checks whether the owner owns the token or not
(define-private (is-owner (actor principal) (token-id uint))
  (is-eq actor
    (unwrap! (nft-get-owner? blockedu-token token-id) false)
  )
)

;; Register token
(define-private (register-token (new-owner principal) (token-id uint))
    (begin
      (unwrap! (nft-mint? blockedu-token token-id new-owner) false)
      (map-set tokens-count
          {owner: new-owner}
          {count: (+ 1 (balance-of new-owner))}
      )
    )
)