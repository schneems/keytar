require 'active_support/all'

module Keytar
  extend ActiveSupport::Concern
  DEFAULTS = {:delimiter  => ":",
                :order    => [:shard, :prefix, :base, :name, :unique, :args, :suffix, :version, :v],
                :pluralize_instances => true,
                :key_case => :downcase,
                :unique   => :id}


# cannot change :order
# can change :unique
#
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
      order.map {|key| options[key]}.flatten.compact.map(&:to_s)
    end

    def to_s
      key = key_array.join(delimiter)
      key = key.send key_case if key_case.present? && key.respond_to?(key_case)
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
        Keytar.define_key_class_method_on(self, options.merge(:name => name))
        Keytar.define_key_instance_method_on(self, options.merge(:name => name))
      end
    end
    alias :define_key  :define_keys


    # a way to define class level configurations for keytar using a hash
    def key_config(options = {})
        options[:base]  = self
        @key_config     ||= options.reverse_merge(Keytar::DEFAULTS)
    end

    # Call Keytar.build_key or Foo.build_key with options
    # :base => self.to_s.downcase, :name => method_name, :args => args
    def build_key(options = {})
      input = options.reverse_merge(key_config)
      input.delete(:unique) # class methods don't have a unique key
      Key.build(input)
    end
  end

  # build_key method for instances by default class is pluralized to create different key
  def build_key(options = {})
    options.reverse_merge!(self.class.key_config)
    unique            = method(options[:unique].to_sym).call if respond_to?(options[:unique].to_sym)
    options[:base]    = options[:base].to_s.pluralize unless options[:pluralize_instances].blank?
    options[:unique]  = unique && unique == object_id ?  nil  : unique
    Key.build(options)
  end
end
