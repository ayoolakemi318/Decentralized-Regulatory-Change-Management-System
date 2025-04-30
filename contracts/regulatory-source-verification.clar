;; Regulatory Source Verification Contract
;; Validates legitimate regulatory authorities

(define-data-var admin principal tx-sender)

;; Map of verified regulatory sources
(define-map regulatory-sources
  { source-id: (string-ascii 64) }
  {
    name: (string-ascii 100),
    jurisdiction: (string-ascii 50),
    verified: bool,
    verification-date: uint,
    verifier: principal
  }
)

;; Add a new regulatory source (admin only)
(define-public (add-regulatory-source
    (source-id (string-ascii 64))
    (name (string-ascii 100))
    (jurisdiction (string-ascii 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (asserts! (is-none (map-get? regulatory-sources { source-id: source-id })) (err u2))
    (ok (map-set regulatory-sources
      { source-id: source-id }
      {
        name: name,
        jurisdiction: jurisdiction,
        verified: true,
        verification-date: block-height,
        verifier: tx-sender
      }
    ))
  )
)

;; Verify if a regulatory source exists and is verified
(define-read-only (is-verified-source (source-id (string-ascii 64)))
  (match (map-get? regulatory-sources { source-id: source-id })
    source (ok (get verified source))
    (err u404)
  )
)

;; Get regulatory source details
(define-read-only (get-source-details (source-id (string-ascii 64)))
  (map-get? regulatory-sources { source-id: source-id })
)

;; Update admin (admin only)
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (ok (var-set admin new-admin))
  )
)
