require 'ruby2d'
set width: 800, height:600
set title: "Game"
set background: "green"
set resizable: true

#character
@player = Image.new('Bungus.png', width:100, height:100)
@player.x = 100
@player.y = 100
@x_speed = 0
@y_speed = 0

#boundaries
min_x = 0
min_y = 0
max_y = Window.height - @player.width
max_x = Window.width - @player.height

# Keep track of keys being held down
$keys_held = []

#movement
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

update do
  @player.x += @x_speed
  @player.y += @y_speed

  if holding?("a") && @player.x > min_x
    image.x -= speed
  end

  if holding?("d") && @player.x < max_x
    image.x += speed
  end

  if holding?("w") && @player.y > min_y
    image.y -= speed
  end

  if holding?("s") && @player.y < max_y
    image.y += speed
  end
  

end

show