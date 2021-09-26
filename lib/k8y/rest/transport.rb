# frozen_string_literal: true
module K8y
  module REST
    class Transport
      attr_reader :cert_data, :key_data, :ca_data

      class << self
        def from_kubeconfig(kubeconfig, context: nil)
          context = context ? context : kubeconfig.current_context
          cluster = kubeconfig.cluster_for_context(context)
          auth_info = kubeconfig.user_for_context(context).auth_info

          transport = new(cert_file: auth_info.client_certificate, key_file: auth_info.client_key,
            ca_file: cluster.certificate_authority, cert_data: auth_info.client_certificate_data,
            key_data: auth_info.client_key_data, ca_data: cluster.certificate_authority_data)
          transport.reconcile!
          transport
        end
      end

      def initialize(cert_file: nil, key_file: nil, ca_file: nil, cert_data: nil, key_data: nil, ca_data: nil)
        @cert_file = cert_file
        @key_file = key_file
        @ca_file = ca_file

        @cert_data = cert_data
        @key_data = key_data
        @ca_data = ca_data
      end

      # TODO: figure out when/where base64 decoding is A: necessary and B: timely
      def reconcile!
        reconcile_cert_data!
        reconcile_key_data!
        reconcile_ca_data!
      end

      private

      attr_writer :cert_data, :key_data, :ca_data

      def reconcile_cert_data!
        unless cert_data
          self.cert_data = File.read(cert_file)
        end
      end

      def reconcile_key_data!
        unless key_data
          self.key_data = File.read(key_file)
        end
      end

      def reconcile_ca_data!
        unless ca_data
          self.ca_data = File.read(ca_file)
        end
      end
    end
  end
end
