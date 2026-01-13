module Mdsmith
  class Token
    attr_reader :type, :value, :metadata

    def initialize(type, value, metadata = {})
      @type = type
      @value = value
      @metadata = metadata
    end
  end
end
