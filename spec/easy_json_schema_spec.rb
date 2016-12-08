require 'spec_helper'

describe EasyJsonSchema do
  it 'has a version number' do
    expect(EasyJsonSchema::VERSION).not_to be nil
  end

  before(:each) do
    described_class.configure do |config|
      config.add_schema_directory('spec/test_data/test_schemas')
      config.add_schema_file('spec/test_data/test_schema.json')
    end
  end

  describe '.schema_titles' do
    subject { described_class.schema_titles }

    it { is_expected.to eq ['test1', 'test2', 'test3', 'test_schema'] }
  end

  describe '.validate' do
    let(:data) { { ok: 'ok', correct: 'correct', not_string: 'a_string' } }

    subject { described_class.validate(schema_title: 'test1', data: data) }

    it 'returns the errors as objects' do
      expect(subject.count).to eq 1
      expect(subject.first.message).to match(/of type String did not match the following type: integer/)
    end
  end

  describe 'custom format validation' do
    subject { described_class.validate(schema_title: 'custom_format_object', data: data).first }

    before(:each) do
      described_class.configure do |config|
        config.add_schema_directory('spec/test_data/custom_format')
      end
    end

    describe '.register_lambda_format_validator' do
      before(:each) do
        described_class.configure do |config|
          config.register_lambda_format_validator(
            format_name: 'custom_format_string',
            validator: -> (value) { value == 'valid' },
            message: 'with value `%{value}` `%{value}` is wrong!!!'
          )
        end
      end

      context 'valid format' do
        let(:data) { { custom_format_string: 'valid' } }

        it { is_expected.to be_nil }
      end

      context 'invalid format' do
        let(:data) { { custom_format_string: 'invalid' } }

        it 'has correct message' do
          expect(subject.message).to eq(
            "The property '#/custom_format_string' with value `invalid` `invalid` is wrong!!! " +
            "in schema custom_format_string.json"
          )
        end
      end
    end

    describe '.register_object_format_validator' do
      let(:validator) do
        Class.new do
          define_singleton_method(:format_name) { 'custom_format_string' }
          define_singleton_method(:valid?) { |value| value == 'correct' }
          define_singleton_method(:message) { |value| "with value `#{value}` is incorrect" }
        end
      end

      before(:each) { described_class.configuration.register_object_format_validator(validator) }

      context 'valid format' do
        let(:data) { { custom_format_string: 'correct' } }

        it { is_expected.to be_nil }
      end

      context 'invalid format' do
        let(:data) { { custom_format_string: 'incorrect' } }

        it 'has correct message' do
          expect(subject.message).to eq(
            "The property '#/custom_format_string' with value `incorrect` is incorrect " +
            "in schema custom_format_string.json"
          )
        end
      end
    end
  end
end
