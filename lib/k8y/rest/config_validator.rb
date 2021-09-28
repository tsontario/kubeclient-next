# frozen_string_literal: true
module K8y
  module REST
    class ConfigValidator
      class ValidationError < Error
        def initialize(validation_errors)
          super
          @message = "Kubeconfig validation failed with the following errors: " + validation_errors.join(",")
        end
      end

      VALIDATIONS = [
        :validate_auth_info,
        :validate_context,
        :validate_cluster,
        :validate_usable,
      ].freeze

      def initialize(kubeconfig, context:)
        @kubeconfig = kubeconfig
        @context = context
      end

      def validate!
        errors = VALIDATIONS.map { |validation| send(validation) }.compact
        raise ValidationError, errors if errors.present?
      end

      private

      def validate_auth_info
        # TODO
      end

      def validate_context
        # TODO
      end

      def validate_cluster
        # TODO
      end

      def validate_usable
        # TODO
      end
    end
  end
end
