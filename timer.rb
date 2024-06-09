class Timer
  attr_reader :time_limit, :start_time

  def initialize(time_limit)
    @time_limit = time_limit
  end

  def start!
    @start_time = Time.now.to_f
  end

  def time_left
    time_limit - (Time.now.to_f - start_time)
  end
end
