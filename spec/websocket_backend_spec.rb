describe WebsocketBackend do
  run_message_handler = nil
  before :each do
    double("Faye::WebSocket")
    run_message_handler = lambda {|socket, env, json|
      allow(Faye::WebSocket).to receive(:websocket?) { true }
      allow(Faye::WebSocket).to receive(:new) { socket }
      allow(socket).to receive(:rack_response)
      message_handler = nil
      allow(socket).to receive(:on) {|event, &handler|
        message_handler = handler if event == :message
      }
      backend = WebsocketBackend.new(create_app())
      backend.call(env)
      event = double({data: json})
      message_handler.call(event)
    }
  end

  it "should handle websocket requests" do
    run_message_handler.call(double("socket"), create_env(), '{"command": "test"}')
  end

  it "should handle command 'load-phone-numbers'" do
    socket = double("socket")
    db = create_db()
    allow(socket).to receive(:send).with("{\"command\":\"load-phone-numbers\",\"result\":[{\"_id\":\"123\",\"id\":\"123\"}]}").and_return(nil)
    allow(db["PhoneNumber"]).to receive(:find).with({}, {sort: {created: -1, deleted: 1}}).and_return([{_id: "123"}])
    env = create_env({"database" => db});
    run_message_handler.call(socket, env, '{"command": "load-phone-numbers"}')
  end

  it "should handle command 'load-calls'" do
    socket = double("socket")
    db = create_db()
    allow(socket).to receive(:send).with("{\"command\":\"load-calls\",\"result\":[{\"_id\":\"123\",\"id\":\"123\"}]}").and_return(nil)
    allow(db["Call"]).to receive(:find).with({phoneNumber: "123"}, {sort: {time: -1}}).and_return([{_id: "123"}])
    env = create_env({"database" => db});
    run_message_handler.call(socket, env, '{"command": "load-calls", "payload": {"id": "123"}}')
  end
end
