package main

import "core:mem"
import "core:slice"
import "core:strings"
import "base:runtime"

import "../calculator/"

ctx: runtime.Context

input_string: string
output_string: string

main :: proc() {
	ctx = context
}

@(export)
alloc_input :: proc "contextless" (size: int) -> rawptr {
	context = ctx

	// free old string
	if strptr := raw_data(input_string); strptr != nil do mem.free(strptr, context.allocator)

	// allocate new string
	ptr, _ := mem.alloc(size, mem.DEFAULT_ALIGNMENT, context.allocator)
	input_string = string(slice.bytes_from_ptr(ptr, cast(int)size))

	return ptr
}

@(export)
calculate :: proc "contextless" (version: i32) {
	context = ctx

	out_string_builder := strings.builder_make(context.allocator)
	err_string_builder := strings.builder_make(context.allocator)

	context.allocator = context.temp_allocator
	if calculator.parse_and_calculate(input_string, strings.to_stream(&out_string_builder), strings.to_stream(&err_string_builder), version == 0 ? .std140 : .std430) {
		output_string = strings.to_string(out_string_builder)
	} else {
		output_string = strings.to_string(err_string_builder)
	}
	free_all(context.temp_allocator)
}

@(export)
get_output_ptr :: proc "contextless" () -> rawptr {
	return raw_data(output_string)
}

@(export)
get_output_size :: proc "contextless" () -> i32 {
	return cast(i32)len(output_string)
}
