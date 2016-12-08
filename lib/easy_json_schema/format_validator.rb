module EasyJsonSchema
  class FormatValidator
    class << self
      def register_lambda(format_name:, validator:, message: 'with value `%{value}` is invalid')
        JSON::Validator.register_format_validator(format_name, lambda_proc(validator, message))
      end

      def register_object(validator)
        JSON::Validator.register_format_validator(validator.format_name, object_proc(validator))
      end

      def deregister_format_validator(format_name)
        JSON::Validator.deregister_format_validator(format_name)
      end

      private

      def lambda_proc(f, message)
        -> (value) { raise_error(lambda_message(message, value)) unless f.call(value) }
      end

      def object_proc(validator)
        -> (value) { raise_error(validator.message(value)) unless validator.valid?(value) }
      end

      def raise_error(message)
        raise JSON::Schema::CustomFormatError, message
      end

      def lambda_message(message_template, value)
        message_template.gsub('%{value}', value.to_s)
      end
    end
  end
end
