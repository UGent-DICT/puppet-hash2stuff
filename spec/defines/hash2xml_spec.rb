# frozen_string_literal: true

require 'spec_helper'

describe 'hash2stuff::hash2xml' do
  let(:params) do
    {
      file_props: {
        ensure: 'file',
      },
      data: {
        'properties' => {
          'foo' => 'bar',
          'entries' => {
            'entry' => ['one', 'two', 'three'],
          },
        },
      },
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      if %r{windows}i.match?(os)
        let(:title) { 'C:\\Temp\\spec_ini.tmp' }
      else
        let(:title) { '/tmp/spec_ini.tmp' }
      end

      it { is_expected.to compile }
      it do
        is_expected.to contain_file(title).with_content(
          <<-EOS,
<properties>
  <foo>bar</foo>
  <entries>
    <entry>one</entry>
    <entry>two</entry>
    <entry>three</entry>
  </entries>
</properties>
          EOS
        )
      end
    end
  end
end
