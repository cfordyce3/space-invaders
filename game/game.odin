package game

import rl "vendor:raylib"
import "core:fmt"
import "core:math/rand"
import "core:thread"
import "core:time"

SCREEN_SIZE  :: 600
PLAYER_SPEED :: 200

deltaSpeed: f32

Player :: struct {
  texture: rl.Texture2D,
  x: f32,
  lives: i8,
}

reset :: proc(player: ^Player) {
  player.x = f32(SCREEN_SIZE/2 - player.texture.width/2)
  player.lives = 3
}

get_star_x :: proc() -> uint {
  return rand.uint_max(SCREEN_SIZE - 20)
}

// Draw a random star
// ONLY to be called post BeginDrawing()
draw_stars :: proc() {
  star_x := get_star_x()
  fmt.println(star_x)
  rl.DrawRectangle(i32(star_x), 10, 20, 20, rl.WHITE)
}

main :: proc() {
  // Window Initiation
  rl.InitWindow(SCREEN_SIZE, SCREEN_SIZE, "Space Invaders")
  defer rl.CloseWindow()

  // FPS Target
  rl.SetTargetFPS(240)

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

  // Threading


  // Game Loop
  for !rl.WindowShouldClose() {
    // Logic

    // Frametime player speed
    deltaSpeed = PLAYER_SPEED * rl.GetFrameTime()

    if rl.IsKeyPressed(rl.KeyboardKey.R) {
      reset(&player)
    }



    // Player movement
    if rl.IsKeyDown(rl.KeyboardKey.A) || rl.IsKeyDown(rl.KeyboardKey.LEFT) {
      if player.x - deltaSpeed > 0 do player.x -= deltaSpeed
    }
    if rl.IsKeyDown(rl.KeyboardKey.D) || rl.IsKeyDown(rl.KeyboardKey.RIGHT) {
      if player.x + f32(player.texture.width) + deltaSpeed < SCREEN_SIZE do player.x += deltaSpeed
    }



    // Drawing
    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground(rl.BLACK)

    rl.DrawTexture(player_texture, i32(player.x), i32(SCREEN_SIZE - SCREEN_SIZE/6), rl.WHITE)

    draw_stars()
  }
}
