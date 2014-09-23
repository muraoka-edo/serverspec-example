require 'rake'
require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'
require 'json'

servers = JSON.parse(File.read('properties.json'))

desc "Run serverspec to all servers"
task :spec => 'serverspec:all'

class ServerspecTask < RSpec::Core::RakeTask
  attr_accessor :target_host, :target_env

  def spec_command
    cmd = super
    "env TARGET_HOST=#{target_host} \
         TARGET_ENV=#{ target_env } \
    #{cmd}"
  end
end

namespace :serverspec do
  task :all => servers.map {|s| 'serverspec:' + s['host'] }
  servers.each do |server|
    desc "Run serverspec to #{server['host']}"
    ServerspecTask.new(server['host'].to_sym) do |t|
      t.target_host = server['host']
      t.target_env  = server['env' ]
      t.pattern = 'spec/{' + server['roles'].join(',') + '}/*_spec.rb'
    end
  end
end
