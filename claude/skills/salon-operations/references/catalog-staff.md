# The menu and the professionals

Every change here is confirmed like a booking: read it back with the salon's name and ask
exactly **"¿Me confirmas el cambio en el menú?"**; one call after a clear yes.

## Reading

- `search_services`: the services ONE salon sells — name, duration and price (a string in the
  salon's currency; never convert), each with a selection; optionally filtered by name. Active
  services only by default; `include_inactive=True` finds a disabled one for management — read
  `is_active` and never offer an inactive service for booking.
- `list_staff`: the professionals, each with a selection (and her email or work handle, which is
  how you tell two people with the same name apart).

## Add a service ("agrega 'balayage', dos horas y media, 1,800")

`create_service` from what the user dictated: the name in their words, the duration in minutes
(5 to 1440), the price as a fixed-decimal string in the salon's own currency — **never ask for or
pass a currency**. Optional `aftercare_notes` (≤1000 characters): the salon's care text for after
the service, in the user's words — never invent one. Read it back ("Balayage, 150 minutos,
$1,800, en Salón Centro") → the confirmation question → one call. If a service with that name and
price already exists, SALON answers that one and nothing is duplicated.

## Change a service ("sube el corte a 300")

`update_service` with the selection from `search_services`; change ONLY what the user named —
price, duration, name or `aftercare_notes` ("" clears it). Read back the change ("Corte: de 250
a 300, en Salón Centro") → the confirmation question → one call.

## Stop offering a service ("ya no hagas uñas acrílicas")

`deactivate_service`, never a deletion and never a price change; existing appointments stay as
they are. Read back the service, that it becomes inactive, and the salon → the confirmation
question → one call. Report deactivated only after the returned `is_active` is false.

## Who does what ("que Ana también haga color", "quítale el balayage a Sofía")

`assign_service_staff` / `unassign_service_staff` with a service selection and one or more
professional selections from `list_staff`. Only the named relationships change; every other
assignment, every other person and the existing appointments stay. Read back the service, the
professionals and whether each is assigned or unassigned, name the salon → the confirmation
question → one call. A partial answer lists `completed_staff`, `unverified_staff` and
`not_attempted_staff`: report only the verified changes as done — never "everything changed" or
"nothing changed".
