# frozen_string_literal: true

module K8y
  class GroupVersion
    attr_reader :group, :version

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
