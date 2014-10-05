#!/usr/bin/env ruby
# coding: utf-8
  
require 'json'
require 'csv'

class GenarateJsonFomatter

  def initialize
    @flst       = _check_config(File.expand_path('~/ops/repos/target/all_files.lst'))
    @config     = _check_config(File.expand_path('~/ops/repos/target/basic_config.tsv'))
    @properties = Array.new
    @usage      = -> {
      prg_name  = File.basename(__FILE__)
      return <<-EOS
-------------------------
  puts prm.usage: #{prg_name} [options]
      -t (json|ssh|hosts)
      -t csv   <hostname>
      -t hosts (production|development)
-------------------------
      EOS
    }
    _generate_properties
  end

  def usage
    puts @usage.call
  end

  def _check_config(fname)
    if File.exist?(fname)
      return fname
    else
      puts "[Error]: No such file: #{fname}"
      puts usage; exit 1
    end
  end

  def _generate_properties
    CSV.foreach(@config, { :col_sep => ' ',
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

  def dump_hosts(env)
    @properties.map do |p|
      if p[:env] == env
        puts p[:host]
      end
    end
  end

  def dump_csv(hostname)
    @flsts = Array.new

    CSV.foreach(@flst, { :col_sep => ':',
                         :headers => true,
                         :skip_blanks => true,
                       }) do |row|
      attr  = row["attr" ]
      fname = row["fname"]
      property_of = Hash.new
      property_of[:attr ] = attr
      property_of[:fname] = fname
      @flsts << property_of
    end

    @properties.map do |p|
      if p[:host] == hostname
        p[:roles].each do |role|
          @flsts.map do |m|
            if m[:attr] == role
              puts m[:fname]
            end
          end
        end
      end
    end
#    @properties.each do |hs|
#      hs.each do |k, v|
#        case k
#        when /^host$|^env$/
#          print "#{v},"
#        when /^roles$/
#          puts "#{v}"
#        end
#      end
#    end
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

  prm = GenarateJsonFomatter.new
  params   = ARGV.getopts('t:')

  if params['t'].nil?
    puts prm.usage; exit 1
  else
    #GenarateJsonFomatter.new(ARGV[0])

    case params['t']
      when /^csv$/
        if ARGV[0].nil?
          puts prm.usage; exit 1
        else
          prm.dump_csv(ARGV[0])
        end

      when /^hosts$/
        if ARGV[0].nil?
          puts prm.usage; exit 1
        else
          if ARGV[0] == 'production' || params['t'] == 'development'
            prm.dump_hosts(ARGV[0])
          else
            puts prm.usage; exit 1
          end
        end
      
      when /^json$/
        prm.dump_json

      when /^ssh$/
        prm.dump_sshconfig

      else
        puts prm.usage; exit 1
    end
  end

end
