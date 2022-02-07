;; @contract Fractal
;; @version 1.8
;; @author asteria.id

;; This contract is licensed under GNU GPLv3 available here: 
;;   https://www.gnu.org/licenses/gpl-3.0.html

;; asteria.id means the owner of the Stacks mainnet BNS name `asteria.id'
;; as of this writing, the Stacks address of said owner is:
;;   SP343J7DNE122AVCSC4HEK4MF871PW470ZSXJ5K66

(use-trait sip9 .sip9.nft-trait)
(define-fungible-token fractal)


;;              P U B L I C


;; @desc Accepts any SIP-009 NFT and fractalizes it to the tx-sender
;; @param nftContract; A SIP-009 NFT contract address
;; @param nftId; The original uint ID of the NFT used in SIP-009
;; @post tok; The NFT is transferred from the user to this contract

(define-public (fractalize-nft (nftContract <sip9>) (nftId uint) (fractalCount uint))
  (let (
    (owner (unwrap-panic (get-owner nftContract nftId)))
    (userId (get-or-create-user-id tx-sender))
    (targetId (var-get nftTip))
  )
    (begin 
      (asserts! (contract-is-whitelisted nftContract) (err UNAUTHORIZED_CONTRACT))
      (asserts! (is-eq owner tx-sender) (err UNAUTHORIZED))
      (asserts! (> fractalCount u0) (err FRACTAL_COUNT_TOO_LOW))
      (try! (transfer-nft-to-vault nftContract nftId))
      (try! (ft-mint? fractal fractalCount tx-sender))
      (map-insert userBalances { userId: userId, nftId: targetId } fractalCount)
      (map-insert fractalNfts targetId { 
        totalSupply: fractalCount, sip9Contract: (contract-of nftContract), sip9Id: nftId, 
        issuer: tx-sender, uri: (try! (pull-token-uri nftContract nftId)) })
      (unwrap-panic (add-nft-to-owned-tokens userId targetId))
      (var-set nftTip (+ targetId u1))
      (ok targetId)
    )
  )
)

;; @desc Defractalizes an NFT from all of its fractals and releases it to the tx-sender
;; @param nftContract; The SIP-009 NFT contract address
;; @param nftId; The uint ID of the NFT used in SIP-009
;; @param fractalNftId; The uint Fractal ID of the NFT
;; @post tok; The NFT is transferred from this contract to the tx-sender

(define-public (defractalize-nft (nftContract <sip9>) (fractalNftId uint))
  (let (
    (userId (get-or-create-user-id tx-sender))
    (balance (get-or-create-fractal-balance userId fractalNftId))
    (details (unwrap-panic (map-get? fractalNfts fractalNftId )))
  )
    (begin 
      (asserts! (is-eq (contract-of nftContract) (get sip9Contract details))
        (err UNAUTHORIZED_CONTRACT))
      (asserts! (is-eq balance (get totalSupply details)) (err FRACTAL_COUNT_TOO_LOW))
      (try! (ft-burn? fractal balance tx-sender))
      (try! (transfer-nft-out-vault nftContract (get sip9Id details)))
      (map-set fractalNfts fractalNftId { 
        totalSupply: u0, sip9Contract: (get sip9Contract details), 
        sip9Id: (get sip9Id details), issuer: (get issuer details),
        uri: (get uri details)
      })
      (map-delete userBalances { userId: userId, nftId: fractalNftId })
      (remove-nft-from-owned-tokens userId fractalNftId)
      (ok fractalNftId)
    )
  )
)

;; @desc Transfers fractals from tx-sender to another principal
;; @param amount; The amount of fractals to transfer
;; @param recipient; The principal of the user to transfer to
;; @param memo; A memo to attach to the transaction
;; @param nftId; The uint Fractal ID of the NFT

(define-public (transfer 
    (amount uint) 
    (nftId uint)
    (recipient principal) 
    (memo (optional (buff 34))) 
  )
    (begin
      (asserts! (> amount u0) (err FRACTAL_COUNT_TOO_LOW))
      (asserts! (<= amount (unwrap-panic 
        (get-fractal-balance tx-sender nftId))) (err BALANCE_TOO_LOW)
      )
      (try! (ft-transfer? fractal amount tx-sender recipient))

      ;; update balances in maps
      (let (
        (senderUserId (get-or-create-user-id tx-sender))
        (recipientUserId (get-or-create-user-id recipient))

        (senderStartBalance (get-or-create-fractal-balance senderUserId nftId))
        (recipientStartBalance (get-or-create-fractal-balance recipientUserId nftId))

        (senderNewBalance (- senderStartBalance amount))
        (recipientNewBalance (+ recipientStartBalance amount))
      )
        (begin
          (map-set userBalances { userId: senderUserId, nftId: nftId } senderNewBalance)
          (map-set userBalances { userId: recipientUserId, nftId: nftId } recipientNewBalance)
          
          (if (is-eq senderNewBalance u0) 
            (remove-nft-from-owned-tokens senderUserId nftId)
            true
          )

          (unwrap-panic (add-nft-to-owned-tokens recipientUserId nftId))
        )
      )

      (print memo)
      (ok true)
    )
)


;;              E R R O R   C O D E S


(define-constant USER_DOES_NOT_EXIST u300)
(define-constant NFT_DOES_NOT_EXIST u301)
(define-constant USER_OWNED_TOKENS_DOES_NOT_EXIST u302)
(define-constant FRACTAL_COUNT_TOO_LOW u400)
(define-constant BALANCE_TOO_LOW u401)
(define-constant UNAUTHORIZED u500)
(define-constant UNAUTHORIZED_CONTRACT u501)


;;              R E A D - O N L Y


;; @desc Returns a response containing a uint userId
;; @param user; The principal of the user

(define-read-only (get-user-id (user principal)) 
  (let ((userId (map-get? userIds user )))
    (begin 
      (asserts! (is-some userId) (err USER_DOES_NOT_EXIST))
      (ok (unwrap-panic userId))
    )
  )
)

;; @desc Retrieves the Fractal details of a certain NFT
;; @param nftId; The uint Fractal ID of the NFT

(define-read-only (get-nft-details (nftId uint))
  (let ((nft (map-get? fractalNfts nftId )))
    (begin 
      (asserts! (is-some nft) (err NFT_DOES_NOT_EXIST))
      (ok (unwrap-panic nft))
    )
  )
)

;; @desc Retrieves the last Fractal nftId fractalized

(define-read-only (get-last-token-id) (ok (- (var-get nftTip) u1)))

;; @desc Retrieves the last userId created

(define-read-only (get-last-user-id) (ok (- (var-get userIdTip) u1)))

;; @desc Retrieves the SIP9 URI of a certain Fractal NFT
;; @param nftId; The uint Fractal ID of the NFT

(define-read-only (get-token-uri (nftId uint))
  (let ((nft (map-get? fractalNfts nftId )))
    (begin 
      (asserts! (is-some nft) (err NFT_DOES_NOT_EXIST))
      (ok (get uri (unwrap-panic nft)))
    )
  )
)

;; @desc Retrieves a list of a user's owned Fractal NFTs
;; @param user; The principal of the user

(define-read-only (get-user-fractals (user principal))
  (ok (unwrap! 
    (map-get? userOwnedTokens (unwrap-panic (map-get? userIds user))) 
    (err USER_OWNED_TOKENS_DOES_NOT_EXIST)
  ))
)

;; @desc Retrieves the fractals balance of a principal for a certain NFT
;; @param user; The principal of the user
;; @param nftId; The uint Fractal ID of the NFT

(define-read-only (get-fractal-balance (user principal) (nftId uint))
  (let ((balance (map-get? userBalances { 
      userId: (unwrap-panic (get-user-id user)),
      nftId: nftId })))
    (if (is-none balance)
      (ok u0)
      (ok (unwrap-panic balance))
    )
  )
)

;; @desc Retrieves the total fractal balance of a principal over all NFTs
;; @param user; The principal of the user

(define-read-only (get-total-balance (user principal))
  (ok (ft-get-balance fractal user))
)

;; @desc Retrieves the total fractals in existence for a certain NFT
;; @param nftId; The uint Fractal ID of the NFT

(define-read-only (get-fractal-supply (nftId uint) )
  (ok (get totalSupply (unwrap-panic (get-nft-details nftId))))
)

;; @desc Retrieves the total fractals in existence for all NFTs

(define-read-only (get-total-supply)
  (ok (ft-get-supply fractal))
)

;; @desc Human readable name to display to the user

(define-read-only (get-name) (ok "Fractal") )

;; @desc Human readable symbol to display to the user

(define-read-only (get-symbol) (ok "FTL") )


;;              S T O R A G E


(define-map fractalNfts uint
  { totalSupply: uint, sip9Contract: principal, sip9Id: uint, 
    issuer: principal, uri: (optional (string-ascii 256)) }
)

(define-map userIds principal uint )

;; userId and nftId against uint balance
(define-map userBalances { userId: uint, nftId: uint } uint)

;; userId against list of uint nftIds
(define-map userOwnedTokens uint (list 512 uint))

(define-data-var userIdTip uint u1)
(define-data-var nftTip uint u1)

(define-data-var toRemove uint u0)

;; i didn't want to add this but otherwise people could use malicious contracts
;; to drain the nft vault through a malicious contract-call. whitelist is added
;; once through map-insert's at the end of the contract and cannot be changed
(define-map whitelist principal bool)


;;              P R I V A T E


(define-private (get-or-create-user-id (user principal)) 
  (let ((userId (map-get? userIds user)))
    (if (is-some userId) 
      (unwrap-panic userId)
      (let ((targetId (var-get userIdTip))) 
        (begin 
          (map-insert userIds user targetId )
          (var-set userIdTip (+ targetId u1))
          targetId
        )
      )
    )
  )
)

(define-private (contract-is-whitelisted (contract <sip9>))
  (is-some (map-get? whitelist (contract-of contract)))
)

(define-private (add-nft-to-owned-tokens (userId uint) (nftId uint))
  (let ((wrappedOwnedTokens (map-get? userOwnedTokens userId)))
    ;; if entry exists
    (if (is-some wrappedOwnedTokens) 
      (let ((ownedTokens (unwrap-panic wrappedOwnedTokens)))
        ;; if nftId is not already in ownedTokens
        (if (is-none (index-of ownedTokens nftId))
          (begin
            (map-set userOwnedTokens userId (unwrap-panic 
              (as-max-len? (append ownedTokens nftId) u512)
            ))
            ;; already owned, so no change
            (ok true)
          )
          (ok true)
        )
      )
      (begin 
        (map-insert userOwnedTokens userId (list nftId) )
        (ok true)
      )
    )
  )
)

(define-private (remove-nft-from-owned-tokens (userId uint) (nftId uint))
  ;; if we get here, we can assume that the user has the nftId in their list
  ;; so we don't need to check if there's an entry or not, or if the list is empty
  (begin 
    (var-set toRemove nftId)
    (map-set userOwnedTokens userId 
      (filter is-eq-toRemove (unwrap-panic (map-get? userOwnedTokens userId)))
    )
  )
)

(define-private (is-eq-toRemove (a uint))
  (is-eq a (var-get toRemove))
)

(define-private (get-or-create-fractal-balance (userId uint) (nftId uint))
  (let (
    (balance (map-get? userBalances { userId: userId, nftId: nftId }))
  )
    (if (is-some balance)
      (unwrap-panic balance)
      (begin 
        (map-insert userBalances { userId: userId, nftId: nftId } u0)
        u0
      )
    )
  )
)

(define-private (get-owner (nftContract <sip9>) (nftId uint))
  (unwrap-panic (contract-call? nftContract get-owner nftId))
)

(define-private (transfer-nft-to-vault (nftContract <sip9>) (nftId uint))
  (contract-call? nftContract transfer nftId tx-sender (as-contract tx-sender))
)

(define-private (transfer-nft-out-vault (nftContract <sip9>) (nftId uint))
  (let ((recipient tx-sender)) 
    (as-contract (contract-call? nftContract transfer nftId tx-sender recipient))
  )
)

(define-private (pull-token-uri (nftContract <sip9>) (nftId uint))
  (contract-call? nftContract get-token-uri nftId)
)


;;              W H I T E L I S T

(map-insert whitelist 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.metaraffes true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.fruits true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.rangoli true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.anime-girls true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.cybernetic-souls true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.stacculents true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.stacks-army true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.cyber-angels true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.bitcoin-pizza true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.mother-satoshi-2 true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.straw-collection true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.saints true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.future-of-money true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.zebras true)
(map-insert whitelist 'SP2Z2BST4Z2RFSDTF7GJ4D07VXCFRBRTR1JPCCE7J.dreamcatchers true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.bulls true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.roads true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.owls true)
(map-insert whitelist 'SP2Z2BST4Z2RFSDTF7GJ4D07VXCFRBRTR1JPCCE7J.anime-boys true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.miami-vice true)
(map-insert whitelist 'SP2Z2BST4Z2RFSDTF7GJ4D07VXCFRBRTR1JPCCE7J.picasso-magic-1 true)
(map-insert whitelist 'SP2Z2BST4Z2RFSDTF7GJ4D07VXCFRBRTR1JPCCE7J.picasso-magic-2 true)
(map-insert whitelist 'SP2Z2BST4Z2RFSDTF7GJ4D07VXCFRBRTR1JPCCE7J.spooky-staccs true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.ueberkatzen true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.cyber-stx true)
(map-insert whitelist 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.arties true)
(map-insert whitelist 'SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY.stacks-roots true)
(map-insert whitelist 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8.tiles true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.mother-of-satoshi true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.spacewhales true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.satoshis-team true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.hexstx true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.testing-liquidity true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.mandelbrots-v1 true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.pox-monks true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.crypto-graffiti true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.phases-of-satoshi true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.blue-ridge-biker true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-pops true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.bitcoin-birds true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.byte-fighters true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.blocks true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stx-youth true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stx-jokers true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.virtual-tulips true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.funky-donuts true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.zombie-wabbits true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-mandala true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.citadels true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-snowball-rabbits true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-storm true)
(map-insert whitelist 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-ape-club-nft true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-nakamoto-guardians true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcutties true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-pixel-world-v1 true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-vampire-slayers true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-cyborg true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-vague-art-paintings true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-homagic true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-sadoughshis-bitcoin-pizza true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-fruitmen true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-shroomies true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-satoshi-knights true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-kittens true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-the-himalayan-trinity true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-blurred-museum true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-tulips true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-foxes-community true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.bitcoin-birds true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-animal-stacks true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-dragons true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-english-hat-club true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-matryoshka-dolls true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-genesis true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.deruptars true)
(map-insert whitelist 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.arties true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.ueberkatzen true)
(map-insert whitelist 'SP2Z2BST4Z2RFSDTF7GJ4D07VXCFRBRTR1JPCCE7J.anime-boys true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.miami-vice true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.roads true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.bulls true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-shroomies true)
(map-insert whitelist 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-ape-club-nft true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.owls true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.bulls true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.owls-v2 true)
(map-insert whitelist 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy true)
(map-insert whitelist 'SP2Z2BST4Z2RFSDTF7GJ4D07VXCFRBRTR1JPCCE7J.dreamcatchers true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.zebras true)
(map-insert whitelist 'SP2Z2BST4Z2RFSDTF7GJ4D07VXCFRBRTR1JPCCE7J.picasso-magic-2 true)
(map-insert whitelist 'SP2Z2BST4Z2RFSDTF7GJ4D07VXCFRBRTR1JPCCE7J.picasso-magic-1 true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.future-of-money true)
(map-insert whitelist 'SP2E03GHWY145XMFDTHX4Z913EADP4RMZ0P0DCTE9.megapont-ape-club-nft true)
(map-insert whitelist 'SP1SCEXE6PMGPAC6B4N5P2MDKX8V4GF9QDE1FNNGJ.miami-degens true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.stacks-army true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.metaraffes true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.fruits true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.mother-satoshi-2 true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.cyber-angels true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.bitcoin-pizza true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.bitcoin-pizza true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.cybernetic-souls true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.rangoli true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.anime-girls true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.citadels true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.stacculents true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.stacculents true)
(map-insert whitelist 'SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY.stacks-roots true)
(map-insert whitelist 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8.tiles true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.mother-of-satoshi true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-english-hat-club true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-matryoshka-dolls true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.mother-of-satoshi true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.spacewhales true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.byte-fighters true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-pops true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.satoshis-team true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.hexstx true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.testing-liquidity true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-genesis true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.bitcoin-birds true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-pops true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.blue-ridge-biker true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.phases-of-satoshi true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.mandelbrots-v1 true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.deruptars true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.pox-monks true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.crypto-graffiti true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.get-a-life true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.trubit-rose true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.trubit-domino true)
(map-insert whitelist 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.happy-welsh true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.magic-ape-school true)
(map-insert whitelist 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-component-nft true)
(map-insert whitelist 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-nft true)
(map-insert whitelist 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-nft true)
(map-insert whitelist 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.arties true)
(map-insert whitelist 'SP2CNW7ZAQRXPP8KRXM6VCC8H2XS8QNETAMEMBEX9.citypack-airdrop true)
(map-insert whitelist 'SP2RJP81KF3V6NJVZEZ2SR8DD73VQJC98EJSTQWDV.dcards-v4 true)
(map-insert whitelist 'SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY.special-ingredient true)
(map-insert whitelist 'SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY.punk-donuts true)
(map-insert whitelist 'SPS51PEXKRDZMR0NYPYMM1EH2Y054T3ND173N0NW.ab-airdrop true)
(map-insert whitelist 'SPS51PEXKRDZMR0NYPYMM1EH2Y054T3ND173N0NW.ag-airdrop true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.macaws true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.fishy-business true)
(map-insert whitelist 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v1 true)
(map-insert whitelist 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.citypacks-nft-001 true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.theopetra-king true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.theopetra-rook true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.theopetra-knight true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.theopetra-pawn true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-samurai true)
(map-insert whitelist 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.african-queen-mother true)
(map-insert whitelist 'SP27SD3H5TTZXPBFXHN1ZNMFJ3HNE2070QWHH3BXX.cube true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wolf-pack-academy-v1 true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wolf-pack-academy-v1 true)
(map-insert whitelist 'SPZW30K9VG6YCPYV4BX4V1FT0VJ66R1Q01W9DQ1W.commoners true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.miamicoin-artweek true)
(map-insert whitelist 'SP39HFKW38EPPPRQ1R52GK02WCN8314DQAQHF6EZ6.wolf-pack-academy true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.frontier true)
(map-insert whitelist 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bears true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bears true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bulls true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bears true)
(map-insert whitelist 'SP1QK1AZ24R132C0D84EEQ8Y2JDHARDR58R72E1ZW.boomboxes-cycle-22 true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.saints true)
(map-insert whitelist 'SPZW30K9VG6YCPYV4BX4V1FT0VJ66R1Q01W9DQ1W.pokinometry true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.genesis-64 true)
(map-insert whitelist 'SPZW30K9VG6YCPYV4BX4V1FT0VJ66R1Q01W9DQ1W.vaguearts-gods true)
(map-insert whitelist 'SPZW30K9VG6YCPYV4BX4V1FT0VJ66R1Q01W9DQ1W.borges-mia-btc-fam true)
(map-insert whitelist 'SPZW30K9VG6YCPYV4BX4V1FT0VJ66R1Q01W9DQ1W.other-worlds true)
(map-insert whitelist 'SP1QK1AZ24R132C0D84EEQ8Y2JDHARDR58R72E1ZW.boomboxes-cycle-20-v2 true)
(map-insert whitelist 'SP1QK1AZ24R132C0D84EEQ8Y2JDHARDR58R72E1ZW.boomboxes-cycle-20-v1 true)
(map-insert whitelist 'SP1QK1AZ24R132C0D84EEQ8Y2JDHARDR58R72E1ZW.boomboxes-cycle-18 true)
(map-insert whitelist 'SP1QK1AZ24R132C0D84EEQ8Y2JDHARDR58R72E1ZW.boomboxes-cycle-17 true)
(map-insert whitelist 'SP1QK1AZ24R132C0D84EEQ8Y2JDHARDR58R72E1ZW.boomboxes-cycle-16 true)
(map-insert whitelist 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boomboxes-cycle-14 true)
(map-insert whitelist 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boomboxes-cycle-12 true)
(map-insert whitelist 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boomboxes-cycle-6 true)
(map-insert whitelist 'SPZW30K9VG6YCPYV4BX4V1FT0VJ66R1Q01W9DQ1W.htl true)
(map-insert whitelist 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.helias true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-skaters true)
(map-insert whitelist 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.bitgear-genesis true)
(map-insert whitelist 'SP1T4Y4WK9DGZ2EDWSNHRE5HRRBPVG7S46JAHW552.panda-nft true)
(map-insert whitelist 'SP1T4Y4WK9DGZ2EDWSNHRE5HRRBPVG7S46JAHW552.panda-nft true)
(map-insert whitelist 'SP1T4Y4WK9DGZ2EDWSNHRE5HRRBPVG7S46JAHW552.panda-nft true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.shapes true)
(map-insert whitelist 'SPZW30K9VG6YCPYV4BX4V1FT0VJ66R1Q01W9DQ1W.stacks-ludenz true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-space-lambos true)
(map-insert whitelist 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.arties true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.openxis true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-space-lambos true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.miami-beach true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bulls true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-the-nostalgia-machine true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-hero-of-miami true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-the-nostalgia-machine true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-giantpandas true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-giantpandas true)
(map-insert whitelist 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.stxplates true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-groot true)
(map-insert whitelist 'SP38FN88VZ97GWV0E8THXRM6Z5VMFPHFY4J1JEC5S.btc-badgers true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.owls-v2 true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.entangled-flowers true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-parrots true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-mad-pandas true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-pixels true)
(map-insert whitelist 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173.the-explorer-guild true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-blurred-museum true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacksboi true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-african-royalty true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitzombies true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-proof-of-puf true)
(map-insert whitelist 'SP2Z2BST4Z2RFSDTF7GJ4D07VXCFRBRTR1JPCCE7J.snacks true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.wgmiami true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.ghost-rock true)
(map-insert whitelist 'SP1SCEXE6PMGPAC6B4N5P2MDKX8V4GF9QDE1FNNGJ.nyc-degens true)
(map-insert whitelist 'SP39HFKW38EPPPRQ1R52GK02WCN8314DQAQHF6EZ6.Bitcoin-Kitties true)
(map-insert whitelist 'SP39HFKW38EPPPRQ1R52GK02WCN8314DQAQHF6EZ6.Wolf-Pack-Academy-V1 true)
(map-insert whitelist 'SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY.stacks-roots-v2 true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-whales true)
(map-insert whitelist 'SPXGFH9JTKPF2TQZJ2AH7NSMMMXJ72VMGH8PR654.itwillnotbetelevised true)
(map-insert whitelist 'SP2F87X6HJ6H0KMB5XY0M414ZNYFDYWSBBX3DRQPD.immortal-butterflies---part-1 true)
(map-insert whitelist 'SP1XPCCJE4NR82X6D8PX32NF1KAYYM36B5T83J6GP.stiltsville true)
(map-insert whitelist 'SP2GNDY6AVZBEZAQ5R2BY04FYXTC23CHVE1216PK8.miami-beach-volleyball true)
(map-insert whitelist 'SP1WP1GYZV50CRGV6T6AJ5408XV68VSS1WQNRMBXZ.beernfts true)
(map-insert whitelist 'SP3A4867MC9SVY6V66EJCRXTE1MV836EVMEGDBFYH.gold-rush true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.venice-visuals true)
(map-insert whitelist 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.rpgcharacters true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.stacks-parrots-3d true)
(map-insert whitelist 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.rpgcharacters true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys true)
(map-insert whitelist 'SP176ZMV706NZGDDX8VSQRGMB7QN33BBDVZ6BMNHD.project-indigo-landmarks true)
(map-insert whitelist 'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH.hooch-haus---booze-brains true)
(map-insert whitelist 'SP3M05ETW09E98NNFMFHT1WND3ZRX9DV31TFC6DFW.hooch-haus---booze-brains true)
(map-insert whitelist 'SP1SCEXE6PMGPAC6B4N5P2MDKX8V4GF9QDE1FNNGJ.SDGU-stackspunks true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.saints true)
(map-insert whitelist 'SP1QK1AZ24R132C0D84EEQ8Y2JDHARDR58R72E1ZW.boomboxes-cycle-26 true)
(map-insert whitelist 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.funky-donuts true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.future-of-money true)
(map-insert whitelist 'SP1QK1AZ24R132C0D84EEQ8Y2JDHARDR58R72E1ZW.boomboxes-cycle-18 true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.cyber-angels true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-punks-v3 true)
(map-insert whitelist 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-ape-club-nft true)
(map-insert whitelist 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.arties true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.bitcoin-pizza true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-satoshi-knights true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-homagic true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.blocks true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-mandala true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.testing-liquidity true)
(map-insert whitelist 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-kittens true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.citadels true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-pops true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.stacculents true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.pox-monks true)
(map-insert whitelist 'SP1SCEXE6PMGPAC6B4N5P2MDKX8V4GF9QDE1FNNGJ.miami-degens true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-genesis true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.miami-vice true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-dragons true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.satoshis-team true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-foxes-community true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-matryoshka-dolls true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-tulips true)
(map-insert whitelist 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8.tiles true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.anime-girls true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.bulls true)
(map-insert whitelist 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.thisisnumberone-v2 true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.zebras true)
(map-insert whitelist 'SP2Z2BST4Z2RFSDTF7GJ4D07VXCFRBRTR1JPCCE7J.picasso-magic-1 true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-animal-stacks true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.fruits true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.spacewhales true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.deruptars true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.stacks-army true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-blurred-museum true)
(map-insert whitelist 'SP2Z2BST4Z2RFSDTF7GJ4D07VXCFRBRTR1JPCCE7J.anime-boys true)
(map-insert whitelist 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boomboxes-cycle-12 true)
(map-insert whitelist 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boomboxes-cycle-14 true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-sadoughshis-bitcoin-pizza true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-snowball-rabbits true)
(map-insert whitelist 'SP2Z2BST4Z2RFSDTF7GJ4D07VXCFRBRTR1JPCCE7J.dreamcatchers true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.bitcoin-birds true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.phases-of-satoshi true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-vampire-slayers true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.roads true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-fruitmen true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.hexstx true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.mandelbrots-v1 true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.crypto-graffiti true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-cyborg true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.cybernetic-souls true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.byte-fighters true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.mother-of-satoshi true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.metaraffes true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-vague-art-paintings true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.mother-satoshi-2 true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-english-hat-club true)
(map-insert whitelist 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.ruma-v1 true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.mandelbrots true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-shroomies true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.rangoli true)
(map-insert whitelist 'SP2Z2BST4Z2RFSDTF7GJ4D07VXCFRBRTR1JPCCE7J.picasso-magic-2 true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.zombie-wabbits true)
(map-insert whitelist 'SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY.stacks-roots true)
(map-insert whitelist 'SP1QK1AZ24R132C0D84EEQ8Y2JDHARDR58R72E1ZW.boomboxes-cycle-16 true)
(map-insert whitelist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.blue-ridge-biker true)
(map-insert whitelist 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts true)
(map-insert whitelist 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.cyber-angels true)
(map-insert whitelist 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.spacewhales true)
(map-insert whitelist 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-nft-shades true)
(map-insert whitelist 'SPZW30K9VG6YCPYV4BX4V1FT0VJ66R1Q01W9DQ1W.city-collection-nyc true)
(map-insert whitelist 'SPZW30K9VG6YCPYV4BX4V1FT0VJ66R1Q01W9DQ1W.city-collection-mia true)
(map-insert whitelist 'SP3N81TKV43PN24NPHNNM8BBNQJ51Q31HE9G0GC46.bubo true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-lost-explorers true)
(map-insert whitelist 'SP3M7N9Q9HDRM7RVP1Q26P0EE69358PZZAX4MD19Q.nft-nyc-exclusive true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-proof-of-puf true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft true)
(map-insert whitelist 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-rare-v1 true)