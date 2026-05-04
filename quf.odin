// This file implements the Quick_Union_Find data structure managing a set of connected nodes.
// Inspired by Algorithms, Video Lecture, Robert Sedgewick, Kevin Wayne (Lecture 1).
package midgard

import "core:mem"
import "core:testing"

// The Quick_Union_Find structure contains an array indexed by the nodes.
// Each node points to the id of its root. If a node is a root, it points to itself.
// Two nodes are connected if they have the same root.
//
// As an example, if we have 10 nodes (0..9) and we have connections
// between the sets {0, 5, 6}, {1, 2, 7}, {3, 4, 8, 9},
// one possible representation is
// index :  0, 1, 2, 3, 4, 5, 6, 7, 8, 9
// values:  5, 2, 7, 4, 8, 6, 6, 7, 8, 8
Quick_Union_Find :: struct {
	ids: []int,
}

// Create a Quick_Union_Find structure of n (initially) unconnected nodes.
quf_create :: proc(n: int, allocator: mem.Allocator) -> Quick_Union_Find {

	ids := make([]int, n, allocator)
	for i in 0 ..< n {
		ids[i] = i
	}
	return Quick_Union_Find{ids}
}

// Release the memory associated with the UF structure.
quf_destroy :: proc(quf: ^Quick_Union_Find) {

	delete(quf.ids)
}

// Returns the root of a node.
@(private = "file")
quf_root_of :: proc(quf: ^Quick_Union_Find, p: int) -> int {

	root := p
	for root != quf.ids[root] {
		root = quf.ids[root]
	}
	return root
}

// Connect the nodes p and q.
quf_union :: proc(quf: ^Quick_Union_Find, p, q: int) {

	// To connect the two nodes (really the two sets of nodes),
	// We chaneg the root of the p set to the root of the q set.
	p_root := quf_root_of(quf, p)
	q_root := quf_root_of(quf, q)
	quf.ids[p_root] = q_root
}

// Check if the nodes p and q are connected.
quf_is_connected :: proc(quf: ^Quick_Union_Find, p, q: int) -> bool {

	return quf_root_of(quf, p) == quf_root_of(quf, q)
}

// --------------------------------------------
// Tests
// --------------------------------------------

@(test)
test_quf_union_2_elements :: proc(t: ^testing.T) {

	nodes := quf_create(10, context.allocator)
	defer quf_destroy(&nodes)
	quf_union(&nodes, 4, 3)
	expected := [?]int{0, 1, 2, 3, 3, 5, 6, 7, 8, 9}
	expect_slices(t, nodes.ids, expected[:])
}

@(test)
test_quf_union_3_elements :: proc(t: ^testing.T) {

	nodes := quf_create(10, context.allocator)
	defer quf_destroy(&nodes)
	quf_union(&nodes, 4, 3)
	quf_union(&nodes, 3, 8)
	expected := [?]int{0, 1, 2, 8, 3, 5, 6, 7, 8, 9}
	expect_slices(t, nodes.ids, expected[:])
}

@(test)
test_quf_union_many_elements :: proc(t: ^testing.T) {

	nodes := quf_create(10, context.allocator)
	defer quf_destroy(&nodes)
	quf_union(&nodes, 4, 3)
	quf_union(&nodes, 3, 8)
	quf_union(&nodes, 6, 5)
	quf_union(&nodes, 9, 4)
	quf_union(&nodes, 2, 1)
	expected := [?]int{0, 1, 1, 8, 3, 5, 5, 7, 8, 8}
	expect_slices(t, nodes.ids, expected[:])
}

@(test)
test_quf_connected :: proc(t: ^testing.T) {

	nodes := quf_create(10, context.allocator)
	defer quf_destroy(&nodes)
	quf_union(&nodes, 4, 3)
	quf_union(&nodes, 3, 8)
	quf_union(&nodes, 6, 5)
	quf_union(&nodes, 9, 4)
	quf_union(&nodes, 2, 1)
	testing.expect(t, quf_is_connected(&nodes, 8, 9), "8 and 9 are connected")
	testing.expect(t, !quf_is_connected(&nodes, 0, 5), "0 and 5 are not connected")
}
