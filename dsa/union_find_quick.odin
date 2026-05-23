// This file implements the Quick_Union_Find data structure managing a set of connected nodes.
// Inspired by Algorithms, Video Lecture, Robert Sedgewick, Kevin Wayne (Lecture 1).
package dsa

import "core:mem"

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
	parents: []int,
}

// Create a Quick_Union_Find structure of n (initially) unconnected nodes.
quf_create :: proc(n: int, allocator: mem.Allocator = context.allocator) -> Quick_Union_Find {

	parents := make([]int, n, allocator)
	for i in 0 ..< n {
		parents[i] = i
	}
	return Quick_Union_Find{parents}
}

// Release the memory associated with the UF structure.
quf_destroy :: proc(set: ^Quick_Union_Find) {

	delete(set.parents)
}

// Returns the root of a node.
@(private = "file")
quf_root_of :: proc(set: ^Quick_Union_Find, p: int) -> int {

	// By definition, a root is its own parent.
	root := p
	for root != set.parents[root] {
		root = set.parents[root]
	}
	return root
}

// Connect the nodes p and q.
quf_union :: proc(set: ^Quick_Union_Find, p, q: int) {

	// To connect the two nodes (really the two sets of nodes),
	// We chaneg the root of the p set to the root of the q set.
	p_root := quf_root_of(set, p)
	q_root := quf_root_of(set, q)
	set.parents[p_root] = q_root
}

// Check if the nodes p and q are connected.
quf_is_connected :: proc(set: ^Quick_Union_Find, p, q: int) -> bool {

	return quf_root_of(set, p) == quf_root_of(set, q)
}

// --------------------------------------------
// Tests
// --------------------------------------------

import "core:slice"
import "core:testing"

@(test)
test_quf_union_2_elements :: proc(t: ^testing.T) {

	set := quf_create(10)
	defer quf_destroy(&set)
	quf_union(&set, 4, 3)
	expected := []int{0, 1, 2, 3, 3, 5, 6, 7, 8, 9}

	if !slice.equal(set.parents, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, set.parents)
	}
}

@(test)
test_quf_union_3_elements :: proc(t: ^testing.T) {

	set := quf_create(10)
	defer quf_destroy(&set)
	quf_union(&set, 4, 3)
	quf_union(&set, 3, 8)
	expected := []int{0, 1, 2, 8, 3, 5, 6, 7, 8, 9}

	if !slice.equal(set.parents, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, set.parents)
	}
}

@(test)
test_quf_union_many_elements :: proc(t: ^testing.T) {

	set := quf_create(10)
	defer quf_destroy(&set)
	quf_union(&set, 4, 3)
	quf_union(&set, 3, 8)
	quf_union(&set, 6, 5)
	quf_union(&set, 9, 4)
	quf_union(&set, 2, 1)
	expected := []int{0, 1, 1, 8, 3, 5, 5, 7, 8, 8}

	if !slice.equal(set.parents, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, set.parents)
	}
}

@(test)
test_quf_connected :: proc(t: ^testing.T) {

	set := quf_create(10)
	defer quf_destroy(&set)
	quf_union(&set, 4, 3)
	quf_union(&set, 3, 8)
	quf_union(&set, 6, 5)
	quf_union(&set, 9, 4)
	quf_union(&set, 2, 1)

	testing.expect(t, quf_is_connected(&set, 8, 9), "8 and 9 are connected")
	testing.expect(t, !quf_is_connected(&set, 0, 5), "0 and 5 are not connected")
}

