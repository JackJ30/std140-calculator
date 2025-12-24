package main

import "core:fmt"

version: enum {
	std140,
	std430,
} = .std140

calculated_blocks: map[rawptr]struct {
	offsets, sizes: []int
}

main :: proc() {

	block := Block{ Vector{ type = .single, count = .three }, .single, Vector{ type = .single, count = .two }, Vector{ type = .single, count = .two }, .single, .single, .single, .single, Vector{ type = .single, count = .four } }
	offsets, sizes := calculate_block(block)

	// print
	prev_end := 0
	for v, i in block {
		if offsets[i] > prev_end {
			fmt.printfln("%v-%v: PADDING", prev_end, offsets[i] - 1)
		}
		prev_end = offsets[i] + sizes[i]
		fmt.printfln("%v-%v: %v", offsets[i], offsets[i] + sizes[i] - 1, v)
	}
}

// TYPES

round_up :: proc(val, align: int) -> int {
	assert(val >= 0)
	if val == 0 do return 0
	return (((val - 1) / align) + 1) * align
}

Count :: enum {
	two = 2,
	three = 3,
	four = 4,
}
	
Scalar :: enum {
	single,
	double,
}

get_scalar_size :: proc(b: Scalar) -> int {
	switch b {
	case .single:
		return 4
	case .double:
		return 8
	}
	panic("Invalid base type")
}

Vector :: struct {
	type: Scalar,
	count: Count
}

Matrix :: struct {
	major, minor : Count,
	type: Scalar,
}

get_matrix_array :: proc(m: Matrix, num := 1) -> Array {
	return Array{size = cast(int)m.major * num, type = Vector{ type = m.type, count = m.minor }}
}

Array :: struct {
	type: union { Scalar, Vector, Matrix },
	size: int,
}


get_scalarvector_array_stride :: proc(a: Array) -> int {
	t: Type
	switch v in a.type {
	case Scalar:
		t = v
	case Vector:
		t = v
	case Matrix:
		panic("Can not get scalarvector array stride of matrix array")
	}

	element_alignment := get_alignment(t)

	if version == .std430 do return element_alignment
	else do return round_up(get_alignment(t), get_alignment(Vector{ type = .single, count = .four }))
}

Type :: union {
	Scalar,
	Vector,
	Matrix,
	Array,
}

get_advance :: proc(type: Type) -> int {
	switch v in type {
	case Scalar:
		return get_scalar_size(v)
	case Vector:
		switch v.count {
		case .two:
			return get_scalar_size(v.type) * 2
		case .three:
			return get_scalar_size(v.type) * 3
		case .four:
			return get_scalar_size(v.type) * 4
		}
	case Matrix:
		return get_advance(get_matrix_array(v))
	case Array:
		switch t in v.type {
		case Scalar:
			return get_scalarvector_array_stride(v) * v.size
		case Vector:
			return get_scalarvector_array_stride(v) * v.size
		case Matrix:
			return get_advance(get_matrix_array(t, v.size))
		}
	}
	panic("Invalid type")
}

get_alignment :: proc(type: Type) -> int {
	switch v in type {
	case Scalar:
		return get_scalar_size(v)
	case Vector:
		switch v.count {
		case .two:
			return get_scalar_size(v.type) * 2
		case .three:
			return get_scalar_size(v.type) * 4
		case .four:
			return get_scalar_size(v.type) * 4
		}
	case Matrix:
		return get_alignment(get_matrix_array(v))
	case Array:
		switch t in v.type {
		case Scalar:
			return get_scalarvector_array_stride(v)
		case Vector:
			return get_scalarvector_array_stride(v)
		case Matrix:
			return get_alignment(get_matrix_array(t, v.size))
		}
	}
	panic("Invalid type")
}

Block :: distinct []Type

calculate_block :: proc(b: Block, alloc := context.temp_allocator) -> (offsets: []int, sizes: []int) {
	if calculated, ok := calculated_blocks[raw_data(b)]; ok {
		return calculated.offsets, calculated.sizes
	}

	offsets = make([]int, len(b))
	sizes = make([]int, len(b))
	current := 0
	for v, i in b {
		offsets[i] = round_up(current, get_alignment(v))
		sizes[i] = get_advance(v)
		current = offsets[i] + sizes[i]
	}

	calculated_blocks[raw_data(b)] = { offsets, sizes }
	return
}
