# frozen_string_literal: true
module KubeclientNext
  module Client
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
          data.fetch("items").map { |item| RecursiveOpenStruct.new(item) }
        elsif resources_list?(data)
          data.fetch("resources").map { |item| RecursiveOpenStruct.new(item) }
        else
          RecursiveOpenStruct.new(data)
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
