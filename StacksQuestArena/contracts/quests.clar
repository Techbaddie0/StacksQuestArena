;; StacksQuestArena - A blockchain-based game on Stacks
;; Contract for player registration and character creation

;; Define data maps
(define-map players 
  { wallet: principal } 
  { 
    username: (string-utf8 20),
    registered-at: uint,
    character-count: uint
  }
)

(define-map usernames 
  { username: (string-utf8 20) } 
  { owner: principal }
)

(define-map characters 
  { id: uint } 
  {
    owner: principal,
    name: (string-utf8 20),
    health: uint,
    attack: uint,
    defense: uint,
    created-at: uint,
    level: uint
  }
)

;; Define variables
(define-data-var next-character-id uint u1)

;; Error codes
(define-constant ERR-NOT-REGISTERED u100)
(define-constant ERR-ALREADY-REGISTERED u101)
(define-constant ERR-USERNAME-TAKEN u102)
(define-constant ERR-CHARACTER-NOT-FOUND u103)
(define-constant ERR-NOT-OWNER u104)
(define-constant ERR-INVALID-HEALTH u200)
(define-constant ERR-INVALID-ATTACK u201)
(define-constant ERR-INVALID-DEFENSE u202)
(define-constant ERR-INVALID-NAME u203)

;; Read-only functions

;; Check if a player is registered
(define-read-only (is-registered (wallet principal))
  (is-some (map-get? players {wallet: wallet}))
)

;; Check if a username is taken
(define-read-only (is-username-taken (username (string-utf8 20)))
  (is-some (map-get? usernames {username: username}))
)

;; Get player information
(define-read-only (get-player-info (wallet principal))
  (map-get? players {wallet: wallet})
)

;; Get character information
(define-read-only (get-character (id uint))
  (map-get? characters {id: id})
)

;; Helper function to check if a character is owned by a specific wallet
(define-private (is-character-owned-by (id uint) (wallet principal))
  (let ((char (get-character id)))
    (and (is-some char) 
         (is-eq (get owner (unwrap-panic char)) wallet))
  )
)

;; Helper function to validate character name
(define-private (is-valid-name (name (string-utf8 20)))
  ;; Name must not be empty and must be at least 3 characters
  (>= (len name) u3)
)

;; Get characters owned by a player (simplified approach)
(define-read-only (get-player-characters (wallet principal))
  (if (is-registered wallet)
    (ok (list 
          (if (is-character-owned-by u1 wallet) u1 u0)
          (if (is-character-owned-by u2 wallet) u2 u0)
          (if (is-character-owned-by u3 wallet) u3 u0)))
    (err ERR-NOT-REGISTERED)
  )
)

;; Public functions

;; Register a new player
(define-public (register-player (username (string-utf8 20)))
  (let ((caller tx-sender))
    (if (is-registered caller)
      (err ERR-ALREADY-REGISTERED)
      (if (is-username-taken username)
        (err ERR-USERNAME-TAKEN)
        (if (is-valid-name username)
          (begin
            (map-set players 
              {wallet: caller} 
              {
                username: username,
                registered-at: block-height,
                character-count: u0
              }
            )
            (map-set usernames 
              {username: username} 
              {owner: caller}
            )
            (ok true)
          )
          (err ERR-INVALID-NAME)
        )
      )
    )
  )
)

;; Create a new character
(define-public (create-character 
                (name (string-utf8 20)) 
                (health uint) 
                (attack uint) 
                (defense uint))
  (let ((caller tx-sender)
        (next-id (var-get next-character-id))
        (player-info (get-player-info caller)))
    
    ;; Check if player is registered
    (if (is-none player-info)
      (err ERR-NOT-REGISTERED)
      ;; Validate all input parameters
      (if (not (is-valid-name name))
        (err ERR-INVALID-NAME)
        (if (or (< health u10) (> health u100))
          (err ERR-INVALID-HEALTH)
          (if (or (< attack u5) (> attack u50))
            (err ERR-INVALID-ATTACK)
            (if (or (< defense u5) (> defense u50))
              (err ERR-INVALID-DEFENSE)
              (begin
                ;; Create new character with validated inputs
                (map-set characters 
                  {id: next-id} 
                  {
                    owner: caller,
                    name: name,
                    health: health,
                    attack: attack,
                    defense: defense,
                    created-at: block-height,
                    level: u1
                  }
                )
                
                ;; Update player's character count
                (map-set players 
                  {wallet: caller} 
                  (merge (unwrap-panic player-info)
                         {character-count: (+ u1 (get character-count (unwrap-panic player-info)))}
                  )
                )
                
                ;; Increment next character ID
                (var-set next-character-id (+ next-id u1))
                
                (ok next-id)
              )
            )
          )
        )
      )
    )
  )
)

;; Initialize contract
(begin
  ;; Set initial character ID
  (var-set next-character-id u1)
)