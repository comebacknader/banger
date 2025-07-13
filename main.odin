/*

BANGERS: A 2D tag-based fighting game made entirely from scratch using Odin.   

*/

package main

import "core:fmt"
import win "core:sys/windows"


main :: proc() {
    fmt.println("beginning of banger")
    instance := win.HINSTANCE(win.GetModuleHandleW(nil))
    
    message := win.utf8_to_wstring("This is Banger")
    title := win.utf8_to_wstring("Banger")

    win.MessageBoxW(nil, message, title, win.MB_OK|win.MB_ICONINFORMATION)

    fmt.println("end of game")
}
