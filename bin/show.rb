require "graphite_slideshow/graphite_slideshow"

CONFIG = File.join(File.dirname(__FILE__), '..', 'config', 'dashboards.yml')

GraphiteSlideshow.new(YAML.load(File.open(CONFIG))).go!
