package main

import "core:fmt"
import win32 "core:sys/windows"

/*

Rather than learn DX12, I should just use OpenGl, and then abstract
away the renderer, and then I can install DX12 as a backend, later down 
the line.  

TODO(Nader): Need to set up win32 platform layer. Opening a window. 
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
        case win32.WM_ACTIVATEAPP:
        case win32.WM_DESTROY:
        case win32.WM_SYSKEYDOWN:
        case win32.WM_SYSKEYUP:
        case win32.WM_KEYDOWN:
        case win32.WM_KEYUP:
        case win32.WM_PAINT: {
            paint: win32.PAINTSTRUCT
            device_context: win32.HDC = win32.BeginPaint(window, &paint)
            win32.EndPaint(window, &paint)
        }
        case: {
            result = win32.DefWindowProcA(window, message, wparam, lparam)
        }
    }

    return result
}

main :: proc() {
    fmt.println("Banger Platformer")
    instance := win32.HINSTANCE(win32.GetModuleHandleW(nil))
    assert(instance != nil)

    lpsz_class_name := win32.utf8_to_wstring("BangerWindowClass")
    idc_arrow := win32.utf8_to_wstring(string(win32.IDC_ARROW))
    window_class: win32.WNDCLASSW = {}
    window_class.style = win32.CS_HREDRAW | win32.CS_VREDRAW | win32.CS_OWNDC
    window_class.lpfnWndProc = win32_main_window_callback
    window_class.lpszClassName = lpsz_class_name
    window_class.hCursor = win32.LoadCursorW(nil, idc_arrow)

    if win32.RegisterClassW(&window_class) != 0 {
        game_name := win32.utf8_to_wstring("Bangers")
        window: win32.HWND = win32.CreateWindowExW(
                0, window_class.lpszClassName, game_name,
                win32.WS_OVERLAPPEDWINDOW | win32.WS_VISIBLE, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT,
                1080, 720, nil, nil, instance, nil)
        
        if window != nil {
            for game_loop {
                fmt.println("game loop")
            }
        } else {
            fmt.println("window failed to get created")
        }
    } else {
        fmt.println("window class failed to register")
    }


}