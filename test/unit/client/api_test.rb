# frozen_string_literal: true

require "test_helper"

module K8y
  module Client
    class APITest < TestCase
      def test_path
        core_api = api_fixture("core", "v1")
        other_api = api_fixture("bogus", "v2")
        assert_equal("/api/v1", core_api.path)
        assert_equal("/apis/bogus/v2", other_api.path)
      end

      def test_has_api_method?
        api = api_fixture
        refute(api.has_api_method?(:fake_method))
        api.expects(:api_methods).returns({ fake_method: true })
        assert(api.has_api_method?(:fake_method))
      end

      private

      def api_fixture(group = "core", version = "v1")
        API.new(group_version: GroupVersion.new(group: group, version: version))
      end
    end
  end
end
