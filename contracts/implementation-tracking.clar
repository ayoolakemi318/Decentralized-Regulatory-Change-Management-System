;; Implementation Tracking Contract
;; Monitors compliance activities

(define-data-var admin principal tx-sender)

;; Map of implementation activities
(define-map implementations
  { implementation-id: (string-ascii 64) }
  {
    requirement-id: (string-ascii 64),
    status: (string-ascii 20), ;; "NOT_STARTED", "IN_PROGRESS", "COMPLETED"
    start-date: uint,
    completion-date: (optional uint),
    responsible-party: principal,
    notes: (string-utf8 500)
  }
)

;; Add a new implementation activity
(define-public (add-implementation
    (implementation-id (string-ascii 64))
    (requirement-id (string-ascii 64))
    (responsible-party principal)
    (notes (string-utf8 500)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (asserts! (is-none (map-get? implementations { implementation-id: implementation-id })) (err u2))
    (ok (map-set implementations
      { implementation-id: implementation-id }
      {
        requirement-id: requirement-id,
        status: "NOT_STARTED",
        start-date: block-height,
        completion-date: none,
        responsible-party: responsible-party,
        notes: notes
      }
    ))
  )
)

;; Update implementation status
(define-public (update-implementation-status
    (implementation-id (string-ascii 64))
    (status (string-ascii 20)))
  (let ((implementation (unwrap! (map-get? implementations { implementation-id: implementation-id }) (err u404))))
    (begin
      (asserts! (or (is-eq tx-sender (var-get admin)) (is-eq tx-sender (get responsible-party implementation))) (err u1))
      (ok (map-set implementations
        { implementation-id: implementation-id }
        (merge implementation {
          status: status,
          completion-date: (if (is-eq status "COMPLETED") (some block-height) (get completion-date implementation))
        })
      ))
    )
  )
)

;; Get implementation details
(define-read-only (get-implementation (implementation-id (string-ascii 64)))
  (map-get? implementations { implementation-id: implementation-id })
)

;; Update admin (admin only)
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (ok (var-set admin new-admin))
  )
)
