require "graphite_slideshow/graphite_client"
require "core_ext/hash"
require "tempfile"
require "RMagick"

class GraphiteSlideshow
  include Magick

def initialize options={}
  @options = options.symbolize_keys!
end

def display_images tmpfiles, time_to_wait
  file_paths = tmpfiles.collect &:path
  list = ImageList.new(*file_paths)
  list.delay = time_to_wait*100
  list.iterations = 1
  list.animate
end

def go!
  @graphite_client = GraphiteClient.new graphite_host: @options[:graphite_host]

  while true
    @options[:dashboards].each do |dashboard_name|
      tmpfiles = []
      begin
        @graphite_client.dashboard_graph_urls(dashboard_name).each do |graph_url|
          #Either override or add in the sizes we want for the graph
          graph_url << "&width=#{@options[:graph_width]}"   unless graph_url.gsub!(/width=\d+/,  "width=#{@options[:graph_width]}")
          graph_url << "&height=#{@options[:graph_height]}" unless graph_url.gsub!(/height=\d+/, "height=#{@options[:graph_height]}")

          graph_png = Tempfile.new("graphite.render")
          @graphite_client.download_graph!(graph_url, graph_png.path)

          tmpfiles << graph_png
        end
        display_images(tmpfiles, @options[:time_per_graph])
      ensure
        tmpfiles.each do |file|
          file.close
          file.unlink #not really needed after close, but we'll be explicit rather than rely on GC
        end
      end
    end
  end
end

end
