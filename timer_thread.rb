class TimerThread
  attr_reader :game, :timer

  def initialize(game, timer)
    @game = game
    @timer = timer
  end

  def start
    Thread.new do
      timer.start!
      until game.finished?
        sleep 0.0001
        Curses.setpos(Curses.lines - 1, 1)
        Curses.addstr("Time Left: #{timer.time_left.round(2)}")
      end
    end
  end
end
