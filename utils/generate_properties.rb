#!/usr/bin/env ruby
# coding: utf-8
  
require 'json'
require 'csv'

class GenarateJsonFomatter

  def initialize
    @hostlst    = _check_config(File.expand_path('~/ops/repos/target/basic_config'))
    @properties = Array.new
    _generate_properties
  end

  def _check_config(config)
    if File.exists?(config)
      return config
    else
      puts usage
      exit 1
    end
  end

  def _generate_properties
    CSV.foreach(@hostlst, { :col_sep => ' ',
                            :headers => true,
                            :skip_blanks => true,
                          }) do |row|
      host      = row["host"    ]
      hostname  = row["hostname"]
      env       = row["env"     ]
      user      = row["user"    ]
      roles     = row["roles"   ].split(':')
      property_of = Hash.new
      property_of[:host    ] = host
      property_of[:hostname] = hostname
      property_of[:env     ] = env
      property_of[:user    ] = user
      property_of[:roles   ] = roles
      @properties << property_of
    end
  end

  def dump_json
    puts JSON.pretty_generate(@properties)
  end

  def dump_csv
    {:host=>"bastion", :hostname=>"vmcentos64key", :env=>"production", :user=>"hoge", :roles=>["base", "apache"]}

    @properties.each do |hs|
      hs.each do |k, v|
        case k
        when /^host$|^env$/
          print "#{v},"
        when /^roles$/
          puts "#{v}"
        end
      end
    end
  end

  def dump_sshconfig
    require 'erb'

    @properties.each do |hs|
      host     =''
      user     =''
      hostname =''
      env      =''
      hs.each do |k, v|
        case k
        when /^host$/
          host = v
        when /^user$/
          user = v
        when /^hostname$/
          hostname = v
        when /^env$/
          env = v
        end
      end

      erb = ERB.new(<<-EOS, nil, '-')
Host <%= host %>
    User            <%= user %>
    HostName        <%= hostname %>
    IdentityFile    ~/.ssh/id_rsa
    Port            22
    StrictHostKeyChecking no
    ConnectTimeout  3
    <%- if env == 'production' -%>
    ProxyCommand ssh bastion nc %h %p
    <%- end -%>
      EOS

      erb.run binding
    end
  end

end

if __FILE__ == $0 
  require 'optparse'

  params   = ARGV.getopts('t:')
  prg_name = File.basename(__FILE__)

  usage = <<-EOS
-------------------------
  Usage: #{prg_name} [options]
      -t TYPE( csv or json )
-------------------------
  EOS
  if params['t'].nil?
    puts usage
    exit 1
  else
    prm = GenarateJsonFomatter.new
    #GenarateJsonFomatter.new(ARGV[0])

    case params['t']
      when /csv/
        prm.dump_csv
      when /json/
        prm.dump_json
      when /ssh/
        prm.dump_sshconfig
      else
        puts usage
        exit 1
    end
  end

end

