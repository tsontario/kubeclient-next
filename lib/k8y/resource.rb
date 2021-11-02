# frozen_string_literal: true

require "recursive-open-struct"

module K8y
  # Resource is a loose wrapper around RecursiveOpenStruct. It's used to model arbitrary
  # Kubernetes resource objects.
  class Resource < RecursiveOpenStruct
    def initialize(hash, args = {})
      args[:recurse_over_arrays] = true
      super(hash, args)
    end
  end
end
