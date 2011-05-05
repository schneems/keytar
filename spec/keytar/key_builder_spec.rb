require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


class Foo
  include KeyBuilder
end


describe KeyBuilder do

  describe 'class methods' do
    it 'should respond to "key" method by returning downcase of class name' do
      Foo.key.should == "foo"
    end

    it 'should respond to "awesome_key" method by returning :class, :delimiter, :name' do
      Foo.awesome_key.should == "foo:awesome"
    end

    it 'should respond to "awesome_key(number)" method by returning :class, :delimiter, :name, :delimiter, :arg' do
      number = rand(100)
      Foo.awesome_key(number).should == "foo:awesome:#{number}"
    end

    it 'should dynamically define a class method capeable of producing different keys' do
      key1 = Foo.define_method_time_test_key(1)
      key2 = Foo.define_method_time_test_key(2)
      Foo.respond_to?(:define_method_time_test_key).should be_true
      key2.should_not == key1
    end



    it 'should call method_missing on a non-existant method' do
      begin
        Foo.thismethoddoesnotexist
      rescue => ex
      end
        ex.class.should == NoMethodError
    end
  end


  describe 'instance methods' do
    before(:each) do
      @foo = Foo.new
    end

    it 'should respond to "key" method by returning pluralized downcase of class name' do
      @foo.key.should == "foos"
    end

    it 'should respond to "awesome_key" method by returning :class, :delimiter, :name' do
      @foo.awesome_key.should == "foos:awesome"
    end

    it 'should respond to "awesome_key(number)" method by returning :class, :delimiter, :name, :delimiter, :arg' do
      number = rand(100)
      @foo.awesome_key(number).should == "foos:awesome:#{number}"
    end

    it 'should dynamically define an instance method capeable of producing different keys' do
      key1 = @foo.define_method_time_test_key(1)
      key2 = @foo.define_method_time_test_key(2)
      @foo.respond_to?(:define_method_time_test_key).should be_true
      key2.should_not == key1
    end

    it 'should call method_missing on a non-existant method' do
      begin
        @foo.thismethoddoesnotexist
      rescue => ex
      end
        ex.class.should == NoMethodError
    end
  end

  # test last
  describe 'class configurations' do
    after(:each) do
      # todo find a better way of resetting all these values
      Foo.key_delimiter KeyBuilder::DEFAULTS[:key_delimiter]
      Foo.key_order KeyBuilder::DEFAULTS[:key_order]
      Foo.key_prefix KeyBuilder::DEFAULTS[:key_prefix]
      Foo.key_suffix KeyBuilder::DEFAULTS[:key_suffix]
      Foo.key_pluralize_instances KeyBuilder::DEFAULTS[:key_pluralize_instances]
      Foo.key_case KeyBuilder::DEFAULTS[:key_case]
      Foo.key_plural KeyBuilder::DEFAULTS[:key_plural]
      Foo.key_unique KeyBuilder::DEFAULTS[:key_unique]
    end

    it 'should change key_delimiter' do
      key_delimiter = "|"
      Foo.key_delimiter key_delimiter
      Foo.key_delimiter.should == key_delimiter
      Foo.awesome_key.should == "foo#{key_delimiter}awesome"
    end


    it 'should change key_order' do
      order_array = [:prefix, :name, :unique, :base, :args, :suffix]
      Foo.key_order order_array
      Foo.key_order.should == order_array
      Foo.awesome_key.should == "awesome:foo"
    end

    it 'should change key_prefix' do
      key_prefix = "memcache"
      Foo.key_prefix key_prefix
      Foo.key_prefix.should == key_prefix
      Foo.awesome_key.should == "#{key_prefix}:foo:awesome"
    end

    it 'should change key_suffix' do
      key_suffix = "slave"
      Foo.key_suffix key_suffix
      Foo.key_suffix.should == key_suffix
      Foo.awesome_key.should == "foo:awesome:#{key_suffix}"
    end

     it 'should change key_pluralize_instances' do
       key_pluralize_instances = false
       Foo.key_pluralize_instances key_pluralize_instances
       Foo.key_pluralize_instances.should == key_pluralize_instances
       foo = Foo.new
       foo.awesome_key.should == "foo:awesome"
     end

     it 'should change key_case' do
       key_case = :upcase
       Foo.key_case key_case
       Foo.key_case.should == key_case
       Foo.awesome_key.should == "FOO:AWESOME"
     end

     it 'should change key_plural' do
       key_plural = "fooz"
       Foo.key_plural key_plural
       Foo.key_plural.should == key_plural
       foo = Foo.new
       foo.awesome_key.should == "fooz:awesome"
     end

     it 'should change key_unique' do
       Foo.class_eval { def timeish; (Time.now.to_i * 0.01).floor; end}
       key_unique = :timeish
       Foo.key_unique key_unique
       Foo.key_unique.should == key_unique
       foo = Foo.new
       foo.awesome_key.should == "foos:awesome:#{foo.timeish}"
     end

     # todo move tests and assertsions to seperate describe and it blocks
     it 'should change key_plural' do
       # variables
       key_delimiter = "/"
       key_order = [:prefix, :base, :suffix]
       key_prefix = "before"
       key_suffix = "after"
       key_pluralize_instances = false
       key_case = :upcase
       key_plural = "zoosk"
       key_unique = "doesn-t_apply_to_instance_methods"
       # config
       Foo.keyfig :key_delimiter => key_delimiter,
                  :key_order => key_order,
                  :key_prefix => key_prefix,
                  :key_suffix => key_suffix,
                  :key_pluralize_instances => key_pluralize_instances,
                  :key_case => key_case,
                  :key_plural => key_plural,
                  :key_unique => key_unique
      # assertions
      Foo.key_delimiter.should == key_delimiter
      Foo.key_order.should == key_order
      Foo.key_prefix.should == key_prefix
      Foo.key_suffix.should == key_suffix
      Foo.key_pluralize_instances.should == key_pluralize_instances
      Foo.key_case.should == key_case
      Foo.key_plural.should == key_plural
      Foo.key_unique.should == key_unique
     end

  end

end