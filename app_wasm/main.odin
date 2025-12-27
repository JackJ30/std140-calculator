package main

import "core:mem"
import "core:slice"
import "core:fmt"
import "core:strings"
import "base:runtime"

import "../calculator/"

input_string: string
output_string: string

main :: proc() {}

@(export)
alloc_input :: proc "contextless" (size: int) -> rawptr {
	context = runtime.default_context()

	// free old string
	if strptr := raw_data(input_string); strptr != nil do mem.free(strptr, context.allocator)

	// allocate new string
	ptr, _ := mem.alloc(size, mem.DEFAULT_ALIGNMENT, context.allocator)
	input_string = string(slice.bytes_from_ptr(ptr, cast(int)size))

	return ptr
}

@(export)
calculate :: proc "contextless" (version: i32) {
	context = runtime.default_context()

	builder := strings.builder_make(context.allocator)
	calculator.calculate(input_string, strings.to_stream(&builder), version == 0 ? .std140 : .std430)
	output_string = strings.to_string(builder)
}

@(export)
get_output_ptr :: proc "contextless" () -> rawptr {
	return raw_data(output_string)
}

@(export)
get_output_size :: proc "contextless" () -> i32 {
	return cast(i32)len(output_string)
}
