;; title: template-batch-endorsements

;; traits
;;
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; token definitions
;; 
;; (VAR) based on title of collection
(define-non-fungible-token endorsement uint)
;; constants
;;
;; (VAR) changes based on the number of recipients
(define-constant TOTAL u19)
(define-constant ERROR-NOT-IMPLEMENTED u1)
(define-constant ERROR-UNAUTHORIZED u1000)
(define-constant ERROR-ALREADY-MINTED u1001)

;; (VAR) changes based on the collection ipfs hash
(define-constant IPFS-ROOT "ipfs://ipfs/bafybeic5tocu2fkzeyzbd3ziw6gtbzvrh2xjcmzrl72ezymn6k44g3imvu/{id}.json")


;; data vars
;;
(define-data-var last-token-id uint u0)
;; data maps
;;


;; public functions
;;
(define-private (mint (address principal))
    (let (
        (token-id (+ u1 (var-get last-token-id)))
    ) 
    (var-set last-token-id token-id)
    (nft-mint? endorsement token-id address)))

;; Non transferrable
(define-public (transfer (id uint) (sender principal) (recipient principal)) 
    (err ERROR-NOT-IMPLEMENTED))

(define-public (burn (id uint)) 
    (let (
        (owner (unwrap! (nft-get-owner? endorsement id) (err ERROR-UNAUTHORIZED)))
    ) 
    (asserts! (is-eq owner tx-sender) (err ERROR-UNAUTHORIZED))
    (nft-burn? endorsement id owner)))
;; read only functions
;;

;; this would be constant to mark collection as preminted
(define-read-only (get-last-token-id) 
    (ok TOTAL))

(define-read-only (get-owner (id uint))
    (ok (nft-get-owner? endorsement id)))

(define-read-only (get-token-uri (token-id uint))
    (ok (some IPFS-ROOT)))

;;; mint calls here
(mint 'SP1FB5SXYZE38E0EZ86NSMQHXCBSPF43KP4KQN9KW)
(mint 'SP1PHAGEQ5RWM8G84DFGMRPENKQGFC4QJ9YWXAYKF)
(mint 'SP1PJ0AYW1WRSRV4H449R31PXKZ3KGSDYKW1HN7DS)
(mint 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1)
(mint 'SP1SE73VJ07WQSZSFJ1QP3SX7TVRPVJGYP0S89WWH)
(mint 'SP1VWZ61MT83GAAY8CGM857MVB91J1ASZGPFPSXCN)
(mint 'SP24X31G5NWF1SWEGSCXX4MQHH4YG50J5BV81QY83)
(mint 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB)
(mint 'SP2TSAGKRZGCD23RQTD925CDD8X3Q1YCGBKAJYP10)
(mint 'SP2Z2CBMGWB9MQZAF5Z8X56KS69XRV3SJF4WKJ7J9)
(mint 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN)
(mint 'SP3RW6BW9F5STYG2K8XS5EP5PM33E0DNQT4XEG864)
(mint 'SP7QQ9DV0DMV7YW4HR713MKBWADVA0BFC2J65PJT)
(mint 'SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D)
(mint 'SP17A1AM4TNYFPAZ75Z84X3D6R2F6DTJBDJ6B0YF)
(mint 'SP2GW18TVQR75W1VT53HYGBRGKFRV5BFYNAF5SS5J)
(mint 'SP13WNJSM44HYQ38SF2YYE5APKFRFPGXVHHQTS2ED)
(mint 'SP1WC407WB50ZPDWDYCG50Z1TCQD0DPH0D2EQ6K39)
(mint 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G)
