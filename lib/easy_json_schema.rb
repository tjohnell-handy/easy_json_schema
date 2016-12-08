require 'easy_json_schema/version'
require 'easy_json_schema/schema_manager'
require 'easy_json_schema/format_validator'

module EasyJsonSchema
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def self.validate(schema_title:, data:)
    SchemaManager.validate_data(schema_title, data)
  end

  def self.schema_titles
    SchemaManager.schema_titles
  end

  class Configuration
    def add_schema_directory(directory_name)
      SchemaManager.add_schema_directory(directory_name)
    end

    def add_schema_file(filename)
      SchemaManager.add_schema_file(filename)
    end

    def add_schema_from_data(data)
      SchemaManager.add_schema_from_data(data)
    end

    def register_lambda_format_validator(format_name:, validator:, message: nil)
      arguments = { format_name: format_name, validator: validator }
      arguments[:message] = message unless message.nil?

      FormatValidator.register_lambda(arguments)
    end

    def register_object_format_validator(validator)
      FormatValidator.register_object(validator)
    end

    def deregister_format_validator(format_name)
      FormatValidator.deregister_validator(format_name)
    end
  end
end
