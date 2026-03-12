# Bookworms — Project Specs

## Overview

Bookworms is a social reading app inspired by fitness communities like Gym Rats. Users connect with others through **book clubs**, log their daily reading, and compete to see who reads the most each month.

## Core Features

- **Users** connect with other users via book clubs
- **Book clubs** are groups where members log reading sessions
- **Monthly competition** — at the end of each month, a winner is determined based on books read (or total reading time)
- **Reading sessions** — users log what they read: book title, amount (pages or time), and date

---

## Data Model (PostgreSQL / Ecto)

| Schema                  | Purpose                                                                                                                         |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------- | -------------------- |
| `users`                 | id, email, name, google_uid (nullable), inserted_at, updated_at                                                                 |
| `book_clubs`            | id, name, invite_code (unique, 6–8 chars), owner_id, inserted_at, updated_at                                                    |
| `book_club_memberships` | user_id, book_club_id, role (:member                                                                                            | :owner), inserted_at |
| `reading_sessions`      | id, user_id, book_club_id, book_name, amount (integer — pages or minutes), unit (:pages \| :minutes), session_date, inserted_at |

**Indexes to consider:** `invite_code`, `(user_id, book_club_id)`, `(book_club_id, session_date desc)`, `(book_club_id, user_id)` for monthly leaderboard queries.

---

## Authentication

- **Google OAuth** — primary login; account auto-created on first sign-in
- No password login in v1 (optional later)

---

## UI / Screens (Phoenix LiveView)

### 1. Login screen

- Sign in with Google button
- Redirect to book clubs after auth

### 2. Book clubs screen

- Lists all book clubs the user belongs to
- Actions:
  - **Join club** — enter invite code (modal or form)
  - **Create club** — new club with auto-generated invite code

### 3. Book club detail (inside a club)

- **Feed** — chronological list of reading sessions from all members
- Each session shows: book name, amount read, unit (pages/minutes), date, user name
- **Log session** — form to add a new reading session (book name, amount, unit, date)
- **Monthly leaderboard** — ranked by total read for current month
- **Winner badge** — previous month’s winner highlighted

---

## Tech Stack

- **Backend:** Phoenix (Elixir)
- **Database:** PostgreSQL via Ecto
- **Frontend:** LiveView + Tailwind
- **Auth:** OAuth2 (e.g. `ueberauth` + `ueberauth_google`)

---

## Open Questions

1. **Metric:** Compete by pages read, minutes read, or number of books finished?
2. **Invite flow:** Should invite codes expire? Invite links?
3. **Units:** Support both pages and minutes, or standardize on one?
