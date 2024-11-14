;; Energetic Welsh Contract
;;
;; This contract manages energy generation bonuses for Welsh NFT holders in the 
;; Charisma protocol. It provides stackable bonuses for holding different Welsh 
;; NFTs (Happy Welsh, Weird Welsh, and Welsh Punk) when generating energy through 
;; approved meme engines.
;;
;; Key Features:
;; 1. NFT-Based Bonuses: Holders of Welsh NFTs receive energy generation bonuses
;; 2. Stackable Effects: Bonuses from different collections can be combined
;; 3. Collection-Specific: Only requires 1 NFT per collection to receive bonus
;; 4. Engine-Specific: Bonuses only apply to whitelisted meme engines
;; 5. Dynamic Engine Support: Admin can add/remove supported engines
;;
;; Bonus Structure:
;; - Happy Welsh: 25% bonus (configurable)
;; - Weird Welsh: 15% bonus (configurable)
;; - Welsh Punk: 10% bonus (configurable)
;; - Maximum Combined: 100% bonus
;; - Minimum Individual: 1% bonus
;;
;; Default Supported Engines:
;; - Pure Welsh Engines:
;;   | .meme-engine-welsh-rc1
;;   | .meme-engine-iou-welsh-rc2
;;   | .meme-engine-welsh-iou-welsh-rc1
;; - Hybrid Engines:
;;   | .meme-engine-cha-iou-welsh-rc1
;;   | .meme-engine-cha-welsh-rc1
;;   | .meme-engine-cha-updog-rc1
;;   | .meme-engine-iou-welsh-rc1
;;
;; Admin Capabilities:
;; 1. Bonus Configuration:
;;    - Set individual NFT collection bonus percentages
;;    - Must be within min/max bounds (1% to 100%)
;; 2. Engine Management:
;;    - Add new supported engines
;;    - Remove existing supported engines
;;    - Query current engine support status
;;
;; Integration Points:
;; - Welsh NFT Contracts:
;;   | 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.happy-welsh
;;   | 'SPKW6PSNQQ5Y8RQ17BWB0X162XW696NQX1868DNJ.weird-welsh
;;   | 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.welsh-punk
;; - Status Effects Contract (calls apply function for energy calculations)
;;
;; Security Features:
;; - Owner-only configuration of bonus percentages
;; - Owner-only management of supported engines
;; - Minimum and maximum bonus constraints
;; - Combined bonus cap
;; - Engine whitelist validation
;;
;; This contract is a crucial component of the Welsh ecosystem within Charisma,
;; providing incentives for Welsh NFT collection and participation in Welsh-related
;; protocol activities. The bonus system encourages collecting across different 
;; Welsh collections while maintaining balance through individual and combined caps.
;; The configurable engine support allows for protocol evolution and integration of
;; new Welsh-related activities over time.

;; Constants
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_INVALID_BONUS (err u402))
(define-constant CONTRACT_OWNER tx-sender)
(define-constant MIN_BONUS u10000)     ;; 1% minimum bonus
(define-constant MAX_BONUS u1000000)   ;; 100% maximum bonus
(define-constant MAX_COMBINED_BONUS u1000000)  ;; 100% maximum combined bonus

;; Data Variables for configurable bonuses
(define-data-var happy-welsh-bonus uint u250000)  ;; 25% bonus
(define-data-var weird-welsh-bonus uint u150000)  ;; 15% bonus
(define-data-var welsh-punk-bonus uint u100000)   ;; 10% bonus

;; Data Maps
(define-map supported-engines principal bool)

;; Initialize supported engines
(map-set supported-engines .meme-engine-welsh-rc1 true)
(map-set supported-engines .meme-engine-iou-welsh-rc2 true)
(map-set supported-engines .meme-engine-welsh-iou-welsh-rc1 true)
(map-set supported-engines .meme-engine-cha-iou-welsh-rc1 true)
(map-set supported-engines .meme-engine-cha-welsh-rc1 true)
(map-set supported-engines .meme-engine-cha-updog-rc1 true)
(map-set supported-engines .meme-engine-iou-welsh-rc1 true)

;; Helper function to validate bonus amount
(define-private (is-valid-bonus (amount uint))
   (and (>= amount MIN_BONUS) (<= amount MAX_BONUS)))

;; Helper function to check if engine is supported
(define-private (is-supported-engine (engine principal))
  (default-to false (map-get? supported-engines engine)))

;; Read-only function to get total bonus
(define-read-only (apply (base-amount uint) (target principal) (caller principal))
   (let (
       ;; Calculate bonuses
       (happy-bonus (if (> (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.happy-welsh get-balance target) u0)
                       (var-get happy-welsh-bonus)
                       u0))
       (weird-bonus (if (> (contract-call? 'SPKW6PSNQQ5Y8RQ17BWB0X162XW696NQX1868DNJ.weird-welsh get-balance target) u0)
                       (var-get weird-welsh-bonus)
                       u0))
       (punk-bonus (if (> (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.welsh-punk get-balance target) u0)
                       (var-get welsh-punk-bonus)
                       u0))
       ;; Calculate total bonus with cap
       (total-bonus (min (+ happy-bonus weird-bonus punk-bonus) MAX_COMBINED_BONUS))

       ;; Calculate bonus amount
       (bonus-amount (/ (* base-amount total-bonus) u1000000)))

       ;; Return modified amount if caller is supported engine
       (if (is-supported-engine caller) (+ base-amount bonus-amount) base-amount)))

;; Admin functions to configure supported engines

(define-public (add-supported-engine (engine principal))
   (begin
       (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
       (ok (map-set supported-engines engine true))))

(define-public (remove-supported-engine (engine principal))
   (begin
       (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
       (ok (map-delete supported-engines engine))))

;; Read-only function to check if engine is supported
(define-read-only (is-engine-supported (engine principal))
   (is-supported-engine engine))

;; Admin functions to configure bonuses

(define-public (set-happy-welsh-bonus (new-bonus uint))
   (begin
       (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
       (asserts! (is-valid-bonus new-bonus) ERR_INVALID_BONUS)
       (ok (var-set happy-welsh-bonus new-bonus))))

(define-public (set-weird-welsh-bonus (new-bonus uint))
   (begin
       (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
       (asserts! (is-valid-bonus new-bonus) ERR_INVALID_BONUS)
       (ok (var-set weird-welsh-bonus new-bonus))))

(define-public (set-welsh-punk-bonus (new-bonus uint))
   (begin
       (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
       (asserts! (is-valid-bonus new-bonus) ERR_INVALID_BONUS)
       (ok (var-set welsh-punk-bonus new-bonus))))

;; Read-only functions to check current bonuses

(define-read-only (get-happy-welsh-bonus)
   (var-get happy-welsh-bonus))

(define-read-only (get-weird-welsh-bonus)
   (var-get weird-welsh-bonus))

(define-read-only (get-welsh-punk-bonus)
   (var-get welsh-punk-bonus))

;; Read-only function to check bonus limits
(define-read-only (get-bonus-limits)
   {
       min-bonus: MIN_BONUS,
       max-individual-bonus: MAX_BONUS,
       max-combined-bonus: MAX_COMBINED_BONUS
   })

;; Utility functions

(define-private (min (a uint) (b uint))
  (if (<= a b) a b))