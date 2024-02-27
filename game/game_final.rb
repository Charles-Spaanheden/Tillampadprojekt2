require 'ruby2d'

using Ruby2D::DSL

set width: 800, height: 600
set title: "Game"
set background: "black"
set resizable: true

# Character
@player = Image.new('v1.png', width: 100, height: 120)
@player.x = 100
@player.y = 100
@x_speed = 0
@y_speed = 0
@player_alive = true

# Player Health
@player_health = 100
@max_player_health = 100

# Health Bar for Player
@player_health_bar_width = 200
@player_health_bar = Rectangle.new(x: 50, y: 50, width: @player_health_bar_width, height: 20, color: 'red')

# Health Text for Player
@player_health_text = Text.new("#{@player_health}/#{@max_player_health}", x: 130, y: 50, size: 20, color: 'white')

# Enemy
@enemies = [{
  enemy: Image.new('imgonnasugarcoatit.png', x: 400, y: 300, width: 75, height: 100),
  health: 50,
  alive: true
}]

# Health Bar for Enemy
@enemy_health_bar_width = 100
@enemy_health_bar = Rectangle.new(x: 400, y: 280, width: @enemy_health_bar_width, height: 10, color: 'green')

# Max Enemy Health
@max_enemy_health = 50

# Damaging Cube
@damaging_cube = nil
@cube_duration = 1000  # Milliseconds the cube is visible
@cube_start_time = nil
@cube_created = false
@cube_direction = nil

def create_damaging_cube
  return if @damaging_cube || @cube_created

  facing_direction = player_facing_direction

  if facing_direction
    @cube_direction = facing_direction  # Store the initial facing direction
    case facing_direction
    when :right
      @damaging_cube = Rectangle.new(x: @player.x + @player.width, y: @player.y, width: 20, height: 100, color: 'red')
    when :left
      @damaging_cube = Rectangle.new(x: @player.x - 20, y: @player.y, width: 20, height: 100, color: 'red')
    when :up
      @damaging_cube = Rectangle.new(x: @player.x, y: @player.y - 20, width: 100, height: 20, color: 'red')
    when :down
      @damaging_cube = Rectangle.new(x: @player.x, y: @player.y + @player.height, width: 100, height: 20, color: 'red')
    end

    @cube_start_time = Time.now
    @cube_created = true
  end
end

def animate_damaging_cube
  return unless @damaging_cube

  elapsed_time = Time.now - @cube_start_time

  if elapsed_time >= @cube_duration / 1000.0
    @damaging_cube.remove
    @damaging_cube = nil
    @cube_start_time = nil
    @cube_created = false
    @cube_direction = nil  # Reset the stored direction when the cube disappears
  else
    # Move the cube towards the initially stored direction
    case @cube_direction
    when :right
      @damaging_cube.x = @player.x + @player.width
      @damaging_cube.y = @player.y
    when :left
      @damaging_cube.x = @player.x - @damaging_cube.width
      @damaging_cube.y = @player.y
    when :up
      @damaging_cube.x = @player.x
      @damaging_cube.y = @player.y - @damaging_cube.height
    when :down
      @damaging_cube.x = @player.x
      @damaging_cube.y = @player.y + @player.height
    end
  end
end

def player_facing_direction
  if @x_speed > 0
    return :right
  elsif @x_speed < 0
    return :left
  elsif @y_speed < 0
    return :up
  elsif @y_speed > 0
    return :down
  else
    return nil
  end
end

def check_damaging_cube_collision
  return unless @player_alive && @damaging_cube

  # Check for collision with damaging cube and enemy
  if collision?(@damaging_cube, @enemies[0][:enemy])
    take_enemy_damage(0, 20)  # Adjust the damage amount as needed
  end
end

# Function to check collision between two objects
def collision?(obj1, obj2)
  obj1.x < obj2.x + obj2.width &&
    obj1.x + obj1.width > obj2.x &&
    obj1.y < obj2.y + obj2.height &&
    obj1.y + obj1.height > obj2.y
end

