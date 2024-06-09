require_relative 'boot'

class Game
  SIDE_PADDING = 20

  include Curses

  attr_reader :exit, :gameover, :goal, :time_limit, :pipe_radius, :mouse_point, :pipe, :timer

  def initialize
    init_screen
    crmode
    noecho
    curs_set(0)
  end

  def run
    until exit
      setup
      threads = []
      threads << input_thread
      threads << timer_thread
      threads << operation_thread
      threads.each(&:join)
    end
  ensure
    close_screen
  end

  def finished?
    goal || gameover || exit
  end

  def goal!
    @goal = true
  end

  def gameover!
    @gameover = true
  end

  def exit!
    @exit = true
  end

  private

    def input_thread
      InputThread.new(self, mouse_point).start
    end

    def timer_thread
      TimerThread.new(self, timer).start
    end

    def operation_thread
      OperationThread.new(self, timer, pipe, mouse_point, 1 + SIDE_PADDING, cols - SIDE_PADDING).start
    end

    def setup
      @exit = false
      @gameover = false
      @goal = false
      select_difficulty
      @mouse_point = MousePoint.new
      @pipe = Pipe.new(1 + SIDE_PADDING, lines / 2, pipe_radius, cols - SIDE_PADDING, lines)
      @timer = Timer.new(time_limit)
      ensure_mouse_on_starting_position
      draw_field
    end

    def select_difficulty
      clear
      Curses.timeout = -1
      stdscr.keypad = true
      setpos(2, 5)
      menu = Menu.new([
        Item.new('Beginner', 'Try this first!'),
        Item.new('Easy', 'No doubt you pass!'),
        Item.new('Normal', 'You\'ve got this!'),
        Item.new('Hard', 'Are you ready?'),
        Item.new('Expert', 'How brilliant!')
      ])
      menu.mark = '* '
      menu.post
      while ch = getch
        begin
          case ch
          when KEY_UP, ?k
            menu.up_item
          when KEY_DOWN, ?j
            menu.down_item
          when ' '
            item = menu.current_item
            set_difficulty(item.name)
            break
          end
        rescue RequestDeniedError
        end
      end
      menu.unpost
      Curses.timeout = 10
      stdscr.keypad = false
    end

    def set_difficulty(name)
      distance = (cols - SIDE_PADDING * 2)
      case name
      when 'Beginner'
        @time_limit = distance / 3
        @pipe_radius = 3
      when 'Easy'
        @time_limit = distance / 6
        @pipe_radius = 3
      when 'Normal'
        @time_limit = distance / 6
        @pipe_radius = 2
      when 'Hard'
        @time_limit = distance / 6
        @pipe_radius = 1
      when 'Expert'
        @time_limit = distance / 12
        @pipe_radius = 1
      end
    end

    def ensure_mouse_on_starting_position
      clear
      (1..SIDE_PADDING).to_a.product((1..lines).to_a).each do |x, y|
        setpos(y - 1, x - 1)
        addstr('/')
      end
      setpos(lines / 2, cols / 2 - 18)
      addstr('Move the mouse pointer to the left.')
      begin
        # Switch on mouse continous position reporting
        print("\e[?1003h")

        # Also enable SGR extended reporting, because otherwise we can only
        # receive values up to 160x94. Everything else confuses Ruby Curses.
        print("\e[?1006h")

        loop do
          c = Curses.get_char
          case c
          when "\e" # ESC
            case Curses.get_char
            when '['
              csi = ""
              loop do
                d = Curses.get_char
                csi += d
                if d.ord >= 0x40 && d.ord <= 0x7E
                  break
                end
              end
              if /<(\d+);(\d+);(\d+)(m|M)/ =~ csi
                _button = $1.to_i
                x = $2.to_i
                _y = $3.to_i
                _state = $4
                break if x <= SIDE_PADDING
              end
            end
          end
        end
      ensure
        print("\e[?1003l")
        print("\e[?1006l")
      end
    end

    def draw_field
      clear
      pipe.generate
      pipe.boundary_points.each do |x, y|
        setpos(y - 1, x - 1)
        addstr('*')
      end
      [1 + SIDE_PADDING, cols - SIDE_PADDING].product((1..lines).to_a).each do |x, y|
        next if (pipe.boundary_points + pipe.inner_points).any? { |point| point == [x, y] }

        setpos(y - 1, x - 1)
        addstr('|')
      end
      setpos(1, 14)
      addstr('START')
      setpos(1, cols - 19)
      addstr('GOAL')
    end
end

game = Game.new
game.run
