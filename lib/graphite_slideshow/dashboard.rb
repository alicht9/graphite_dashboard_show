class Dashboard
  def initialize options
    @name            = options[:name]
    @graphite_client = options[:graphite_client]
    @graph_width     = options[:graph_width]
    @graph_height    = options[:graph_height]
    @loaded          = false
    @tmp_files       = []
  end

  attr_reader :name, :loaded

  def images
    load! unless @loaded
    @tmp_files
  end

  def graph_urls
    @graph_urls ||= get_graph_urls
  end

  def cleanup!
    @tmp_files.each do |file|
      file.close
      file.unlink
    end
    @loaded = false
  end

  def load!
    graph_urls.each do |url|
      @tmp_files << Tempfile.new("graphite.render")
      @graphite_client.download_graph! url, @tmp_files[-1].path
    end
    @loaded = true
  end

  private

  def get_graph_urls
    @graphite_client.dashboard_graph_urls(@name).collect do |url|
      url << "&width=#{@graph_width}"   unless url.gsub!(/width=\d+/,  "width=#{@graph_width}")
      url << "&height=#{@graph_height}" unless url.gsub!(/height=\d+/, "height=#{@graph_height}")
      url
    end
  end
end
