# frozen_string_literal: true
module KubeclientNext
  class GroupVersion
    attr_reader :group, :version

    def initialize(group:, version:)
      @group = group
      @version = version
    end

    def to_s
      "#{group}/#{version}"
    end

    def to_sym
      to_s.to_sym
    end
  end
end
