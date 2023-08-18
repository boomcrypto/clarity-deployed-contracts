;; Title: DME008 Quest Metadata
;; Author: rozar.btc
;; Depends-On: DME000
;; Synopsis: 
;; A dedicated contract to manage the metadata associated with various quests, providing secure CRUD operations.
;; Description:
;; The Quest Metadata contract acts as a pivotal storage and management mechanism for quest-related metadata. 
;; With intricate authorization measures, it ensures that only trusted entities can set or retrieve metadata, keeping the integrity of the quest ecosystem intact. 
;; By facilitating the secure linking of quests with their descriptive metadata, it enriches the questing experience and ensures a cohesive narrative.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.extension-trait.extension-trait)

(define-constant err-not-found (err u2001))
(define-constant err-unauthorized (err u3100))

(define-map quest-metadata-map uint	(optional (string-utf8 256)))

;; --- Authorization check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

;; --- Internal DAO functions

(define-public (set-metadata (quest-id uint) (metadata-uri (optional (string-utf8 256))))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set quest-metadata-map quest-id metadata-uri))
	)
)

;; --- Public functions 

(define-read-only (get-metadata (quest-id uint))
	(ok (unwrap! (map-get? quest-metadata-map quest-id) err-not-found))
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)