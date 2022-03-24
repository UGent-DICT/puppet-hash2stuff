require 'spec_helper'

describe 'hash2php' do
  let(:example_input) do
    [
      {
        'name' => 'simpleString',
        'value' => 'Simple string',
      },
      {
        'name' => ['nested', 'subkey'],
        'value' => 'Subvalue',
      },
      {
        'name' => 'myArray',
        'value' => ['one', 'two', 'three'],
      },
      {
        'name' => 'myNumber',
        'value' => 13,
      },
      {
        'name' => 'nestedHash',
        'value' => {
          'subArray' => ['ten', 'nine', 8, 7],
          'subString' => 'foobar',
          'subHash' => {
            'foo' => 'bar',
            'oof' => 'rab',
            'subsubHash' => { 'thats' => 'enough' },
          },
        },
      },
    ]
  end

  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(ArgumentError, %r{'hash2php' expects between 1 and 2 arguments, got none}) }
  it { is_expected.to run.with_params({}, {}, {}).and_raise_error(ArgumentError, %r{'hash2php' expects between 1 and 2 arguments, got 3}) }
  it { is_expected.to run.with_params('some string').and_raise_error(ArgumentError, %r{'hash2php' parameter 'input'.*Hash2stuff::Php_settings}) }

  context 'default settings' do
    it 'outputs php code' do
      is_expected.to run.with_params(example_input).and_return(<<-EOS
<?php
// THIS FILE IS CONTROLLED BY PUPPET

$simpleString = 'Simple string';
$nested['subkey'] = 'Subvalue';
$myArray = array(
  'one',
  'two',
  'three',
);
$myNumber = 13;
$nestedHash = array(
  'subArray' => array(
    'ten',
    'nine',
    8,
    7,
  ),
  'subString' => 'foobar',
  'subHash' => array(
    'foo' => 'bar',
    'oof' => 'rab',
    'subsubHash' => array(
      'thats' => 'enough',
    ),
  ),
);
      EOS
                                                              )
    end
  end

  context 'hash input' do
    let(:example_input) do
      {
        'simpleString' => 'Simple String',
        ['nested', 'subKey'] => 'Subvalue',
        ['nested', 'subHash'] => {
          'foo' => 'bar',
          'oof' => 'rab',
        },
      }
    end

    it do
      is_expected.to run.with_params(example_input).and_return(
        <<-EOS
<?php
// THIS FILE IS CONTROLLED BY PUPPET

$simpleString = 'Simple String';
$nested['subKey'] = 'Subvalue';
$nested['subHash'] = array(
  'foo' => 'bar',
  'oof' => 'rab',
);
        EOS
      )
    end
  end

  context 'custom settings' do
    let(:example_input) do
      [{ 'name' => 'foo', 'value' => 'bar' }]
    end

    context 'header' do
      it 'uses a custom header' do
        is_expected.to run
          .with_params(example_input, 'header' => '/* Custom header set */')
          .and_return("<?php\n/* Custom header set */\n\n$foo = 'bar';\n")
      end
      it 'skips an empty header' do
        is_expected.to run
          .with_params(example_input, 'header' => '').and_return("<?php\n\n$foo = 'bar';\n")
      end
    end

    context 'php tags' do
      let(:example_input) do
        [{ 'name' => 'foo', 'value' => 'bar' }]
      end

      let(:settings) do
        {
          'header'    => '',
          'php_open'  => true,
          'php_close' => true,
        }
      end

      describe 'both enabled' do
        it 'prints both' do
          is_expected.to run.with_params(example_input, settings).and_return("<?php\n\n$foo = 'bar';\n\n?>\n")
        end
      end
      describe 'php_close only' do
        let(:settings) { super().merge('php_open' => false, 'php_close' => true) }

        it 'prints only the close tag' do
          is_expected.to run.with_params(example_input, settings).and_return("$foo = 'bar';\n\n?>\n")
        end
      end
      describe 'both off' do
        let(:settings) { super().merge('php_open' => false, 'php_close' => false) }

        it 'prints no tags' do
          is_expected.to run.with_params(example_input, settings).and_return("$foo = 'bar';\n")
        end
      end
    end

    context 'php constants' do
      let(:example_input) do
        [{ 'name' => 'foo', 'value' => 'bar' }]
      end

      let(:settings) do
        {
          'php_constants' => true,
        }
      end

      it 'uses php constants instead of variables' do
        is_expected.to run.with_params(example_input, settings).and_return(
            <<-EOS
<?php
// THIS FILE IS CONTROLLED BY PUPPET

define("FOO", 'bar');
            EOS
        )
      end
    end

    context 'indent' do
      let(:example_input) do
        [
          {
            'name' => 'foo',
            'value' => {
              'array' => ['one', 2],
              'hash' => {
                'sub' => 'value',
              },
            },
          },
        ]
      end

      let(:settings) do
        {
          'header' => '',
          'indent_size' => 2,
          'indent_char' => ' ',
        }
      end

      describe 'custom indent size' do
        let(:settings) { super().merge('indent_size' => 4) }

        it 'uses correct indent size' do
          is_expected.to run.with_params(example_input, settings).and_return(
            <<-EOS
<?php

$foo = array(
    'array' => array(
        'one',
        2,
    ),
    'hash' => array(
        'sub' => 'value',
    ),
);
            EOS
          )
        end
      end

      describe 'custom indent character' do
        let(:settings) { super().merge('indent_char' => "\t") }

        it 'uses correct indent character' do
          is_expected.to run.with_params(example_input, settings).and_return(
            <<-EOS
<?php

$foo = array(
\t\t'array' => array(
\t\t\t\t'one',
\t\t\t\t2,
\t\t),
\t\t'hash' => array(
\t\t\t\t'sub' => 'value',
\t\t),
);
            EOS
          )
        end
      end
    end
  end
end
