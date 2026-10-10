# Birthdays

`list_upcoming_client_birthdays` answers "¿quién cumple años?" for the coming days (1 to 31,
default 7) in the salon's own calendar: name, month and day, the date it falls on, and a client
selection each. **Never the year, never contact data.** Read them out briefly and offer two
things: to book, or to prepare a greeting the user sends herself. You send nothing.

## A greeting or an offer ("mándales un saludo de cumpleaños con 50 % si su último servicio fue manicure, 40 % a las demás")

1. `list_upcoming_client_birthdays` with the window the user means.
2. For a conditional offer you need each client's last service: the birthday rows already carry
   `last_service_name` and `last_service_date` — use them. If a row has none, say so and ask
   which offer she gets; never guess, and never look it up through another audience tool (a
   different tool answers a different population).
3. Write **one distinct message per client**: her name, the birthday wish, the offer that applies
   to HER, its expiry if the user set one, and — because it is promotional — the closing line
   **"si prefieres no recibir promos, dime y te quito"**. About 400 characters, different
   wording each.
4. Show two or three, say how many there are and who was left out (`no_contact`), and ask exactly
   **"¿Dejo estos mensajes en la cola de WhatsApp de la app?"** → clear yes →
   `queue_whatsapp_messages` once, with `campaign` (e.g. "Cumpleaños octubre"), `offer_text` and
   `offer_expires` per message, and `share_with` / `share_with_roles` if the user named who
   sends. **At most 50 messages per call and 1,000 characters per text:** more than 50 clients
   → batches of at most 50, each shown and approved with the same question, one call per batch.
5. Say where the messages went and with whom they were shared; give the `send_links` only if the
   user wants to send from the chat.

## Book for a birthday client ("agéndale a la primera")

The selection from `list_upcoming_client_birthdays` goes straight to `check_availability` and
`create_booking` — see `bookings.md` for the read-back and the confirmation question.
