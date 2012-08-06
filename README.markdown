This is the script to update the data on [our (Neomind Labs’) dashboard][nm-dash].

[nm-dash]: redacted

We are powering our dashboard with the [Leftronic](https://www.leftronic.com/) service.

Update the dashboard by running one of the `update` scripts in `bin/`. Use Ctrl+C to stop the `forever` version after you’ve started it.

The script fetches data from [our BigTuna CI server][our-ci-server] and [our Freckle time logs][our-freckle-logs]. You can run the individual files `bigtuna_ci_project_status_reader.rb` and `freckle_hours_logged_reader.rb` to output test data from those sources. You need to run the files with `bundle exec ruby`.

[our-ci-server]: redacted
[our-freckle-logs]: https://redacted.letsfreckle.com/time/pulse/
