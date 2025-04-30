;; Requirement Tracking Contract
;; Records applicable compliance obligations

(define-data-var admin principal tx-sender)

;; Map of compliance requirements
(define-map requirements
  { requirement-id: (string-ascii 64) }
  {
    source-id: (string-ascii 64),
    title: (string-ascii 100),
    description: (string-utf8 500),
    effective-date: uint,
    created-at: uint,
    created-by: principal
  }
)

;; Add a new compliance requirement
(define-public (add-requirement
    (requirement-id (string-ascii 64))
    (source-id (string-ascii 64))
    (title (string-ascii 100))
    (description (string-utf8 500))
    (effective-date uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (asserts! (is-none (map-get? requirements { requirement-id: requirement-id })) (err u2))
    (ok (map-set requirements
      { requirement-id: requirement-id }
      {
        source-id: source-id,
        title: title,
        description: description,
        effective-date: effective-date,
        created-at: block-height,
        created-by: tx-sender
      }
    ))
  )
)

;; Get requirement details
(define-read-only (get-requirement (requirement-id (string-ascii 64)))
  (map-get? requirements { requirement-id: requirement-id })
)

;; Update admin (admin only)
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (ok (var-set admin new-admin))
  )
)
