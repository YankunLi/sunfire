require 'spec_helper'
describe 'sunfire' do

  context 'with defaults for all parameters' do
    it { should contain_class('sunfire') }
  end
end
