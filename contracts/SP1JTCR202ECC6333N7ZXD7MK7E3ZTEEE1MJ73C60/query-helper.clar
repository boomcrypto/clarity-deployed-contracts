;; Query helper contract for fetching an account's names
;; 
;; This contract should only be used in an off-chain context, due to the larger
;; execution cost associated with fetching data.

(define-constant ARRAY (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18))

(define-constant MAX_NAMES_QUERY (+ (len ARRAY) u1))

;; Fetch an account's legacy name and their BNSx names. Up to 20 BNSx names
;; are fetched.
;; 
;; Returns a tuple with `names` (BNSx) and `legacy`.
;; 
;; `legacy` returns a single tuple - an optional with properties
;; return from `.bns#name-resolve`.
;; 
;; `names` - a list of tuples, containing data from `.bns-x#get-name-properties`.
;; 
;; The account's primary BNSx name will be returned first
(define-read-only (get-names (account principal))
  (merge { legacy: (get-legacy-name account) } (crawl-names account))
)

;; Legacy names

;; Fetch the BNS legacy name and name properties owned by a given account.
;; 
;; @returns `none` if the account doesn't own a legacy name.
(define-read-only (get-legacy-name (account principal))
  (match (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal account)
    name (some (merge name (unwrap-panic (resolve-legacy-name name))))
    e none
  )
)

;; Given a `name,namespace` tuple, return the properties of that name
(define-read-only (resolve-legacy-name (name { name: (buff 48), namespace: (buff 20) }))
  (match (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve (get namespace name) (get name name))
    props (some props)
    ;; props (some (merge name props))
    e none
  )
)

;; BNSx Names

;; Fetch name details from the name registry as well as
;; information from legacy BNS.
(define-read-only (get-bnsx-name (id uint))
  (match (contract-call? .bnsx-registry get-name-properties-by-id id)
    props (some (merge props {
      legacy: (resolve-legacy-name { name: (get name props), namespace: (get namespace props) })
    }))
    none
  )
)

;; Same as [`get-bnsx-name`](#get-bnsx-name) but looking up via {name, namespace}.
(define-read-only (get-bnsx-by-name (name { name: (buff 48), namespace: (buff 20) }))
  (match (contract-call? .bnsx-registry get-name-properties name)
    props (some (merge props {
      legacy: (resolve-legacy-name name)
    }))
    none
  )
)

;; Helper method to recursively fetch an account's names using the linked-list
;; data structure exposed by the name registry. Starts with an account's primary name
;; and fetches up to 19 more names.
;; 
;; This method _doesn't_ fetch an account's legacy name, if they have one. Use
;; [`get-names`](#get-names) for that.
;; 
;; Returns a tuple with: 
;; 
;; - `legacy`: (see [`resolve-legacy-name`](#resolve-legacy-name))
;; - `names`: a list of up to 20 names, starting with the account's primary. See
;; [`get-bnsx-name`](#get-bnsx-name) for more information
;; - `next-id`: A "cursor" representing the ID of the next name for this account,
;; if the account has more than 20 names. See [`crawl-from-id`](#crawl-from-id) to
;; paginate.
;; 
;; If an account has no names at all, `names` will be an empty list, and `legacy`
;; will be `none`.
(define-read-only (crawl-names (account principal))
  (match (contract-call? .bnsx-registry get-primary-name-properties account)
    primary (let
      (
        (next-id (contract-call? .bnsx-registry get-next-node-id (get id primary)))
        (first (merge primary {
          legacy: (resolve-legacy-name { name: (get name primary), namespace: (get namespace primary) })
        }))
        (iterator {
          names: (list first),
          next-id: next-id,
        })
      )
      (fold crawl-fold ARRAY iterator)
    )
    {
      names: (list ),
      next-id: none
    }
  )
)

;; If an account has more than 20 names, use this to paginate and fetch 20 more names.
(define-read-only (crawl-from-id (id uint))
  (match (contract-call? .bnsx-registry get-name-properties-by-id id)
    props (let
      (
        (next-id (contract-call? .bnsx-registry get-next-node-id (get id props)))
        (first (merge props {
          legacy: (resolve-legacy-name { name: (get name props), namespace: (get namespace props) })
        }))
        (iterator {
          names: (list first),
          next-id: next-id,
        })
      )
      (fold crawl-fold ARRAY iterator)
    )
    {
      names: (list ),
      next-id: none
    }
  )
)

;; Internal method for iterating over names
(define-read-only (crawl-fold 
  (index uint)
  (iterator { 
    names:
      (list 20 {
        owner: principal,
        name: (buff 48),
        namespace: (buff 48),
        id: uint,
        legacy: (optional {
          lease-ending-at: (optional uint),
          lease-started-at: uint,
          owner: principal,
          zonefile-hash: (buff 20),
        })
      }),
    next-id: (optional uint),
  }
))
  (match (get next-id iterator)
    id (let
      (
        ;; (name (unwrap-panic (contract-call? .bnsx-registry get-name-properties-by-id id)))
        (name (unwrap-panic (get-bnsx-name id)))
        (next-id (contract-call? .bnsx-registry get-next-node-id id))
        (name-list (unwrap-panic (as-max-len? (get names iterator) u19)))
      )
      {
        names: (append name-list name),
        next-id: next-id,
      }
    )
    iterator
  )
)

