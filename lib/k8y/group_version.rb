# frozen_string_literal: true

module K8y
  # GroupVersion is a simple representation of a Kubernetes GroupVersion
  class GroupVersion
    attr_reader :group, :version

    # @param [String] group
    # @param [String] version
    def initialize(group:, version:)
      @group = group
      @version = version
    end

    def to_s
      "#{group}/#{version}"
    end

    def to_method_name
      "#{group}_#{version}"
    end
  end
end
