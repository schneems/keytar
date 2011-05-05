require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
## Gives us ActiveRecord backed model Bar that we can test instances of
ActiveRecord::Base.establish_connection(
:adapter => "sqlite3",
:database => ":memory:",
:host     => 'localhost')

## Gives us ActiveRecord backed model Bar that we can test instances of
ActiveRecord::Migrator.migrate(
  File.expand_path(File.dirname(__FILE__) + "../../../db/migrate") ,
  ENV["VERSION"] ? ENV["VERSION"].to_i : nil )

class Bar < ActiveRecord::Base

end


describe Keytar do
  describe 'requiring Keytar' do
    it 'should load keybuilder into ActiveRecord::Base' do
      describe Bar.ancestors do
        it {should include( KeyBuilder)}
      end
    end

    it 'should ' do
      name = "notblank"
      b = Bar.create(:name => name)
      b.name.should == name
      b.awesome_key.should == "bars:awesome:#{b.id}"
    end
  end
end