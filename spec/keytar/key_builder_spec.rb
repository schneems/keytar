require 'spec_helper'

class Foo
  include Keytar

  def ymd
    Time.now.strftime("%y%m%d")
  end
end

describe KeyBuilder do
  describe 'build_key class method' do
    before do
      @options = {:name => "foo", :args => nil}
    end

    describe 'manually build key' do
      it 'works' do
        foo = Foo.new
        foo.build_key(:name => "method", :args => "args").should eq("foos:method:args")
      end
    end

    describe 'build_key' do
      it 'calls other class methods' do
        Foo.should_receive(:build_key_hash)
        Foo.should_receive(:key_hash_to_ordered_array)
        Foo.should_receive(:key_from_array)
        Foo.build_key(@options)
      end
    end

    describe 'build_key_hash' do
      it 'removes key and _key from the :name option' do
        Foo.build_key_hash(@options.merge(:name => "foo_key"))[:name].should == "foo"
        Foo.build_key_hash(@options.merge(:name => "key"))[:name].should == ""
        Foo.build_key_hash(@options.merge(:name => "fookey"))[:name].should == "fookey"
      end

      describe 'prefix' do
        it 'takes in prefix converts key_prefix to prefix' do
          prefix = "prefix"
          Foo.build_key_hash(@options.merge(:key_prefix => prefix))[:prefix].should == prefix
        end

        it 'favors direct options over class settings' do
          prefix = "prefix"
          Foo.should_not_receive(:key_prefix)
          Foo.build_key_hash(@options.merge(:key_prefix => prefix))[:prefix].should == prefix
        end

        it "defaults to class settings when no direct option is given" do
          prefix = "classPrefix"
          Foo.should_receive(:key_prefix).and_return(prefix)
          Foo.build_key_hash(@options)[:prefix].should == prefix
        end
      end

      describe "suffix" do
        it 'takes in suffix and converts key_suffix to suffix' do
          suffix = "sufix"
          Foo.build_key_hash(@options.merge(:key_suffix => suffix))[:suffix].should == suffix
        end

        it 'favors direct options over class settings' do
          suffix = "suffix"
          Foo.should_not_receive(:key_suffix)
          Foo.build_key_hash(@options.merge(:key_suffix => suffix))[:suffix].should == suffix
        end

        it "defaults to class settings when no direct option is given" do
          suffix = "classSuffix"
          Foo.should_receive(:key_suffix).and_return(suffix)
          Foo.build_key_hash(@options)[:suffix].should == suffix
        end
      end
    end

    describe 'key_hash_to_rdered_array' do
      before do
        @options.merge!(:prefix => "prefix", :base => "base", :name => "name", :suffix => "suffix", :version => 1)
      end

      it "converts a hash to an array based on default order" do
        Foo.key_hash_to_ordered_array(@options).should == [@options[:shard], @options[:prefix], @options[:base], @options[:name], @options[:unique], @options[:suffix], @options[:version], @options[:v]]
      end

      it "order output using direct option before class config" do
        Foo.should_not_receive(:key_order)
        key_order = [:prefix, :base, :name, :unique, :args, :suffix, :version, :v].reverse
        Foo.key_hash_to_ordered_array(@options.merge(:key_order => key_order)).should == [@options[:prefix], @options[:base], @options[:name], @options[:unique], @options[:suffix], @options[:version], @options[:v]].reverse
      end

      it "convert each arg in args to a string" do
        args = ["hey", 1 , "what", 2, "up", []]
        Foo.key_hash_to_ordered_array(@options.merge(:args => args)).include?(args.map(&:to_s)).should be_true
      end
    end

    describe 'key_from_array' do
      before do
        @key_array = ["foo", "Bar", "oH", "YEAH"]
      end

      it "strip out nil from the array and have no spaces" do
        Foo.key_from_array([nil, nil]).match(/nil/).should be_false
        Foo.key_from_array([nil, nil]).match(/\s/).should be_false
      end

      it "return a string" do
        Foo.key_from_array(@key_array).class.should == String
      end

      it "keep the key case consistent (downcase by default)" do
        Foo.key_from_array(@key_array).should == @key_array.map(&:downcase).join(":")
      end

      it "allow different cases to be passed in via options" do
        Foo.should_not_receive(:key_case)
        Foo.key_from_array(@key_array, :key_case => :upcase).should == @key_array.map(&:upcase).join(":")
      end

      it "flattens all inputs" do
        array = @key_array << [[["1"], ["2"]],["3"]]
        Foo.key_from_array(array, :key_case => :upcase).should == array.flatten.map(&:upcase).join(":")
      end
    end
  end

  describe 'build_key instance method' do
    before do
      @options = {:name => "foo", :args => nil}
      @foo = Foo.new
    end

    describe 'build_key' do
      it 'sets_base to class name and pluralizes it' do
        @foo.class.should_receive(:build_key).with(hash_including(:base => @foo.class.to_s.downcase + "s"))
        @foo.build_key(@options)
      end

      it 'allows a manual over-ride of base' do
        base = "base"
        @foo.class.should_receive(:build_key).with(hash_including(:base => base + "s"))
        @foo.build_key(@options.merge(:base => base))
      end

      it "don't pluralize base if key_pluralize_instances is set to false" do
        @foo.class.should_not_receive(:key_pluralize_instances)
        @foo.class.should_receive(:build_key).with(hash_including(:base => @foo.class.to_s.downcase))
        @foo.build_key(@options.merge(:key_pluralize_instances => false))
      end

      it "don't pluralize base if key_pluralize_instances is set to false" do
        @foo.class.should_not_receive(:key_pluralize_instances)
        @foo.class.should_receive(:build_key).with(hash_including(:base => @foo.class.to_s.downcase))
        @foo.build_key(@options.merge(:key_pluralize_instances => false))
      end

      it "allow unique method to be passed in via options" do
        @foo.class.should_not_receive(:key_unique)
        @foo.class.should_receive(:build_key).with(hash_including(:unique => @foo.ymd))
        @foo.build_key(@options.merge(:key_unique => :ymd))
      end

      it "set unique based on configuration" do
        @foo.class.should_receive(:key_unique).at_least(:once).and_return("ymd")
        @foo.class.should_receive(:build_key).with(hash_including(:unique => @foo.ymd))
        @foo.build_key
      end
    end
  end
end