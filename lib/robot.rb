# frozen_string_literal: true
require 'letters' if ENV['DEBUG'] && !ENV['DEBUG'].empty?
require 'byebug'  if ENV['DEBUG'] && !ENV['DEBUG'].empty?

# A simple toy robot implementation
class Robot
  VALID_COMMANDS = [
    :place,
    :move,
    :left,
    :right,
    :report
  ].freeze

  VALID_DIRECTIONS = [
    :north,
    :east,
    :south,
    :west
  ].freeze

  attr_reader :x, :y, :direction

  def initialize(grid_size = 5, output = $stdout)
    @x, @y, @direction = nil, nil, nil
    @grid = (0...grid_size)
    @output = output
  end

  def place(x, y, direction)
    if valid_coordinates?(x, y) && valid_direction?(direction)
      @x = x.to_i
      @y = y.to_i
      @direction = direction.downcase.to_sym
    end
  end

  def move
    return unless placed?

    case @direction
    when :north
      @y += 1 if valid_coordinates?(@x, @y + 1)
    when :east
      @x += 1 if valid_coordinates?(@x + 1, @y)
    when :south
      @y -= 1 if valid_coordinates?(@x, @y - 1)
    when :west
      @x -= 1 if valid_coordinates?(@x - 1, @y)
    end
  end

  def right
    return unless placed?

    @direction = VALID_DIRECTIONS[VALID_DIRECTIONS.index(@direction) + 1] || :north
  end

  def left
    return unless placed?

    @direction = VALID_DIRECTIONS[VALID_DIRECTIONS.index(@direction) - 1] || :west
  end

  def report
    return unless placed?

    @output.puts "#{@x},#{@y},#{@direction.upcase}"
  end

  def do(script)
    return unless script

    input = script.kind_of?(IO) ? script : StringIO.new(script)

    parse_script(input.readlines)
    perform

    nil
  end

  def state
    return @x, @y, @direction
  end

  private

  def perform
    @commands.each do |command|
      cmd, args = *command
      next unless placed? || cmd === :place
      send(cmd, *args)
    end
  end

  def parse_script(script_str)
    @commands = []

    script_str.each do |command|
      command, args = command.strip.split(' ')
      command = command.downcase.to_sym

      @commands << [command, parse_args(args)] if valid_command?(command)
    end
  end

  def parse_args(command_args)
    return unless command_args

    parsed_args = command_args.split(',')
    parsed_args_count = parsed_args.count

    raise ArgumentError,
      "Wrong args count given to PLACE command! (expected 3, given #{parsed_args_count})" unless parsed_args_count == 3

    x = parsed_args[0].to_i
    y = parsed_args[1].to_i
    direction = parsed_args[2].downcase.to_sym

    raise ArgumentError,
      "Wrong direction given to PLACE command! (expected one of NORTH, SOUTH, EAST, WEST; given '#{parsed_args[2].to_s})'" unless valid_direction?(direction)

    [x, y, direction]
  end

  def valid_command?(command)
    VALID_COMMANDS.include?(command.to_sym)
  end

  def valid_direction?(directoin)
    VALID_DIRECTIONS.include?(directoin.to_sym)
  end

  def valid_coordinates?(x, y)
    @grid.include?(x) && @grid.include?(y)
  end

  def placed?
    @x && @y && @direction
  end
end

# Toy Robot playground (when executed directly)
if __FILE__ == $PROGRAM_NAME
  # @robot = Robot.new
end
