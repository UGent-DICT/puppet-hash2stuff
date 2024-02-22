require 'rspec-puppet'
require 'rspec-puppet/matchers/run'

# Monkey patch diffable support so we can see what we are doing in the tests.
class RSpec::Puppet::FunctionMatchers::Run
  def diffable?
    true
  end

  def actual
    @actual_return
  end

  def expected
    @expected_return
  end
end
