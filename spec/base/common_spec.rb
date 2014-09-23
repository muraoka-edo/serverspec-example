require 'spec_helper'

describe command('uname -n') do
  it { should return_stdout "vmcentos70key" }
end
