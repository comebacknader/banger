package main

import "core:fmt"
import glm "core:math/linalg/glsl"
import "core:time"
import "core:mem"

import SDL "vendor:sdl2"
import gl "vendor:OpenGL"

v3 :: glm.vec3
v2 :: glm.vec2
m4 :: glm.mat4

/*

TODO(Nader): Replicate what I have in blowback repository.
    - Draw square
    - Translate square with OpenGL 
    - Pass memory into game_update_and_render
    - Enforce a video frame rate

*/

game_loop: bool = true

vertex_source := `#version 330 core

layout (location = 0) in vec3 aPos;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main() {
	gl_Position = projection * model * view * vec4(aPos, 1.0);
}
`
fragment_source := `#version 330 core

out vec4 FragColor;

void main() {
	FragColor = vec4(0.9, 0.8, 0.0, 1.0);
}
`
game_update_and_render :: proc(game_memory: ^GameMemory, game_state: ^GameState, game_input: ^GameInput, shader_program_id: u32) {
    if !game_memory.is_initialized {
        game_state.camera_position = v3{0.0, 0.0, 3.0}
        game_state.camera_front = v3{0.0, 0.0, -1.0}
        game_state.up = v3{0.0, 1.0, 0.0}

        game_state.camera_target = v3{0.0, 0.0, 0.0}
        game_state.camera_direction = glm.normalize_vec3(game_state.camera_position - game_state.camera_target)
        game_state.camera_right = glm.normalize_vec3(glm.cross_vec3(game_state.up, game_state.camera_direction))
        game_state.camera_up = glm.cross_vec3(game_state.camera_direction, game_state.camera_right)

        game_state.movement_x = 0.0
        game_state.movement_y = 0.0
        game_state.position_x = 0.0
        game_state.position_y = 0.0

        game_state.old_time = 0
        game_state.new_time = 0
        game_state.dt = 0
        game_state.fps = 0.0
        game_state.shader_program = shader_program_id
        game_state.window_width = 1280.0
        game_state.window_height = 720.0
        game_memory.is_initialized = true
    }

    gl.UseProgram(game_state.shader_program)
    view: glm.mat4 = glm.mat4(1)
    view = glm.mat4LookAt(game_state.camera_position, game_state.camera_position + game_state.camera_front, game_state.camera_up)

    projection: glm.mat4 = glm.mat4(1)
    projection = glm.mat4Ortho3d(0.0, game_state.window_width, 0.0, game_state.window_height, -0.1, 1000.0)

    view_location: i32 = gl.GetUniformLocation(game_state.shader_program, "view")
    projection_location: i32 = gl.GetUniformLocation(game_state.shader_program, "projection")

    gl.UniformMatrix4fv(view_location, 1, gl.FALSE, &view[0, 0])
    gl.UniformMatrix4fv(projection_location, 1, gl.FALSE, &projection[0, 0])

    scale: v3 = v3{50.0, 50.0, 0.0}
    adjust_x: f32 = scale.x
    adjust_y: f32 = scale.y
    translation: v3 = v3{game_state.position_x + adjust_x,
                    game_state.position_y + adjust_y,
                    0.0}

    if game_input.controllers[0].buttons.right.ended_down {
        fmt.println("RIGHT button pressed")
        game_state.position_x += 10.0
        fmt.printf("game_state.position_x: %f \n", game_state.position_x)
    }

    if game_input.controllers[0].buttons.left.ended_down {
        fmt.println("LEFT button pressed")
        game_state.position_x -= 10.0
        fmt.printf("game_state.position_x: %f \n", game_state.position_x)
    }

    if game_input.controllers[0].buttons.down.ended_down {
        fmt.println("DOWN button pressed")
        game_state.position_y -= 10.0
        fmt.printf("game_state.position_y: %f \n", game_state.position_y)
    }

    if game_input.controllers[0].buttons.up.ended_down {
        fmt.println("UP button pressed")
        game_state.position_y += 10.0
        fmt.printf("game_state.position_y: %f \n", game_state.position_y)
    }

    model: m4 = m4(1)

    model = glm.mat4Scale(scale)

    model[3].x = translation.x
    model[3].y = translation.y
    model[3].z = 0.0

    model_location: i32 = gl.GetUniformLocation(game_state.shader_program, "model")
    gl.UniformMatrix4fv(model_location, 1, gl.FALSE, &model[0, 0])

    gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, nil)
}

