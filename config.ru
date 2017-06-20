require "rack/moneta_store"
require "./app"

use Rack::MonetaStore, :Memory, cache: true

use lambda do |env|
  db = Mongo::Client.new(ENV["DATABASE_URL"] || ENV["MONGODB_URI"] || "mongodb://localhost/call-tracking")
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
  env["database"] = db
end

run CallTrackingApp
