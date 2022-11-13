# PowerYet

A mobile-friendly way to check if a given location (e.g. your home) is still suffering from a known Hydro Ottawa outage.  Hosted at [ismypowerbackyet.com](https://ismypowerbackyet.com/).

I wrote this during the [storm of May 2022](https://en.wikipedia.org/wiki/May_2022_Canadian_derecho), but the idea had been rolling around in my brain in various forms (including some early attempts) during previous Ottawa storms and outages.  The idea was to help people who were "in exile" from their no-power home and wanted to check if it was time to go home yet — especially if they were on mobile, and/or were trying to conserve battery life and wanted something less intensive than [the full Hydro Ottawa outage map](https://hydroottawa.com/en/outages-safety/outage-centre).

Unfortunately, it became clear during that outage that Hydro Ottawa's updating of the map was not exactly in real-time, and that major events (like the May 2022 storm) might even involve them taking down the outage map entirely because they just don't have the time to update it.  As such, I abandoned my plans to develop this app further — for example, making some sort of notification system that would send people SMS updates when their outage status changed.

I'm leaving the site up, because it might come in handy someday, but I don't think I'll be working on it much any more.  That said, there's still a few things I might do just for practice & completeness; see the [TODO](#todo) section below.

## Installation

* Set up a local Postgres server, with PostGIS extensions
* Install dependencies with `mix deps.get`
* Create and migrate your database with `mix ecto.setup`
* Start the web endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
Outage data will be downloaded 5 minutes after starting, and every 5 minutes thereafter.

## TODO

* ~~Finally write a README~~
* Write some actual tests.  Notable things to test:
  * Import some sample data
  * Import some different data, make sure adds & updates & deletions occur
  * Test search at various locations
  * Check that `status.last_import_at` is being updated, and displayed in the page footer
* Add some sort of monitoring to detect if/when imports break.
  * Probably just a URL that returns "number of seconds since last import"
  * I can periodically fetch that, store it in my local [Datadog](https://www.datadoghq.com/), and set up an alert if it gets too high.
* Consider tracking the `Last-Modified` header from Hydro Ottawa.
  * This would allow for more accurate reporting of the age of the data on each page.
  * Could also be useful for monitoring, e.g. if Hydro Ottawa changes the URL and abandons (rather than deletes) the old one.
