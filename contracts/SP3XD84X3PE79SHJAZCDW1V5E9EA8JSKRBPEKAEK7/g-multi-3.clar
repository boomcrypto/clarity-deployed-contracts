(define-read-only (get-user-position-inner (user principal))
  {key: user, res: (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-user-position user)}
)

(define-read-only (get-user-position (users (list 100 principal))) 
    (map get-user-position-inner users)
)

(define-read-only (get-user-collateral-inner (arg {user: principal, collateral: principal}))
  {key: {user: (get user arg), collateral: (get collateral arg)}, res: (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-user-collateral (get user arg) (get collateral arg))}
)

(define-read-only (get-user-collateral (args (list 100 {user: principal, collateral: principal})))
    (map get-user-collateral-inner args)
)

(define-read-only (get-balance-inner (account principal))
  {key: account, res: (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-balance account)}
)

(define-read-only (get-balance (accounts (list 100 principal))) 
    (map get-balance-inner accounts)
)
