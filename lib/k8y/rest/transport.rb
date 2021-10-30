# frozen_string_literal: true

module K8y
  module REST
    class Transport
      attr_reader :cert_file, :key_file, :ca_file, :cert_data, :key_data, :ca_data

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

      def reconcile!
        return if reconciled?
        reconcile_cert_data!
        reconcile_key_data!
        reconcile_ca_data!

        @reconciled = true
      end

      def to_faraday_options
        if ca_data
          cert_store = OpenSSL::X509::Store.new
          cert_store.add_cert(OpenSSL::X509::Certificate.new(ca_data))
        end

        {
          client_cert: (OpenSSL::X509::Certificate.new(cert_data) if cert_data),
          client_key: (OpenSSL::PKey::RSA.new(key_data) if key_data),
          cert_store: cert_store,
          verify: OpenSSL::SSL::VERIFY_PEER,
        }
      end

      private

      attr_reader :reconciled
      attr_writer :cert_data, :key_data, :ca_data

      def reconcile_cert_data!
        @cert_data = if cert_data
          Base64.decode64(cert_data)
        elsif cert_file
          File.read(cert_file)
        end
      end

      def reconcile_key_data!
        @key_data = if key_data
          Base64.decode64(key_data)
        elsif key_file
          File.read(key_file)
        end
      end

      def reconcile_ca_data!
        @ca_data = if ca_data
          Base64.decode64(ca_data)
        elsif ca_file
          File.read(ca_file)
        end
      end

      def reconciled?
        reconciled
      end
    end
  end
end
