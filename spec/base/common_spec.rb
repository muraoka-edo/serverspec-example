require 'spec_helper'

describe command('uname -n') do
  it { should return_stdout 'hogehoge_server' }
end
