# frozen_string_literal: true

require "test_helper"

module K8y
  class GroupVersionTest < TestCase
    def test_to_s
      gv = GroupVersion.new(group: "group", version: "version")
      assert_equal(gv.to_s, "group/version")
    end
  end
end
