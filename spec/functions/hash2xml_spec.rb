require 'spec_helper'

describe 'hash2xml' do
  let(:example_input) do
    {
      'sheet' => {
        'head' => {
          'title' => 'Test Xml',
        },
        'entries' => {
          'entry' => [
            {
              'name' => 'foo',
              'tag attribute="foobar"' => 'bar',
            },
            {
              'name' => 'bar',
            },
            {
              'more' => {
                'count' => ['one', 'two', 'three'],
              },
            },
          ],
        },
      },
    }
  end

  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(ArgumentError, %r{'hash2xml' expects between 1 and 2 arguments, got none}) }
  it { is_expected.to run.with_params({}, {}, {}).and_raise_error(ArgumentError, %r{'hash2xml' expects between 1 and 2 arguments, got 3}) }
  it { is_expected.to run.with_params('some string').and_raise_error(ArgumentError, %r{'hash2xml' parameter 'input'}) }

  it 'fails with unsupported value types' do
    is_expected.to run.with_params('foo' => true).and_raise_error(ArgumentError, %r{'hash2xml': unable to convert a value with type TrueClass})
  end

  context 'default settings' do
    it 'outputs xml' do
      is_expected.to run.with_params(example_input).and_return(<<-EOS
<sheet>
  <head>
    <title>Test Xml</title>
  </head>
  <entries>
    <entry>
      <name>foo</name>
      <tag attribute="foobar">bar</tag>
    </entry>
    <entry>
      <name>bar</name>
    </entry>
    <entry>
      <more>
        <count>one</count>
        <count>two</count>
        <count>three</count>
      </more>
    </entry>
  </entries>
</sheet>
      EOS
                                                              )
    end
  end

  context 'custom settings' do
    let(:example_input) do
      {
        'entry' => 'foo',
        'nest' => {
          'entry' => 'bar',
          'nest' => {
            'entry' => 'foobar',
          },
        },
      }
    end

    let(:settings) do
      {
        'indent_size' => 2,
        'indent_char' => "\s",
      }
    end

    context 'level' do
      let(:settings) { super().merge('level' => 2) }

      it 'starts at correct level' do
        is_expected.to run.with_params(example_input, settings).and_return(
          <<-EOS
    <entry>foo</entry>
    <nest>
      <entry>bar</entry>
      <nest>
        <entry>foobar</entry>
      </nest>
    </nest>
          EOS
        )
      end
    end

    context 'indent' do
      describe 'custom indent size' do
        let(:settings) { super().merge('indent_size' => 4) }

        it 'uses correct indent size' do
          is_expected.to run.with_params(example_input, settings).and_return(
            <<-EOS
<entry>foo</entry>
<nest>
    <entry>bar</entry>
    <nest>
        <entry>foobar</entry>
    </nest>
</nest>
            EOS
          )
        end
      end

      describe 'custom indent character' do
        let(:settings) { super().merge('indent_char' => "\t") }

        it 'uses correct indent character' do
          is_expected.to run.with_params(example_input, settings).and_return(
            <<-EOS
<entry>foo</entry>
<nest>
\t\t<entry>bar</entry>
\t\t<nest>
\t\t\t\t<entry>foobar</entry>
\t\t</nest>
</nest>
            EOS
          )
        end
      end
    end
  end
end
