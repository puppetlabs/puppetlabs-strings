# frozen_string_literal: true

require 'spec_helper'

require 'puppet-strings/json_schema/p_types'
require 'puppet/test/test_helper'

Puppet::Test::TestHelper.initialize

describe PuppetStrings::JsonSchema::PTypes do
  before(:all) do
    Puppet::Test::TestHelper.before_all_tests()
  end

  after(:all) do
    Puppet::Test::TestHelper.after_all_tests()
  end

  before(:each) do
    Puppet::Test::TestHelper.before_each_test()
  end

  after(:each) do
    Puppet::Test::TestHelper.after_each_test()
  end

  context '#valid_environment?' do
    subject { described_class.valid_environment? }

    after(:each) do
      PuppetStrings::JsonSchema::PTypes.instance_variable_set(:@valid_env, nil)
    end

    context 'without an environment' do
      before(:each) do
        Puppet[:environmentpath] = '/dev/null'
        Puppet.initialize_settings
      end

      it { is_expected.to be false }
    end

    context 'with an environment' do
      before(:each) do
        path = File.expand_path(File.join(__dir__, '..', '..', '..', 'fixtures', 'environments'))
        Puppet[:environmentpath] = path
        Puppet[:environment] = 'testenv'
        Puppet.initialize_settings
      end

      it { is_expected.to be true }
    end

    context 'when receiving an interpolation error' do
      before(:each) do
        path = File.expand_path(File.join(__dir__, '..', '..', '..', 'fixtures', 'environments'))
        Puppet[:environmentpath] = path
        Puppet[:environment] = 'testenv'
        Puppet.initialize_settings
        Puppet::Pal.stubs(:in_environment).with(any_parameters).raises(Puppet::Settings::InterpolationError)
      end

      it { is_expected.to be false }
    end
  end

  context '#puppet_compiler' do
    context 'without a valid environment' do
      before do
        described_class.stubs(:valid_environment?).returns(false)
      end

      it { expect { |b| described_class.puppet_compiler(&b) }.to yield_with_args(Puppet::Pal::CatalogCompiler) }
    end

    context 'with a valid environment' do
      before do
        described_class.stubs(:valid_environment?).returns(true)
      end

      it { expect { |b| described_class.puppet_compiler(&b) }.to yield_with_args(Puppet::Pal::CatalogCompiler) }
    end
  end

  context 'Base#emit' do
    it { expect { described_class::Base.new.emit }.to raise_error(StandardError) }
  end

  context '#ptype_to_schema' do
    let(:code) { nil }

    subject(:ptype) do |example|
      type = described_class.puppet_compiler(code_string: code) do |c|
        c.type(example.description)
      end
      described_class.ptype_to_schema(type)
    end

    context 'when conversion is not implemented' do
      before do
        Object.stubs(:const_get).with("PuppetStrings::JsonSchema::PTypes::PStringType").raises(NameError)
      end

      it 'String' do
        is_expected.to eq(:$comment => 'Conversion for Puppet type PStringType is not implemented yet')
      end
    end

    context 'Any' do
      it 'Any' do
        is_expected.to eq({})
      end
    end

    context 'Array' do
      it 'Array' do
        is_expected.to eq(
          type: 'array'
        )
      end

      it 'Array[String]' do
        is_expected.to eq(
          type: 'array',
          items: {type: 'string'},
        )
      end

      it 'Array[Integer, 2, 3]' do
        is_expected.to eq(
          type: 'array',
          items: {type: 'integer'},
          minItems: 2,
          maxItems: 3,
        )
      end
    end

    context 'Boolean' do
      it 'Boolean' do
        is_expected.to eq(type: 'boolean')
      end
    end

    context 'Collection' do
      it 'Collection' do
        is_expected.to eq({anyOf: [{type: 'object'}, {type: 'array'}]})
      end
    end

    context 'Data' do
      it 'Data' do
        is_expected.to eq({})
      end
    end

    context 'Default' do
      it 'Default' do
        is_expected.to eq({})
      end
    end

    context 'Enum' do
      it 'Enum[red, green, blue]' do
        is_expected.to eq({enum: ['blue', 'green', 'red']})
      end
    end

    context 'Float' do
      it 'Float' do
        is_expected.to eq(type: 'number')
      end

      it 'Float[1.2,5.3]' do
        is_expected.to eq(type: 'number', minimum: 1.2, maximum: 5.3)
      end

      it 'Float[default,5.2]' do
        is_expected.to eq(type: 'number', maximum: 5.2)
      end

      it 'Float[2.3]' do
        is_expected.to eq(type: 'number', minimum: 2.3)
      end
    end

    context 'Hash' do
      it 'Hash' do
        is_expected.to eq(type: 'object')
      end

      it 'Hash[String, String]' do
        is_expected.to eq(type: 'object', additionalProperties: { type: 'string' })
      end

      it 'Hash[Scalar, Integer, 1, 4]' do
        is_expected.to eq(
          type: 'object',
          additionalProperties: { type: 'integer' },
          minProperties: 1,
          maxProperties: 4,
        )
      end
    end

    context 'Integer' do
      it 'Integer' do
        is_expected.to eq(type: 'integer')
      end

      it 'Integer[1,5]' do
        is_expected.to eq(type: 'integer', minimum: 1, maximum: 5)
      end

      it 'Integer[default,5]' do
        is_expected.to eq(type: 'integer', maximum: 5)
      end

      it 'Integer[2]' do
        is_expected.to eq(type: 'integer', minimum: 2)
      end
    end

    context 'NotUndef' do
      it 'NotUndef' do
        is_expected.to eq({not: { type: 'null' } })
      end
    end

    context 'Numeric' do
      it 'Numeric' do
        is_expected.to eq({ type: 'number' })
      end
    end

    context 'Optional' do
      it 'Optional[String]' do
        is_expected.to eq({anyOf: [{type: 'null'}, {type: 'string'}]})
      end
    end

    context 'Pattern' do
      it 'Pattern[/^foobar$/]' do
        is_expected.to eq(type: 'string', pattern: '^foobar$')
      end

      it 'Pattern[/^foobar$/, /^[a-z][0-9]+/]' do
        is_expected.to eq(
          {
            anyOf: [
              {
                type: 'string',
                pattern: '^foobar$',
              },
              {
                type: 'string',
                pattern: '^[a-z][0-9]+',
              },
            ],
          },
        )
      end

      it 'Pattern[/(?<!fizz)buzz/]' do
        is_expected.to include(:$comment => %r{^Unable to convert regex to Javascript})
      end

      it 'Pattern[/(?i:foo)/]' do
        is_expected.to eq(
          type: 'string',
          pattern: '(?:[fF][oO][oO])',
        )
      end

      it 'Pattern[/(?x:foo  bar)/]' do
        is_expected.to eq(
          type: 'string',
          pattern: '(?:foobar)',
        )
      end
    end

    context 'Regexp' do
      it 'Regexp[/^[a-z][a-z0-9]+/]' do
        is_expected.to eq(const: '^[a-z][a-z0-9]+')
      end

      it 'Regexp' do
        is_expected.to eq({type: 'string'})
      end
    end

    context 'Scalar' do
      it 'Scalar' do
        is_expected.to eq({anyOf: [{type: 'number'}, {type: 'string'}, {type: 'boolean'}]})
      end

      it 'ScalarData' do
        is_expected.to eq({anyOf: [{type: 'number'}, {type: 'string'}, {type: 'boolean'}]})
      end
    end

    context 'Strings' do
      it 'String' do
        is_expected.to eq(type: 'string')
      end

      it 'String[1,5]' do
        is_expected.to eq(type: 'string', maxLength: 5, minLength: 1)
      end

      it 'String[default,5]' do
        is_expected.to eq(type: 'string', minLength: 0, maxLength: 5)
      end

      it 'String[1]' do
        is_expected.to eq(type: 'string', minLength: 1)
      end
    end

    context 'Struct' do
      it 'Struct[{foo => String}]' do
        is_expected.to eq(
          {
            type: 'object',
            properties: {
              foo: {
                type: 'string',
              }
            },
            required: [:foo],
            additionalProperties: false,
          }
        )
      end

      it 'Struct[{foo => String, bar => Integer}]' do
        is_expected.to eq(
          {
            type: 'object',
            properties: {
              foo: {
                type: 'string',
              },
              bar: {
                type: 'integer',
              }
            },
            required: [:foo, :bar],
            additionalProperties: false,
          }
        )
      end

      it 'Struct[{foo => String, Optional[bar] => Integer}]' do
        is_expected.to eq(
          {
            type: 'object',
            properties: {
              foo: {
                type: 'string',
              },
              bar: {
                type: 'integer',
              }
            },
            required: [:foo],
            additionalProperties: false,
          }
        )
      end

      it 'Struct[{foo => String, bar => Optional[Integer]}]' do
        is_expected.to eq(
          {
            type: 'object',
            properties: {
              foo: {
                type: 'string',
              },
              bar: {
                anyOf: [
                  {
                    type: 'null',
                  },
                  {
                    type: 'integer',
                  },
                ]
              }
            },
            required: [:foo],
            additionalProperties: false,
          }
        )
      end
    end

    context 'Timestamp' do
      it 'Timestamp' do
        is_expected.to eq(
          {
            anyOf: [
              {
                type: 'string',
                format: 'date-time',
              },
              {
                type: 'string',
                format: 'date',
              },
            ],
          }
        )
      end
    end

    context 'Tuple' do
      it 'Tuple[String, Integer]' do
        is_expected.to eq(
          type: 'array',
          prefixItems: [
            { type: 'string' },
            { type: 'integer' },
          ],
          minItems: 2,
          maxItems: 2,
        )
      end

      it 'Tuple[String, Integer, 1]' do
        is_expected.to eq(
          type: 'array',
          prefixItems: [
            { type: 'string' },
            { type: 'integer' },
          ],
          minItems: 1,
          maxItems: 2,
        )
      end

      it 'Tuple[String, Integer, 1, 4]' do
        is_expected.to eq(
          type: 'array',
          prefixItems: [
            { type: 'string' },
            { type: 'integer' },
          ],
          items: { type: 'integer' },
          minItems: 1,
          maxItems: 4,
        )
      end
    end

    context 'TypeAlias' do
      let(:code) { 'type Foo = Variant[String[1,2], Integer[0,4]]' }
      it 'Foo' do
        is_expected.to eq(
          {
            :$ref => '#/data_type_aliases/foo'
          }
        )
      end
    end

    context 'Undef' do
      it 'Undef' do
        is_expected.to eq({type: 'null'})
      end
    end

    context 'Variant' do
      it 'Variant[String, Integer]' do
        is_expected.to eq(
          {
            anyOf: [
              { type: 'string' },
              { type: 'integer' },
            ]
          }
        )
      end
    end
  end
end
