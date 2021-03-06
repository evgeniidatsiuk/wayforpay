require 'bundler/setup'
require 'wayforpay'
require 'webmock/rspec'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    WebMock.disable_net_connect!
  end

  config.after(:suite) do
    WebMock.allow_net_connect!
  end
end
