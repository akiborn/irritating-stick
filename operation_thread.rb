class OperationThread
  attr_reader :game, :timer, :pipe, :mouse_point, :entrance_x, :exit_x

  include Curses

  def initialize(game, timer, pipe, mouse_point, entrance_x, exit_x)
    @game = game
    @timer = timer
    @pipe = pipe
    @mouse_point = mouse_point
    @entrance_x = entrance_x
    @exit_x = exit_x
  end

  def start
    Thread.new do
      until game.finished?
        sleep 0.0001
        next if valid_mouse_location? && in_time?

        if !in_time?
          notime
        elsif mouse_point.x >= exit_x
          goal
        else
          touch
        end
      end
    end
  end

  private

    def valid_mouse_location?
      mouse_point.absent? ||
        mouse_point.x <= entrance_x ||
        pipe.inner_points.any? { |point| point == [mouse_point.x, mouse_point.y] }
    end

    def in_time?
      timer.time_left > 0
    end

    def goal
      game.goal!
      display_finish('CONGRATULATIONS!')
    end

    def touch
      game.gameover!
      display_finish('OOPS!!')
    end

    def notime
      game.gameover!
      display_finish('TIME IS MONEY...')
    end

    def display_finish(message)
      clear
      setpos(lines / 2, cols / 2 - message.size / 2 - 1)
      addstr(message)
      setpos(lines / 2 + 2, cols / 2 - 10)
      addstr('Press `q\' to quit.')
      setpos(lines / 2 + 3, cols / 2 - 10)
      addstr('Press `r\' to retry.')
    end
end
