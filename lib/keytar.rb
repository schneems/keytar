
module Keytar
  autoload :KeyUtility, "keytar/key_utility"
  autoload :KeyBuilder, 'keytar/key_builder'
  def self.included(klass)
    klass.class_eval {include KeyBuilder}
  end
end
