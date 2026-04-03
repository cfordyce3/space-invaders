package game

import rl "vendor:raylib"
// import "core:fmt"

SCREEN_SIZE :: 600

main :: proc() {
  // Window Initiation
  rl.InitWindow(SCREEN_SIZE, SCREEN_SIZE, "Space Invaders")
  defer rl.CloseWindow()

  // FPS Target
  rl.SetTargetFPS(60)

  // Custom Exit Key (CAPS LOCK)
  rl.SetExitKey(rl.KeyboardKey.CAPS_LOCK)
    

  // Game Loop
  for !rl.WindowShouldClose() {
    // Logic



    // Drawing
    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground(rl.BLACK)
  }
}
