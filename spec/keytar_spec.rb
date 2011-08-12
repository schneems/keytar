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

  describe 'define_key' do

    it 'allows us to pre-define instance methods' do
      Foo.define_key(:cached_instance_method, :delimiter => "|", :version => "3")
      @foo = Foo.new
      @foo.respond_to?(:cached_instance_method_key).should be_true
      @foo.cached_instance_method_key.should == "foos|cached_instance_method|3"
    end

    describe 'taking an array' do
      it 'allows us to pre-define multiple class key methods' do
        Foo.define_key(:m1, :m2, :m3, :delimiter => ":", :key_prefix => "foo")
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

  describe 'class methods on Foo' do
    it 'should respond to "awesome_key" method by returning :class, :delimiter, :name' do
      Foo.awesome_key.should == "foo:awesome"
    end

    it 'should respond to "awesome_key(number)" method by returning :class, :delimiter, :name, :delimiter, :arg' do
      number = rand(100)
      Foo.awesome_key(number).should == "foo:awesome:#{number}"
    end
  end


  describe 'Foo instance methods' do
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




  describe 'requiring Keytar' do
    it 'should allow ActiveRecord based objects to use their unique identifiers' do
      name = "notblank"
      b = Bar.create(:name => name)
      b.name.should == name
      b.awesome_key.should == "bars:awesome:#{b.id}"
    end
  end

  describe 'requiring Keytar with ActiveRecord undefined' do
    it 'does not automatically add Keytar to the class' do
      describe BarNonActiveRecord.ancestors do
        it {should_not include( Keytar)}
      end
    end

    describe 'allows non ActiveRecord based classes to use keytar directly' do
      it 'includes Keytar when it is included' do
        BarNonActiveRecord.class_eval do
          include Keytar
          define_key :awesome
        end
        describe BarNonActiveRecord.ancestors do
          it {should include( Keytar)}
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