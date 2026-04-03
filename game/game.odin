package game

import rl "vendor:raylib"
import "core:fmt"
import "core:math/rand"
import "core:thread"
import "core:time"

TARGET_FPS   :: 240
SCREEN_SIZE  :: 600
PLAYER_SPEED :: 200
NUM_STARS    :: 60

deltaSpeed: f32
starCount: u8

Player :: struct {
  texture: rl.Texture2D,
  x: f32,
  lives: i8,
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

  star.y += deltaSpeed * 4/8
  if starCount % 16 == 0 do star.alpha -= 1

  if starCount == 64 {
    starCount = 1
  }
}

reset_game :: proc(player: ^Player) {
  player.x = f32(SCREEN_SIZE/2 - player.texture.width/2)
  player.lives = 3
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
  player_sprite := rl.LoadImage("resources/player.png")
  player_texture := rl.LoadTextureFromImage(player_sprite)
  rl.UnloadImage(player_sprite)

  // Player init
  player: Player = { 
    texture = player_texture,
    x = f32(SCREEN_SIZE/2 - player_texture.width/2), 
    lives = 3,
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
      reset_game(&player)
    }



    // Player movement
    if rl.IsKeyDown(rl.KeyboardKey.A) || rl.IsKeyDown(rl.KeyboardKey.LEFT) {
      if player.x - deltaSpeed > 0 do player.x -= deltaSpeed
    }
    if rl.IsKeyDown(rl.KeyboardKey.D) || rl.IsKeyDown(rl.KeyboardKey.RIGHT) {
      if player.x + f32(player.texture.width) + deltaSpeed < SCREEN_SIZE do player.x += deltaSpeed
    }



    //
    // Drawing
    //
    rl.BeginDrawing()
    defer rl.EndDrawing()

    // Black background
    rl.ClearBackground(rl.BLACK)

    // Draw stars
    for &star, index in stars {
      // fmt.println(star, index)
      rl.DrawRectangle(i32(star.x), i32(star.y), 2, 5, rl.Color{255, 255, 255, star.alpha}) 
      update_star(&star)
    }
    starCount += 1

    // Draw player
    rl.DrawTexture(player_texture, i32(player.x), i32(SCREEN_SIZE - SCREEN_SIZE/6), rl.WHITE)

  }
}
