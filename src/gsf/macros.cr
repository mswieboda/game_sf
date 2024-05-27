module GSF
  private module Util
    # Copy all constants from the namespace into the current namespace
    macro extract(from)
      {% for c in from.resolve.constants %}
        # :nodoc:
        {{c}} = {{from}}::{{c}}{% if c.id.ends_with? "Count" %}.value{% end %}
      {% end %}
    end

    macro axes_moved_helpers(axes)
      {% for axis in axes %}
        def {{axis.id.underscore}}_moved_up?(id : UInt32, amount : Number = AxisMovedThreshold)
          axis_moved?(id, {{axis.id}}Y, {% unless axis == "DPad" %}-{% end %}amount)
        end

        def {{axis.id.underscore}}_moved_up?(amount : Number = AxisMovedThreshold)
          {{axis.id.underscore}}_moved_up?(0, amount)
        end

        def {{axis.id.underscore}}_moved_down?(id : UInt32, amount : Number = AxisMovedThreshold)
          axis_moved?(id, {{axis.id}}Y, {% if axis == "DPad" %}-{% end %}amount)
        end

        def {{axis.id.underscore}}_moved_down?(amount : Number = AxisMovedThreshold)
          {{axis.id.underscore}}_moved_down?(0, amount)
        end

        def {{axis.id.underscore}}_moved_left?(id : UInt32, amount : Number = AxisMovedThreshold)
          axis_moved?(id, {{axis.id}}X, -amount)
        end

        def {{axis.id.underscore}}_moved_left?(amount : Number = AxisMovedThreshold)
          {{axis.id.underscore}}_moved_left?(0, amount)
        end

        def {{axis.id.underscore}}_moved_right?(id : UInt32, amount : Number = AxisMovedThreshold)
          axis_moved?(id, {{axis.id}}X, amount)
        end

        def {{axis.id.underscore}}_moved_right?(amount : Number = AxisMovedThreshold)
          {{axis.id.underscore}}_moved_right?(0, amount)
        end
      {% end %}
    end

    macro axes_just_moved_helpers(axes)
      {% for axis in axes %}
        def {{axis.id.underscore}}_just_moved_up?(id : UInt32)
          axis_just_moved_{% if axis == "DPad" %}positive{% else %}negative{% end %}?(id, {{axis.id}}Y)
        end

        def {{axis.id.underscore}}_just_moved_up?
          {{axis.id.underscore}}_just_moved_up?(0)
        end

        def {{axis.id.underscore}}_just_moved_down?(id : UInt32)
          axis_just_moved_{% if axis == "DPad" %}negative{% else %}positive{% end %}?(id, {{axis.id}}Y)
        end

        def {{axis.id.underscore}}_just_moved_down?
          {{axis.id.underscore}}_just_moved_down?(0)
        end

        def {{axis.id.underscore}}_just_moved_left?(id : UInt32)
          axis_just_moved_negative?(id, {{axis.id}}X)
        end

        def {{axis.id.underscore}}_just_moved_left?
          {{axis.id.underscore}}_just_moved_left?(0)
        end

        def {{axis.id.underscore}}_just_moved_right?(id : UInt32)
          axis_just_moved_positive?(id, {{axis.id}}X)
        end

        def {{axis.id.underscore}}_just_moved_right?
          {{axis.id.underscore}}_just_moved_right?(0)
        end
      {% end %}
    end
  end
end
