require 'active_support/all'
autoload :KeyBuilder, 'keytar/key_builder'

module Keytar
  extend ActiveSupport::Concern
  DEFAULTS = {:delimiter  => ":",
                :order    => [:shard, :prefix, :base, :name, :unique, :args, :suffix, :version, :v],
                :pluralize_instances => true,
                :key_case => :downcase,
                :unique   => :id}

  class Key
    attr_accessor :delimiter, :order, :key_case, :options
    def initialize(options = {})
      options[:name]  = options.delete(:name).to_s.gsub(/(^key$|_key$)/, '')
      self.delimiter  = options.delete(:delimiter)
      self.order      = options.delete(:order)
      self.key_case   = options.delete(:key_case)
      self.options    = options
    end

    def key_array
      order.map do |key|
        if key != :args
          options[key].try(:to_s)
        else
          options[key].map(&:to_s) unless options[key].blank?
        end
      end.flatten.compact
    end

    def to_s
      key = key_array
      key = key.send key_case if key_case.present?
      key
    end

    def self.build(options = {})
      self.new(options).to_s
    end
  end


  def self.define_key_class_method_on(base, options = {})
    (class << base;self ;end).instance_eval do
      define_method("#{options[:name]}_key") do |*args|
        build_key(options.merge(:args => args))
      end
    end
  end

  def self.define_key_instance_method_on(base, options)
    base.class_eval do
      define_method("#{options[:name]}_key") do |*args|
        build_key(options.merge(:args => args))
      end
    end
  end

  # class methods to be extended
  module ClassMethods
    # sets up configuration options for individual keys
    # alows us to define the keys without calling method missing
    def define_keys(*args)
      # coherce args into meaningful things
      names = []; options = {}; args.each {|arg| arg.is_a?(Hash) ? options = arg : names << arg}
      names.each do |name|
        name = name.to_s.gsub(/(^key$|_key$)/, '')
        KeyBuilder.define_key_class_method_on(self, options.merge(:name => name))
        KeyBuilder.define_key_instance_method_on(self, options.merge(:name => name))
      end
    end
    alias :define_key  :define_keys


    # a way to define class level configurations for keytar using a hash
    def key_config(options = {})
        options[:base]  = self.class
        @key_config     ||= options.reverse_merge(KeyBuilder::DEFAULTS)
    end

    # Call KeyBuilder.build_key or Foo.build_key with options
    # :base => self.to_s.downcase, :name => method_name, :args => args
    def build_key(options = {})
      Key.build(options.reverse_merge(key_config))
    end
  end

  # build_key method for instances by default class is pluralized to create different key
  def build_key(options = {})
    options.reverse_merge(self.class.key_config)
    unique            = self.send (options.key_config[:key_unique].to_sym)
    options[:base]    = options[:base].pluralize if options[:pluralize_instances]
    options[:unique]  = unique unless unique == object_id
    Key.build(options)
  end
end
