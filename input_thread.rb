class InputThread
  attr_reader :game, :mouse_point

  def initialize(game, mouse_point)
    @game = game
    @mouse_point = mouse_point
  end

  def start
    Thread.new do
      begin
        # Switch on mouse continous position reporting
        print("\e[?1003h")

        # Also enable SGR extended reporting, because otherwise we can only
        # receive values up to 160x94. Everything else confuses Ruby Curses.
        print("\e[?1006h")

        loop do
          sleep 0.0001
          c = Curses.get_char
          case c
          when 'q'
            game.exit!
            break
          when 'r'
            break if game.gameover || game.goal
          when "\e" # ESC
            get_mouse_coordinates
          end
        end
      ensure
        print("\e[?1003l")
        print("\e[?1006l")
      end
    end
  end

  private

    def get_mouse_coordinates
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
          y = $3.to_i
          _state = $4
          mouse_point.set_coordinates!(x, y)
        end
      end
    end
end
