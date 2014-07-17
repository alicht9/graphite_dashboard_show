require "graphite_slideshow/graphite_client"
require "graphite_slideshow/dashboard"
require "core_ext/hash"
require "tempfile"
require "RMagick"

class GraphiteSlideshow
  include Magick

  def initialize options={}
    @options = options.symbolize_keys!
    @graphite_client = GraphiteClient.new graphite_host: @options[:graphite_host]
  end

  def go!
    dashboards[0].load! #gotta kick the first one off by hand
    while true
      dashboards.each_with_index do |dashboard, idx|
        threads = []

        threads << Thread.new { display_dashboard dashboard }
        threads << Thread.new { preload_next_dashboard idx }

        threads.each &:join
      end
    end
  end

  private

  def dashboards
    @dashboards ||= @options[:dashboards].collect do |dashboard|
      Dashboard.new(
        name: dashboard,
        graphite_client: @graphite_client,
        graph_width:  @options[:graph_width],
        graph_height: @options[:graph_height],
      )
    end
  end

  def display_images tmpfiles, time_to_wait
    file_paths = tmpfiles.collect &:path
    list = ImageList.new(*file_paths)
    list.delay = time_to_wait*100
    list.iterations = 1
    list.animate
  end

  def display_dashboard dashboard
    display_images(dashboard.images, @options[:time_per_graph])
    dashboard.cleanup!
  end

  def preload_next_dashboard current_idx
    next_index = (current_idx == (@dashboards.count - 1)) ? 0 : current_idx + 1
    dashboards[next_index].load!
  end

end
