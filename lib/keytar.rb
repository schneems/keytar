require 'active_support/all'
autoload :KeyUtility, "keytar/key_utility"
autoload :KeyBuilder, 'keytar/key_builder'

module Keytar
  extend ActiveSupport::Concern

  included do
    include KeyBuilder
  end
end
