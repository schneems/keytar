module KeyBuilder
  DEFAULTS = {:key_delimiter => ":",
                :key_order => [:shard, :prefix, :base, :name, :unique, :args, :suffix, :version, :v],
                :key_prefix => nil,
                :key_suffix => nil,
                :key_pluralize_instances => true,
                :key_case => :downcase,
                :key_plural => nil,
                :key_unique => "id"}

  def self.included(klass)
    # setup method missing on class
    klass.class_eval do
      extend KeyBuilder::Ext
    end
  end

  # class methods to be extended
  module Ext
    # creates class level getter and setter methods for the defaults for config
    DEFAULTS.keys.each do |key|
      # TODO: re-write without eval
      eval %{
        def #{key}(#{key}_input = :key_default)
          @@#{key} = DEFAULTS[:#{key}] unless defined? @@#{key}
          @@#{key} = #{key}_input unless #{key}_input  == :key_default
          return @@#{key}
        end
      }
    end

    # sets up configuration options for individual keys
    # alows us to define the keys without calling method missing
    def cache_key( *args)
      # coherce args into meaningful things
      names = []; options = {}; args.each {|arg| arg.is_a?(Hash) ? options = arg : names << arg}
      options.merge!(:name => name, :base => self.to_s.downcase)

      # allow for loose naming of keys configuration symbols can use :key_prefix or just :prefix
      options.keys.each do |key|
        options["key_#{key}".to_sym] = options[key] if key.to_s !~ /^key_/
      end
      names.each do |name|
        # define (cache) class method
        (class << self;self ;end).instance_eval do
          define_method("#{name}_key") do |*args|
            build_options = options.merge(:name => name, :base => self.to_s.downcase, :args => args)
            build_key(build_options)
          end
        end

        # define (cache) instance method
        class_eval do
          define_method("#{name}_key") do |*args|
            build_options = options.merge(:name => name, :args => args)
            build_key(build_options)
          end
        end
      end
    end
    alias :cache_keys  :cache_key
    alias :define_key  :cache_key
    alias :define_keys :cache_key

    # a way to define configurations for keytar using a hash
    def key_config(options = {})
      # allow for loose naming of keys configuration symbols can use :key_prefix or just :prefix
      options.keys.each do |key|
        options["key_#{key}".to_sym] = options[key] if key.to_s !~ /^key_/
      end
      options.each do |key, value|
        self.send( key , value) if self.respond_to? key
      end
    end
    alias :keyfig :key_config

    # Call KeyBuilder.build_key or Foo.build_key with options
    # :base => self.to_s.downcase, :name => method_name, :args => args
    def build_key(options = {})
      key_hash = build_key_hash(options)
      key_array = key_hash_to_ordered_array(key_hash)
      return key_from_array(key_array, options)
    end

    # takes input options and turns to a hash, which can be sorted based on key
    def build_key_hash(options)
      options[:name] = options[:name].to_s.gsub(/(^key$|_key$)/, '')
      {:prefix => options[:key_prefix]||self.key_prefix,
       :suffix => options[:key_suffix]||self.key_suffix}.merge(options)
    end

    # orders the elements based on defaults or config
    def key_hash_to_ordered_array(key_hash)
      key_array ||= []
      (key_hash[:key_order]||self.key_order).each do |key|
        if key != :args
          key_array << key_hash[key]
        else
          key_array << key_hash[key].map(&:to_s) unless key_hash[key].blank?
        end
      end
      return key_array
    end

    # applys a delimter and appropriate case to final key
    def key_from_array(key_array, options = {})
      key = key_array.flatten.reject {|item| item.blank? }.join(options[:key_delimiter]||self.key_delimiter)
      key_case = options[:key_case] || self.key_case
      key = key.downcase if key_case == :downcase
      key = key.upcase if key_case == :upcase
      key
    end
  end

  # build_key method for instances by default class is pluralized to create different key
  def build_key(options = {})
    options[:base] = options[:base]||self.class.to_s.downcase
    if (options[:key_pluralize_instances] == true ) || (options[:key_pluralize_instances] != false && self.class.key_pluralize_instances.present?)
      options[:base] =  options[:key_plural]||self.class.key_plural||options[:base].pluralize
    end
    unique = self.send "#{options[:key_unique]||self.class.key_unique}".to_sym
    options[:unique] = unique unless unique == object_id
    self.class.build_key(options)
  end
end