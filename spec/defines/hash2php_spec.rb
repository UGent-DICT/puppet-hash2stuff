# frozen_string_literal: true

require 'spec_helper'

describe 'hash2stuff::hash2php' do
  let(:params) do
    {
      file_props: {
        ensure: 'file',
      },
      variables: {
        'foo' => 'bar',
        ['nested', 'subkey'] => ['one', 'two'],
      },
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      if os =~ %r{windows}i
        let(:title) { 'C:\\Temp\\spec_ini.tmp' }
      else
        let(:title) { '/tmp/spec_ini.tmp' }
      end
      it { is_expected.to compile }
      it do
        is_expected.to contain_file(title).with_content(
<<-EOS
<?php
// THIS FILE IS CONTROLLED BY PUPPET

$foo = 'bar';
$nested['subkey'] = array(
  'one',
  'two',
);
EOS
        )
      end
    end
  end
end
