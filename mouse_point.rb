class MousePoint
  attr_reader :x, :y

  def set_coordinates!(x, y)
    @x = x
    @y = y
  end

  def present?
    x.is_a?(Integer) && y.is_a?(Integer)
  end

  def absent?
    !present?
  end
end
