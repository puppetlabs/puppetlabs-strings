# frozen_string_literal: true

require 'spec_helper'
require 'puppet-strings/json_schema'
require 'tempfile'
require 'puppet/test/test_helper'

Puppet::Test::TestHelper.initialize

describe PuppetStrings::JsonSchema do
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

  before :each do
    # Populate the YARD registry with Puppet source
    YARD::Parser::SourceParser.parse_string(code, :puppet)
  end

  let(:code) do
    <<~CODE
    # This is a simple struct.
    # @summary Quick summary.
    # @param one The first.
    # @param two The second.
    type Foobar::MyStruct = Struct[{'one' => String, 'two' => Optional[String]}]

    # Simple data type alias
    type Foobar::Simple = String[1,2]

    # A simple class.
    # @todo Do a thing
    # @note Some note
    # @param param1 First param.
    # @param param2 Second param.
    # @param param3 Third param.
    # @param param4 Fourth param.
    class klass(Integer $param1, $param2, Variant[Foobar::Simple] $param3 = hi, Foobar::MyStruct $param4) {
    }
    CODE
  end

  RSpec.shared_examples "correct JSON schema" do
    subject(:output) { JSON.parse(json_output) }

    it 'should include the $schema key' do
      is_expected.to include('$schema' => 'https://json-schema.org/draft/2020-12/schema#')
    end

    it 'should be an object at the top level' do
      is_expected.to include('type' => 'object')
    end

    it 'should allow additional properties' do
      is_expected.to include('additionalProperties' => true)
    end

    it 'should have data type aliases' do
      is_expected.to include('data_type_aliases')
    end

    context 'data type alias Foobar::MyStruct' do
      subject { super().dig('data_type_aliases', 'foobar::mystruct') }

      it 'should have Foobar::MyStruct' do
        is_expected.to be_a(Hash)
      end

      it 'should have $comment' do
        is_expected.to include('$comment' => 'Struct[{\'one\' => String, \'two\' => Optional[String]}]')
      end

      it 'should have type' do
        is_expected.to include('type' => 'object')
      end

      it 'should have additionalProperties' do
        is_expected.to include('additionalProperties' => false)
      end

      it 'should have description' do
        is_expected.to include('description' => 'This is a simple struct.')
      end

      it 'should have markdowndescription' do
        is_expected.to include('markdownDescription' => 'This is a simple struct.')
      end

      it 'should have title' do
        is_expected.to include('title' => 'Quick summary.')
      end

      it 'should have property one' do
        is_expected.to include(
          'properties' => include(
            'one' => {
              'type' => 'string'
            }
          )
        )
      end

      it 'should have property two' do
        is_expected.to include(
          'properties' => include(
            'two' => {
              'anyOf' => [
                { 'type' => 'null' },
                { 'type' => 'string' },
              ]
            }
          )
        )
      end

      it 'should have required' do
        is_expected.to include('required' => ['one'])
      end
    end

    context 'with klass::param1' do
      subject { super().dig('properties', 'klass::param1') }

      it 'should have klass::param1' do
        is_expected.to be_a(Hash)
      end

      it 'should have $comment' do
        is_expected.to include('$comment' => 'Puppet Data type: "Integer"')
      end

      it 'should have description' do
        is_expected.to include('description' => 'First param.')
      end

      it 'should have markdownDescription' do
        is_expected.to include('markdownDescription' => "`[Integer]`\n\nFirst param.\n\n")
      end

      it 'should have type' do
        is_expected.to include('type' => 'integer')
      end
    end

    context 'with klass::param2' do
      subject { super().dig('properties', 'klass::param2') }

      it 'should have klass::param2' do
        is_expected.to be_a(Hash)
      end

      it 'should have $comment' do
        is_expected.to include('$comment' => 'Puppet Data type: "Any"')
      end

      it 'should have description' do
        is_expected.to include('description' => 'Second param.')
      end

      it 'should have markdownDescription' do
        is_expected.to include('markdownDescription' => "`[Any]`\n\nSecond param.\n\n")
      end

      it 'should not have type' do
        is_expected.not_to include('type')
      end
    end

    context 'with Foobar::Simple' do
      subject { super().dig('data_type_aliases', 'foobar::simple') }

      it 'should have foobar::simple' do
        is_expected.to be_a(Hash)
      end

      it 'should have $comment' do
        is_expected.to include('$comment' => 'String[1, 2]')
      end

      it 'should have description' do
        is_expected.to include('description' => 'Simple data type alias')
      end

      it 'should have markdownDescription' do
        is_expected.to include('markdownDescription' => 'Simple data type alias')
      end

      it 'should have type' do
        is_expected.to include('type' => 'string')
      end

      it 'should have title' do
        is_expected.to include('title' => 'Foobar::Simple')
      end

      it 'should have minLength' do
        is_expected.to include('minLength' => 1)
      end

      it 'should have maxLength' do
        is_expected.to include('maxLength' => 2)
      end
    end
  end

  describe 'rendering JSON to a file' do
    let(:json_output) do
      json_output = nil

      Tempfile.open('json') do |file|
        PuppetStrings::JsonSchema.render(file.path, code_string: code)

        json_output = File.read(file.path)
      end

      json_output
    end

    include_examples "correct JSON schema"
  end

  describe 'rendering JSON to stdout' do
    let(:json_output) { @json_output }

    before(:each) do
      output = StringIO.new

      old_stdout = $stdout
      $stdout = output

      PuppetStrings::JsonSchema.render(nil, code_string: code)

      $stdout = old_stdout

      @json_output = output.string
    end

    include_examples "correct JSON schema"
  end
end
