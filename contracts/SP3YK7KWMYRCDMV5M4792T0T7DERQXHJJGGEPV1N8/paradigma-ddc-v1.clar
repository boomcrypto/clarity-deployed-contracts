;; paradigma-ddc-v1
;; Paradigma Distributed Data Control (DDC)
;; Controller of data accessability

;;constants
(define-constant ERR_INSUFFICIENT_FUNDS u101)
(define-constant ERR_PERMISSION_DENIED u109)

;; set constant for local contract access owner
(define-constant LOCAL-CONTRACT-OWNER tx-sender)

;; check if contract caller is local contract owner
(define-private (is-authorized-local-owner)
  (is-eq contract-caller LOCAL-CONTRACT-OWNER)
)

;; Manage authorized callers to execute restricted functions in contracts
(define-data-var authorizedRemoteCallersToExecuteCount uint u0)

(define-read-only (get-authorized-remote-callers-to-execute-count)
  (var-get authorizedRemoteCallersToExecuteCount)
)

(define-map AuthorizedRemoteCallersToExecuteIndex
   {
     authorizedRemoteCallersToExecuteId: uint
   }
   {
     remoteCallerPrincipal: principal,
     executePrincipal: principal
   }  
)

(define-read-only (get-authorized-remote-callers-to-execute-index (id uint))
     (map-get? AuthorizedRemoteCallersToExecuteIndex
        {
            authorizedRemoteCallersToExecuteId: id
        }
     ) 
)

(define-map AuthorizedRemoteCallersToExecute
   {
     remoteCallerPrincipal: principal,
     executePrincipal: principal
   }
   {
     auth: bool
   }
)

(define-read-only (get-ref-remote-authorized-callers-to-execute
                     (remoteCallerPrincipal principal)
                     (executePrincipal principal)
                  )
      (map-get? AuthorizedRemoteCallersToExecute
                 {
                    remoteCallerPrincipal: remoteCallerPrincipal,
                    executePrincipal: executePrincipal
                 }
      )              
)

(define-read-only (is-remote-caller-authorized-to-execute
                     (remoteCallerPrincipal principal))
            (let 
              (
              (executePrincipal contract-caller)
              (request-to-execute 
                  (get-ref-remote-authorized-callers-to-execute
                      remoteCallerPrincipal
                      executePrincipal
                  )
              )
              )
               (if 
                  (is-some
                      request-to-execute
                  )
                  (unwrap-panic (get auth request-to-execute))
                  false              
               )
            )
)

;; Set reference info for authorized callers to execute
;; protected function to update authorized callers to execute functions in a contract
(define-public (create-authorized-remote-callers-to-execute 
                      (remoteCallerPrincipal principal)
                      (executePrincipal principal)
                      (auth bool)
                )
  (begin
    (if (is-authorized-local-owner) 
      (if
        (is-none 
              (map-get? AuthorizedRemoteCallersToExecute
                     {
                       remoteCallerPrincipal: remoteCallerPrincipal,
                       executePrincipal: executePrincipal
                     }
              )
        )       
        (begin
          (var-set authorizedRemoteCallersToExecuteCount (+ (var-get authorizedRemoteCallersToExecuteCount) u1))
          (map-insert AuthorizedRemoteCallersToExecuteIndex
          { 
            authorizedRemoteCallersToExecuteId: (var-get authorizedRemoteCallersToExecuteCount)
          }
           {
              remoteCallerPrincipal: remoteCallerPrincipal,
              executePrincipal: executePrincipal
           } 
          )
          (map-insert AuthorizedRemoteCallersToExecute 
           {
              remoteCallerPrincipal: remoteCallerPrincipal,
              executePrincipal: executePrincipal
           } 
           {
             auth: auth
           }
          ) 
         (ok true)
        )
        (begin
         (ok 
          (map-set AuthorizedRemoteCallersToExecute
           {
              remoteCallerPrincipal: remoteCallerPrincipal,
              executePrincipal: executePrincipal
           } 
           {
            auth: auth
           }
          )
         )
        )
      )
      (err ERR_PERMISSION_DENIED)
  )
 )
)

;; Set reference info for authorized callers to execute
;; protected function to update authorized callers to execute functions in a contract
(define-public (delete-authorized-remote-callers-to-execute 
                    (id uint)
               )
  (begin
    (if (is-authorized-local-owner) 
      (let 
        (
         (authorizedRemoteCallersIndex 
              (unwrap-panic (map-get? AuthorizedRemoteCallersToExecuteIndex
                     {
                      authorizedRemoteCallersToExecuteId: id
                     }
              )
           )
         )
         (remoteCallerPrincipal 
               (get remoteCallerPrincipal authorizedRemoteCallersIndex)
         )
         (executePrincipal 
               (get executePrincipal authorizedRemoteCallersIndex)
         )
         )   
          (map-delete AuthorizedRemoteCallersToExecuteIndex
            { 
             authorizedRemoteCallersToExecuteId: id
            }
           )
         (map-delete AuthorizedRemoteCallersToExecute 
           {
              remoteCallerPrincipal: remoteCallerPrincipal,
              executePrincipal: executePrincipal
           } 
         ) 
         (ok true)
      )
      (err ERR_PERMISSION_DENIED)
   )
  )
)