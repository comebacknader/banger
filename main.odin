package main

import "core:fmt"
import win32 "core:sys/windows"

/*

TODO(Nader): Need to set up win32 platform layer. Opening a window. 
TODO(Nader): Hook up Direct3D12 and render a color on the screen.
TODO(Nader): Replicate what I have in blowback repository.

*/

game_loop: bool = true


win32_main_window_callback :: proc "stdcall" (window: win32.HWND, 
    message: win32.UINT, 
    wparam: win32.WPARAM,
    lparam: win32.LPARAM) -> win32.LRESULT {

    result: win32.LRESULT

    switch message {
        case win32.WM_CLOSE:
            game_loop = false
            break
        case win32.WM_ACTIVATEAPP:
            break
        case win32.WM_DESTROY:
            break
        case win32.WM_SYSKEYDOWN:
        case win32.WM_SYSKEYUP:
        case win32.WM_KEYDOWN:
        case win32.WM_KEYUP:
            break
        case win32.WM_PAINT: {
            paint: win32.PAINTSTRUCT
            device_context: win32.HDC = win32.BeginPaint(window, &paint)
            win32.EndPaint(window, &paint)
            break
        }
        case: {
            result = win32.DefWindowProcA(window, message, wparam, lparam)
            break
        }
    }

    return result
}

main :: proc() {
    fmt.println("Banger Platformer")

    window_class: win32.WNDCLASSW = {}
    window_class.style = win32.CS_HREDRAW | win32.CS_VREDRAW | win32.CS_OWNDC
    window_class.lpfnWndProc = win32_main_window_callback
    window_class.lpszClassName = "BangerWindowClass"
    window_class.hCursor = win32.LoadCursorW(0, win32.IDC_ARROW)

    if win32.RegisterClassW(&window_class) {
        window: win32.HWND = win32.CreateWindowExW(
                0, window_class.lpszClassName, "Bangers",
                win32.WS_OVERLAPPEDWINDOW | win32.WS_VISIBLE, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT,
                win32.WINDOW_WIDTH, win32.WINDOW_HEIGHT, 0, 0, instance, 0)
        
        if window == 1 {
            for game_loop {
            }
        }
    }


}