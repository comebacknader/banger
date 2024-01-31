package main

import "core:fmt"
import glm "core:math/linalg/glsl"
import "core:time"

import SDL "vendor:sdl2"
import gl "vendor:OpenGL"

main :: proc() {
    WINDOW_WIDTH :: 1280
    WINDOW_HEIGHT :: 720

    window := SDL.CreateWindow("Banger Game", SDL.WINDOWPOS_UNDEFINED, SDL.WINDOWPOS_UNDEFINED, WINDOW_WIDTH, WINDOW_HEIGHT, {.OPENGL})
    if window == nil {
        fmt.eprintln("Failed to create window")
        return
    }
    defer SDL.DestroyWindow(window)

    gl_context := SDL.GL_CreateContext(window)
    SDL.GL_MakeCurrent(window, gl_context)
    gl.load_up_to(3, 3, SDL.gl_set_proc_address)

    program, program_ok := gl.load_shaders_source(sprite_vertex_source, sprite_fragment_source)
    if !program_ok {
        fmt.eprintln("Failed to create GLSL program")
    }

    gl.UseProgram(program)

    uniforms := gl.get_uniforms_from_program(program)
    defer delete(uniforms)

    Vertex :: struct {
        pos: glm.vec3,
    }

    vertices := []Vertex{
        {{1.0, 1.0, 0.0}},
        {{1.0, -1.0, 0.0}},
        {{-1.0, -1.0, 0.0}},
        {{-1.0, 1.0, 0.0}},
    }

    indices := []u16 {
        0, 1, 3, // first triangle
        1, 2, 3, // second triangle
    }

    vao, vbo, ebo: u32

    gl.GenVertexArrays(1, &vao); defer gl.DeleteVertexArrays(1, &vao)
    gl.GenBuffers(1, &vbo); defer gl.DeleteBuffers(1, &vbo)
    gl.GenBuffers(1, &ebo); defer gl.DeleteBuffers(1, &ebo)

    gl.BindVertexArray(vao)

    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
    gl.BufferData(gl.ARRAY_BUFFER, len(vertices)*size_of(vertices[0]), raw_data(vertices), gl.STATIC_DRAW)
    
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(indices)*size_of(indices[0]), raw_data(indices), gl.STATIC_DRAW)

    gl.VertexAttribPointer(0, 3, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, pos))
    gl.EnableVertexAttribArray(0)

    start_tick := time.tick_now()
    movement_x: f32 = 0.1 
    movement_y: f32 = 0.1 
    game_loop: for {
        duration := time.tick_since(start_tick)
        t := f32(time.duration_seconds(duration))

        event: SDL.Event
        for SDL.PollEvent(&event) {
            #partial switch event.type {
            case .KEYDOWN:
                #partial switch event.key.keysym.sym {
                case .ESCAPE: 
                    break game_loop
                case .LEFT:
                    movement_x -= 0.01
                case .RIGHT:
                    movement_x += 0.01
                case .DOWN:
                    movement_y -= 0.01
                case .UP:
                    movement_y += 0.01
                }
            case .QUIT:
                break game_loop
            }
        }

        gl.Viewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
        gl.ClearColor(0.5, 0.7, 1.0, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        model := glm.mat4{
			0.5,   0,   0, 0,
			  0, 0.5,   0, 0,
			  0,   0, 0.5, 0,
			  0,   0,   0, 1,
		}
        model[3][0] += movement_x
        model[3][1] = movement_y
        movement_x += 0.001
        // model matrix with default scale of 0.5

        model = model * glm.mat4Rotate({0, 1, 1}, movement_x)
        view := glm.mat4LookAt({0, -1, +1}, {0, 0, 0}, {0, 0, 1})
		proj := glm.mat4Perspective(45.0, 1.3, 0.1, 100.0)
        //view := glm.mat4LookAt({0, 0, 0}, {0, 0, 0}, {0, 1, 0})
        //proj := glm.mat4Ortho3d(0, WINDOW_WIDTH, 0.0, WINDOW_HEIGHT, -0.1, 1000.0)

        u_transform := proj * view * model

        gl.UniformMatrix4fv(uniforms["u_transform"].location, 1, false, &u_transform[0, 0])

        gl.BindVertexArray(vao)

        gl.DrawElements(gl.TRIANGLES, i32(6), gl.UNSIGNED_SHORT, nil)

        SDL.GL_SwapWindow(window)
        
    }
}

sprite_vertex_source := `#version 330 core

layout(location = 0) in vec3 a_position;

uniform mat4 u_transform;

void main() {
    gl_Position = u_transform * vec4(a_position, 1.0);
}
`

sprite_fragment_source := `#version 330 core

out vec4 FragColor;

void main() {
    FragColor = vec4(0.9, 0.2, 0.3, 1.0);
}
`