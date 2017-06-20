require "faye/websocket"
require "json"

class WebsocketBackend
  def initialize(app)
    @app = app
    @clients = []
    @commands = {}

    @commands["load-phone-numbers"] = Proc.new do |message, ws, api, applicationId, db|
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
