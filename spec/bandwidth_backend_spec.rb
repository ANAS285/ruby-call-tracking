describe BandwidthBackend do
  before :each do
    double("Bandwidth::Client")
    double("Bandwidth::Application")
  end

  it "should provide bandwidth api instance (create an app)" do
    client = double("MockClient")
    app = double({id: "appId"})
    ENV["BANDWIDTH_USER_ID"] = "userId"
    ENV["BANDWIDTH_API_TOKEN"] = "apiToken"
    ENV["BANDWIDTH_API_SECRET"] = "apiSecret"
    allow(Bandwidth::Client).to receive(:new).with("userId", "apiToken", "apiSecret").and_return(client)
    allow(Bandwidth::Application).to receive(:list).with(client, {size: 1000}).and_return([])
    allow(Bandwidth::Application).to receive(:create).with(client, {
      name: "CallTracking on localhost",
      incoming_call_url: "https://localhost/bandwidth/callback/call",
      auto_answer: true,
      callback_http_method: "POST"
    }).and_return(app)
    backend = BandwidthBackend.new(create_app())
    db = create_db()
    env = create_env({"database" => db, "SERVER_NAME" => "localhost"})
    backend.call(env)
    expect(env["bandwidthApi"]).to eql(client)
    expect(env["applicationId"]).to eql("appId")
  end

  it "should provide bandwidth api instance (use existing app)" do
    client = double("MockClient")
    app = double({id: "appId", name: "CallTracking on localhost"})
    ENV["BANDWIDTH_USER_ID"] = "userId"
    ENV["BANDWIDTH_API_TOKEN"] = "apiToken"
    ENV["BANDWIDTH_API_SECRET"] = "apiSecret"
    allow(Bandwidth::Client).to receive(:new).with("userId", "apiToken", "apiSecret").and_return(client)
    allow(Bandwidth::Application).to receive(:list).with(client, {size: 1000}).and_return([app])
    backend = BandwidthBackend.new(create_app())
    db = create_db()
    env = create_env({"database" => db, "SERVER_NAME" => "localhost"})
    backend.call(env)
    expect(env["bandwidthApi"]).to eql(client)
    expect(env["applicationId"]).to eql("appId")
  end
end
