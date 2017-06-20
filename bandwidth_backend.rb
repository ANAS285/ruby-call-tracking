require "./helpers"
APPLICATION_NAME = "call-tracking"

class BandwidthBackend
  def initialize(app)
    @app = app
  end

  def call(env)
    api = Bandwidth::Client.new(ENV["BANDWIDTH_USER_ID"], ENV["BANDWIDTH_API_TOKEN"], ENV["BANDWIDTH_API_SECRET"])
    env["bandwidthApi"] = api
    host = env["SERVER_NAME"]
    env["applicationId"] = get_from_cache env, "#{APPLICATION_NAME}::#{host}", lambda do
      application_name = "#{APPLICATION_NAME} on #{host}"
      app = Bandwidth::Application.list(api, {size: 1000}).detect({|a| a.name == application_name})
      unless app
        base_url = "https://#{host}"
        app = Bandwidth::Application.create(api, {
          name: application_name,
          incoming_call_url: "#{base_url}/bandwidth/callback/call",
          auto_answer: true,
          callback_http_method: "POST"
        })
      end
      app.id
    end
    @app.call(env)
  end
end
