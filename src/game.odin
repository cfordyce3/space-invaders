package game

import rl "vendor:raylib"
import "core:fmt"
import "core:math/rand"

TARGET_FPS  :: 240
SCREEN_SIZE :: 600

PLAYER_SPEED :: 200

PROJECTILE_WIDTH        :: 4
PROJECTILE_HEIGHT       :: 20
PROJECTILE_SPEED_PLAYER :: 200

NUM_STARS :: 60


deltaPlayerSpeed: f32
globalCount: u8

centerTop: rl.Vector2 = {SCREEN_SIZE / 2, 0}
centerBot: rl.Vector2 = {SCREEN_SIZE / 2, SCREEN_SIZE}

EnemyRow :: enum {
  TOP    = 40,
  TOPMID = 80,
  BOTMID = 120,
  BOT    = 160
}

// Dynamic array of player's spawned projectiles
projectileList: [dynamic]Projectile

// List of enemies
enemyList: [24]Entity


// Entity stuff
Entity :: struct {
  texture: rl.Texture2D,
  x: f32,
  y: f32,
  health: u8,
}

// Projectile stuff
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

update_projectile :: proc(proj: ^Projectile, enemy: ^Entity) -> (remove: bool = false) {
  if proj.y < 0 do remove = true // if at top of screen

  if rl.CheckCollisionRecs(get_bounding_box(proj), get_bounding_box(enemy)) {
    remove = true
    enemy.health = 0
  }

  proj.y -= f32(proj.speed) * rl.GetFrameTime()

  return // remove = true|false
}


// Star stuff
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

  star.y += deltaPlayerSpeed * 1/2
  if globalCount % 16 == 0 do star.alpha -= 1

  if globalCount == 64 {
    globalCount = 1
  }
}



//
// Reset Game
//
reset_game :: proc(player: ^Entity, stars: ^[NUM_STARS]Star, proj: ^[dynamic]Projectile) {
  // Reset player
  player.x = f32(SCREEN_SIZE/2 - player.texture.width/2)
  player.y = f32(SCREEN_SIZE - SCREEN_SIZE/6)
  player.health = 3

  // Reset stars
  for &star in stars {
    star.x = f32(rand.uint_max(SCREEN_SIZE - 20))
    star.y = f32(rand.uint_range(0, SCREEN_SIZE))
    star.alpha = u8(rand.uint_range(16, 200))
  }
  globalCount = 1
  
  // Reset projectiles
  clear(proj)
  shrink(proj)
  fmt.println("size of list:", len(proj))
  fmt.println("cap of list: ", len(proj))
}
//
//
//

main :: proc() {
  defer delete(projectileList)

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
  rl.UnloadImage(player_sprite)
  defer rl.UnloadTexture(player_texture)

  // Enemy1 sprite
  enemy1_sprite := rl.LoadImage("resources/enemy1.png")
  enemy1_texture := rl.LoadTextureFromImage(enemy1_sprite)
  rl.UnloadImage(enemy1_sprite)
  defer rl.UnloadTexture(enemy1_texture)


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
    y = f32(EnemyRow.TOP),
    health = 1,
  }

  // Stars init
  stars: [NUM_STARS]Star 
  for &star in stars {
    star.x = f32(rand.uint_max(SCREEN_SIZE - 20))
    star.y = f32(rand.uint_range(0, SCREEN_SIZE))
    star.alpha = u8(rand.uint_range(16, 200))
  }
  globalCount = 1


  shootingDelay := 0

  //
  // Game Loop
  for !rl.WindowShouldClose() {
    //
    // Logic
    //

    // Frametime player speed
    deltaPlayerSpeed = PLAYER_SPEED * rl.GetFrameTime()

    if rl.IsKeyPressed(rl.KeyboardKey.R) {
      reset_game(&player, &stars, &projectileList)
    }



    // Player movement
    if rl.IsKeyDown(rl.KeyboardKey.A) || rl.IsKeyDown(rl.KeyboardKey.LEFT) {
      if player.x - deltaPlayerSpeed > 0 do player.x -= deltaPlayerSpeed
    }
    if rl.IsKeyDown(rl.KeyboardKey.D) || rl.IsKeyDown(rl.KeyboardKey.RIGHT) {
      if player.x + f32(player.texture.width) + deltaPlayerSpeed < SCREEN_SIZE do player.x += deltaPlayerSpeed
    }
    // Player shoot
    if rl.IsKeyPressed(rl.KeyboardKey.SPACE) && shootingDelay == 0 {
      // fmt.println("[shoot here]")
      inject_at(&projectileList, 0, Projectile {
        x = player.x + f32(player.texture.width / 2) - 2,
        y = player.y - PROJECTILE_HEIGHT - 2,
        color = rl.SKYBLUE,
        speed = PROJECTILE_SPEED_PLAYER,
      })
      // fmt.println("# of projectiles:", len(projectileList))
      shootingDelay = 60 
    }
    if shootingDelay != 0 do shootingDelay -= 1


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
    globalCount += 1

    // Draw player
    rl.DrawTexture(player.texture, i32(player.x), i32(player.y), rl.WHITE)

    // Draw enemy
    if enemy1.health != 0 do rl.DrawTexture(enemy1.texture, i32(enemy1.x), i32(enemy1.y), rl.WHITE)
    // rl.DrawTexture(enemy1.texture, i32(enemy1.x), i32(EnemyRow.TOPMID), rl.WHITE)
    // rl.DrawTexture(enemy1.texture, i32(enemy1.x), i32(EnemyRow.BOTMID), rl.WHITE)
    // rl.DrawTexture(enemy1.texture, i32(enemy1.x), i32(EnemyRow.BOT), rl.WHITE)
    // rl.DrawRectangleLinesEx(get_bounding_box(enemy1), 1, rl.BLUE)

    // Draw projectiles
    for &proj, index in projectileList {
      rl.DrawRectangle(i32(proj.x), i32(proj.y), PROJECTILE_WIDTH, PROJECTILE_HEIGHT, proj.color)
      if update_projectile(&proj, &enemy1) { 
        unordered_remove(&projectileList, index)
      // fmt.println("# of projectiles:", len(projectileList))
      }
    }

    // Draw center line
    // rl.DrawLineEx(centerTop, centerBot, 2, rl.GREEN)
  }
}
