require 'ruby2d'

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
@player_health_text = Text.new("#{@player_health}/#{@max_player_health}", x: 260, y: 50, size: 20, color: 'black')

# Enemy
@enemies = [{
  enemy: Image.new('imgonnasugarcoatit.png', x: 400, y: 300, width: 75, height: 100),
  health: 50,
  alive: true
}]

# Health Bar for Enemy
@enemy_health_bar_width = 100
@enemy_health_bar = Rectangle.new(x: 400, y: 280, width: @enemy_health_bar_width, height: 10, color: 'green')


# Sword Slash
@sword_slash = Rectangle.new(x: 0, y: 0, width: 20, height: 5, color: 'white')
@slash_duration = 200  # Milliseconds the sword slash is visible

def update_sword_slash
  return unless @player_alive

  @sword_slash.x = @player.x + (@player.width / 2) - (@sword_slash.width / 2)
  @sword_slash.y = @player.y + (@player.height / 2) - (@sword_slash.height / 2)
end

def animate_sword_slash
  return unless @player_alive

  @sword_slash.color = 'white'
  after(@slash_duration) { @sword_slash.color = 'black' }  # Make the sword slash invisible after a duration
end

on :key_down do |event|
  case event.key
  when 'space'
    player_attack
  when 'x'
    sword_slash_attack
  end
end

def sword_slash_attack
  return unless @player_alive

  animate_sword_slash
  check_sword_slash_collision
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

  @x_speed -= 4 if $keys_held.include?('a')
  @x_speed += 4 if $keys_held.include?('d')
  @y_speed -= 4 if $keys_held.include?('w')
  @y_speed += 4 if $keys_held.include?('s')
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

    if @player.x < enemy.x + enemy.width &&
       @player.x + @player.width > enemy.x &&
       @player.y < enemy.y + enemy.height &&
       @player.y + @player.height > enemy.y
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
  update_enemy_health_bar
  update_player_health_text

  # Update sword slash position
  update_sword_slash
end


show
