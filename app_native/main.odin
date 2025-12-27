package app_native

import "core:flags"
import os "core:os/os2"
import calc "../calculator"

main :: proc() {

	// parse options
	opts: struct {
		std140: bool `usage:"Use std140 layout (default)"`,
		std430: bool `usage:"Use std430 layout"`, 
	}
	flags.parse_or_exit(&opts, os.args, .Unix)

	// read from stdin
	input, err := os.read_entire_file_from_file(os.stdin, context.temp_allocator)
	if err != nil {
		panic("Failed to read input")
	}

	calc.parse_and_calculate(string(input), os.to_stream(os.stdout), os.to_stream(os.stderr), opts.std430 ? .std430 : .std140)
}

