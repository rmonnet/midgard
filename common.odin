// This file contains types and procedures that are useful across
// a set of algorithms.
package midgard

import "base:intrinsics"

// The Linked_List_Node represents a node of a single Linked List.
@(private)
Linked_List_Node :: struct($T: typeid) {
	element: T,
	next:    ^Linked_List_Node(T),
}

// Pair defines a pair of elements.
@(private)
Pair :: struct($T1: typeid, $T2: typeid) {
	first:  T1,
	second: T2,
}

// The Cmp type is used when comparing types which
// do not implement the comparison operators.
// It is used with procedures of signature
// cmp :: proc(a, b: $T) -> Cmp
Cmp :: enum {
	Greater,
	Equal,
	Less,
}

cmp_gen :: proc(a, b: $T) -> Cmp where intrinsics.type_is_comparable(T) {

	if a < b {return .Less}
	if a > b {return .Greater}
	return .Equal
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

