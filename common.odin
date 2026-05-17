// This file contains types and procedures that are useful across
// a set of algorithms.
package midgard

// The Cmp type is used when comparing types which
// do not implement the comparison operators.
// It is used with procedures of signature
// cmp :: proc(a, b: $T) -> Cmp
Cmp :: enum {
	Greater,
	Equal,
	Less,
}

// The following are comparison procedures
// that satisfy the cmd signature above.

cmp_int :: proc(a, b: int) -> Cmp {

	if a < b {return .Less}
	if a > b {return .Greater}
	return .Equal
}

cmp_f64 :: proc(a, b: f64) -> Cmp {

	if a < b {return .Less}
	if a > b {return .Greater}
	return .Equal
}

cmp_string :: proc(a, b: string) -> Cmp {

	if a < b {return .Less}
	if a > b {return .Greater}
	return .Equal
}

cmp_string_reverse :: proc(a, b: string) -> Cmp {

	if a < b {return .Greater}
	if a > b {return .Less}
	return .Equal
}

