require 'active_support/all'
autoload :KeyBuilder, 'keytar/key_builder'

module Keytar
  extend ActiveSupport::Concern

  included do
    include KeyBuilder
  end
end
