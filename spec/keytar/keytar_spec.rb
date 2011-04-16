require 'spec_helper'
class Bar < ActiveRecord::Base
end

describe Keytar do
  describe 'requiring Keytar' do
    it 'should load keybuilder into ActiveRecord::Base' do
      describe Bar.ancestors do
        it {should include( KeyBuilder)}
      end
    end
  end
end