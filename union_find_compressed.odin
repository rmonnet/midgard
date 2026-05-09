// This file implements the Weighted_Quick_Union_Find data structure managing a set of connected nodes.
// Inspired by Algorithms, Video Lecture, Robert Sedgewick, Kevin Wayne (Lecture 1).
package midgard

import "core:mem"
import "core:testing"

// The Weighted_Quick_Union_Find structure contains an array indexed by the nodes.
// Each node points to the id of its root. If a node is a root, it points to itself.
// Two nodes are connected if they have the same root.
// For efficiency we want the connected sets to be as shallow as possible so
// when we connect two sets, we will set the root of the smallest to the root of the largest.
// To reduce the time found in finding roots of nodes, we will use "path compression",
// by connecting every other node to its grand-parent node when visiting the tree to find a root.
//
// As an example, if we have 10 nodes (0..9) and we have connections
// between the sets {1, 2, 7}, {3, 4, 8, 9}, {0, 5, 6},
// one possible representation is
// index :  0, 1, 2, 3, 4, 5, 6, 7, 8, 9
// values:  6, 2, 2, 4, 4, 6, 6, 2, 4, 4
Compressed_Union_Find :: struct {
	parents: []int,
	sizes:   []int,
}

// Create a Weighted_Quick_Union_Find structure of n (initially) unconnected nodes.
cuf_create :: proc(n: int, allocator: mem.Allocator = context.allocator) -> Compressed_Union_Find {

	parents := make([]int, n, allocator)
	for i in 0 ..< n {
		parents[i] = i
	}
	sizes := make([]int, n, allocator)
	for i in 0 ..< n {
		sizes[i] = 1
	}
	return Compressed_Union_Find{parents, sizes}
}

// Release the memory associated with the UF structure.
cuf_destroy :: proc(set: ^Compressed_Union_Find) {

	delete(set.parents)
	delete(set.sizes)
}

// Returns the root of a node.
@(private = "file")
cuf_root_of :: proc(set: ^Compressed_Union_Find, p: int) -> int {

	root := p
	for root != set.parents[root] {
		// As we visit the tree, we will partially flatten it to shorten the time it takes to find roots.
		set.parents[root] = set.parents[set.parents[root]]
		root = set.parents[root]
	}
	return root
}

// Connect the nodes p and q.
cuf_union :: proc(set: ^Compressed_Union_Find, p, q: int) {

	// To connect the two nodes (really the two sets of nodes),
	// We chaneg the root of the p set to the root of the q set.
	p_root := cuf_root_of(set, p)
	q_root := cuf_root_of(set, q)
	if set.sizes[p_root] < set.sizes[q_root] {
		set.parents[p_root] = q_root
		set.sizes[q_root] += set.sizes[p_root]
	} else {
		set.parents[q_root] = p_root
		set.sizes[p_root] += set.sizes[q_root]
	}
}

// Check if the nodes p and q are connected.
cuf_is_connected :: proc(set: ^Compressed_Union_Find, p, q: int) -> bool {

	return cuf_root_of(set, p) == cuf_root_of(set, q)
}

// --------------------------------------------
// Tests
// --------------------------------------------

@(test)
test_cuf_union_2_elements :: proc(t: ^testing.T) {

	set := cuf_create(10)
	defer cuf_destroy(&set)
	cuf_union(&set, 4, 3)
	expected := [?]int{0, 1, 2, 4, 4, 5, 6, 7, 8, 9}
	expect_slices(t, set.parents, expected[:])
}

@(test)
test_cuf_union_3_elements :: proc(t: ^testing.T) {

	set := cuf_create(10, context.allocator)
	defer cuf_destroy(&set)
	cuf_union(&set, 4, 3)
	cuf_union(&set, 3, 8)
	expected := [?]int{0, 1, 2, 4, 4, 5, 6, 7, 4, 9}
	expect_slices(t, set.parents, expected[:])
}

