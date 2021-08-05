# frozen_string_literal: true

module KubeclientNext
  module Kubeconfig
    class Cluster
      attr_reader :name, :insecure_skip_tls_verify, :certificate_authority, :server

      def self.from_hash(hash)
        cluster = hash.fetch("cluster")
        new(
          insecure_skip_tls_verify: cluster.fetch("insecure-skip-tls-verify", false),
          certificate_authority: cluster.fetch("certificate-authority", nil),
          server: cluster.fetch("server"),
          name: hash.fetch("name")
        )
      rescue Psych::Exception, KeyError => e
        raise Error, e
      end

      def initialize(name:, insecure_skip_tls_verify:, certificate_authority:, server:)
        @name = name
        @insecure_skip_tls_verify = insecure_skip_tls_verify
        @certificate_authority = certificate_authority
        @server = URI.parse(server)
      end
    end
  end
end
