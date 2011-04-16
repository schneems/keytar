require 'rubygems'
require 'active_record'

module Keytar
  autoload :KeyBuilder, 'keytar/key_builder'
  ActiveRecord::Base.class_eval %{ include KeyBuilder }
end
