# frozen_string_literal: true

require "test_helper"

module KubeclientNext
  module Client
    class APITest < KubeclientNext::TestCase
      def test_path
        core_api = API.new(group_version: GroupVersion.new(group: "core", version: "v1"))
        other_api = API.new(group_version: GroupVersion.new(group: "bogus", version: "v2"))
        assert_equal("/api/v1", core_api.path)
        assert_equal("/apis/bogus/v2", other_api.path)
      end
    end
  end
end
