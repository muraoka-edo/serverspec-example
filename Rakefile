require 'rake'
require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'
require 'yaml'

hosts = YAML.load_file('properties.yml')

desc "Run serverspec to all hosts (=serverspec:all)"
task :spec => 'serverspec:all'

class ServerspecTask < RSpec::Core::RakeTask
  attr_accessor :target
  def spec_command
    cmd = super
    "env TARGET_HOST=#{target} #{cmd}"
  end
end

namespace :serverspec do
  desc "Run serverspec to all hosts (=spec)"
  task :all => hosts.keys.map {|host| 'serverspec:' + host }
  hosts.keys.each do |host|
    desc "Run serverspec to #{host}"
    ServerspecTask.new(host.to_sym) do |t|
      t.target = host
      t.pattern = 'spec/{' + hosts[host][:roles].join(',') + '}/*_spec.rb'
    end
  end
end