@(test)
test_cuf_union_many_elements :: proc(t: ^testing.T) {

	set := cuf_create(10, context.allocator)
	defer cuf_destroy(&set)
	cuf_union(&set, 4, 3)
	cuf_union(&set, 3, 8)
	cuf_union(&set, 6, 5)
	cuf_union(&set, 9, 4)
	cuf_union(&set, 2, 1)
	cuf_union(&set, 5, 0)
	cuf_union(&set, 7, 2)
	cuf_union(&set, 6, 1)
	cuf_union(&set, 7, 3)
	expected := [?]int{6, 2, 6, 4, 6, 6, 6, 6, 4, 4}
	expect_slices(t, set.parents, expected[:])
}

@(test)
test_cuf_connected :: proc(t: ^testing.T) {

	// We have two sets of connected nodes,
	// {3, 4, 8, 9} and {0, 1, 2, 5, 6, 7}.
	set := cuf_create(10, context.allocator)
	defer cuf_destroy(&set)
	cuf_union(&set, 4, 3)
	cuf_union(&set, 3, 8)
	cuf_union(&set, 6, 5)
	cuf_union(&set, 9, 4)
	cuf_union(&set, 2, 1)
	cuf_union(&set, 5, 0)
	cuf_union(&set, 7, 2)
	cuf_union(&set, 6, 1)
	testing.expect(t, cuf_is_connected(&set, 3, 4))
	testing.expect(t, cuf_is_connected(&set, 3, 8))
	testing.expect(t, cuf_is_connected(&set, 3, 9))
	testing.expect(t, cuf_is_connected(&set, 4, 8))
	testing.expect(t, cuf_is_connected(&set, 4, 9))
	testing.expect(t, cuf_is_connected(&set, 8, 9))
	testing.expect(t, cuf_is_connected(&set, 0, 1))
	testing.expect(t, cuf_is_connected(&set, 0, 2))
	testing.expect(t, cuf_is_connected(&set, 0, 5))
	testing.expect(t, cuf_is_connected(&set, 0, 6))
	testing.expect(t, cuf_is_connected(&set, 0, 7))
	testing.expect(t, cuf_is_connected(&set, 1, 2))
	testing.expect(t, cuf_is_connected(&set, 1, 5))
	testing.expect(t, cuf_is_connected(&set, 1, 6))
	testing.expect(t, cuf_is_connected(&set, 1, 7))
	testing.expect(t, cuf_is_connected(&set, 2, 5))
	testing.expect(t, cuf_is_connected(&set, 2, 6))
	testing.expect(t, cuf_is_connected(&set, 2, 7))
	testing.expect(t, cuf_is_connected(&set, 5, 6))
	testing.expect(t, cuf_is_connected(&set, 5, 7))
	testing.expect(t, cuf_is_connected(&set, 6, 7))
	testing.expect(t, !cuf_is_connected(&set, 3, 0))
	testing.expect(t, !cuf_is_connected(&set, 3, 1))
	testing.expect(t, !cuf_is_connected(&set, 3, 2))
	testing.expect(t, !cuf_is_connected(&set, 3, 5))
	testing.expect(t, !cuf_is_connected(&set, 3, 6))
	testing.expect(t, !cuf_is_connected(&set, 3, 7))
	testing.expect(t, !cuf_is_connected(&set, 4, 0))
	testing.expect(t, !cuf_is_connected(&set, 4, 1))
	testing.expect(t, !cuf_is_connected(&set, 4, 2))
	testing.expect(t, !cuf_is_connected(&set, 4, 5))
	testing.expect(t, !cuf_is_connected(&set, 4, 6))
	testing.expect(t, !cuf_is_connected(&set, 4, 7))
	testing.expect(t, !cuf_is_connected(&set, 8, 0))
	testing.expect(t, !cuf_is_connected(&set, 8, 1))
	testing.expect(t, !cuf_is_connected(&set, 8, 2))
	testing.expect(t, !cuf_is_connected(&set, 8, 5))
	testing.expect(t, !cuf_is_connected(&set, 8, 6))
	testing.expect(t, !cuf_is_connected(&set, 8, 7))
	testing.expect(t, !cuf_is_connected(&set, 9, 0))
	testing.expect(t, !cuf_is_connected(&set, 9, 1))
	testing.expect(t, !cuf_is_connected(&set, 9, 2))
	testing.expect(t, !cuf_is_connected(&set, 9, 5))
	testing.expect(t, !cuf_is_connected(&set, 9, 6))
	testing.expect(t, !cuf_is_connected(&set, 9, 7))
}
