module KhepriRadiance
using KhepriBase

# functions that need specialization
include(khepribase_interface_file())
include("Radiance.jl")

function __init__()
  set_material(RAD, material_basic, radiance_material_neutral)
  set_material(RAD, material_metal, radiance_generic_metal)
  set_material(RAD, material_glass, radiance_generic_glass_80)
  set_material(RAD, material_wood, radiance_light_wood)
  set_material(RAD, material_concrete, radiance_outside_facade_30)
  set_material(RAD, material_plaster, radiance_generic_interior_wall_70)

  add_current_backend(radiance)
end
end
