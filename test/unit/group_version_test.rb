# frozen_string_literal: true

require "test_helper"

module KubeclientNext
  class GroupVersionTest < KubeclientNext::TestCase
    def test_to_s
      gv = GroupVersion.new(group: "group", version: "version")
      assert_equal(gv.to_s, "group/version")
    end

    def test_to_sym
      gv = GroupVersion.new(group: "group", version: "version")
      assert_equal(gv.to_sym, :"group/version")
    end
  end
end
