module Confetti
  module PhoneGap
    class Plugin < Struct.new(:name, :version, :platforms, :source)
      attr_reader :param_set

      def initialize(name, version, platforms = nil, source = :auto)
        @param_set = TypedSet.new Confetti::Config::Param
        super name, version, platforms, source
      end
    end
  end
end
