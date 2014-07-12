Graphite Dashboard Slideshow
=======================

A script to cycle through all of the graphs in specified graphite dashboards and display them.
This is useful for running on team dashboard monitors.

Dependencies
=======================
<ul>
<li>HTTParty</li>

<li>Rmagick</li>
</ul>

Instalation
=======================
There exists a Gemfile in the root directory of this project, so the command `bundle install` will ensure all gems are installed and in the correct place.

Once the bundle is complete, setup your config file. There is a sample at `config/dashboards.yml.sample`

To run, simply run bin/show.rb

Rock Users
=======================
`rock build` will build the project sucessfully

`rock run` will then run the correct executables
