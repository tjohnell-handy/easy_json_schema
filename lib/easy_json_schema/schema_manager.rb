require 'json'
require 'json-schema'

module EasyJsonSchema
  class SchemaManager
    class << self
      def add_schema_directory(directory_name)
        schema_files(directory_name).each { |f| add_schema_file(f) }
      end

      def add_schema_file(filename)
        add_schema_from_data(load_schema_file(filename))
      end

      def add_schema_from_data(schema_data)
        schema_title, schema_id = schema_title_and_id(schema_data)

        register_schema(schema_id, schema_data)
        schema_titles_to_ids[schema_title] = schema_id
      end

      def schema_titles
        schema_titles_to_ids.keys
      end

      def validate_data(schema_title, data)
        schema = retrieve_schema(schema_title)

        JSON::Validator.fully_validate(schema, data, errors_as_objects: true).map do |hash|
          OpenStruct.new(hash)
        end
      end

      private

      def retrieve_schema(schema_title)
        schema = schema_titles_to_ids[schema_title]

        if schema.nil?
          raise EasyJsonSchema::UnknownSchemaTitle, "Unknown schema title: #{schema_title}"
        end

        schema
      end

      def register_schema(schema_id, schema_data)
        uri = Addressable::URI.parse(schema_id)

        # If we register the schema, the lower level library can make use of it by
        # referencing it by the id
        schema = JSON::Schema.new(schema_data, uri)
        JSON::Validator.add_schema(schema)
      end

      def schema_title_and_id(schema_data)
        raise_if_missing_title!(schema_data)
        raise_if_missing_id!(schema_data)

        [schema_data['title'], schema_data['id']]
      end

      def schema_titles_to_ids
        @schema_titles_to_ids ||= {}
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
