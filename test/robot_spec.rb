# frozen_string_literal: true
require_relative './helper'
require_relative '../lib/robot'

describe 'Robot' do
  before do
    @output = StringIO.new
    @robot = Robot.new(5, @output)
  end

  after do
    @output.close
  end

  it 'must be instantiated with defaults' do
    Robot.new.must_be_instance_of Robot
  end

  it 'must be instantiated with custom grid size' do
    Robot.new(10).must_be_instance_of Robot
  end

  it 'must ignore empty or nil script' do
    @robot.do('').must_be_nil
    @robot.do(nil).must_be_nil
  end

  it 'must ignore any commands before being placed' do
    # methods
    @robot.move.must_be_nil
    @robot.left.must_be_nil
    @robot.right.must_be_nil

    @robot.report
    @output.string.must_be_empty

    # script
    @robot.do <<-SCRIPT
      MOVE
      LEFT
      MOVE
      REPORT
      PLACE 0,0,NORTH
      REPORT
    SCRIPT

    @robot.state.must_equal [0, 0, :north]
  end

  it 'must ignore any unknown commands in the script' do
    # script
    @robot.do <<-SCRIPT
      PLACE 0,0,NORTH
      JUMP
      TAKE_OVER_HUMANITY
      MOVE
      REPORT
    SCRIPT

    @robot.state.must_equal [0, 1, :north]
  end

  it 'must report its position to the output' do
    @robot.do <<-SCRIPT
      PLACE 0,0,NORTH
      MOVE
      REPORT
    SCRIPT

    @output.string.must_equal("0,1,NORTH\n")
  end

  it 'must accept files as script source' do
    File.open('./test/fixtures/robot_1.script') do |script|
      @robot.do script
    end

    @robot.state.must_equal [1, 1, :east]
  end

  it 'must maintain its state' do
    @robot.do('PLACE 0,0,NORTH')
    @robot.do('MOVE')
    @robot.do('RIGHT')
    @robot.do('MOVE')

    @robot.state.must_equal [1, 1, :east]
  end

  it 'must ignore wrong placement' do
    @robot.place(0, 0, :north)

    @robot.do('PLACE 5,5,NORTH')
    @robot.state.must_equal [0, 0, :north]

    @robot.do('PLACE -1,-1,NORTH')
    @robot.state.must_equal [0, 0, :north]
  end

  it '#place must initialise robot\'s position' do
    # method
    @robot.place(1, 1, :south)
    @robot.state.must_equal [1, 1, :south]

    # script
    @robot.do 'PLACE 0,0,NORTH'
    @robot.state.must_equal [0, 0, :north]
  end

  it '#move must move robot in the direction it faces' do
    # method
    @robot.place(1, 1, :north)
    @robot.move
    @robot.state.must_equal [1, 2, :north]

    # script
    @robot.place(1, 1, :south)
    @robot.do 'MOVE'
    @robot.state.must_equal [1, 0, :south]
  end

  it '#right must turn the robot 90° to the right' do
    @robot.place(1, 1, :north)
    @robot.do <<-SCRIPT
      RIGHT
      REPORT
      RIGHT
      REPORT
      RIGHT
      REPORT
      RIGHT
      REPORT
      RIGHT
      REPORT
    SCRIPT

    @output.string.must_equal "1,1,EAST\n1,1,SOUTH\n1,1,WEST\n1,1,NORTH\n1,1,EAST\n"
  end

  it '#left must turn the robot 90° to the left' do
    @robot.place(1, 1, :north)
    @robot.do <<-SCRIPT
      LEFT
      REPORT
      LEFT
      REPORT
      LEFT
      REPORT
      LEFT
      REPORT
      LEFT
      REPORT
    SCRIPT

    @output.string.must_equal "1,1,WEST\n1,1,SOUTH\n1,1,EAST\n1,1,NORTH\n1,1,WEST\n"
  end

  it 'must stay within the grid' do
    # ↙ corner
    @robot.do <<-SCRIPT
      PLACE 0,0,WEST
      MOVE
      LEFT
      MOVE
    SCRIPT
    @robot.state.must_equal [0, 0, :south]

    # ↖ corner
    @robot.do <<-SCRIPT
      PLACE 0,4,NORTH
      MOVE
      LEFT
      MOVE
    SCRIPT
    @robot.state.must_equal [0, 4, :west]

    # ↗ corner
    @robot.do <<-SCRIPT
      PLACE 4,4,NORTH
      MOVE
      RIGHT
      MOVE
    SCRIPT
    @robot.state.must_equal [4,4,:east]

    # ↘ corner
    @robot.do <<-SCRIPT
      PLACE 4,0,SOUTH
      MOVE
      LEFT
      MOVE
    SCRIPT
    @robot.state.must_equal [4,0,:east]
  end

  it 'must survive being controlled by monkey :)' do
    @robot.place(0, 0, :north)

    1000.times do
      command = Robot::VALID_COMMANDS.sample
      args = [rand(5), rand(5), Robot::VALID_DIRECTIONS.sample] if command === :place
      @robot.send(command, *args)
    end
  end

  it '#do must fail on wrong PLACE arguments count' do
    -> {
      @robot.do('PLACE 0,0')
    }.must_raise ArgumentError
  end

  it '#do must fail on wrong direction keyword' do
    -> {
      @robot.do('PLACE 0,0,UPTOTHESTARS')
    }.must_raise ArgumentError
  end
end
