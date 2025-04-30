;; Attestation Contract
;; Records certified regulatory compliance

(define-data-var admin principal tx-sender)

;; Map of compliance attestations
(define-map attestations
  { attestation-id: (string-ascii 64) }
  {
    requirement-id: (string-ascii 64),
    implementation-id: (string-ascii 64),
    attester: principal,
    attestation-date: uint,
    valid-until: uint,
    evidence-hash: (buff 32),
    notes: (string-utf8 500)
  }
)

;; Add a new attestation
(define-public (add-attestation
    (attestation-id (string-ascii 64))
    (requirement-id (string-ascii 64))
    (implementation-id (string-ascii 64))
    (valid-until uint)
    (evidence-hash (buff 32))
    (notes (string-utf8 500)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (asserts! (is-none (map-get? attestations { attestation-id: attestation-id })) (err u2))
    (ok (map-set attestations
      { attestation-id: attestation-id }
      {
        requirement-id: requirement-id,
        implementation-id: implementation-id,
        attester: tx-sender,
        attestation-date: block-height,
        valid-until: valid-until,
        evidence-hash: evidence-hash,
        notes: notes
      }
    ))
  )
)

;; Verify if an attestation is valid and not expired
(define-read-only (is-valid-attestation (attestation-id (string-ascii 64)))
  (match (map-get? attestations { attestation-id: attestation-id })
    attestation (ok (< block-height (get valid-until attestation)))
    (err u404)
  )
)

;; Get attestation details
(define-read-only (get-attestation (attestation-id (string-ascii 64)))
  (map-get? attestations { attestation-id: attestation-id })
)

;; Update admin (admin only)
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (ok (var-set admin new-admin))
  )
)
