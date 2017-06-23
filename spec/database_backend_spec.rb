describe DatabaseBackend do
  it "should return return database instance" do
    cache = {"db:mongodb://localhost/call-tracking" => {}}
    env = create_env({}, cache)
    backend = DatabaseBackend.new(create_app())
    backend.call(env)
    expect(env["database"]).not_to be_nil
  end
  it "should create indexes" do
    double("Mongo::Client")
    get_mock_collection = Proc.new do |name|
      indexes = double("#{name}Indexes")
      c = double("#{name}Collection")
      allow(c).to receive(:indexes) {indexes}
      allow(indexes).to receive(:create_many).with(any_args).once
      c
    end
    client = {
      "Call" => get_mock_collection.call("Call"),
      "PhoneNumber" => get_mock_collection.call("PhoneNumber")
    }
    allow(Mongo::Client).to receive(:new) { client }
    env = create_env()
    backend = DatabaseBackend.new(create_app())
    backend.call(env)
    backend.call(env)
  end
end
