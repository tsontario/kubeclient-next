# frozen_string_literal: true

require "test_helper"

module K8y
  module REST
    class TransportTest < TestCase
      # For most tests, transport config is reconciled with direct data, so we should
      # test the 'read from file' path here, since it's a fairly key workflow
      def test_reconcile_with_data_from_files
        config = render_config
        transport = Transport.from_kubeconfig(config)
        assert_equal("FAKE_CERT", transport.cert_data)
        assert_equal("FAKE_KEY", transport.key_data)
        assert_equal("FAKE_CA", transport.ca_data)
      end

      private

      def render_config
        path = kubeconfig_fixture_path("with_data_from_files", sub_dir: "transport", erb: true)
        template = ERB.new(File.read(path))
        template.filename = path
        rendered = template.result
        Kubeconfig.from_file(StringIO.new(rendered))
      end
    end
  end
end
