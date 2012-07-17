This is the script to update the data on [our (Neomind Labs’) dashboard][nm-dash].

[nm-dash]: redacted

We are powering our dashboard with [Leftronic](https://www.leftronic.com/).

Update the dashboard by running

    bundle exec ruby push_leftronic_data.rb

The script fetches data from [our BigTuna CI server][ci-server] and [our Freckle time logs][our-freckle-logs]. You can run the individual files containing the code that accesses those data sources to output test data from those sources.

[ci-server]: redacted
[our-freckle-logs]: https://redacted.letsfreckle.com/time/pulse/
