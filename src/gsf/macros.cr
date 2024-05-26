module GSF
  private module Util
    # Copy all constants from the namespace into the current namespace
    macro extract(from)
      {% for c in from.resolve.constants %}
        # :nodoc:
        {{c}} = {{from}}::{{c}}{% if c.id.ends_with? "Count" %}.value{% end %}
      {% end %}
    end

    macro stick_directions(axes)
      {% for axis in axes %}
        def {{axis.id.underscore}}_up?(id : UInt32, amount : Number = AxisThreshold)
          axis_moved?(id, {{axis.id}}Y, {% unless axis == "DPad" %}-{% end %}amount)
        end

        def {{axis.id.underscore}}_up?(amount : Number = AxisThreshold)
          {{axis.id.underscore}}_up?(0, amount)
        end

        def {{axis.id.underscore}}_down?(id : UInt32, amount : Number = AxisThreshold)
          axis_moved?(id, {{axis.id}}Y, {% if axis == "DPad" %}-{% end %}amount)
        end

        def {{axis.id.underscore}}_down?(amount : Number = AxisThreshold)
          {{axis.id.underscore}}_down?(0, amount)
        end

        def {{axis.id.underscore}}_left?(id : UInt32, amount : Number = AxisThreshold)
          axis_moved?(id, {{axis.id}}X, -amount)
        end

        def {{axis.id.underscore}}_left?(amount : Number = AxisThreshold)
          {{axis.id.underscore}}_left?(0, amount)
        end

        def {{axis.id.underscore}}_right?(id : UInt32, amount : Number = AxisThreshold)
          axis_moved?(id, {{axis.id}}X, amount)
        end

        def {{axis.id.underscore}}_right?(amount : Number = AxisThreshold)
          {{axis.id.underscore}}_right?(0, amount)
        end
      {% end %}
    end
  end
end
