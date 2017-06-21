require "bundler"
Bundler.require

require "rack/moneta_store"

require "./websocket_backend"
require "./bandwidth_backend"
require "./database_backend"
require "./helpers"

class CallTrackingApp < Sinatra::Base
  use Rack::PostBodyContentTypeParser
  use Rack::MonetaStore, :Memory, cache: true
  use DatabaseBackend
  use BandwidthBackend
  #use WebsocketBackend

  set :public_dir, File.join(File.dirname(__FILE__), "public")

  get "/" do
    redirect "/index.html"
  end

  post "/bandwidth/callback/call" do
    p ["/bandwidth/callback/call", params]
    cache = env["rack.moneta_store"]
    db = env["database"]
    api = env["bandwidthApi"]
    application_id = params["applicationId"]
    call_id = params["callId"]
    case(params["eventType"])
      when "answer"
        transfered_call_data = cache[call_id]
        if transfered_call_data
          cache.delete(call_id)
          Moneta::Mutex.new(cache, transfered_call_data[:mutex_name]).synchronize do
            # wait for call data to be stored in db
            puts "Call state (#{transfered_call_data[:call_id]}->#{transfered_call_data[:transfered_call_id]}): active"
            db["Call"].update({_id: transfered_call_data[:id]}, {"$set" => {state: "active"}})
          end
        end
        number = db["PhoneNumber"].find({number: params["to"]}, {limit: 1})[0]
        return unless number
        callback_url = get_from_cache env, "callback-#{application_id}", lambda do
          app = Bandwidth::Application.get(api, application_id)
          app[:incoming_call_url]
        end
        mutex_name = "transfered_call_data_#{call_id}"
        mutex = Moneta::Mutex.new(cache, mutex_name)
        mutex.synchronize do
          call = Bandwidth::Call.get(api, call_id)
          transfered_call_id = call.update({
            state: "transferring",
            transfer_caller_id: params["from"],
            transfer_to: number["forwardTo"],
            callback_url: callback_url
          })
          cache[call_id] = {
            id: number["_id"],
            call_id: call_id,
            transfered_call_id: transfered_call_id,
            mutex_name: mutex_name
          }
          puts "Call state (#{call_id}->#{transfered_call_id}): ringing"
          info = Bandwidth::NumberInfo.get(api, params["from"])
          db["Call"].insert({
            time: params["time"],
            fromNumber: params["from"],
            callId: call_id,
            transferedCallId: transfered_call_id,
            phoneNumber: number["_id"],
            fromCName: info[:name],
            state: "ringing"
          })
        end
      when "hangup"
        call = db["Call"].find(
          {"$or" => [{callId: call_id}, {transferCallId: call_id}], state: {"$ne" => 'completed'}},
          {limit: 1}
        )[0]
        if call
          seconds = Time.iso8601(params["time"]) - Time.iso8601(call["time"])
          hours = 0
          minutes = 0
          if seconds >= 60
            minutes = seconds/60
            seconds = seconds%60
          end
          if minutes >= 60
            hours = minutes/60
            minutes = minutes%60
          end
          duration = "%02d:%02d:%02d" % [hours, minutes, seconds]
          db["Call"].update({_id: call["_id"]}, {"$set" => {state: "completed", duration: duration}})
        end
    end
  end
end
