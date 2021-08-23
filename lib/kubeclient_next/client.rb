# frozen_string_literal: true
require_relative "client/client"

module KubeclientNext
  module Client
    Error = Class.new(Error)

    DEFAULT_GROUP_VERSIONS = [
      GroupVersion.new(group: "core", version: "v1"),
      GroupVersion.new(group: "apps", version: "v1"),
    ]

    def self.from_config(config, context: nil, group_versions: DEFAULT_GROUP_VERSIONS)
      Client.new(config: config, context: context || config.current_context, group_versions: group_versions)
    end
  end
end
