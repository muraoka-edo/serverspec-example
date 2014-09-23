#!/usr/bin/env ruby
# coding: utf-8
  
require 'json'
require 'csv'

class GenProps
  def initialize(hostlst)
    @hostlst  = hostlst
    @properties = Array.new
    _generate_properties
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
      attrs     = row["attrs"   ].split(':')
      property_of = Hash.new
      property_of[:host    ] = host
      property_of[:hostname] = hostname
      property_of[:env     ] = env
      property_of[:user    ] = user
      property_of[:roles   ] = attrs
      @properties << property_of
    end

    puts _dump_json
  end

  def _dump_json
    JSON.pretty_generate(@properties)
  end
end
