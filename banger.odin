package main

GameMemory :: struct {
    is_initialized: b32,
    permanent_storage_size: u64,
    permanent_storage: rawptr,
    transient_storage_size: u64,
    transient_storage: rawptr,
}

