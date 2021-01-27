module KhepriRadiance
using KhepriBase

# functions that need specialization
include(khepribase_interface_file())
include("Radiance.jl")

function __init__()
  set_material(radiance, material_basic, radiance_material_neutral)
  set_material(radiance, material_metal, radiance_generic_metal)
  set_material(radiance, material_glass, radiance_generic_glass_80)
  set_material(radiance, material_wood, radiance_light_wood)
  set_material(radiance, material_concrete, radiance_outside_facade_30)
  set_material(radiance, material_plaster, radiance_generic_interior_wall_70)

  add_current_backend(radiance)
end
end
