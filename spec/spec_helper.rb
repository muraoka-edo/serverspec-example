require 'serverspec'
require 'pathname'
require 'net/ssh'
require 'csv'
 
include SpecInfra::Helper::Ssh
include SpecInfra::Helper::DetectOS

RSpec.configure do |c|
  #c.request_pty = true
  c.host  = ENV['TARGET_HOST']
  user    = ENV['TARGET_USER']
  options = Net::SSH::Config.for(c.host)
  #options[:password] = ENV['TARGET_PASS' ] if ENV['TARGET_ENV'] == 'production'
  options[:password] = ENV['TARGET_PASS' ] if ENV['TARGET_PASS'] == 'none'
  c.ssh   = Net::SSH.start(c.host, user, options)
  c.os    = backend.check_os
end
