# Data type to represent php settings:
#   [ { 'name'  => 'name1',
#       'value' => 'value1',
#     },
#     {
#       'name'  => ['name2', 'sub'],
#       'value' => 2',
#     },
#     ...
#   ]
#
type Hash2stuff::Php_settings = Array[Struct[{
      name  => Variant[String[1], Array[String[1], 1]],
      value => Any,
}]]
