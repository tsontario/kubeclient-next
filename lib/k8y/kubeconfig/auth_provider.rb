# frozen_string_literal: true

require "recursive-open-struct"

module K8y
  module Kubeconfig
    class AuthProvider < RecursiveOpenStruct
      def present?
        to_h.present?
      end
    end
  end
end
