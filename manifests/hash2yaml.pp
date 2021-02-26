# @summary Defined type provides an implementation of the hash2yaml function, creating a YAML file from the input hash
#
# @parameter file_props
#  Properties of the target file resource.  Accepts and requires the same parameters of a puppet "file"
#  
# @parameter data_hash
#   Hash representation of the YAML file.
#
# @parameter options
#   Hash of optional values to pass to the "hash2yaml" function.  See function for details.
#
# @example
#   hash2stuff::hash2yaml { 'namevar':
#     file_props => {
#       ensure => file,
#       owner  => 'root',
#       group  => 'root',
#       mode   => '0644',
#     }
#     data_hash  => {
#       section1 => {
#         key1   => 'value1',
#       }
#     }
#   }
#
define hash2stuff::hash2yaml (
  Hash $file_props,
  Hash $data_hash,
  Hash $options = {},
) {
  File {$name:
    * => merge($file_props, content => hash2yaml($data_hash, $options)),
  }
}
