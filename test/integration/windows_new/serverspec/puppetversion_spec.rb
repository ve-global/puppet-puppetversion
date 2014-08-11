require 'spec_helper'

describe windows_scheduled_task('puppet upgrade task') do
  it { should exist }
end
