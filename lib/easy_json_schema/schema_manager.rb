require 'json'
require 'json-schema'

module EasyJsonSchema
  class SchemaManager
    def initialize(data: nil, file: nil, directory: nil, files: [], directories: [])
      @schema_titles_to_ids = {}

      initialize_from_data(data) unless data.nil?

      initialize_from_file(file) unless file.nil?

      files.each { |f| initialize_from_file(f) }

      initialize_from_directory(directory) unless directory.nil?

      directories.each { |d| initialize_from_directory(d) }
    end

    def schema_titles
      @schema_titles_to_ids.keys
    end

    def validate_data(schema_title, data)
      schema = @schema_titles_to_ids[schema_title]
      if schema.nil?
        raise EasyJsonSchema::UnknownSchemaTitle.new(
          "Unknown schema title: #{schema_title}"
        )
      end

      JSON::Validator.fully_validate(schema, data, errors_as_objects: true)
    end

    private

    def initialize_from_directory(directory)
      schema_files(directory).each { |f| initialize_from_file(f) }
    end

    def initialize_from_file(filename)
      initialize_from_data(load_schema_file(filename))
    end

    def initialize_from_data(schema_data)
      raise_if_missing_title!(schema_data)
      raise_if_missing_id!(schema_data)

      schema_title = schema_data['title']
      schema_id = schema_data['id']

      uri = Addressable::URI.parse(schema_data['id'])

      # If we register the schema, the library can make use of it by
      # referencing it by the id
      schema = JSON::Schema.new(schema_data, uri)
      JSON::Validator.add_schema(schema)

      @schema_titles_to_ids[schema_title] = schema_id
    end

    def load_schema_file(filename)
      File.open(filename, 'r') { |f| JSON.load(f) }
    end

    def schema_files(directory)
      Dir.glob(File.join(directory, '**/*.json'))
    end

    def raise_if_missing_title!(data, filename: nil)
      if data['title'].nil?
        raise EasyJsonSchema::MissingSchemaTitle, missing_title_message
      end
    end

    def raise_if_missing_id!(data, filename: nil)
      raise EasyJsonSchema::MisingSchemaId, message if data['id'].nil?
    end

    def missing_title_message(filename)
      if filename.nil?
        'Schema is missing title attribute'
      else
        "Schema from #{filename} is missing title attribute"
      end
    end

    def missing_id_message(filename)
      if filename.nil?
        'Schema is missing id attribute'
      else
        "Schema from '#{filename}' is missing id attribute"
      end
    end
  end

  class SchemaManagerError < StandardError
  end

  class MissingSchemaTitle < SchemaManagerError
  end

  class MissingSchemaId < SchemaManagerError
  end

  class UnknownSchemaTitle < SchemaManagerError
  end
end
