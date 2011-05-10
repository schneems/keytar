require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
## Gives us ActiveRecord backed model Bar that we can test instances of
ActiveRecord::Base.establish_connection(
:adapter => "sqlite3",
:database => ":memory:",
:host     => 'localhost')

ActiveRecord::Schema.define do
  create_table :bars do |t|
    t.string :name, :null => false
  end
end

class Bar < ActiveRecord::Base

end

class BarNonActiveRecord

end


describe Keytar do
  describe 'requiring Keytar' do
    it 'should load keybuilder into ActiveRecord::Base if defined' do
      describe Bar.ancestors do
        it {should include( KeyBuilder)}
      end
    end

    it 'should allow ActiveRecord based objects to use their unique identifiers' do
      name = "notblank"
      b = Bar.create(:name => name)
      b.name.should == name
      b.awesome_key.should == "bars:awesome:#{b.id}"
    end
  end

  describe 'requiring Keytar with ActiveRecord undefined' do
    before do
      begin; Object.send(:remove_const, "ActiveRecord"); rescue NameError; end
    end

    it 'does not automatically add KeyBuilder to the class' do
      describe BarNonActiveRecord.ancestors do
        it {should_not include( KeyBuilder)}
      end
    end

    describe 'allows non ActiveRecord based classes to use keytar directly' do
      it 'includes keybuilder when it is included' do
        BarNonActiveRecord.class_eval do
          include Keytar
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


end