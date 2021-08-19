# frozen_string_literal: true

require_relative "api"

module KubeclientNext
  module Client
    class APIs
      include Enumerable
      def initialize(group_versions:)
        @apis = group_versions.each_with_object({}) do |gv, acc|
          api = API.new(group_version: gv)
          acc[gv.to_s] = api
          define_singleton_method(gv.to_method_name) { api }
        end
      end

      def each(&block)
        @apis.each { |_, api| yield(api) }
      end
    end
  end
end
