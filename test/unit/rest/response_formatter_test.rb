# frozen_string_literal: true

require "test_helper"

module K8y
  module REST
    class ResponseFormatterTest < TestCase
      def test_format_raw
        response = mock.responds_like_instance_of(Faraday::Response)
        formatter = ResponseFormatter.new(response)
        assert_equal(response, formatter.format(as: :raw))
      end

      def test_format_ros_single_item
        response = mock.responds_like_instance_of(Faraday::Response)
        response.expects(:body).returns(JSON.dump({ kind: "kind", apiVersion: "v1" }))
        formatted = ResponseFormatter.new(response).format(as: :ros)
        assert_equal("kind", formatted.kind)
        assert_equal("v1", formatted.apiVersion)
      end

      def test_format_ros_collection_of_resources
        body = discovery_response_fixture("test_v1")
        response = mock.responds_like_instance_of(Faraday::Response)
        response.expects(:body).returns(body)

        resources = ResponseFormatter.new(response).format(as: :ros)
        expected = JSON.parse(body)["resources"].map do |resource|
          RecursiveOpenStruct.new(resource, recurse_over_arrays: true)
        end
        assert_equal(expected, resources)
        expected_names = ["testresources", "moretestresources"]
        resources.each { |resource| assert(expected_names.include?(resource.name)) }
      end

      def test_formate_ros_collection_of_items
      end
    end
  end
end
