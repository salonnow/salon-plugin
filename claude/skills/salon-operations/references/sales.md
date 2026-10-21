# Sales — closed months and today

Two tools, two different things:

- **`get_monthly_sales`** — closed days and months: up to 3 salons, WHOLE months (at most 12
  with `detail='summary'`, 2 with `'full'`). Each month comes with daily rows, weekly subtotals
  and totals. Ask for the whole months that cover the question, then do every filter,
  comparison and projection yourself from the returned days.
- **`get_intraday_sales`** — TODAY, right now, for one salon: the live totals of the shifts open
  at this moment (sales, services, products, discounts, tips, paid, pending). **Provisional**
  until the shift closes — say so. When no shift is open there is no intraday figure: say so,
  never report a zero. Today's open shift is never in `get_monthly_sales`.

## Rules that make the figures true

- Money is a fixed-decimal string in the salon's own currency. Say it as returned, with the
  currency; never convert.
- **Never add up amounts from salons with different `currency` values**; compare them side by
  side.
- Each month states `coverage_status`, `data_through` and `generated_at`: never quote a
  `month_total` without saying which window it covers (`data_through`), and never present a
  partial day as final.
- An ISO week that crosses into another month is INCOMPLETE in one month's rows: fetch the
  adjacent month before comparing weeks, or say the week is partial.
- "This week vs last week", "this month vs the same month last year", "best day of the month":
  all from the daily rows, computed by you, stated with their window.
- `capability_not_enabled` means this salon keeps the monthly report out of the assistant for
  this person: say it in one sentence and move on; never guess at a figure, never speculate why,
  never tell the user to ask the owner.

## "¿Por qué vendí menos el sábado?" / "¿Cómo viene la próxima semana?"

Bring the outside world in YOURSELF: with the salon's city, country and timezone from
`list_salons`, use your own web search or knowledge for the weather, local events (concerts,
matches, fairs), public and regional holidays, paydays (quincena, fin de mes) and the school
calendar, and cross them with the days SALON returned. SALON's figures are the facts; the
outside causes are ESTIMATES — say "probablemente" or "puede explicar parte de", never state
them as SALON's data, and if you find nothing, say so rather than invent a cause. SALON never
fetches weather or events itself.

## Good output

- "Septiembre cerró en $148,320 MXN con datos hasta el 30; la mejor semana fue la del 15 al 21
  ($41,900). Comparado con agosto ($139,100), subió 6.6 %."
- "Hoy llevas $6,450 MXN en dos turnos abiertos; es provisional hasta que cierren."
- "El sábado 20 vendiste 38 % menos que los otros sábados; probablemente pesó la lluvia de la
  tarde y el partido de las 5. Es una estimación, no un dato de SALON."
