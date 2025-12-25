#+private package
package calculator

Type :: union {
	Scalar,
	Vector,
	Matrix,
	Array,
	Structure,
}

get_size :: proc(type: Type) -> int {
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
		return get_size(get_matrix_array(v))
	case Array:
		switch t in v.type {
		case Scalar:
			return get_alignment(v) * v.size
		case Vector:
			return get_alignment(v) * v.size
		case Matrix:
			return get_size(get_matrix_array(t, v.size))
		case Structure:
			return get_size(t) * v.size
		}
	case Structure:
		calc := calculate_block(v)
		return round_up(calc.total_size, get_alignment(v))
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
			return round_up_to_vec4(get_alignment(t))
		case Vector:
			return round_up_to_vec4(get_alignment(t))
		case Matrix:
			return get_alignment(get_matrix_array(t, v.size))
		case Structure:
			return get_alignment(t)
		}
	case Structure:
		return round_up_to_vec4(calculate_block(v).greatest_alginment)
	}
	panic("Invalid type")
}

// SCALAR

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

// VECTOR

Vector :: struct {
	type: Scalar,
	count: Count
}

Count :: enum {
	two = 2,
	three = 3,
	four = 4,
}

// MATRIX

Matrix :: struct {
	major, minor : Count,
	type: Scalar,
}


get_matrix_array :: proc(m: Matrix, num := 1) -> Array {
	return Array{size = cast(int)m.major * num, type = Vector{ type = m.type, count = m.minor }}
}

// ARRAY

Array :: struct {
	type: union { Scalar, Vector, Matrix, Structure },
	size: int,
}

// STRUCTURE

Structure :: ^Block

// UTIL
round_up :: proc(val, align: int) -> int {
	assert(val >= 0)
	if val == 0 do return 0
	return (((val - 1) / align) + 1) * align
}

round_up_to_vec4 :: proc(val: int) -> int {
	if selected_version == .std430 do return val
	else do return round_up(val, get_alignment(Vector{ type = .single, count = .four }))
}
