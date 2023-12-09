;; Crosscheck did:web:idp.xck.app
;; crosscheck-id-validation-v1.clar
;; Provides id validation services for a user of CrossCheck by Paradigma OpenID Connect IDP
;; Verifies that the provided signature of the message-hash was signed with the private key that generated the public key. 
;; The message-hash is the sha256 of the message. The signature includes 64 bytes plus an optional additional recovery id (00..03) for a total of 64 or 65 bytes.
;; constants
;;
(define-read-only (validate-message (message-hash (buff 32)) (signature (buff 65)) (public-key (buff 33)) )
     (secp256k1-verify message-hash signature public-key)
)
