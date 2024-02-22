# @summary
#   Defined type provides an implementation of the hash2xml function, creating a XML File.
#
# @param file_props
#   Properties of the target file resource.  Accepts and requires the same parameters of a puppet "file"
#
# @param data
#   A hash to format using xml.
#
# @param options
#   Hash of optional values to pass to the "hash2php" function.  See function for details.
#
# @example
#   hash2stuff::hash2xml { '/path/to/settings.xml':
#     file_props => {
#       ensure => file,
#       owner  => 'root',
#       group  => 'root',
#       mode   => '0644',
#     },
#     data       => {
#       'properties' => {
#         'foo' => 'bar',
#         'oof' => 'rab',
#       },
#     }
#   }
#
define hash2stuff::hash2xml (
  Hash $file_props,
  Hash[String, Any] $data = {},
  Hash $options = {},
) {
  File { $name:
    * => merge($file_props, { 'content' => hash2xml($data, $options) }),
  }
}
