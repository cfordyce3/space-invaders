package game

import rl "vendor:raylib"

BoundingBox :: rl.Rectangle

get_bounding_box_entity :: proc(ent: Entity) -> BoundingBox {
  return {
    ent.x,
    ent.y,
    f32(ent.texture.width),
    f32(ent.texture.height)
  }
}

get_bounding_box_entity_ptr :: proc(ent: ^Entity) -> BoundingBox {
  return {
    ent.x,
    ent.y,
    f32(ent.texture.width),
    f32(ent.texture.height)
  }
}

get_bounding_box_projectile :: proc(proj: Projectile) -> BoundingBox {
  return {
    proj.x,
    proj.y,
    f32(PROJECTILE_WIDTH),
    f32(PROJECTILE_HEIGHT)
  }
}

get_bounding_box_projectile_ptr :: proc(proj: ^Projectile) -> BoundingBox {
  return {
    proj.x,
    proj.y,
    f32(PROJECTILE_WIDTH),
    f32(PROJECTILE_HEIGHT)
  }
}

get_bounding_box :: proc{get_bounding_box_entity, get_bounding_box_entity_ptr, get_bounding_box_projectile, get_bounding_box_projectile_ptr}
