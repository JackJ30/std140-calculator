#+private package
package calculator

import "core:math"

// Block
Block_Type :: enum {
	Uniform,
	Structure,
}
Block_Element :: struct {
	type: Type,
	name: string,
}
Block :: struct {
	title: string,
	type: Block_Type,
	elements: [dynamic]Block_Element
}

// Calculated
Calculated_Block :: struct {
	offsets, sizes: []int,
	greatest_alginment, total_size: int,
}
calculate_block :: proc(b: ^Block, alloc := context.temp_allocator) -> (calc: Calculated_Block) {
	calc.offsets = make([]int, len(b.elements))
	calc.sizes = make([]int, len(b.elements))
	current := 0
	for e, i in b.elements {
		alignment := get_alignment(e.type)
		calc.greatest_alginment = math.max(calc.greatest_alginment, alignment)

		calc.offsets[i] = round_up(current, alignment)
		calc.sizes[i] = get_size(e.type)
		current = calc.offsets[i] + calc.sizes[i]
	}
	calc.total_size = current

	return
}
