require 'spec_helper'

describe 'puppetversion' do
  context 'do nothing on windows' do
    describe package('puppet') do
      it { should be_installed.with_version('3.4.2') }
    end
  end
end
