describe "get_from_cache" do
  it "should return cached item" do
    env = create_env({}, {"test" => 11})
    res = get_from_cache(env, "test", lambda { 10 })
    expect(res).to eql(11)
  end
  it "should call action and save value in cache" do
    cache = {}
    env = create_env({}, cache)
    res = get_from_cache(env, "test", lambda { 10 })
    expect(res).to eql(10)
    expect(cache["test"]).to eql(10)
  end
end
