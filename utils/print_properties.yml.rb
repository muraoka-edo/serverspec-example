#!/usr/bin/env ruby
# coding: utf-8
$:.unshift(File.dirname(File.expand_path(__FILE__)))
  
require 'generator/generate_properties'

raise 'ArgumentError: Set Filename' if ARGV[0].nil?

GenProps.new(ARGV[0])
