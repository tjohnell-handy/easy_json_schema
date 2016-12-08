require 'spec_helper'

module EasyJsonSchema
  describe FormatValidator do
    let(:mgr) { SchemaManager.new(directory: 'spec/test_data/custom_format') }

    subject { mgr.validate_data('custom_format_object', data).first }

    describe '.register_lambda' do
      before(:each) do
        described_class.register_lambda(
          format_name: 'custom_format_string',
          validator: -> (value) { value == 'valid' },
          message: 'with value `%{value}` `%{value}` is wrong!!!'
        )
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

    describe '.register_object' do
      let(:validator) do
        Class.new do
          define_singleton_method(:format_name) { 'custom_format_string' }
          define_singleton_method(:valid?) { |value| value == 'correct' }
          define_singleton_method(:message) { |value| "with value `#{value}` is incorrect" }
        end
      end

      before(:each) { described_class.register_object(validator) }

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
