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

## Good output

- "Mañana tienes 9 citas: 4 pendientes y 5 confirmadas; 2 entraron por la vitrina."
- "Beatriz Pérez, mañana jueves 16:00, lavado y color ($650) con María, en Salón Centro.
  ¿Me confirmas si está correcto para agendar la cita?"
- "Listo: Beatriz Pérez, mañana jueves 16:00, lavado y color con María, en Salón Centro — quedó
  pendiente. ¿La dejo confirmada?"
