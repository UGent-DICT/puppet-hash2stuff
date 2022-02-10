# frozen_string_literal: true

# Original source: https://github.com/WhatsARanjit/puppet-hash_to_xml

# @summary Converts a hash to a xml snippet.
#
# **Options**
#
# These options can be used to adjust output.
#
# * **`indent_size`** (`Integer`): How many times to repeat indent_char in each additional indentation level. Defaults to `2`.
# * **`indent_char`** (`String`): Which character to use when indenting. Defaults to ` ` (space).
# * **`level`** (`Integer`): Indentation level to start at.
#
Puppet::Functions.create_function(:hash2xml) do
  # Converts a hash to a valid xml snippet
  #
  # @example Create a xml file
  #   hash2xml({
  #     'collection version="1"' => {
  #       'name' => 'Puppetlabs',
  #       'properties' => {
  #         'foo' => 'bar',
  #         'bar' => 'foo',
  #       },
  #       'books' => {
  #         'book' => [
  #           {
  #             "name" => "The Tools for Learning Puppet: Command Line, Vim &amp; Git",
  #             "url"  => "https://puppet.com/resources/ebook/tools-for-learning-puppet",
  #           },
  #           {
  #             "name" => "DevOps Mythbusting",
  #             "url"  => "https://puppet.com/resources/ebook/devops-mythbusting",
  #           },
  #         ],
  #       },
  #     },
  #   })
  #   # =>
  #   # <collection version="1">
  #   #   <name>Puppetlabs</name>
  #   #   <properties>
  #   #     <foo>bar</foo>
  #   #     <bar>foo</bar>
  #   #   </properties>
  #   #   <books>
  #   #     <book>
  #   #       <name>The Tools for Learning Puppet: Command Line, Vim &amp; Git</name>
  #   #       <url>https://puppet.com/resources/ebook/tools-for-learning-puppet</url>
  #   #     </book>
  #   #     <book>
  #   #       <name>DevOps Mythbusting</name>
  #   #       <url>https://puppet.com/resources/ebook/devops-mythbusting</url>
  #   #     </book>
  #   #   </books>
  #   # </collection>
  #
  # @param input A hash to be formatted as xml.
  # @param options A hash of options to control the output.
  dispatch :hash2xml do
    param 'Hash', :input
    optional_param 'Hash', :options
    return_type 'String'
  end

  def hash2xml(input, options = {})
    settings = {
      'level' => 0,
      'indent_size' => 2,
      'indent_char' => "\s",
    }
    settings.merge!(options)
    hash_to_xml(input, settings['level'], settings['indent_char'], settings['indent_size'])
  end

  def calc_indent(level)
    @character * @num * level
  end

  def kv_to_xml(k, v = nil, level = 0, open = true, close = true)
    output = ''
    output += calc_indent(level)
    output += "<#{k}>" if open
    output += v if open && close
    output += "</#{k.split(%r{\s}, 2)[0]}>" if close
    output + "\n"
  end

  def hash_to_xml(input, level = 0, character = "\s", num = 2)
    @character             = character
    @num                   = num
    xml                    = ''
    input.each do |key, value|
      case value
      when String
        xml += kv_to_xml(key, value, level)
      when Hash
        xml += kv_to_xml(key, nil, level, true, false)
        xml += hash_to_xml(value, level + 1, @character, @num)
        xml += kv_to_xml(key, nil, level, false, true)
      when FalseClass
        xml += kv_to_xml(key, nil, level, true, false)
      when Array
        value.each do |v|
          xml += hash_to_xml({ key => v }, level, @character, @num)
        end
      else
        raise ArgumentError, "'hash2xml': unable to convert a value with type %s" % [value.class.name]
      end
    end
    xml
  end
end
