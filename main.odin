package main

import "core:fmt"

Type :: enum {
	float,
	int,
	vec2,
	vec3,
	vec4,
}

Word :: 4

Type_Sizes := #partial [Type]int {
	.float = Word,
	.int = Word,
	.vec2 = Word * 2,
	.vec3 = Word * 4,
	.vec4 = Word * 4,
}

Type_Alignments := #partial [Type]int {
	.float = Word,
	.int = Word,
	.vec2 = Word * 2,
	.vec3 = Word * 4,
	.vec4 = Word * 4,
}

main :: proc() {
	values := [?]Type{.vec3, .float, .vec2, .float, .float, .float, .float, .vec4}
	old_end := 0
	for v, i in values {
		// calculate new offset and end
		new_offset: int
		if i != 0 {
			alignment := Type_Alignments[v]
			new_offset = ((old_end / alignment) + 1) * alignment
		}
		new_end := new_offset + Type_Sizes[v] - 1

		if old_end + 1 < new_offset {
			fmt.printfln("%v-%v: UNUSED", old_end + 1, new_offset - 1)
		}
		fmt.printfln("%v-%v: %v", new_offset, new_end, v)
		old_end = new_end
	}
}
