# @summary Converts a puppet hash to YAML string.
Puppet::Functions.create_function(:hash2yaml) do
  # @param input The hash to be converted to YAML
  # @param options A hash of options to control YAML file format
  # @return [String] A YAML formatted string
  # @example Call the function with the $input hash
  #   hash2yaml($input)
  dispatch :yaml do
    param 'Hash', :input
    optional_param 'Hash', :options
  end

  require 'yaml'

  def yaml(input, options = {})
    output = options['symbolize_keys'] ? deep_transform_keys(input) : input

    return "#{options['header']}\n#{output.to_yaml}" unless options['header'].to_s.empty?

    output.to_yaml
  end

  def deep_transform_keys(hash)
    hash.transform_keys(&:to_sym).transform_values { |v| v.is_a?(Hash) ? deep_transform_keys(v) : v }
  end
end