# Function to simulate the player taking damage
def take_player_damage(damage_amount)
  return unless @player_alive
  @player_health -= damage_amount
  @player_health = 0 if @player_health < 0
  update_player_health_bar
  update_player_health_text
  check_player_status
end

# Function to simulate the enemy taking damage
def take_enemy_damage(index, damage_amount)
  return unless @enemies[index][:alive]
  @enemies[index][:health] -= damage_amount
  @enemies[index][:health] = 0 if @enemies[index][:health] < 0
  update_enemy_health_bar
  check_enemy_status(index)
end

# Function to update the player health bar
def update_player_health_bar
  percentage = (@player_health.to_f / @max_player_health.to_f)
  @player_health_bar.width = @player_health_bar_width * percentage
end

# Update the player health text whenever player health changes
def update_player_health_text
  @player_health_text.text = "#{@player_health}/#{@max_player_health}"
end

# Function to check the player status and perform actions when the player is dead
def check_player_status
  if @player_health <= 0
    @player_alive = false
    remove_object(@player)
  end
end

# Function to check the enemy status and perform actions when the enemy is dead
def check_enemy_status(index)
  if @enemies[index][:health] <= 0
    @enemies[index][:alive] = false
    remove_object(@enemies[index][:enemy])
  end
end

# Function to remove an object when its health is zero
def remove_object(object)
  object.remove
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
  case event.key
  when 'space'
    create_damaging_cube
  end
end

on :key_held do |event|
  $keys_held << event.key

  # Update speed based on keys held
  @x_speed = 0
  @y_speed = 0

  @x_speed -= 4 if $keys_held.include?('a')
  @x_speed += 4 if $keys_held.include?('d')
  @y_speed -= 4 if $keys_held.include?('w')
  @y_speed += 4 if $keys_held.include?('s')
end
  
  # Add a new :key_up event to handle key release
  on :key_up do |event|
    $keys_held.delete(event.key)
  
    # If no movement keys are held, stop the player
    if $keys_held.none? { |key| ['a', 'd', 'w', 's'].include?(key) }
      @x_speed = 0
      @y_speed = 0
    end
end

# Function to move the enemy towards the player
def move_enemy_towards_player
  return unless @enemies[0][:alive]

  enemy = @enemies[0][:enemy]

  if enemy.x < @player.x
    enemy.x += 1
  elsif enemy.x > @player.x
    enemy.x -= 1
  end

  if enemy.y < @player.y
    enemy.y += 1
  elsif enemy.y > @player.y
    enemy.y -= 1
  end
end

# Function to update the enemy health bar
def update_enemy_health_bar
  return unless @enemies[0][:alive]

  enemy = @enemies[0][:enemy]

  percentage = (@enemies[0][:health].to_f / @max_enemy_health.to_f)
  @enemy_health_bar.width = @enemy_health_bar_width * percentage
  @enemy_health_bar.x = enemy.x + (enemy.width - @enemy_health_bar_width) / 2
  @enemy_health_bar.y = enemy.y - 20
end

# Function to check collision between player and enemy
def check_enemy_collisions
  return unless @player_alive

  @enemies.each do |enemy_data|
    next unless enemy_data[:alive]
    enemy = enemy_data[:enemy]

    if collision?(@player, enemy)
      take_enemy_damage(0, 10) # Adjust the damage amount as needed
      take_player_damage(5)    # Simulate player taking damage upon collision
    end
  end
end

# Function to constrain the player within boundaries
def constrain_player_within_boundaries
  min_x = 0
  min_y = 0
  max_y = Window.height - @player.height
  max_x = Window.width - @player.width

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

# Main game loop
update do
  next unless @player_alive

  # Move the player
  @player.x += @x_speed
  @player.y += @y_speed

  # Move the enemy towards the player
  move_enemy_towards_player

  # Update enemy health bar position
  update_enemy_health_bar

  # Check collisions
  check_enemy_collisions

  # Constrain the player within boundaries
  constrain_player_within_boundaries

  # Update the player health bar and text
  update_player_health_bar
  update_player_health_text

  # Update damaging cube position and check collisions
  animate_damaging_cube
  check_damaging_cube_collision
end

show
