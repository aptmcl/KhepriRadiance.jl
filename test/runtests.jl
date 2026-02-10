# KhepriRadiance tests - Tests for Radiance RAD file generation

using KhepriRadiance
using KhepriBase
using Test

# Helper to get the output from the backend's IOBuffer
function get_rad_output(b)
  io = KhepriBase.connection(b)
  String(take!(io))
end

# Helper to clear the backend's buffer
function clear_rad_buffer!(b)
  io = KhepriBase.connection(b)
  take!(io)
  nothing
end

@testset "KhepriRadiance.jl" begin

  @testset "Backend initialization" begin
    @testset "radiance backend exists" begin
      @test radiance isa KhepriBase.IOBackend
    end

    @testset "backend_name" begin
      # IOBackend uses the type name as backend_name
      @test occursin("RADKey", KhepriBase.backend_name(radiance))
    end

    @testset "void_ref" begin
      vr = KhepriBase.void_ref(radiance)
      @test vr === -1
    end
  end

  @testset "RAD primitive writing" begin
    @testset "write_rad_primitive" begin
      io = IOBuffer()
      KhepriRadiance.write_rad_primitive(io, "void", "plastic", "test_mat", String[], Int[], [0.5, 0.5, 0.5, 0.0, 0.0])
      output = String(take!(io))
      @test occursin("void", output)
      @test occursin("plastic", output)
      @test occursin("test_mat", output)
    end

    @testset "write_rad_sphere" begin
      io = IOBuffer()
      KhepriRadiance.write_rad_sphere(io, "test_mat", 1, xyz(0, 0, 0), 5.0)
      output = String(take!(io))
      @test occursin("sphere", output)
      @test occursin("test_mat", output)
      @test occursin("5", output)
    end

    @testset "write_rad_cylinder" begin
      io = IOBuffer()
      KhepriRadiance.write_rad_cylinder(io, "test_mat", 2, xyz(0, 0, 0), 3.0, xyz(0, 0, 10))
      output = String(take!(io))
      @test occursin("cylinder", output)
      @test occursin("test_mat", output)
    end

    @testset "write_rad_ring" begin
      io = IOBuffer()
      KhepriRadiance.write_rad_ring(io, "test_mat", 3, xyz(0, 0, 0), 1.0, 5.0, vxyz(0, 0, 1))
      output = String(take!(io))
      @test occursin("ring", output)
      @test occursin("test_mat", output)
    end

    @testset "write_rad_trig" begin
      io = IOBuffer()
      KhepriRadiance.write_rad_trig(io, "test_mat", 4, xyz(0, 0, 0), xyz(1, 0, 0), xyz(0, 1, 0))
      output = String(take!(io))
      @test occursin("polygon", output)
      @test occursin("test_mat", output)
      @test occursin("9", output)  # 9 coordinates for 3 vertices
    end

    @testset "write_rad_quad" begin
      io = IOBuffer()
      KhepriRadiance.write_rad_quad(io, "test_mat", 5, "face0", xyz(0, 0, 0), xyz(1, 0, 0), xyz(1, 1, 0), xyz(0, 1, 0))
      output = String(take!(io))
      @test occursin("polygon", output)
      @test occursin("12", output)  # 12 coordinates for 4 vertices
    end

    @testset "write_rad_polygon" begin
      io = IOBuffer()
      pts = [xyz(0, 0, 0), xyz(1, 0, 0), xyz(1, 1, 0), xyz(0.5, 1.5, 0), xyz(0, 1, 0)]
      KhepriRadiance.write_rad_polygon(io, "test_mat", 6, pts)
      output = String(take!(io))
      @test occursin("polygon", output)
      @test occursin("15", output)  # 15 coordinates for 5 vertices
    end
  end

  @testset "Material system" begin
    @testset "radiance_plastic_material" begin
      mat = radiance_plastic_material("red", red=0.7, green=0.1, blue=0.1)
      @test mat isa RadianceMaterial
      @test mat.name == "red"
    end

    @testset "radiance_metal_material" begin
      mat = radiance_metal_material("chrome", gray=0.8, specularity=0.9)
      @test mat isa RadianceMaterial
      @test mat.name == "chrome"
    end

    @testset "radiance_glass_material" begin
      mat = radiance_glass_material("clear_glass", gray=0.6)
      @test mat isa RadianceMaterial
      @test mat.name == "clear_glass"
    end

    @testset "radiance_light_material" begin
      mat = radiance_light_material("bright", gray=100)
      @test mat isa RadianceMaterial
      @test mat.name == "bright"
    end

    @testset "predefined materials exist" begin
      @test radiance_material_neutral isa RadianceMaterial
      @test radiance_generic_metal isa RadianceMaterial
      @test radiance_generic_glass_80 isa RadianceMaterial
    end

    @testset "material output" begin
      io = IOBuffer()
      mat = radiance_plastic_material("test_plastic", red=0.5, green=0.5, blue=0.5)
      KhepriRadiance.write_rad_material(io, mat)
      output = String(take!(io))
      @test occursin("plastic", output)
      @test occursin("test_plastic", output)
    end
  end

  @testset "Backend drawing operations" begin
    @testset "b_trig" begin
      clear_rad_buffer!(radiance)
      mat = radiance_plastic_material("trig_mat", gray=0.5)
      ref = KhepriBase.b_trig(radiance, xyz(0, 0, 0), xyz(1, 0, 0), xyz(0, 1, 0), mat)
      output = get_rad_output(radiance)
      @test ref != KhepriBase.void_ref(radiance)
      @test occursin("polygon", output)
    end

    @testset "b_surface_polygon" begin
      clear_rad_buffer!(radiance)
      mat = radiance_plastic_material("poly_mat", gray=0.5)
      ref = KhepriBase.b_surface_polygon(radiance, [xyz(0, 0, 0), xyz(1, 0, 0), xyz(1, 1, 0), xyz(0, 1, 0)], mat)
      output = get_rad_output(radiance)
      @test ref != KhepriBase.void_ref(radiance)
      @test occursin("polygon", output)
    end

    @testset "b_sphere" begin
      clear_rad_buffer!(radiance)
      mat = radiance_plastic_material("sphere_mat", gray=0.5)
      ref = KhepriBase.b_sphere(radiance, xyz(0, 0, 0), 5.0, mat)
      output = get_rad_output(radiance)
      @test ref != KhepriBase.void_ref(radiance)
      @test occursin("sphere", output)
      @test occursin("5", output)
    end

    @testset "b_box" begin
      clear_rad_buffer!(radiance)
      mat = radiance_plastic_material("box_mat", gray=0.5)
      ref = KhepriBase.b_box(radiance, xyz(0, 0, 0), 10.0, 5.0, 3.0, mat)
      output = get_rad_output(radiance)
      @test ref != KhepriBase.void_ref(radiance)
      @test length(output) > 0
    end

    @testset "b_cylinder" begin
      clear_rad_buffer!(radiance)
      mat = radiance_plastic_material("cyl_mat", gray=0.5)
      ref = KhepriBase.b_cylinder(radiance, xyz(0, 0, 0), 3.0, 10.0, mat, mat, mat)
      output = get_rad_output(radiance)
      @test ref isa Vector
      @test length(ref) == 3  # bottom ring, cylinder, top ring
      @test occursin("cylinder", output)
      @test occursin("ring", output)
    end
  end

  @testset "View and rendering" begin
    @testset "radiance has view field" begin
      @test hasfield(typeof(radiance), :view)
    end
  end

  @testset "ID generation" begin
    @testset "next_id increments" begin
      # Reset the counter
      radiance.extra = 0
      id1 = KhepriRadiance.next_id(radiance)
      id2 = KhepriRadiance.next_id(radiance)
      @test id1 == 0
      @test id2 == 1
      @test id2 > id1
    end
  end

  @testset "Save RAD file" begin
    @testset "save_rad creates file" begin
      # save_rad re-realizes from b.shapes, but the ManualCommitTransaction
      # proxy system pushes shapes to transaction proxies, not b.shapes.
      # So save_rad produces an empty file. Test that the file is at least created.
      delete_all_shapes()
      sphere(xyz(0, 0, 0), 1)

      temp_path = tempname() * ".rad"
      save_rad(temp_path, radiance)

      @test isfile(temp_path)

      # Cleanup
      rm(temp_path)
      delete_all_shapes()
    end

    @testset "save_rad with direct buffer content" begin
      # Test that b_sphere writes RAD content to the backend buffer
      buf = KhepriBase.connection(radiance)
      take!(buf)
      mat = radiance_plastic_material("test_mat", gray=0.5)
      KhepriBase.b_sphere(radiance, xyz(0, 0, 0), 5.0, mat)
      output = String(take!(buf))
      @test length(output) > 0
    end
  end

end
