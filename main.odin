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

    vao: u32
    gl.GenVertexArrays(1, &vao); defer gl.DeleteVertexArrays(1, &vao)

    vbo, ebo: u32
    gl.GenBuffers(1, &vbo); defer gl.DeleteBuffers(1, &vbo)
    gl.GenBuffers(1, &ebo); defer gl.DeleteBuffers(1, &ebo)

    Vertex :: struct {
        pos: glm.vec3,
        col: glm.vec4
    }

    vertices := []Vertex{
        {{-0.5, +0.5, 0}, {1.0, 0.0, 0.0, 0.75}},
        {{-0.5, -0.5, 0}, {1.0, 1.0, 0.0, 0.75}},
        {{+0.5, -0.5, 0}, {0.0, 1.0, 0.0, 0.75}},
        {{+0.5, +0.5, 0}, {0.0, 0.0, 1.0, 0.75}},
    }

    indices := []u16 {
        0, 1, 2,
        2, 3, 0,
    }

    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
    gl.BufferData(gl.ARRAY_BUFFER, len(vertices)*size_of(vertices[0]), raw_data(indices), gl.STATIC_DRAW)
}

sprite_vertex_source := `#version 330 core

layout(location = 0) in vec3 a_position;
layout(location = 1) in vec4 a_color;

out vec4 v_color;

uniform mat4 u_transform;

void main() {
    gl_Position = u_transform * vec4(a_position, 1.0);
    v_color = a_color;
}
`

sprite_fragment_source := `#version 330 core

in vec4 v_color;
out vec4 o_color;

void main() {
    o_color = v_color;
}
`