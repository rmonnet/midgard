// This file implements the Union_Find data structure managing a set of connected nodes.
// Inspired by Algorithms, Video Lecture, Robert Sedgewick, Kevin Wayne (Lecture 1).
package midgard

import "core:mem"
import "core:testing"

// The Union_Find structure contains an array indexed by the nodes.
// All connected nodes have the same value.
//
// As an example, if we have 10 nodes (0..9) and we have connections
// between the sets {0, 5, 6}, {1, 2, 7}, {3, 4, 8, 9},
// one possible representation is
// index :  0, 1, 2, 3, 4, 5, 6, 7, 8, 9
// values:  0, 1, 1, 8, 8, 0, 0, 1, 8, 8
Union_Find :: struct {
	ids: []int,
}

// Create an UF structure of n (initially) unconnected nodes.
uf_create :: proc(n: int, allocator: mem.Allocator) -> Union_Find {

	ids := make([]int, n, allocator)
	for i in 0 ..< n {
		ids[i] = i
	}
	return Union_Find{ids}
}

// Release the memory associated with the UF structure.
uf_destroy :: proc(uf: ^Union_Find) {

	delete(uf.ids)
}

// Connect the nodes p and q.
uf_union :: proc(uf: ^Union_Find, p, q: int) {

	// Each node (p and q) is part of a pre-existing connection set.
	// Each connection set is defined by a specific id.
	// We connect both sets by replacing the id of the p set with the id of q set.
	p_id := uf.ids[p]
	q_id := uf.ids[q]
	if p_id == q_id {return}
	for i in 0 ..< len(uf.ids) {
		if uf.ids[i] == p_id {
			uf.ids[i] = q_id
		}
	}
}

// Check if the nodes p and q are connected.
uf_connected :: proc(uf: ^Union_Find, p, q: int) -> bool {

	return uf.ids[p] == uf.ids[q]
}

// --------------------------------------------
// Tests
// --------------------------------------------

@(test)
test_union_2_elements :: proc(t: ^testing.T) {

	nodes := uf_create(10, context.allocator)
	defer uf_destroy(&nodes)
	uf_union(&nodes, 4, 3)
	expected := [?]int{0, 1, 2, 3, 3, 5, 6, 7, 8, 9}
	expect_slices(t, nodes.ids, expected[:])
}

@(test)
test_union_3_elements :: proc(t: ^testing.T) {

	nodes := uf_create(10, context.allocator)
	defer uf_destroy(&nodes)
	uf_union(&nodes, 4, 3)
	uf_union(&nodes, 3, 8)
	expected := [?]int{0, 1, 2, 8, 8, 5, 6, 7, 8, 9}
	expect_slices(t, nodes.ids, expected[:])
}

@(test)
test_union_many_elements :: proc(t: ^testing.T) {

	nodes := uf_create(10, context.allocator)
	defer uf_destroy(&nodes)
	uf_union(&nodes, 4, 3)
	uf_union(&nodes, 3, 8)
	uf_union(&nodes, 6, 5)
	uf_union(&nodes, 9, 4)
	uf_union(&nodes, 2, 1)
	expected := [?]int{0, 1, 1, 8, 8, 5, 5, 7, 8, 8}
	expect_slices(t, nodes.ids, expected[:])
}

@(test)
test_connected :: proc(t: ^testing.T) {

	nodes := uf_create(10, context.allocator)
	defer uf_destroy(&nodes)
	uf_union(&nodes, 4, 3)
	uf_union(&nodes, 3, 8)
	uf_union(&nodes, 6, 5)
	uf_union(&nodes, 9, 4)
	uf_union(&nodes, 2, 1)
	testing.expect(t, uf_connected(&nodes, 8, 9), "8 and 9 are connected")
	testing.expect(t, !uf_connected(&nodes, 0, 5), "0 and 5 are not connected")
}
