require "json"
describe CallTrackingApp do
  before :each do
    double("Bandwidth::Client")
    double("Bandwidth::Application")
    double("Bandwidth::Call")
    double("Bandwidth::NumberInfo")
    @client = double("MockClient")
    allow(Bandwidth::Client).to receive(:new).with(any_args).and_return(@client)
    app = double({id: "appId", name: "CallTracking on localhost"})
    allow(Bandwidth::Application).to receive(:list).with(@client, {size: 1000}).and_return([app])
    @db = create_db()
    @make_event_handler_request = Proc.new do |data|
      env = create_env({"database" => @db, "SERVER_NAME" => "localhost"})
      app = CallTrackingApp.new()
      json = data.to_json()
      env = Rack::MockRequest.env_for("/bandwidth/callback/call", {method: "POST", input: json, "CONTENT_LENGTH" => json.length.to_s, "CONTENT_TYPE" => "application/json"}).merge(env)
      res = app.call(env)
      expect(res[0]).to eql(200)
      res
    end
  end

  it "should show index page on GET /" do
    env = create_env({"database" => @db, "SERVER_NAME" => "localhost"})
    env = Rack::MockRequest.env_for("/", {method: "GET"}).merge(env)
    app = CallTrackingApp.new()
    res = app.call(env)
    expect(res[0]).to eql(302)
    expect(res[1]["Location"].end_with?("/index.html")).to be true
  end

  it "should handle answer event (ringing)" do
    number = {_id: "id", forwardTo: "+1234567890"}
    app = {id: "appId", incoming_call_url: "http://localhost"}
    call = double()
    allow(@db["PhoneNumber"]).to receive(:find).with({number: "+1234567892"}, {limit: 1}).and_return([number])
    allow(Bandwidth::Application).to receive(:get).with(@client, "appId").and_return(app)
    allow(Bandwidth::Call).to receive(:get).with(@client, "callId").and_return(call)
    allow(call).to receive(:update).with({
      state: "transferring",
      transfer_caller_id: "+1234567891",
      transfer_to: "+1234567890",
      callback_url: "http://localhost"
    }).and_return("transferedCallId")
    allow(Bandwidth::NumberInfo).to receive(:get).with(@client, "+1234567891").and_return({name: "cnam"})
    allow(@db["Call"]).to receive(:insert_one).with(hash_including({
      fromNumber: "+1234567891",
      callId: "callId",
      transferedCallId: "transferedCallId",
      phoneNumber: "id",
      fromCName: "cnam",
      state: "ringing"
    }))
    @make_event_handler_request.call({"eventType" => "answer", "callId" => "callId", "to" => "+1234567892", "from" => "+1234567891"})
  end

  it "should handle answer event (active)" do
    number = {_id: "id", forwardTo: "+1234567890"}
    app = {id: "appId", incoming_call_url: "http://localhost"}
    call = double()
    allow(@db["PhoneNumber"]).to receive(:find).with({number: "+1234567892"}, {limit: 1}).and_return([number])
    allow(@db["PhoneNumber"]).to receive(:find).with({number: "+1234567890"}, {limit: 1}).and_return([])
    allow(Bandwidth::Application).to receive(:get).with(@client, "appId").and_return(app)
    allow(Bandwidth::Call).to receive(:get).with(@client, "callId").and_return(call)
    allow(call).to receive(:update).with({
      state: "transferring",
      transfer_caller_id: "+1234567891",
      transfer_to: "+1234567890",
      callback_url: "http://localhost"
    }).and_return("transferedCallId")
    allow(Bandwidth::NumberInfo).to receive(:get).with(@client, "+1234567891").and_return({name: "cnam"})
    allow(@db["Call"]).to receive(:insert_one).with(hash_including({
      fromNumber: "+1234567891",
      callId: "callId",
      transferedCallId: "transferedCallId",
      phoneNumber: "id",
      fromCName: "cnam",
      state: "ringing"
    }))
    @make_event_handler_request.call({"eventType" => "answer", "callId" => "callId", "to" => "+1234567892", "from" => "+1234567891"})
    allow(@db["Call"]).to receive(:update_one).with({callId: "callId"}, {"$set" => {state: "active"}})
    allow(@db["Call"]).to receive(:find).with({callId: "callId"}, {limit: 1}).and_return([{}])
    @make_event_handler_request.call({"eventType" => "answer", "callId" => "transferedCallId", "to" => "+1234567890", "from" => "+1234567891"})
  end

  it "should handle hangup event" do
    call = {time: "2017-06-26T09:44:32Z", _id: "id"}
    allow(@db["Call"]).to receive(:find).with({"$or" => [{callId: "callId"}, {transferCallId: "callId"}], state: {"$ne" => "completed"}}, {limit: 1}).and_return([call])
    allow(@db["Call"]).to receive(:update_one).with({_id: "id"}, {"$set" => {state: "completed", duration: "00:00:10"}})
    @make_event_handler_request.call({"eventType" => "hangup", "callId" => "callId", "time" => "2017-06-26T09:44:42Z"})
  end

end
