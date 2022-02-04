# frozen_string_literal: true

# @summary Converts an array of variable (struct name, value) to a php file
#
# **Input**:
#
# This function can deal with 2 different formats:
#
# * A hash with variable names mapped to values
#   ```puppet
#   hash2php({
#     'name1' => 'value1',
#   })
#   ```
#
# * An array with tuples that represent variables
#   ```puppet
#   hash2php([
#     { 'name'  => 'name1',
#       'value' => 'value1',
#     }
#   ])
#   ```
#
#   This format might be easier to use in combination with hiera when you are using nested assignments.
#
# **Variable names**:
#
# A variable name can be a single string or it can be an array. If it is an array,
# the first element will be used as variable name and all other members of the array
# will be used as sub-keys:
#
#   ```puppet
#   hash2php({['foo', 'bar'] => 'value'})
#   hash2php([{'name' => ['foo', 'bar'], 'value' => 'value'}])
#   ```
#
# Both above examples would result in a single variable foo with subkey bar:
#
#   ```php
#   $foo['bar'] = 'value';
#   ```
# **Options**:
#
# Both variants of the function support the same options in the options hash:
#
# * **`header`** (`String`):
#
#   Configure the header to be shown on top of the file.
#   No comment markings are added. Make sure to add them yourselves.
#
#   Defaults to `// THIS FILE IS CONTROLLED BY PUPPET`
#
# * **`php_open`** (`Boolean`): Flag to include the opening `<?php`. Defaults to `true`.
# * **`php_close`** (`Boolean`): Flag to include the closing `?>`. Defaults to `false`.
# * **`indent_size`** (`Integer`): How many times to repeat indent_char in each additional indentation level. Defaults to `2`.
# * **`indent_char`** (`String`): Which character to use when indenting. Defaults to ` ` (space).
#
#
Puppet::Functions.create_function(:hash2php) do
  # Converts a hash to valid php code (variables)
  #
  # Underlying, it uses the hash2php_settings function and calls itself
  # to generate the actual php code.
  #
  # @example Create a php file from php_settings.
  #   hash2php(
  #     [
  #       { 'name' => 'var1',
  #         'value' => 'value1',
  #       },
  #       { 'name' => 'var2',
  #         'value' => 'value2',
  #       },
  #       { 'name' => ['sub1', 'sub2'],
  #         'value' => 'value3',
  #       },
  #       { 'name' => ['sub1', 'sub3'],
  #         'value' => {'foo' => 'bar'},
  #       },
  #     ],
  #     {'header' => ''}
  #   )
  #   # =>
  #   #################################################################
  #   # <?php
  #   #
  #   # $var1 = 'value1';
  #   # $var2 = 'value2';
  #   # $sub1['sub2'] = 'value3';
  #   # $sub1['sub3'] = array(
  #   #   'foo' => 'bar',
  #   # );
  #
  # @param input
  #   A custom input format that might be more usefull when using from hiera
  #   It takes an array of hashes with the following keys: `name` and `value`.
  #
  # @param options
  #   A hash of options to control the output.
  #
  # @return [String] PHP code.
  dispatch :data2php do
    param 'Hash2stuff::Php_settings', :input
    optional_param 'Hash', :options
    return_type 'String'
  end


  # Convert an array with tuples to valid php code (variables)
  #
  # @example Create variables from a hash
  #   hash2php({
  #     'var1' => 'value1',
  #     'var2' => 'value2',
  #     ['sub1', 'sub2'] => 'value3',
  #   })
  #   # =>
  #   #################################################################
  #   # <?php
  #   # // THIS FILE IS CONTROLLED BY PUPPET
  #   #
  #   # $var1 = 'value1';
  #   # $var2 = 'value2';
  #   # $sub1['sub2'] = 'value3';
  #
  # @example Creating an array without file header.
  #   hash2php(
  #     {
  #       'arr' => ['one', 'two', true, 4],
  #     },
  #     { 'header' => '' }
  #   )
  #   # =>
  #   #################################################################
  #   # <?php
  #   #
  #   # $arr = array(
  #   #   'one',
  #   #   'two',
  #   #   true,
  #   #   4,
  #   # );
  #
  # @param input
  #   A hash with variable and value pairs that are converted to php code.
  # @param options
  #   A hash of options to control the output.
  #
  # @return [String] PHP code.
  dispatch :hash2php do
    param 'Hash', :input
    optional_param 'Hash', :options
    return_type 'String'
  end

  def hash2php(input, options = {})
    converted = call_function('hash2php_settings', input)
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
