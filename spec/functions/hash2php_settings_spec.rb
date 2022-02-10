require 'spec_helper'

describe 'hash2php_settings' do
  let(:input) do
    {
      'simple' => 'string',
      ['nested', 'with', 'subkeys'] => { 'value' => 'subkey' },
    }
  end

  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(ArgumentError, %r{'hash2php_settings' expects 1 argument, got none}) }
  it { is_expected.to run.with_params({}, {}).and_raise_error(ArgumentError, %r{'hash2php_settings' expects 1 argument, got 2}) }
  it { is_expected.to run.with_params('some string').and_raise_error(ArgumentError, %r{'hash2php_settings' parameter 'input' expects a Hash value, got String}) }

  it 'converts a hash to php settings' do
    is_expected.to run.with_params(input).and_return(
      [
        { 'name' => 'simple', 'value' => 'string' },
        {
          'name' => ['nested', 'with', 'subkeys'],
          'value' => { 'value' => 'subkey' },
        },
      ],
    )
  end
end
