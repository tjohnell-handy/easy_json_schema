require 'spec_helper'

describe EasyJsonSchema::SchemaManager do
  describe '#new' do
    it 'creates a new manager using schemas from a directory' do
      mgr = EasyJsonSchema::SchemaManager.new(directory: 'spec/test_data/test_schemas')

      expect(mgr.list_schema_titles).to eq ['test1', 'test2', 'test3']
    end

    it 'creates a new manager using schemas from multiple directories' do
      mgr = EasyJsonSchema::SchemaManager.new(directories: ['spec/test_data/test_schemas', 'spec/test_data/test_schemas2'])

      expect(mgr.list_schema_titles).to eq ['test1', 'test2', 'test3', 'test4', 'test5']
    end

    it 'creates a new manager using a schema in a file' do
      mgr = EasyJsonSchema::SchemaManager.new(file: 'spec/test_data/test_schema.json')

      expect(mgr.list_schema_titles).to eq ['test_schema']
    end
  end

  describe '#validate_data' do
    it 'returns the errors as objects' do
      mgr = EasyJsonSchema::SchemaManager.new(file: 'spec/test_data/test_schemas/test1.json')

      data = {
        ok: 'ok',
        correct: 'correct',
        not_string: 'a_string'
      }
      errors = mgr.validate_data('test1',data)

      expect(errors.count).to eq 1

      expect(errors.first[:message]).to match(/of type String did not match the following type: integer/)
    end
  end
end
