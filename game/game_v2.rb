require 'ruby2d'

set width: 800, height: 600
set title: "Game"
set background: "green"
set resizable: true


# Character
@player = Image.new('Bungus.png', width: 50, height: 50)
@player.x = 100
@player.y = 100
@x_speed = 0
@y_speed = 0
@current_health = 100
@max_health = 100

# Boundaries
min_x = 0
min_y = 0
max_y = Window.height - @player.height
max_x = Window.width - @player.width

# Keep track of keys being held down
$keys_held = []

# Movement
on :key_down do |event|
  $keys_held << event.key unless $keys_held.include?(event.key)
  update_speed
end

on :key_up do |event|
  $keys_held.delete(event.key)
  update_speed
end

def update_speed
  @x_speed = 0
  @y_speed = 0

  @x_speed -= 2 if $keys_held.include?('a')
  @x_speed += 2 if $keys_held.include?('d')
  @y_speed -= 2 if $keys_held.include?('w')
  @y_speed += 2 if $keys_held.include?('s')
end

speed = 5

#Health

health_bar_width = 200
@health_bar = Rectangle.new(x: 50, y: 50, width: health_bar_width, height: 20, color: 'red')

def update_health_bar
  percentage = (@current_health.to_f / @max_health.to_f)
  @health_bar.width = health_bar_width * percentage
end

# Example: If the player takes damage
def take_damage(damage_amount)
  @current_health -= damage_amount
  @current_health = 0 if @current_health < 0
  update_health_bar
end

# Example: If the player gains health
def gain_health(heal_amount)
  @current_health += heal_amount
  @current_health = @max_health if @current_health > @max_health
  update_health_bar
end

# Add this line after the 'update_health_bar' function
@health_text = Text.new("#{@current_health}/#{@max_health}", x: 260, y: 50, size: 20, color: 'black')

# Update the health text whenever health changes
def update_health_text
  @health_text.text = "#{@current_health}/#{@max_health}"
end



update do

  update_health_bar
  update_health_text

  @player.x += @x_speed
  @player.y += @y_speed

  if @player.x < min_x
    @player.x = min_x
  elsif @player.x > max_x
    @player.x = max_x
  end

  if @player.y < min_y
    @player.y = min_y
  elsif @player.y > max_y
    @player.y = max_y
  end
end

show