# Clients — the portfolio, the best ones, adding and changing a record

## The portfolio ("¿cómo va mi cartera de clientas?")

`get_client_insights` answers it in ONE read: how many active clients; how they split into new,
regular, VIP, at risk and dormant; the ten best by lifetime spend (name, visits, last visit;
spend only with the sales permission — say so if absent); and the ten longest away among those
who have not come back in 90 days (name, masked phone, last visit). Each comes with a selection,
so "llámala" or "agéndale" goes straight on. This insight exists only here, not in the app. The
segments are COUNTS: for WHO to write to, use `preview_crm_audience` (see
`outreach-rebooking.md`).

## The best clients ("¿quiénes son mis mejores clientas?")

`rank_clients` by LIFETIME spending or visits (up to 10): say they are lifetime figures, never
this month's. Selections included, so "agéndale a la primera" goes to `check_availability`.

## Tags

`list_client_tags`: the words this salon uses, most used first, with counts — never a client.
Use it when the user wants to tag a client, or when a tag was refused. `automatic` tags are
computed by SALON and never set by hand; a new tag is added in the app.

## Add a client ("agrégame a Juana Pérez, su cel es 477 841 3630, cumple el 16 de agosto")

1. Read back the name, the **FULL phone number exactly as the user dictated it**, and the
   birthday (month and day), the gender in THEIR words and the tags, if given — it is their own
   dictation, and reading it whole is how a wrong digit is caught — and ask exactly
   **"¿La guardo así?"**.
2. A clear yes → `create_client` once. Gender is an IDENTIFIER: map hombre / mujer / no binario /
   prefiere no decir to `male` / `female` / `non_binary` / `prefer_not_to_say`, never pass the
   user's word. A tag must ALREADY exist in the salon: pass the word as they said it; the tool
   matches the salon's spelling and refuses a word that is not a tag — then say so, offer
   `list_client_tags`, and never invent one.
3. If SALON answers that the phone already belongs to somebody, read those names back (masked)
   and let the user pick — nothing was created or merged; a picked candidate is a client
   selection you can book with at once.

## Change a client ("cámbiale el teléfono a Juana", "anótale que prefiere las tardes")

The client is a selection from `search_client`. Read the change back ("Juana P.: teléfono
termina en 30 → 477 841 3645" — the current number came FROM SALON and stays masked; the new
one is the user's dictation and is read back whole) and ask exactly **"¿Lo cambio así?"**. A
clear yes → `update_client` ONCE, with ONLY the fields named: a repeated call adds a note again.

- A phone or email the client herself verified cannot be changed here — say it is done in the
  app.
- A note is ADDED after the salon's notes, never replaces them, and must carry no health or
  personal detail.
- Tags: ADD only (ones the salon already uses); removing one is done in the app.
- Gender as an identifier, read back in the user's words.

## Phone numbers, by source

A number that comes FROM SALON (a search result, a candidate, the answer to a write) arrives
masked to its last two digits and is never reconstructed, guessed or read out. A number the user
dictated in this conversation is theirs and is read back whole.
