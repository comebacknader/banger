package main

GameMemory :: struct {
    is_initialized: b32,
    permanent_storage_size: u64,
    permanent_storage: rawptr,
    transient_storage_size: u64,
    transient_storage: rawptr,
}

GameState :: struct {
    shader_program: u32,
    camera_position: v3,
    camera_front: v3,
    up: v3,
    
    camera_target: v3,
    camera_direction: v3,
    camera_right: v3,
    camera_up: v3,

    movement_x: f32,
    movement_y: f32,

    old_time: u32,
    new_time: u32,
    dt: u32,
    fps: u32,

    position_x: f32,
    position_y: f32,

    window_width: f32,
    window_height: f32,
}

GameButtonState :: struct {
    half_transition_count: i32,
    ended_down: b32,
}

GameControllerInput :: struct {
    is_connected: b32,
    is_analog: b32,
    stick_average_x: f32,
    stick_average_y: f32,
    start_x: f32,
    start_y: f32,
    min_x: f32,
    min_y: f32,
    max_x: f32,
    max_y: f32,
    end_x: f32,
    end_y: f32,

    buttons: struct {
            up: GameButtonState,
            down: GameButtonState,
            left: GameButtonState,
            right: GameButtonState,

            action_up: GameButtonState,
            action_down: GameButtonState,
            action_left: GameButtonState,
            action_right: GameButtonState,

            left_shoulder: GameButtonState,
            right_shoulder: GameButtonState,

            select: GameButtonState,
            start: GameButtonState,
    }
}

GameInput :: struct {
    dt_for_frame: f32,
    controllers: [4]GameControllerInput,
}