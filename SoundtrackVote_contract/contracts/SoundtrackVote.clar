
;; title: SoundtrackVote
;; version: 1.0.0
;; summary: A community music curation system for shared listening experiences
;; description: This contract allows users to submit, vote on, and curate music tracks
;;              for shared playlists and listening sessions

;; traits
;;

;; token definitions
;;

;; constants
;;
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-voted (err u102))
(define-constant err-insufficient-votes (err u103))
(define-constant err-track-exists (err u104))
(define-constant err-invalid-input (err u105))

;; Minimum votes required for a track to be featured
(define-constant min-votes-for-featured u10)

;; data vars
;;
(define-data-var next-track-id uint u1)
(define-data-var total-tracks uint u0)
(define-data-var contract-paused bool false)

;; data maps
;;

;; Track information
(define-map tracks
  { track-id: uint }
  {
    title: (string-ascii 100),
    artist: (string-ascii 100),
    submitter: principal,
    vote-count: uint,
    featured: bool,
    submission-time: uint
  }
)

;; User votes - tracks which users voted for which tracks
(define-map user-votes
  { user: principal, track-id: uint }
  { voted: bool }
)

;; User submission count - prevent spam
(define-map user-submissions
  { user: principal }
  { count: uint }
)

;; Featured tracks list - for easy querying
(define-map featured-tracks
  { track-id: uint }
  { featured-time: uint }
)

;; public functions
;;

;; Submit a new track for voting
(define-public (submit-track (title (string-ascii 100)) (artist (string-ascii 100)))
  (let
    (
      (track-id (var-get next-track-id))
      (current-time block-height)
      (user-submission-count (default-to u0 (get count (map-get? user-submissions { user: tx-sender }))))
    )
    (asserts! (not (var-get contract-paused)) (err u106))
    (asserts! (> (len title) u0) err-invalid-input)
    (asserts! (> (len artist) u0) err-invalid-input)
    (asserts! (< user-submission-count u5) (err u107)) ;; Max 5 submissions per user

    ;; Store track information
    (map-set tracks
      { track-id: track-id }
      {
        title: title,
        artist: artist,
        submitter: tx-sender,
        vote-count: u0,
        featured: false,
        submission-time: current-time
      }
    )

    ;; Update user submission count
    (map-set user-submissions
      { user: tx-sender }
      { count: (+ user-submission-count u1) }
    )

    ;; Update counters
    (var-set next-track-id (+ track-id u1))
    (var-set total-tracks (+ (var-get total-tracks) u1))

    (ok track-id)
  )
)

;; Vote for a track
(define-public (vote-for-track (track-id uint))
  (let
    (
      (track-data (unwrap! (map-get? tracks { track-id: track-id }) err-not-found))
      (has-voted (default-to false (get voted (map-get? user-votes { user: tx-sender, track-id: track-id }))))
      (new-vote-count (+ (get vote-count track-data) u1))
    )
    (asserts! (not (var-get contract-paused)) (err u106))
    (asserts! (not has-voted) err-already-voted)

    ;; Record the vote
    (map-set user-votes
      { user: tx-sender, track-id: track-id }
      { voted: true }
    )

    ;; Update track vote count
    (map-set tracks
      { track-id: track-id }
      (merge track-data { vote-count: new-vote-count })
    )

    ;; Check if track should be featured
    (if (and (>= new-vote-count min-votes-for-featured) (not (get featured track-data)))
      (begin
        (map-set tracks
          { track-id: track-id }
          (merge track-data { vote-count: new-vote-count, featured: true })
        )
        (map-set featured-tracks
          { track-id: track-id }
          { featured-time: block-height }
        )
        (ok { track-id: track-id, featured: true })
      )
      (ok { track-id: track-id, featured: false })
    )
  )
)

;; Remove vote from a track
(define-public (remove-vote (track-id uint))
  (let
    (
      (track-data (unwrap! (map-get? tracks { track-id: track-id }) err-not-found))
      (has-voted (default-to false (get voted (map-get? user-votes { user: tx-sender, track-id: track-id }))))
      (current-votes (get vote-count track-data))
    )
    (asserts! (not (var-get contract-paused)) (err u106))
    (asserts! has-voted (err u108))
    (asserts! (> current-votes u0) err-insufficient-votes)

    ;; Remove the vote
    (map-delete user-votes { user: tx-sender, track-id: track-id })

    ;; Update track vote count
    (let ((new-vote-count (- current-votes u1)))
      (map-set tracks
        { track-id: track-id }
        (merge track-data { vote-count: new-vote-count })
      )

      ;; Remove from featured if votes drop below threshold
      (if (and (get featured track-data) (< new-vote-count min-votes-for-featured))
        (begin
          (map-set tracks
            { track-id: track-id }
            (merge track-data { vote-count: new-vote-count, featured: false })
          )
          (map-delete featured-tracks { track-id: track-id })
          (ok { track-id: track-id, unfeatured: true })
        )
        (ok { track-id: track-id, unfeatured: false })
      )
    )
  )
)

;; Admin function to pause/unpause contract
(define-public (set-contract-pause (paused bool))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set contract-paused paused)
    (ok paused)
  )
)

;; read only functions
;;

;; Get track information
(define-read-only (get-track (track-id uint))
  (map-get? tracks { track-id: track-id })
)

;; Check if user has voted for a track
(define-read-only (has-user-voted (user principal) (track-id uint))
  (default-to false (get voted (map-get? user-votes { user: user, track-id: track-id })))
)

;; Get user submission count
(define-read-only (get-user-submission-count (user principal))
  (default-to u0 (get count (map-get? user-submissions { user: user })))
)

;; Get total number of tracks
(define-read-only (get-total-tracks)
  (var-get total-tracks)
)

;; Get next track ID
(define-read-only (get-next-track-id)
  (var-get next-track-id)
)

;; Check if track is featured
(define-read-only (is-track-featured (track-id uint))
  (is-some (map-get? featured-tracks { track-id: track-id }))
)

;; Get contract pause status
(define-read-only (is-contract-paused)
  (var-get contract-paused)
)

;; Get contract owner
(define-read-only (get-contract-owner)
  contract-owner
)

;; Get minimum votes required for featured status
(define-read-only (get-min-votes-for-featured)
  min-votes-for-featured
)

;; private functions
;;

;; Helper function to validate track exists (for internal use)
(define-private (track-exists (track-id uint))
  (is-some (map-get? tracks { track-id: track-id }))
)
