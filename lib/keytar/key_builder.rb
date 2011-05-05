require 'rubygems'
require 'active_support/inflector' # used for pluralize
require 'active_support/core_ext/object/blank' # used for blank? and present?

module KeyBuilder
  alias :original_method_missing :method_missing

  DEFAULTS = {:key_delimiter => ":",
                :key_order => [:prefix, :base, :name, :unique, :args, :suffix],
                :key_prefix => nil,
                :key_suffix => nil,
                :key_pluralize_instances => true,
                :key_case => :downcase,
                :key_plural => nil,
                :key_unique => "id"
                }

  def self.included(klass)
    # setup method missing on class
    klass.class_eval do
      extend KeyBuilder::Ext
      # if method_missing doesn't already exist, aliasing and calling it will create an infinite loop
      @@key_builder_jump_to_superclass = true
      if klass.respond_to?("method_missing")
        @@key_builder_jump_to_superclass = false
        alias :key_builder_alias_method_missing :method_missing
      end

      def self.method_missing(method_name, *args, &blk)
        if method_name.to_s =~ /.*key$/
          self.build_key(:base => self.to_s.downcase, :name => method_name, :args => args)
        else
          if @@key_builder_jump_to_superclass
            super
          else
            key_builder_alias_method_missing(method_name, *args, &blk)
          end
        end
      end
    end
  end

  # class methods to be extended
  module Ext
    # creates class level getter and setter methods for the defaults for config
    DEFAULTS.keys.each do |key|
      eval %{
        def #{key}(#{key}_input = :key_default)
          @@#{key} = DEFAULTS[:#{key}] unless defined? @@#{key}
          @@#{key} = #{key}_input unless #{key}_input  == :key_default
          return @@#{key}
        end
      }
    end

    def keyfig(options = {})
      options.keys.each do |key|
        eval("@@#{key} = options[key]") if key.to_s =~ /^key_.*/
      end
    end

    # Call KeyBuilder.build_key or Foo.build_key with options
    # :base => self.to_s.downcase, :name => method_name, :args => args
    def build_key(options = {})
      key_hash = build_key_hash(options)
      key_array = key_hash_to_ordered_array(key_hash)
      return key_from_array(key_array)
    end

    # takes input options and turns to a hash, which can be sorted based on key
    def build_key_hash(options)
      options[:name] = options[:name].to_s.gsub(/(key|_key)/, '')
      options.merge :prefix => self.key_prefix, :suffix => self.key_suffix
    end

    # orders the elements based on defaults or config
    def key_hash_to_ordered_array(key_hash)
      key_array ||= []
      self.key_order.each do |key|
        if key != :args
          key_array << key_hash[key]
        else
          key_array << key_hash[key].map(&:to_s)
        end
      end
      return key_array
    end

    # applys a delimter and appropriate case to final key
    def key_from_array(key_array)
      key = key_array.flatten.reject {|item| item.blank? }.join(self.key_delimiter)
      key = key.downcase if self.key_case == :downcase
      key = key.upcase if self.key_case == :upcase
      key
    end
  end

  # build_key method for instances by default class is pluralized to create different key
  def build_key(method_name, *args)
    base = self.class.to_s.downcase
    base =  self.class.key_plural||base.pluralize if self.class.key_pluralize_instances.present?
    unique = eval("self.#{self.class.key_unique}") unless eval("self.#{self.class.key_unique}") == object_id
    self.class.build_key(:base => base, :name => method_name, :args => args, :unique => unique)
  end



  def method_missing(method_name, *args, &blk)
    if method_name.to_s =~ /.*key$/
      build_key(method_name, *args)
    else
      original_method_missing(method_name, *args, &blk)
    end
  end
end