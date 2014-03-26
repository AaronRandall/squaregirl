require 'gosu'

class Window < Gosu::Window
  WINDOW_WIDTH = 1200
  WINDOW_HEIGHT = 800

  MOVEMENT_INTERVAL = 10

  KEY_LEFT  = 123
  KEY_RIGHT = 124
  KEY_DOWN  = 125
  KEY_UP    = 126

  attr_accessor :objects, :movement_interval

  def initialize
    super WINDOW_WIDTH, WINDOW_HEIGHT, false

    @width = WINDOW_WIDTH
    @height = WINDOW_HEIGHT
    @movement_interval = MOVEMENT_INTERVAL
    @keys_being_pressed = []

    @squareboy = Squareboy.new(self)
    @objects = [Floor.new(self), 
                Block.new(self, 300, 600),
                Block.new(self, 300, 600),
                Block.new(self, 330, 500),
                Block.new(self, 330, 600),
                Block.new(self, 430, 500),
                Block.new(self, 530, 300),
                Block.new(self, 730, 500),
                Block.new(self, 930, 300),
                Block.new(self, 1030, 600),
                Block.new(self, 1130, 500),
                Block.new(self, 1230, 600)
                ]
  end

  def update
    if @keys_being_pressed.count > 0
      perform_key_press_action
    end

    @squareboy.update
    @objects.each do |object|
      object.update
    end
  end

  def draw
    @squareboy.draw

    @objects.each do |object|
      object.draw
    end
  end

  def button_down(input)
    @keys_being_pressed.push(input)
  end

  def button_up(input)
    @keys_being_pressed.delete(input)
  end

  def perform_key_press_action
    if @keys_being_pressed.include? KEY_RIGHT
      @squareboy.move_right
    end

    if @keys_being_pressed.include? KEY_LEFT
      @squareboy.move_left
    end

    if @keys_being_pressed.include? KEY_DOWN
      @squareboy.move_down
    end

    if @keys_being_pressed.include? KEY_UP
      @squareboy.jump
    end
  end

  def move_screen_left
    @objects.each do |object|
      object.x = object.x - MOVEMENT_INTERVAL
    end
  end
end

class Squareboy
  WIDTH = 30
  HEIGHT = 30

  attr_accessor :x, :y, :width, :height

  def initialize(window)
    @window = window
    @x = 10
    @y = 500
    @width = WIDTH
    @height = HEIGHT
    @is_jumping = false
    @color = Gosu::Color::WHITE
    @jump_progress = 0
  end

  def update
    if @jumping
      if @jump_progress < 15 && move_up
        @jump_progress = @jump_progress + 1
      elsif move_down
        @jump_progress = 15
        @jumping = false
      else 
        @jumping = false
        @jump_progress = 0
      end
    else
      move_down
    end
  end

  def draw
    @window.draw_quad(@x, @y, @color,
                      (@x + @width), @y, @color,
                      @x, (@y + @height), @color,
                      (@x + @width), (@y + @height), @color)
  end

  def collided_with_object?(object)
    if (self.x > object.x && self.x < object.x + object.width) &&
       (self.y + self.height >= object.y)
       return true
    end

    return false
  end

  def jump
    @jumping = true
  end

  def move_left
    @window.objects.each do |object|
      # if any of the objects right-hand-sides are touching the left-hand-side of squareboy, prevent movement
      if (@x == (object.x + object.width)) && 
         (((@y > object.y) && @y < (object.y + object.height)) ||
         (((@y + @height) > object.y) && ((@y + @height) < (object.y + object.height))))
        return false
      end
    end

    @x = @x - @window.movement_interval
    return true
  end

  def move_right
    @window.objects.each do |object|
      # if any of the objects right-hand-sides are touching the left-hand-side of squareboy, prevent movement
      if ((@x + @width) == object.x) && 
         (((@y > object.y) && @y < (object.y + object.height)) ||
         (((@y + @height) > object.y) && ((@y + @height) < (object.y + object.height))))
        puts "CANNOT MOVE RIGHT"
        puts "@y=#{@y}, @height=#{@height}, object.y=#{object.y}, object.height=#{object.height}"
        return false
      end
    end

    if @x > (@window.width / 2)
      @window.move_screen_left
    else 
      @x = @x + @window.movement_interval
    end

    return true
  end

  def move_up
    @window.objects.each do |object|
      # if any of the objects bottom-sides are touching the top-side of squareboy, prevent movement
      if (@y == (object.y + object.height)) && 
         (((@x >= object.x) && @x <= (object.x + object.width)) ||
         (((@x + @width) >= object.x) && ((@x + @width) <= (object.x + object.width))))
        return false
      end
    end

    @y = @y - @window.movement_interval
    return true
  end

  def move_down
    @window.objects.each do |object|
      # if any of the objects top-sides are touching the bottom-side of squareboy, prevent movement
      if ((@y + @height) == object.y) && 
         (((@x >= object.x) && @x <= (object.x + object.width)) ||
         (((@x + @width) >= object.x) && ((@x + @width) <= (object.x + object.width))))
        return false
      end
    end

    @y = @y + @window.movement_interval
    return true
  end
end

class Block
  WIDTH = 30
  HEIGHT = 30

  attr_accessor :x, :y, :width, :height

  def initialize(window, x, y)
    @window = window
    @x = x
    @y = y
    @width = WIDTH
    @height = HEIGHT
    @is_jumping = false
    @color = Gosu::Color::RED
  end

  def update
  end

  def draw
    @window.draw_quad(@x, @y, @color,
                      (@x + @width), @y, @color,
                      @x, (@y + @height), @color,
                      (@x + @width), (@y + @height), @color)
  end
end

class Floor
  WIDTH = 3000
  HEIGHT = 30

  attr_accessor :x, :y, :width, :height

  def initialize(window)
    @window = window
    @x = 0
    @y = 700
    @width = WIDTH
    @height = HEIGHT
    @color = Gosu::Color::GREEN
  end

  def update
  end

  def draw
    @window.draw_quad(@x, @y, @color,
                      (@x + @width), @y, @color,
                      @x, (@y + @height), @color,
                      (@x + @width), (@y + @height), @color)
  end
end

Window.new.show
