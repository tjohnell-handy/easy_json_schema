require 'spec_helper'

describe EasyJsonSchema::SchemaManager do
  describe '#new' do
    subject { EasyJsonSchema::SchemaManager.new(options).schema_titles }

    context 'single directory option' do
      let(:options) { { directory: 'spec/test_data/test_schemas' } }

      it { is_expected.to eq ['test1', 'test2', 'test3'] }

      context 'directory with sub-directories containing schemas' do
        let(:options) { { directory: 'spec/test_data' } }

        it { is_expected.to eq ['test_schema', 'test1', 'test2', 'test3', 'test4', 'test5'] }
      end
    end

    context 'directories option' do
      let(:options) { { directories: ['spec/test_data/test_schemas', 'spec/test_data/test_schemas2'] } }

      it { is_expected.to eq ['test1', 'test2', 'test3', 'test4', 'test5'] }
    end

    context 'file option' do
      let(:options) { { file: 'spec/test_data/test_schema.json' } }

      it { is_expected.to eq ['test_schema'] }
    end
  end

  describe '#validate_data' do
    let(:data) { { ok: 'ok', correct: 'correct', not_string: 'a_string' } }
    subject do
      EasyJsonSchema::SchemaManager.new(file: 'spec/test_data/test_schemas/test1.json')
                                   .validate_data('test1', data)
    end

    it 'returns the errors as objects' do
      expect(subject.count).to eq 1
      expect(subject.first[:message]).to match(/of type String did not match the following type: integer/)
    end
  end
end
