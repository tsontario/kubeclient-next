# frozen_string_literal: true

require_relative "api"

module KubeclientNext
  module Client
    class APIs
      include Enumerable
      def initialize(group_versions:)
        @apis = group_versions.each_with_object({}) do |gv, acc|
          acc[gv.to_sym] = API.new(group_version: gv)
        end
      end

      def each(&block)
        @apis.each { |_, api| yield(api) }
      end
    end
  end
end
