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

# Player Health
@player_health = 100
@max_player_health = 100

# Health Bar for Player
@player_health_bar_width = 200
@player_health_bar = Rectangle.new(x: 50, y: 50, width: @player_health_bar_width, height: 20, color: 'red')

# Health Text for Player
@player_health_text = Text.new("#{@player_health}/#{@max_player_health}", x: 260, y: 50, size: 20, color: 'black')

# Enemy
@enemy = Rectangle.new(x: 400, y: 300, width: 50, height: 50, color: 'blue')

# Enemy Health
@enemy_health = 50
@max_enemy_health = 50

# Health Bar for Enemy
@enemy_health_bar_width = 100
@enemy_health_bar = Rectangle.new(x: 400, y: 280, width: @enemy_health_bar_width, height: 10, color: 'green')

# Function to update the player health bar
def update_player_health_bar
  percentage = (@player_health.to_f / @max_player_health.to_f)
  @player_health_bar.width = @player_health_bar_width * percentage
end

# Update the player health text whenever player health changes
def update_player_health_text
  @player_health_text.text = "#{@player_health}/#{@max_player_health}"
end

# Function to update the enemy health bar
def update_enemy_health_bar
  percentage = (@enemy_health.to_f / @max_enemy_health.to_f)
  @enemy_health_bar.width = @enemy_health_bar_width * percentage
end

# Function to simulate the player taking damage
def take_player_damage(damage_amount)
  @player_health -= damage_amount
  @player_health = 0 if @player_health < 0
  update_player_health_bar
  update_player_health_text
end

# Function to simulate the enemy taking damage
def take_enemy_damage(damage_amount)
  @enemy_health -= damage_amount
  @enemy_health = 0 if @enemy_health < 0
  update_enemy_health_bar
end

# Define boundaries
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

# Function to check collision between player and enemy
def check_collision
  if @player.x < @enemy.x + @enemy.width &&
     @player.x + @player.width > @enemy.x &&
     @player.y < @enemy.y + @enemy.height &&
     @player.y + @player.height > @enemy.y
    take_enemy_damage(10) # Adjust the damage amount as needed
    take_player_damage(1) # Simulate player taking damage upon collision
  end
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
