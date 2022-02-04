# @summary
#   Defined type provides an implementation of the hash2php function, creating a PHP file from the input.
#
# @param file_props
#   Properties of the target file resource.  Accepts and requires the same parameters of a puppet "file"
#
# @param variables
#   Either a hash or Hash2stuff::Php_settings.
#
# @param options
#   Hash of optional values to pass to the "hash2php" function.  See function for details.
#
# @example
#   hash2stuff::hash2php { '/path/to/settings.php':
#     file_props => {
#       ensure => file,
#       owner  => 'root',
#       group  => 'root',
#       mode   => '0644',
#     }
#     variables  => {
#       'foo' => 'bar',
#       'oof' => 'rab',
#     }
#   }
#
define hash2stuff::hash2php (
  Hash $file_props,
  Variant[Hash, Hash2stuff::Php_settings] $variables,
  Hash $options = {},
) {

  File {$name:
    * => merge($file_props, {'content' => hash2php($variables, $options)}),
  }
}
