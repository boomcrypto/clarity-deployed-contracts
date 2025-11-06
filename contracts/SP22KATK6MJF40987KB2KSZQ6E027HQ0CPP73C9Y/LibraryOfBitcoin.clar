;; Book Publishing Contract v2

;; --- Error Constants ---
(define-constant ERR_NOT_AUTHOR (err u1001))
(define-constant ERR_BOOK_EXISTS (err u1002))
(define-constant ERR_BOOK_NOT_FOUND (err u1003))
(define-constant ERR_INVALID_INPUT (err u1004))
(define-constant ERR_PAGE_OUT_OF_BOUNDS (err u1005))

;; --- Book ID Counter ---
(define-data-var last-book-id uint u0)

;; --- Book Metadata Map: book-id -> book info ---
(define-map books uint {
    author: principal,
    title: (string-utf8 64),
    description: (string-utf8 256)
})

;; --- Pages Map: (book-id, page-number) -> content ---
(define-map book-pages (tuple (book-id uint) (page uint)) (string-utf8 2048))

;; --- Chapter Map: (book-id, chapter) -> start-page (uint) ---
(define-map chapters (tuple (book-id uint) (chapter uint)) uint)

;; --- Read-Only Functions ---

(define-read-only (get-book-by-id (book-id uint))
    (map-get? books book-id)
)

(define-read-only (get-page (book-id uint) (page uint))
    (map-get? book-pages { book-id: book-id, page: page })
)

(define-read-only (get-chapter-start-page (book-id uint) (chapter uint))
    (map-get? chapters { book-id: book-id, chapter: chapter })
)

(define-read-only (get-last-book-id)
    (var-get last-book-id)
)

;; --- Public Functions ---

(define-public (publish-book
    (title (string-utf8 64))
    (description (string-utf8 256))
)
    (let (
        (book-id (+ (var-get last-book-id) u1))
        (caller tx-sender)
    )
        ;; Validate input
        (asserts! (> (len title) u0) ERR_INVALID_INPUT)
        (asserts! (> (len description) u0) ERR_INVALID_INPUT)

        ;; Save metadata
        (map-set books book-id {
            author: caller,
            title: title,
            description: description
        })

        ;; Update counter
        (var-set last-book-id book-id)

        (ok book-id)
    )
)

(define-public (edit-book-meta
    (book-id uint)
    (new-title (string-utf8 64))
    (new-description (string-utf8 256))
)
    (let (
        (caller tx-sender)
        (book (unwrap! (map-get? books book-id) ERR_BOOK_NOT_FOUND))
    )
        (asserts! (is-eq caller (get author book)) ERR_NOT_AUTHOR)
        (asserts! (> (len new-title) u0) ERR_INVALID_INPUT)
        (asserts! (> (len new-description) u0) ERR_INVALID_INPUT)

        (map-set books book-id {
            author: (get author book),
            title: new-title,
            description: new-description
        })

        (ok true)
    )
)

(define-public (add-or-edit-page
    (book-id uint)
    (page-number uint)
    (content (string-utf8 2048))
)
    (let (
        (caller tx-sender)
        (book (unwrap! (map-get? books book-id) ERR_BOOK_NOT_FOUND))
    )
        (asserts! (is-eq caller (get author book)) ERR_NOT_AUTHOR)
        (asserts! (> (len content) u0) ERR_INVALID_INPUT)

        (map-set book-pages { book-id: book-id, page: page-number } content)

        (ok true)
    )
)

(define-public (set-chapter
    (book-id uint)
    (chapter-number uint)
    (start-page uint)
)
    (let (
        (caller tx-sender)
        (book (unwrap! (map-get? books book-id) ERR_BOOK_NOT_FOUND))
    )
        (asserts! (is-eq caller (get author book)) ERR_NOT_AUTHOR)

        (map-set chapters { book-id: book-id, chapter: chapter-number } start-page)

        (ok true)
    )
)
