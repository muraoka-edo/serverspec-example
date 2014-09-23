#!/usr/bin/env ruby
# coding: utf-8
  
require 'yaml'
require 'csv'

class GenProps
  def initialize(hostlst)
    @hostlst  = hostlst
    @property = Hash.new { |hash,key| hash[key] ={} }
    _generate_properties
  end

  def _generate_properties
    CSV.foreach(@hostlst, { :col_sep => ',',
                            :headers => true,
                            :skip_blanks => true,
                          }) do |row|
      host  = row["host" ]
      attrs = row["attrs"].split(':')
      @property[host][:roles] = attrs
      @property[host][:host_name] = host
    end

    puts _dump_yml
  end

  def _dump_yml
    YAML.dump(@property)
  end
end

