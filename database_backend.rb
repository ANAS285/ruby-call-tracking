require "./helper"

Mongo::Logger.logger.level = ::Logger::FATAL

class DatabaseBackend
  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call(env) if env["database"]
    url = ENV["DATABASE_URL"] || ENV["MONGODB_URI"] || "mongodb://localhost/call-tracking"
    db = Mongo::Client.new(url)
    get_from_cache env, "db:#{url}", lambda {
      # Call only once
      db["PhoneNumber"].indexes().create_many([
        { key: { number: 1 }},
        { key: { deleted: 1 }},
        { key: { created: -1 }}
      ])
      db["Call"].indexes().create_many([
        { key: { time: -1 }},
        { key: { callId: 1 }},
        { key: { transferedCallId: 1 }},
        { key: { state: 1 }},
        { key: { phoneNumber: 1 }}
      ])
      db
    }
    env["database"] = db
    @app.call(env)
  end
end
