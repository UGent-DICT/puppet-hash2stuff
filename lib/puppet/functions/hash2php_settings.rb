# frozen_string_literal: true

# Converts a hash to a php settings array with structs to use in the hash2php function.
Puppet::Functions.create_function(:hash2php_settings) do
  # @param input
  #   A hash with keys as variable names and values.
  #
  # @return [Hash2stuff::Php_settings] The converted hash as Php_settings.
  #
  # @example Call the function with the $input hash
  #   hash2php_settings({
  #     'foo' => 'bar',
  #     ['nested', 'subkey'] => 'foobar',
  #   })
  #   # =>
  #   [
  #     { 'name' => 'foo',
  #       'value' => 'bar',
  #     },
  #     { 'name' => ['nested', 'subkey'],
  #       'value' => 'foobar',
  #     },
  #   ]
  #
  dispatch :hash2php_settings do
    param 'Hash', :input
    return_type 'Hash2stuff::Php_settings'
  end

  def hash2php_settings(input)
    # convert input to structed
    converted = []
    input.each do |k, v|
      converted << { 'name' => k, 'value' => v }
    end
    converted
  end
end
