# Original source: https://github.com/WhatsARanjit/puppet-hash_to_xml
Puppet::Functions.create_function(:hash2xml) do
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
    output +="<#{k}>" if open
    output += v if (open and close)
    output += "</#{k.split(/\s/, 2)[0]}>" if close
    output += "\n"
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
        xml += hash_to_xml(value, level+1, @character, @num)
        xml += kv_to_xml(key, nil, level, false, true)
      when FalseClass
        xml += kv_to_xml(key, nil, level, true, false)
      else
        fail('Error')
      end
    end
    return xml
  end
end
