;; MentorChain - Professional mentorship hours tracking and recognition platform
;; Version: 1.0.0

(define-data-var program-coordinator principal tx-sender)
(define-data-var total-mentorship-hours uint u0)
(define-data-var recognition-multiplier uint u25) ;; recognition points per hour
(define-data-var last-recognition-cycle uint u0)

(define-map mentor-contributions principal uint)
(define-map mentor-specializations principal (string-utf8 64))
(define-map specialization-approvals (string-utf8 64) bool)

;; Error codes
(define-constant err-unauthorized-coordinator (err u1200))
(define-constant err-coordinator-already-exists (err u1201))
(define-constant err-invalid-hours (err u1202))
(define-constant err-no-recognition-due (err u1203))
(define-constant err-no-contributions (err u1204))
(define-constant err-invalid-specialization (err u1205))
(define-constant err-specialization-not-approved (err u1206))

;; Verify coordinator authorization
(define-private (is-program-coordinator (caller principal))
  (begin
    (asserts! (is-eq caller (var-get program-coordinator)) err-unauthorized-coordinator)
    (ok true)))

;; Initialize mentorship tracking program
(define-public (launch-mentorship-program (coordinator principal))
  (begin
    (asserts! (is-none (map-get? mentor-contributions coordinator)) err-coordinator-already-exists)
    (var-set program-coordinator coordinator)
    (ok "MentorChain program launched successfully")))

;; Approve specialization for mentorship tracking
(define-public (approve-specialization (spec-name (string-utf8 64)))
  (begin
    (try! (is-program-coordinator tx-sender))
    (asserts! (> (len spec-name) u0) err-invalid-specialization)
    (map-set specialization-approvals spec-name true)
    (ok "Specialization approved for mentorship tracking")))

;; Register mentorship hours
(define-public (log-mentorship-hours (hours uint) (specialization (string-utf8 64)))
  (begin
    (asserts! (> hours u0) err-invalid-hours)
    (asserts! (default-to false (map-get? specialization-approvals specialization)) err-specialization-not-approved)
    
    (let ((current-hours (default-to u0 (map-get? mentor-contributions tx-sender))))
      (map-set mentor-contributions tx-sender (+ current-hours hours))
      (map-set mentor-specializations tx-sender specialization)
      (var-set total-mentorship-hours (+ (var-get total-mentorship-hours) hours))
      (ok (+ current-hours hours)))))

;; Calculate recognition points
(define-public (calculate-recognition-points)
  (begin
    (try! (is-program-coordinator tx-sender))
    (let ((current-cycle (+ (var-get last-recognition-cycle) u1))
          (total-hours (var-get total-mentorship-hours)))
      (asserts! (> total-hours (var-get last-recognition-cycle)) err-no-recognition-due)
      
      (let ((new-recognition-points (* (var-get recognition-multiplier) total-hours)))
        (var-set last-recognition-cycle current-cycle)
        (ok new-recognition-points)))))

;; Claim mentorship recognition rewards
(define-public (claim-mentorship-recognition)
  (begin
    (let ((mentor-hours (default-to u0 (map-get? mentor-contributions tx-sender))))
      (asserts! (> mentor-hours u0) err-no-contributions)
      
      (let ((total-hours (var-get total-mentorship-hours))
            (recognition-points (* (var-get recognition-multiplier) mentor-hours))
            (contribution-percentage (/ (* mentor-hours u100000) total-hours)))
        
        (let ((final-recognition (/ (* contribution-percentage recognition-points) u100000)))
          (map-delete mentor-contributions tx-sender)
          (map-delete mentor-specializations tx-sender)
          (var-set total-mentorship-hours (- (var-get total-mentorship-hours) mentor-hours))
          (ok (+ mentor-hours final-recognition)))))))

;; Read-only functions
(define-read-only (get-mentorship-hours (mentor principal))
  (default-to u0 (map-get? mentor-contributions mentor)))

(define-read-only (get-mentor-specialization (mentor principal))
  (map-get? mentor-specializations mentor))

(define-read-only (get-total-mentorship-hours)
  (var-get total-mentorship-hours))

(define-read-only (is-specialization-approved (spec-name (string-utf8 64)))
  (default-to false (map-get? specialization-approvals spec-name)))

(define-read-only (get-program-stats)
  {
    coordinator: (var-get program-coordinator),
    total-hours: (var-get total-mentorship-hours),
    recognition-multiplier: (var-get recognition-multiplier)
  })