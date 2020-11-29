function create_sprite(name, width, height)
    return {
      type ="sprite",
      name = "cssa-"..name,
      filename = "__coop-secure-spawn-areas__/graphics/sprites/"..name..".png",
      priority = "medium",
      width = width,
      height = height
    }
  end
  
data:extend({
    create_sprite("main-sprite-button", 32, 32)--,
})