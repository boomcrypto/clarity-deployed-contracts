
;; unlockable-characters
;; <add a description here>

;; constants
;;

;; data maps and vars
(define-map unlockable-characters (string-ascii 50) 
    {name: (string-ascii 50), category: (string-ascii 100), strength: uint, defense: uint, image-url: (string-ascii 200)}
)

;; private functions
;;

;; public functions
(define-public (unlock-character (specific-character (string-ascii 50)) (character-name (string-ascii 50)) (category (string-ascii 100)) (attack uint) (shield uint) (hero-image (string-ascii 200)))
    (begin
        (ok (map-set unlockable-characters specific-character {name: character-name, category: category, strength: attack, defense: shield, image-url: hero-image}))
    )
)
(define-read-only (get-character (specific-character (string-ascii 50)))
    (map-get? unlockable-characters specific-character)
)
