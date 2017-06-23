require "rspec"
require_relative "../app"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def create_env(env = {}, cache= {})
  env["rack.moneta_store"] = cache
  env
end

def create_app()
  MockApp.new()
end

class MockApp
  def call(env)
  end
end
