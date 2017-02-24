require_relative './lib/robot.rb'

# using methods
robot = Robot.new
robot.move                # ignored cause the robot wasn't placed on the table
robot.place(0, 0, :north) # now the robot is on the table
robot.move                # move North
robot.right               # turn East
4.times { robot.move }    # move to the edge of the 5×5 grid
robot.left                # turn to the North again
3.times { robot.move }    # move to the upper-right corner of the 5×5 grid
robot.report              # => 4,4,NORTH
robot.move                # try to move farther
robot.report              # still '4,4,NORTH' since robot won't move behind the edge

# using script (similar to the previous)
robot = Robot.new
robot.do <<-SCRIPT
  MOVE
  PLACE 0,0,NORTH
  MOVE
  RIGHT
  MOVE
  MOVE
  MOVE
  MOVE
  LEFT
  MOVE
  MOVE
  MOVE
  REPORT
  MOVE
  REPORT
SCRIPT
