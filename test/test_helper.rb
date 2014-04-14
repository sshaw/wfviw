ENV['RACK_ENV'] = 'test'
require_relative '../wfviw.rb'

require 'rack/test'
require 'minitest/autorun'
require 'minitest/pride'

