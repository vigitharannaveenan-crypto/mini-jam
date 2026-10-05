package main

import rl "vendor:raylib"
import "core:math"

Game_State :: enum {
    Title,
    Playing,
    Won,
    Lost,
}

Enemy :: struct {
    position: rl.Vector2,
    health: int,
    active: bool,
}

Bullet :: struct {
    position: rl.Vector2,
    velocity: rl.Vector2,
    damage: int,
    piercing: bool,
    active: bool,
}

spawn_position :: proc() -> rl.Vector2 {
    switch rl.GetRandomValue(0, 3) {
    case 0:
        return {0, f32(rl.GetRandomValue(100, 620))}
    case 1:
        return {960, f32(rl.GetRandomValue(100, 620))}
    case 2:
        return {f32(rl.GetRandomValue(20, 940)), 90}
    case:
        return {f32(rl.GetRandomValue(20, 940)), 640}
    }
}

main :: proc() {
    rl.InitWindow(960, 640, "Blood Budget")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    state: Game_State = .Title
    player := rl.Vector2{480, 350}
    health := 100
    kills := 0

    enemies: [24]Enemy
    bullets: [48]Bullet

    spawn_timer: f32 = 0
    shot_cooldown: f32 = 0
    damage_cooldown: f32 = 0
    elapsed: f32 = 0

    for !rl.WindowShouldClose() {
        dt := min(rl.GetFrameTime(), f32(0.05))

        // Reset every part of the run.
        if state != .Playing && rl.IsKeyPressed(.ENTER) {
            player = {480, 350}
            health = 100
            kills = 0
            enemies = {}
            bullets = {}
            spawn_timer = 0
            shot_cooldown = 0
            damage_cooldown = 0
            elapsed = 0
            state = .Playing
        }

        if state == .Playing {
            elapsed += dt
            spawn_timer -= dt
            shot_cooldown = max(f32(0), shot_cooldown - dt)
            damage_cooldown = max(f32(0), damage_cooldown - dt)

            // Movement.
            direction := rl.Vector2{0, 0}
            if rl.IsKeyDown(.W) { direction.y -= 1 }
            if rl.IsKeyDown(.S) { direction.y += 1 }
            if rl.IsKeyDown(.A) { direction.x -= 1 }
            if rl.IsKeyDown(.D) { direction.x += 1 }

            if direction.x != 0 && direction.y != 0 {
                direction.x *= 0.70710678
                direction.y *= 0.70710678
            }

            player.x += direction.x * 250 * dt
            player.y += direction.y * 250 * dt
            player.x = clamp(player.x, f32(20), f32(940))
            player.y = clamp(player.y, f32(110), f32(620))

            // Spawn enemies into unused array slots.
            if spawn_timer <= 0 {
                for &enemy in enemies {
                    if !enemy.active {
                        enemy.position = spawn_position()
                        enemy.health = 1
                        if rl.GetRandomValue(0, 3) == 0 {
                            enemy.health = 3
                        }
                        enemy.active = true
                        break
                    }
                }
                spawn_timer = max(f32(0.45), 1.3 - elapsed * 0.008)
            }

            // Select the shot type.
            normal := rl.IsMouseButtonPressed(.LEFT)
            strong := rl.IsMouseButtonPressed(.RIGHT)

            if (normal || strong) && shot_cooldown <= 0 {
                cost := 2
                damage := 1
                speed: f32 = 600
                cooldown: f32 = 0.18

                if strong {
                    cost = 8
                    damage = 3
                    speed = 450
                    cooldown = 0.55
                }

                mouse := rl.GetMousePosition()
                aim := rl.Vector2{
                    mouse.x - player.x,
                    mouse.y - player.y,
                }
                length := math.sqrt(aim.x * aim.x + aim.y * aim.y)

                // Keep at least one health and avoid zero-length aim.
                if health > cost && length > 0 {
                    for &bullet in bullets {
                        if !bullet.active {
                            bullet.position = player
                            bullet.velocity = {
                                aim.x / length * speed,
                                aim.y / length * speed,
                            }
                            bullet.damage = damage
                            bullet.piercing = strong
                            bullet.active = true

                            // Charge only when a bullet was created.
                            health -= cost
                            shot_cooldown = cooldown
                            break
                        }
                    }
                }
            }

            // Enemies chase the player.
            for &enemy in enemies {
                if !enemy.active { continue }

                chase := rl.Vector2{
                    player.x - enemy.position.x,
                    player.y - enemy.position.y,
                }
                length := math.sqrt(
                    chase.x * chase.x + chase.y * chase.y,
                )
                speed := min(f32(180), 95 + elapsed * 0.4)

                if length > 0 {
                    step := min(speed * dt, length)
                    enemy.position.x += chase.x / length * step
                    enemy.position.y += chase.y / length * step
                }
            }

            // Move bullets and check their hits.
            for &bullet in bullets {
                if !bullet.active { continue }

                bullet.position.x += bullet.velocity.x * dt
                bullet.position.y += bullet.velocity.y * dt

                if bullet.position.x < -10 ||
                   bullet.position.x > 970 ||
                   bullet.position.y < -10 ||
                   bullet.position.y > 650 {
                    bullet.active = false
                    continue
                }

                bullet_radius: f32 = 6
                if bullet.piercing { bullet_radius = 10 }

                for &enemy in enemies {
                    if !enemy.active { continue }

                    if rl.CheckCollisionCircles(
                        bullet.position, bullet_radius,
                        enemy.position, 18,
                    ) {
                        enemy.health -= bullet.damage

                        if enemy.health <= 0 {
                            enemy.active = false
                            kills += 1
                            health = min(100, health + 6)
                        }

                        // Piercing shots defeat either enemy type
                        // in one hit, so they cannot repeatedly
                        // damage the same surviving enemy.
                        if !bullet.piercing {
                            bullet.active = false
                            break
                        }
                    }
                }
            }

            // Contact damage: at most once per second.
            for &enemy in enemies {
                if !enemy.active { continue }

                if damage_cooldown <= 0 &&
                   rl.CheckCollisionCircles(
                       player, 20, enemy.position, 18,
                   ) {
                    health = max(0, health - 20)
                    damage_cooldown = 1
                    enemy.active = false
                    break
                }
            }

            // Losing takes priority if both happen this frame.
            if health <= 0 {
                state = .Lost
            } else if kills >= 30 {
                state = .Won
            }
        }

        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)

        switch state {
        case .Title:
            rl.DrawText("BLOOD BUDGET", 260, 140, 40, rl.RED)
            rl.DrawText("Your health is your ammunition.", 230, 210, 24, rl.WHITE)
            rl.DrawText("WASD: Move | Mouse: Aim", 260, 260, 24, rl.WHITE)
            rl.DrawText("Left click: Normal shot (2 health)", 200, 305, 24, rl.YELLOW)
            rl.DrawText("Right click: Piercing shot (8 health)", 180, 350, 24, rl.SKYBLUE)
            rl.DrawText("Each kill restores 6 health. Contact costs 20.", 120, 400, 22, rl.WHITE)
            rl.DrawText("Defeat 30 enemies to win.", 270, 445, 24, rl.WHITE)
            rl.DrawText("Press ENTER to start", 280, 510, 28, rl.GREEN)

        case .Playing:
            rl.DrawLine(0, 90, 960, 90, rl.GRAY)

            rl.DrawText("HEALTH / AMMO", 20, 12, 20, rl.WHITE)
            rl.DrawRectangle(20, 42, 200, 20, rl.DARKGRAY)
            rl.DrawRectangle(20, 42, i32(health * 2), 20, rl.GREEN)

            rl.DrawText("KILLS / 30", 270, 12, 20, rl.WHITE)
            rl.DrawRectangle(270, 42, 180, 20, rl.DARKGRAY)
            rl.DrawRectangle(
                270, 42, i32(min(kills, 30) * 6), 20, rl.YELLOW,
            )

            rl.DrawText("Left: 2 HP | Right: 8 HP", 520, 15, 20, rl.WHITE)
            rl.DrawText("Kill: +6 HP | Hit: -20 HP", 520, 45, 20, rl.WHITE)

            color := rl.GREEN
            if damage_cooldown > 0 { color = rl.WHITE }
            rl.DrawCircleV(player, 20, color)

            for enemy in enemies {
                if !enemy.active { continue }

                enemy_color := rl.RED
                if enemy.health > 1 { enemy_color = rl.ORANGE }
                rl.DrawCircleV(enemy.position, 18, enemy_color)

                // Remaining health marks.
                for i in 0..<enemy.health {
                    rl.DrawRectangle(
                        i32(enemy.position.x) - 12 + i32(i * 8),
                        i32(enemy.position.y) - 27,
                        5, 5, rl.WHITE,
                    )
                }
            }

            for bullet in bullets {
                if !bullet.active { continue }

                if bullet.piercing {
                    rl.DrawCircleV(bullet.position, 10, rl.SKYBLUE)
                } else {
                    rl.DrawCircleV(bullet.position, 6, rl.YELLOW)
                }
            }

            if health <= 8 {
                rl.DrawText(
                    "LOW HEALTH: expensive shots unavailable!",
                    180, 600, 22, rl.ORANGE,
                )
            }

        case .Won:
            rl.DrawText("YOU WIN!", 340, 230, 40, rl.GREEN)
            rl.DrawText("You defeated 30 enemies.", 260, 310, 24, rl.WHITE)
            rl.DrawText("Press ENTER to replay", 280, 400, 28, rl.YELLOW)

        case .Lost:
            rl.DrawText("GAME OVER", 320, 230, 40, rl.RED)
            rl.DrawText("Your health reached zero.", 250, 310, 24, rl.WHITE)
            rl.DrawText("Press ENTER to replay", 280, 400, 28, rl.YELLOW)
        }

        rl.EndDrawing()
    }
}