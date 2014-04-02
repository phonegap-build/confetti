module Confetti
  class Config
    class Image 
      attr_accessor :src, :width, :height, :extras, :index, :retain,
        :role, :platform, :main, :density, :state, :qualifier

      def initialize *args
        @src = args.shift
        @height = args.shift
        @width = args.shift

        @extras   = (args.shift || {}).reject do |name, val|
          %w{src height width}.include?(name)
        end

        @index = args.shift

        @role     = @extras['role']
        @platform = @extras['platform']
        @main     = @extras['main']
        @density  = @extras['density']
        @qualifier= @extras['qualifier']
        @state    = @extras['state']
        @retain   = @extras['retain']
      end

      def defined_attrs
        {
            "src" => @src,
            "height" => @height,
            "width" => @width,
            "gap:role" => @role,
            "gap:platform" => @platform,
            "gap:main" => @main,
            "gap:density" => @density,
            "gap:state" => @state,
            "gap:retain" => @retain,
            "gap:qualifier" => @qualifier
        }
      end
    end
  end
end

