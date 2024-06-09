class Pipe
  attr_reader :entrance_center_x, :entrance_center_y, :radius, :exit_x, :max_y, :current_center_x, :current_center_y, :inner_points, :boundary_points

  def initialize(entrance_center_x, entrance_center_y, radius, exit_x, max_y)
    @entrance_center_x = entrance_center_x
    @entrance_center_y = entrance_center_y
    @radius = radius
    @exit_x = exit_x
    @max_y = max_y
  end

  def generate
    @current_center_x = entrance_center_x
    @current_center_y = entrance_center_y
    @inner_points = []
    @boundary_points = []

    while current_center_x <= exit_x
      ring = Ring.new(current_center_x, current_center_y, radius)
      @inner_points += ring.inner_points
      @boundary_points += ring.boundary_points

      @current_center_x += 1
      @current_center_y = select_forward_center_y
    end
  end

  private

    def select_forward_center_y
      loop do
        selected_y = current_center_y + [-1, 0, 1].sample
        return selected_y if selected_y - radius - 1 >= 1 && selected_y + radius + 1 <= max_y
      end
    end

    class Ring
      attr_reader :center_point_x, :center_point_y, :radius

      def initialize(center_point_x, center_point_y, radius)
        @center_point_x = center_point_x
        @center_point_y = center_point_y
        @radius = radius
      end

      def inner_points
        ((center_point_y - radius)..(center_point_y + radius)).map { |y| [center_point_x, y] }
      end

      def boundary_points
        [[center_point_x, center_point_y - radius - 1], [center_point_x, center_point_y + radius + 1]]
      end
    end
end
