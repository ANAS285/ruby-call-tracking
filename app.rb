require "bundler"
Bundler.require

require "./websocket_backend"
require "./bandwidth_backend"


class CallTrackingApp < Sinatra::Base
  use BandwidthBackend
  use WebsocketBackend

  set :public_dir, File.join(File.dirname(__FILE__), "public")

  get "/" do
    redirect "/index.html"
  end

  post "/bandwidth/callback/call" do

  end

end
