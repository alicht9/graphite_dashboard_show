require "httparty"
require "uri"

class GraphiteClient
  include HTTParty

  def initialize options={}
    self.class.base_uri options[:graphite_host]
  end

  def load_dashboard dashboard_name
    self.class.get "/dashboard/load/#{URI.encode(dashboard_name)}"
  end

  def download_graph! url, tmpfile
    File.open(tmpfile, 'wb') do |f|
      f.write retrieve_graph(url)
    end
  end

  def retrieve_graph url
    self.class.get(url).parsed_response
  end

  def dashboard_graph_urls dashboard_name
    get_urls load_dashboard(dashboard_name)
  end

  def get_urls dashboard
    render_urls = dashboard['state']['graphs'].collect &:last
    return render_urls if render_urls[0].is_a?(String) && render_urls[0].match(/^\/render\?/)
    construct_render_urls(dashboard)
  end

  def construct_render_urls dashboard
    #So apparently not all dashboards in our graphite are stored the same way.
    #Anything in here doesn't have the '/render?...' url in the response, so we
    #have to munge everything together our selves. I <3 graphite, don't you?
   default_params = dashboard['state']['defaultGraphParams'] 
   dashboard['state']['graphs'].collect do |graph|
     combined_graph = graph[-1].merge! default_params
     "/render?#{URI.encode_www_form(combined_graph)}"
   end
  end
end
