package game

import rl "vendor:raylib"
import "core:fmt"
import "core:math/rand"
import "core:thread"
import "core:time"

TARGET_FPS  :: 240
SCREEN_SIZE :: 600

PLAYER_SPEED :: 200

PROJECTILE_WIDTH  :: 4
PROJECTILE_HEIGHT :: 10

NUM_STARS :: 60


deltaSpeed: f32
starCount: u8

centerTop: rl.Vector2 = {SCREEN_SIZE / 2, 0}
centerBot: rl.Vector2 = {SCREEN_SIZE / 2, SCREEN_SIZE}

Entity :: struct {
  texture: rl.Texture2D,
  x: f32,
  y: f32,
  health: u8,
}

Projectile :: struct {
  x: f32,
  y: f32,
  color: rl.Color,
  speed: i32,
}

spawn_projectile :: proc(proj: Projectile) -> rl.Rectangle {
  return rl.Rectangle {
    x = proj.x,
    y = proj.y,
    width = PROJECTILE_WIDTH,
    height = PROJECTILE_HEIGHT
  }
}

Star :: struct {
  x: f32,
  y: f32,
  alpha: u8,
}

update_star :: proc(star: ^Star) {
  if star.alpha == 16 || star.y > SCREEN_SIZE {
    star.x = f32(rand.uint_max(SCREEN_SIZE - 20))
    star.y = f32(-4)
    star.alpha = u8(rand.uint_range(16, 200))
  }

  star.y += deltaSpeed * 1/2
  if starCount % 16 == 0 do star.alpha -= 1

  if starCount == 64 {
    starCount = 1
  }
}

reset_game :: proc(player: ^Entity, stars: ^[NUM_STARS]Star) {
  player.x = f32(SCREEN_SIZE/2 - player.texture.width/2)
  player.y = f32(SCREEN_SIZE - SCREEN_SIZE/6)
  player.health = 3

  for &star in stars {
    star.x = f32(rand.uint_max(SCREEN_SIZE - 20))
    star.y = f32(rand.uint_range(0, SCREEN_SIZE))
    star.alpha = u8(rand.uint_range(16, 200))
  }
  starCount = 1
}

main :: proc() {
  // Window Initiation
  rl.InitWindow(SCREEN_SIZE, SCREEN_SIZE, "Space Invaders")
  defer rl.CloseWindow()

  // FPS Target
  rl.SetTargetFPS(TARGET_FPS)

  // Custom Exit Key (CAPS LOCK)
  rl.SetExitKey(rl.KeyboardKey.CAPS_LOCK)

  // Asset Loading
  // Player sprite
  player_sprite := rl.LoadImage("resources/player.png")
  player_texture := rl.LoadTextureFromImage(player_sprite)
  defer rl.UnloadTexture(player_texture)
  rl.UnloadImage(player_sprite)

  // Enemy1 sprite
  enemy1_sprite := rl.LoadImage("resources/enemy1.png")
  enemy1_texture := rl.LoadTextureFromImage(enemy1_sprite)
  defer rl.UnloadTexture(enemy1_texture)
  rl.UnloadImage(enemy1_sprite)


  // Player init
  player: Entity = { 
    texture = player_texture,
    x = f32(SCREEN_SIZE/2 - player_texture.width/2), 
    y = f32(SCREEN_SIZE - SCREEN_SIZE/6),
    health = 3,
  }

  // Enemy init
  enemy1: Entity = { 
    texture = enemy1_texture,
    x = f32(SCREEN_SIZE/2 - enemy1_texture.width/2), 
    y = f32(50 + enemy1_texture.height/2), 
    health = 1,
  }

  // Stars init
  stars: [NUM_STARS]Star 
  for &star in stars {
    star.x = f32(rand.uint_max(SCREEN_SIZE - 20))
    star.y = f32(rand.uint_range(0, SCREEN_SIZE))
    star.alpha = u8(rand.uint_range(16, 200))
  }
  starCount = 1



  // Game Loop
  for !rl.WindowShouldClose() {
    //
    // Logic
    //

    // Frametime player speed
    deltaSpeed = PLAYER_SPEED * rl.GetFrameTime()

    if rl.IsKeyPressed(rl.KeyboardKey.R) {
      reset_game(&player, &stars)
    }



    // Player input
    if rl.IsKeyDown(rl.KeyboardKey.A) || rl.IsKeyDown(rl.KeyboardKey.LEFT) {
      if player.x - deltaSpeed > 0 do player.x -= deltaSpeed
    }
    if rl.IsKeyDown(rl.KeyboardKey.D) || rl.IsKeyDown(rl.KeyboardKey.RIGHT) {
      if player.x + f32(player.texture.width) + deltaSpeed < SCREEN_SIZE do player.x += deltaSpeed
    }
    if rl.IsKeyPressed(rl.KeyboardKey.SPACE) {
      fmt.println("[shoot here]")
    }



    //
    // Drawing
    //
    rl.BeginDrawing()
    defer rl.EndDrawing()

    // Black background
    rl.ClearBackground(rl.BLACK)

    // Draw stars
    for &star in stars {
      rl.DrawRectangle(i32(star.x), i32(star.y), 2, 4, rl.Color{255, 255, 255, star.alpha}) 
      update_star(&star)
    }
    starCount += 1

    // Draw player
    rl.DrawTexture(player.texture, i32(player.x), i32(player.y), rl.WHITE)

    // Draw enemy
    rl.DrawTexture(enemy1.texture, i32(enemy1.x), i32(enemy1.y), rl.WHITE)

    // Draw center line
    // rl.DrawLineEx(centerTop, centerBot, 2, rl.GREEN)
  }
}
