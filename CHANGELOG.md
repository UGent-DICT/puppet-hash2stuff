## 2.0.2 (2022-03-28)
- hash2php: Allow using PHP global constants
- Fix small mistake in docs for hash2xml

## 2.0.1 (2022-02-10) - TrueFalse
- Updated to latest pdk template
- Add true as a possible value for hash2xml
- Document true/false usage for hash2xml

## 2.0.0 (2022-02-10) - Fork to UGent
- Merged (upstream) PR to convert to pdk
- Monkeypatch rspec-puppet to help with debugging and development
- Added hash2xml
- Added hash2php

## 1.3.0 (2021-02-28) - Updates contributed by southalc
- Converted to PDK, linted, validated
- Add support for Puppet 7
- Refactored legacy 3.x functions to 4.x API
- Updated unit tests as needed for changes
- Documentation using puppet strings
- Added defined types to complement the respective functions for use from hiera
- Support all releases of puppet supported operating system

## 1.2.1 (2019-06-25)
- Document overlaps with stdlib
- Test on puppet 6
- Simplify testing matrix
- Add support for CentOS/RHEL 8
- Drop support for Debian 7

## 1.2.0 (2018-05-04)
- Add hash2properties function

## 1.1.0 (2018-04-30)
- Add header setting to hash2yaml
- Allow hash2ini to optionally not put quotes around booleans and numeric values
- Drop support for puppet 4.0.x, 4.1.x, and 4.2.x
- Drop support for Debian 6 and Ubuntu 12.04.
- Add support for Debian 9 and Ubuntu 18.04.

## 1.0.2 (2017-07-28)
- Add support for puppet 5.
- Stop supporting and testing on puppet < 3.5, supporting ruby 1.9.3 is becoming
  too hard. The module should still work on puppet < 3.5, its just not being
  tested on puppet < 3.5.

## 1.0.1 (2016-08-06)
- Add support for more operating systems

## 1.0.0 (2016-08-06)
- Initial Release

