# frozen_string_literal: true
module K8y
  module REST
    class ResponseFormatter
      UnsupportedResponseTypeError = Class.new(Error)

      attr_reader :response

      def initialize(response)
        @response = response
      end

      def format(as: :ros)
        case as
        when :ros
          build_recursive_open_struct_response(response.body)
        when :raw
          response
        else
          raise UnsupportedResponseTypeError, as.to_s
        end
      end

      private

      def build_recursive_open_struct_response(body)
        data = JSON.parse(body)
        if item_list?(data)
          data.fetch("items").map { |item| RecursiveOpenStruct.new(item, recurse_over_arrays: true) }
        elsif resources_list?(data)
          data.fetch("resources").map { |item| RecursiveOpenStruct.new(item, recurse_over_arrays: true) }
        else
          RecursiveOpenStruct.new(data, recurse_over_arrays: true)
        end
      end

      def item_list?(data)
        data["kind"] =~ /List$/ && data["items"]
      end

      def resources_list?(data)
        data["kind"] =~ /List$/ && data["resources"]
      end
    end
  end
end