main :: proc() {
    fmt.println("Banger Platformer")
    WINDOW_WIDTH :: 1280 
    WINDOW_HEIGHT :: 720

    window := SDL.CreateWindow("Bangers", SDL.WINDOWPOS_UNDEFINED, 
                    SDL.WINDOWPOS_UNDEFINED, WINDOW_WIDTH, WINDOW_HEIGHT, {.OPENGL})
    if window == nil {
        fmt.eprintln("failed to create window")
        return
    }
    defer SDL.DestroyWindow(window)

    gl_context := SDL.GL_CreateContext(window)
    SDL.GL_MakeCurrent(window, gl_context)
    // load the OpenGL procedures once an OpenGL context has been established
    gl.load_up_to(3, 3, SDL.gl_set_proc_address)

    // useful utility procedures that are part of vendor:OpenGl
    shader_program_id, program_ok := gl.load_shaders_source(vertex_source, fragment_source)
    if !program_ok {
        fmt.eprintln("Failed to create GLSL program")
        return
    }
    defer gl.DeleteProgram(shader_program_id)

    gl.UseProgram(shader_program_id)

    uniforms := gl.get_uniforms_from_program(shader_program_id)
    defer delete(uniforms)

    vao: u32
    gl.GenVertexArrays(1, &vao); defer gl.DeleteVertexArrays(1, &vao)

    vbo, ebo: u32
    gl.GenBuffers(1, &vbo); defer gl.DeleteBuffers(1, &vbo)
    gl.GenBuffers(1, &ebo); defer gl.DeleteBuffers(1, &ebo)

    Vertex :: struct {
        pos: v3,
    }

    vertices := []Vertex{
        {{1.0, 1.0, 0.0}},
        {{1.0, -1.0, 0.0}},
        {{-1.0, -1.0, 0.0}},
        {{-1.0, 1.0, 0.0}},
    }

    indices := []u16{
        0, 1, 3, // first triangle
        1, 2, 3, // second triangle
    }

    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
    gl.BufferData(gl.ARRAY_BUFFER, len(vertices)*size_of(vertices[0]), raw_data(vertices), gl.STATIC_DRAW)
    gl.EnableVertexAttribArray(0)
    gl.VertexAttribPointer(0, 3, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, pos))

    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(indices)*size_of(indices[0]), raw_data(indices), gl.STATIC_DRAW)

    game_state: GameState 
    game_input: GameInput
    game_memory: GameMemory
    monitor_refresh_rate_hz: u8 = 60
    game_update_hz: u8 = monitor_refresh_rate_hz
    target_seconds_elapsed_per_frame: f32 = 1.0 / f32(game_update_hz)

    game_loop: for {
        start_tick := time.tick_now()

        event: SDL.Event
        for SDL.PollEvent(&event) {
            #partial switch event.type {
                case .KEYDOWN:
                    #partial switch event.key.keysym.sym {
                        case .UP:
                            game_input.controllers[0].buttons.up.ended_down = true
                        case .DOWN:
                            game_input.controllers[0].buttons.down.ended_down = true
                        case .ESCAPE:
                            break game_loop
                    }
                case .KEYUP:
                    #partial switch event.key.keysym.sym {
                        case .UP:
                            game_input.controllers[0].buttons.up.ended_down = false
                        case .DOWN:
                            game_input.controllers[0].buttons.down.ended_down = false
                    }
                case .QUIT:
                    break game_loop
            }
        }

        gl.Viewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
        gl.ClearColor(0.8, 0.2, 0.5, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        game_update_and_render(&game_memory, &game_state, &game_input, shader_program_id)

        SDL.GL_SwapWindow(window)
        duration := time.tick_since(start_tick)
        seconds_per_frame := f32(time.duration_seconds(duration))
        ms_per_frame := 1000.0 * seconds_per_frame 
        fps := 1 / seconds_per_frame
        fmt.printf("ms/f: %f | fps: %f \n", ms_per_frame, fps)
    }
}