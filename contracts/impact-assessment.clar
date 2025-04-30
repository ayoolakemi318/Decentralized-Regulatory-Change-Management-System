;; Impact Assessment Contract
;; Analyzes effect of regulatory changes

(define-data-var admin principal tx-sender)

;; Map of impact assessments
(define-map impact-assessments
  { assessment-id: (string-ascii 64) }
  {
    requirement-id: (string-ascii 64),
    impact-level: (string-ascii 20), ;; "HIGH", "MEDIUM", "LOW"
    affected-areas: (string-utf8 500),
    assessment-date: uint,
    assessor: principal,
    notes: (string-utf8 1000)
  }
)

;; Add a new impact assessment
(define-public (add-impact-assessment
    (assessment-id (string-ascii 64))
    (requirement-id (string-ascii 64))
    (impact-level (string-ascii 20))
    (affected-areas (string-utf8 500))
    (notes (string-utf8 1000)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (asserts! (is-none (map-get? impact-assessments { assessment-id: assessment-id })) (err u2))
    (ok (map-set impact-assessments
      { assessment-id: assessment-id }
      {
        requirement-id: requirement-id,
        impact-level: impact-level,
        affected-areas: affected-areas,
        assessment-date: block-height,
        assessor: tx-sender,
        notes: notes
      }
    ))
  )
)

;; Get impact assessment details
(define-read-only (get-impact-assessment (assessment-id (string-ascii 64)))
  (map-get? impact-assessments { assessment-id: assessment-id })
)

;; Update admin (admin only)
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (ok (var-set admin new-admin))
  )
)
