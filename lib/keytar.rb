require 'rubygems'
begin; require 'active_record' rescue; end

module Keytar
  autoload :KeyBuilder, 'keytar/key_builder'
  ActiveRecord::Base.class_eval { include KeyBuilder } if defined?(ActiveRecord::Base)
  def self.included(klass)
    klass.class_eval {include KeyBuilder}
  end
end
