# frozen_string_literal: true

# @summary Converts an array of variable (struct name, value) to a php file
Puppet::Functions.create_function(:hash2php) do
  # @param input
  #   A custom input format that might be more usefull when using from hiera
  #   It takes an array of Tuples
  #
  # @param options
  #   A hash of options to control the output.
  #
  # @return [String] PHP code.
  #
  # @example Call the function with the $input hash
  #   hash2php($input)
  dispatch :data2php do
    param 'Hash2stuff::Php_settings', :input
    optional_param 'Hash', :options
  end

  dispatch :hash2php do
    param 'Hash', :input
    optional_param 'Hash', :options
  end

  def hash2php(input, options = {})
    # convert input to structed
    converted = []
    input.each do |k,v|
      converted << { 'name' => k, 'value' => v }
    end

    data2php(converted, options)
  end

  def data2php(input, options = {})
    settings = {
      'header'      => '// THIS FILE IS CONTROLLED BY PUPPET',
      'indent_size' => 2,
      'indent_char' => ' ',
      'php_open'    => true,
      'php_close'   => false,
    }
    settings.merge!(options)
    php_settings(settings, input)
  end

  private

  def php_settings(settings, input)
    output = []
    if settings['php_open']
      output << '<?php'
    end
    if settings['header'] and settings['header'].length > 0
      output << settings['header']
    end
    if settings['php_open'] or (settings['header'] and settings['header'].length > 0)
      output << ''
    end
    input.each do |var|
      # If the key is an array, use the first part as the variable name
      # All other parts are nested keys in a hash
      _varname = [ var['name'] ].flatten
      varname = _varname[0]
      sub = _varname[1..-1]

      line = []
      line << sprintf('$%{varname}', varname: varname)

      if sub and sub.length > 0
        line << "['"
        line << sub.join("']['")
        line << "']"
      end

      line << ' = '
      line << php_settings_value(settings, var['value'])
      line << ';'
      output << line.join('')
    end
    if settings['php_close']
      output << "\n?>"
    end
    output << ''
    output.join("\n")
  end

  def php_settings_value(settings, value, level = 0)
    _indent = settings['indent_char'] * settings['indent_size'].to_i
    prefix = _indent.to_s * level
    nprefix = _indent.to_s * (level + 1)

    output = []
    case value
    when String
      output << "'#{value}'"
    when ::Numeric, true, false
      output << value
    when Array
      output << 'array('
      value.each do |v|
        output << sprintf("\n%{prefix}%{value},", prefix: nprefix, value: php_settings_value(settings, v, level + 1))
      end
      output << "\n#{prefix})"
    when Hash
      output << 'array('
      value.each do |k,v|
        output << sprintf("\n%{prefix}%{key} => %{value},", prefix: nprefix, key: "'#{k}'" ,value: php_settings_value(settings, v, level + 1))
      end
      output << "\n#{prefix})"
    end
    output.join('')
  end
end
