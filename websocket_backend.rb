require "date"
require "faye/websocket"
require "json"

class WebsocketBackend
  def initialize(app)
    @app = app
    @clients = []
    @commands = {}

    @commands["load-phone-numbers"] = Proc.new do |message, ws, api, application_id, db|
      db["PhoneNumber"].find({}, {sort: {created: -1, deleted: 1}})
    end

    @commands["create-phone-number"] = Proc.new do |message, ws, api, application_id, db|
      number = Bandwidth::PhoneNumber.list(api, {size: 1000, application_id: application_id, name: message["payload"]["forwardTo"]})[0]
      unless number
        new_number = Bandwidth:AvailableNumber.search_local(api, {area_code: message["payload"]["areaCode"], quantity: 1})[0][:number]
        number = Bandwidth::PhoneNumber.create(api, {
          name: message["payload"]["forwardTo"],
          application_id: application_id,
          number: new_number
        })
      end
      raise "Phone number is already used" if db["PhoneNumber"].find({number: new_number, deleted: {"$ne": true}}, {limit: 1})[0]
      num = {
        areaCode: message["payload"]["areaCode"],
        forwardTo: message["payload"]["forwardTo"],
        number: new_number,
        numberId: number.id,
        created: DateTime.now()
      }
      result = db["PhoneNumber"].insert_one(num)
      num.id = result._id
      num
    end

    @commands["delete-phone-number"] = Proc.new do |message, ws, api, application_id, db|
      number = db["PhoneNumber"].find({_id: message["payload"]["id"]}, {limit: 1})[0]
      raise "Phone number is not exists" unless number
      n = Bandwidth::PhoneNumber.get(api, message["payload"]["id"])
      n.delete if n
      db["PhoneNumber"].update_one({_id: message["payload"]["id"]}, {"$set": {deleted: true}})
      message["payload"]["id"]
    end

    @commands["load-calls"] = Proc.new do |message, ws, api, application_id, db|
      db["Call"].find({phoneNumber: message["payload"]["id"]}, {sort: {time: -1}}).map do |c|
        c.id = c._id
        c
      end
    end
  end

  def call(env)
    env["websockets"] = @clients
    if Faye::WebSocket.websocket?(env)
      ws = Faye::WebSocket.new(env)
      class << ws
        def send_message(message)
          self.send JSON.generate(message)
        end
      end
      ws.on :open do |event|
        p [:open, ws.object_id]
        @clients << ws
      end

      ws.on :message do |event|
        puts "Received new message #{event.data}"
        message = {}
        begin
          message = JSON.parse(event.data)
        rescue
          puts "Invalid format of received data #{event.data}"
        end
        handler = @commands[message["command"]]
        return puts "Command #{message["command"]} is not implemented" unless handler
        puts "Executing command #{message["command"]} with data #{message["payload"]}"
        begin
          result = handler.call(message, ws, env["bandwidthApi"], env["applicationId"], env["database"])
          ws.send_message({command: message["command"], result: result});
        rescue Exception => err
          ws.send_message({command: message["command"], error: err});
          puts err.backtrace
        end
      end

      ws.on :close do |event|
        p [:close, ws.object_id, event.code, event.reason]
        @clients.delete(ws)
        ws = nil
      end

      # Return async Rack response
      ws.rack_response

    else
      @app.call(env)
    end
  end
end
