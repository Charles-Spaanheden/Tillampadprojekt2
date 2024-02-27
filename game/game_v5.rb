require 'ruby2d'

set width: 800, height: 600
set title: "Game"
set background: "green"
set resizable: true

# Character
@player = Image.new('Bungus.png', width: 100, height: 100)
@player.x = 100
@player.y = 100
@x_speed = 0
@y_speed = 0

# Health
@current_health = 100
@max_health = 100

# Health Bar
@health_bar_width = 200
@health_bar = Rectangle.new(x: 50, y: 50, width: @health_bar_width, height: 20, color: 'red')

# Health Text
@health_text = Text.new("#{@current_health}/#{@max_health}", x: 260, y: 50, size: 20, color: 'black')

# Define boundaries
min_x = 0
min_y = 0
max_y = Window.height - @player.height
max_x = Window.width - @player.width

# Enemy
@enemy = Rectangle.new(x: 400, y: 300, width: 50, height: 50, color: 'blue')

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

# Function to update the health bar
def update_health_bar
  percentage = (@current_health.to_f / @max_health.to_f)
  @health_bar.width = @health_bar_width * percentage
end

# Update the health text whenever health changes
def update_health_text
  @health_text.text = "#{@current_health}/#{@max_health}"
end

def update_speed
  @x_speed = 0
  @y_speed = 0

  @x_speed -= 2 if $keys_held.include?('a')
  @x_speed += 2 if $keys_held.include?('d')
  @y_speed -= 2 if $keys_held.include?('w')
  @y_speed += 2 if $keys_held.include?('s')
end

# Function to check collision with the enemy
def check_collision
  if @player.x < @enemy.x + @enemy.width &&
     @player.x + @player.width > @enemy.x &&
     @player.y < @enemy.y + @enemy.height &&
     @player.y + @player.height > @enemy.y
    take_damage(0.5) # Adjust the damage amount as needed
  end
end

# Function to simulate taking damage
def take_damage(damage_amount)
  @current_health -= damage_amount
  @current_health = 0 if @current_health < 0
  update_health_bar
  update_health_text
end

speed = 5

update do
  @player.x += @x_speed
  @player.y += @y_speed

  check_collision

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
