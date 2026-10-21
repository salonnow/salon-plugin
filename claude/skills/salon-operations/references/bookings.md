# Bookings — the agenda, by sequence

**Vocabulary.** An appointment is a *cita, reserva, agendamiento, turno* or *hora*; *agendar,
reservar* and *apartar* mean booking one; *cancelar, anular, borrar* mean cancelling; *mover,
cambiar, reagendar, reprogramar* mean moving. Bookings are **pending** by default.

## Book ("agéndale a Beatriz mañana a las 4 corte y lavado con María")

1. `list_salons` if the salon is ambiguous (several salons, or none named yet).
2. `search_client` with the name. Several matches → read them briefly and let the user pick.
   None → say so and offer `create_client` (see `clients.md`); never invent a client.
3. `search_services` for what they are having; pick the ones the user named.
4. `check_availability` with the date (the salon's day, YYYY-MM-DD) and the service selections:
   - the user named a professional → pass her selection from `list_staff`; only her free times
     come back;
   - no professional → call WITHOUT one; every free time comes back once per professional who
     can take it. Read them grouped: "a las 10 con María o con Ana, a las 11 solo con María",
     so the user picks hour and person at once.
   - two professionals share a name → `list_staff` gives each one's email or handle; ask which
     one by that ("¿la María de maria@…?"), never guess.
5. **Read the appointment back in one short message**: client, day, time, service(s) with the
   price when the catalogue gave one, professional, and the SALON by name. Ask exactly:
   **"¿Me confirmas si está correcto para agendar la cita?"**
6. A change → apply it and read it back again (nothing was booked). A no → say nothing was
   booked and stop. A clear yes → `create_booking` once, with exactly the selections confirmed.
7. Answer with the result, briefly: report the returned `status`. `booked=true` means created,
   not confirmed; say **pending** when the status is pending.

`confirmed=True` only when the user explicitly asked for an already-confirmed booking ("créala y
déjala confirmada"); include that in the read-back. A yes to the read-back never means
`confirmed=True`.

## Confirm an existing pending appointment ("confírmale la cita a Beatriz")

`find_bookings` (by client, by day, or both) → read back client, day, time, professional and
salon → ask exactly **"¿La dejo confirmada?"** → clear yes → `confirm_booking` once. Never create
another appointment to confirm one. Report confirmed only when SALON returns `status=confirmed`;
a cancelled, completed or no-show appointment cannot be confirmed here.

## Cancel ("cancélale la cita a Juanita, se enfermó")

`find_bookings` → read the one the user means back (client, day, time, professional, salon) →
ask exactly **"¿Me confirmas que cancelo esta cita?"** → clear yes → `cancel_booking` once with
`reason` as the closest code from its list ("se enfermó" → `client_unavailable`). There is no
comment field, on purpose: never pass health or personal detail anywhere; if the user dictates a
remark, say it goes in the app. A cancellation is not undone here — a new booking is made with
`create_booking`.

## Move ("cámbiale la cita de Beatriz al jueves a las 5")

1. `find_bookings` for the appointment — it hands back its selection AND one selection per
   service.
2. `check_availability` WITH those service selections, the professional, and
   `booking_selection` = this appointment. Only free times found that way can move it.
3. Read the move back — client, from day and time → to day and time, professional, salon — and
   ask exactly **"¿Me confirmas que muevo esta cita?"** → clear yes → `reschedule_booking` once.
4. In the answer, `from` is the hour as it was and `to` where the appointment now is. SALON may
   refuse (hour taken meanwhile, appointment completed or paid): relay its reason as it is.

## Read the agenda ("¿cuántas citas tengo hoy?", "¿qué hay mañana?")

`get_bookings` reads ONE salon live, up to 31 days, in the salon's timezone; with no dates it
answers today. Filter by `status` (pending = not yet confirmed by the salon) or `origin`
(`vitrina` = booked online by the customer, `mcp` = booked through this connector) when the
question is about one of them; count from `summary`. `truncated` → say the list may be
incomplete and narrow the window. Completed, no-show and cancelled appointments are read here,
not with `find_bookings` (which only returns active ones).

## Block the agenda ("bloquéame el salón de 3 a 4:30", "bloquea a María el viernes en la tarde")

**Vocabulary.** *Bloquear, cerrar, apartar un rato, poner un bloqueo*: time nobody can be booked
into. A block is salon-wide ("todo el salón") or one professional's; it has a day, a start and an
end time in the salon's own clock, and an optional title in the user's words ("junta",
"inventario", "comida"). It is not an appointment: no client, no service, no price.

1. `list_salons` if the salon is ambiguous; `list_staff` when the block is for one professional
   (pass her selection; no selection means the whole salon).
2. **Read it back in one short message**: the day, the window, the scope ("todo el salón" or
   the professional), the title if any, and the salon by name. Ask exactly:
   **"¿Me confirmas que bloqueo la agenda?"**
3. A clear yes → `block_agenda` once. Report what SALON returned.

**A repetition is one block per day, never one long block.** "Toda la semana de 3 a 4:30",
"de lunes a viernes a esa hora", "los próximos cinco días": list the days in the read-back
("martes 20, miércoles 21, jueves 22, viernes 23 y sábado 24, de 15:00 a 16:30, todo el salón"),
ask the question ONCE, and after the yes call `block_agenda` once per day, in order. Then say how
many days were blocked and name the days that were not. Do not promise a block that repeats by
itself: SALON has no recurring blocks, and each day you block is a block the user can remove by
itself later.

**An appointment in the way is never buried.** When `block_agenda` answers `blocked: false` with
`reason: appointment_in_the_way`, nothing was blocked for that day. Tell the user which
appointment(s) sit inside the window (its `conflicts` carry client, time, professional and a
selection each) and offer the three ways out, then do what she picks:
- **move it**: `check_availability` with the appointment's service selections, its professional
  and `booking_selection` = that appointment, then `reschedule_booking` after the move's own
  read-back and question;
- **cancel it**: `cancel_booking` after its read-back and question, with the closest reason;
- **ask the client to move**: write her a short WhatsApp message with `queue_whatsapp_messages`
  (a person at the salon sends it) and leave the day unblocked until she answers.
Once the window is free, block it again on her yes. Never cancel or move anything to make room
without the user choosing it.

**See and remove blocks.** `list_blocks` reads ONE salon's blocks for up to 31 days (today by
default), one professional's plus the salon-wide ones when her selection is passed. A block marked
`read_only` is a busy interval mirrored from the professional's Google Calendar: it changes in
Google, not here — say so if asked to remove it. To remove the others: read the block back (day,
window, scope, salon) and ask exactly **"¿Me confirmas que quito este bloqueo?"** → clear yes →
`remove_block` once. Removing a block frees the time; it books nothing.

## Good output

- "Mañana tienes 9 citas: 4 pendientes y 5 confirmadas; 2 entraron por la vitrina."
- "Bloqueo todo el salón el martes 20, miércoles 21, jueves 22, viernes 23 y sábado 24, de 15:00 a
  16:30, en Salón Centro. ¿Me confirmas que bloqueo la agenda?"
- "Listo: cuatro días bloqueados. El jueves 22 no, porque Beatriz tiene cita a las 15:30 con María.
  ¿La movemos, la cancelamos, o le escribo para pedirle que la cambie?"
- "Beatriz Pérez, mañana jueves 16:00, lavado y color ($650) con María, en Salón Centro.
  ¿Me confirmas si está correcto para agendar la cita?"
- "Listo: Beatriz Pérez, mañana jueves 16:00, lavado y color con María, en Salón Centro — quedó
  pendiente. ¿La dejo confirmada?"
