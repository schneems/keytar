require 'spec_helper'

## Gives us ActiveRecord backed model Bar that we can test instances of
ActiveRecord::Base.establish_connection(
:adapter => "sqlite3",
:database => ":memory:",
:host     => 'localhost')

ActiveRecord::Schema.define do
  create_table :bars do |t|
    t.string :name, :null => false
  end
  create_table :bar_bazs do |t|
    t.string :name, :null => false
  end
end

class Foo
  include Keytar
  define_key :awesome
end

class Bar < ActiveRecord::Base
  include Keytar
  define_key :awesome
end

class BarNonActiveRecord
end


class BarBaz < ActiveRecord::Base
end

describe Keytar do
  describe 'class and instance interference' do
    it 'should not happen' do
      bar = Bar.create(:name => "whatever")
      orig_key =  Bar.awesome_key(bar.id)
      bar.awesome_key(bar.id)
      second_key = Bar.awesome_key(bar.id)
      second_key.should eq(orig_key)
    end
  end

  describe 'cache_key' do
    it 'allows us to pre-define class methods' do
      Foo.cache_key(:cached_method, :delimiter => "/", :key_prefix => "woo")
      Foo.respond_to?(:cached_method_key).should be_true
      puts Foo.cached_method_key(22).should == "woo/foo/cached_method/22"
    end

    it 'allows us to pre-define instance methods' do
      Foo.cache_key(:cached_instance_method, :delimiter => "|", :version => "3")
      @foo = Foo.new
      @foo.respond_to?(:cached_instance_method_key).should be_true
      @foo.cached_instance_method_key.should == "foos|cached_instance_method|3"
    end

    describe 'taking an array' do
      it 'allows us to pre-define multiple class key methods' do
        Foo.cache_key(:m1, :m2, :m3, :delimiter => ":", :key_prefix => "foo")
        Foo.respond_to?(:m1_key).should be_true
        Foo.respond_to?(:m2_key).should be_true
        Foo.respond_to?(:m3_key).should be_true
        @foo = Foo.new
        @foo.respond_to?(:m1_key).should be_true
        @foo.respond_to?(:m2_key).should be_true
        @foo.respond_to?(:m3_key).should be_true
      end
    end
  end

  describe 'class methods' do
    it 'should respond to "awesome_key" method by returning :class, :delimiter, :name' do
      Foo.awesome_key.should == "foo:awesome"
    end

    it 'should respond to "awesome_key(number)" method by returning :class, :delimiter, :name, :delimiter, :arg' do
      number = rand(100)
      Foo.awesome_key(number).should == "foo:awesome:#{number}"
    end



    it 'should call method_missing on a non-existant method' do
        lambda{ Foo.thismethoddoesnotexist }.should raise_error(NoMethodError)
    end
  end


  describe 'instance methods' do
    before(:each) do
      @foo = Foo.new
    end

    it 'should respond to "awesome_key" method by returning :class, :delimiter, :name' do
      @foo.awesome_key.should == "foos:awesome"
    end

    it 'should respond to "awesome_key(number)" method by returning :class, :delimiter, :name, :delimiter, :arg' do
      number = rand(100)
      @foo.awesome_key(number).should == "foos:awesome:#{number}"
    end

    it 'should call method_missing on a non-existant method' do
        lambda{ @foo.thismethoddoesnotexist }.should raise_error(NoMethodError)
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
       Foo.class_eval { def timeish; (Time.now.to_i * 0.01).floor.to_s; end}
       key_unique = :timeish
       Foo.key_unique key_unique
       Foo.key_unique.should == key_unique
       foo = Foo.new
       foo.awesome_key.should include(foo.timeish)
     end

     # todo move tests and assertsions to seperate describe and it blocks
     it 'should allow all configurations to be set using a hash' do
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
       Foo.keyfig :delimiter => key_delimiter,
                  :order => key_order,
                  :prefix => key_prefix,
                  :suffix => key_suffix,
                  :pluralize_instances => key_pluralize_instances,
                  :case => key_case,
                  :plural => key_plural,
                  :unique => key_unique
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



  describe 'requiring Keytar' do
    it 'should allow ActiveRecord based objects to use their unique identifiers' do
      name = "notblank"
      b = Bar.create(:name => name)
      b.name.should == name
      b.awesome_key.should == "bars:awesome:#{b.id}"
    end
  end

  describe 'requiring Keytar with ActiveRecord undefined' do
    it 'does not automatically add KeyBuilder to the class' do
      describe BarNonActiveRecord.ancestors do
        it {should_not include( KeyBuilder)}
      end
    end

    describe 'allows non ActiveRecord based classes to use keytar directly' do
      it 'includes keybuilder when it is included' do
        BarNonActiveRecord.class_eval do
          include Keytar
          define_key :awesome
        end
        describe BarNonActiveRecord.ancestors do
          it {should include( KeyBuilder)}
        end
      end

      it 'should allow ActiveRecord based objects to use their unique identifiers' do
        BarNonActiveRecord.awesome_key.should == "barnonactiverecord:awesome"
      end
    end
  end

  describe "keytar should not over-ride default method_missing for AR" do
    before do
      b = BarBaz.create(:name => "something")
      @id = b.id
      Object.instance_eval{ remove_const :BarBaz } ## AR caches methods on object on create, need to pull it from disk
      class BarBaz < ActiveRecord::Base
        include Keytar
        define_key :foo_key
      end
    end

    it 'does not interfere with how ActiveRecord generates methods based on column names' do
      BarBaz.last.id.should == @id
    end
  end

end