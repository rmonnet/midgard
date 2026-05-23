// This file implements the Weighted_Union_Find data structure managing a set of connected nodes.
// Inspired by Algorithms, Video Lecture, Robert Sedgewick, Kevin Wayne (Lecture 1).
package dsa

import "core:mem"

// The Weighted_Union_Find structure contains an array indexed by the nodes.
// Each node points to the id of its root. If a node is a root, it points to itself.
// Two nodes are connected if they have the same root.
// For efficiency we want the connected sets to be as shallow as possible so
// when we connect two sets, we will set the root of the smallest to the root of the largest.
//
// As an example, if we have 10 nodes (0..9) and we have connections
// between the sets {1, 2, 7}, {3, 4, 8, 9}, {0, 5, 6},
// one possible representation is
// index :  0, 1, 2, 3, 4, 5, 6, 7, 8, 9
// values:  6, 2, 2, 4, 4, 6, 6, 2, 4, 4
Weighted_Union_Find :: struct {
	parents: []int,
	sizes:   []int,
}

// Create a Weighted_Union_Find structure of n (initially) unconnected nodes.
wuf_create :: proc(n: int, allocator: mem.Allocator = context.allocator) -> Weighted_Union_Find {

	parents := make([]int, n, allocator)
	for i in 0 ..< n {
		parents[i] = i
	}
	sizes := make([]int, n, allocator)
	for i in 0 ..< n {
		sizes[i] = 1
	}
	return Weighted_Union_Find{parents, sizes}
}

// Release the memory associated with the UF structure.
wuf_destroy :: proc(set: ^Weighted_Union_Find) {

	delete(set.parents)
	delete(set.sizes)
}

// Returns the root of a node.
@(private = "file")
wuf_root_of :: proc(set: ^Weighted_Union_Find, p: int) -> int {

	root := p
	for root != set.parents[root] {
		root = set.parents[root]
	}
	return root
}

// Connect the nodes p and q.
wuf_union :: proc(set: ^Weighted_Union_Find, p, q: int) {

	// To connect the two nodes (really the two sets of nodes),
	// We change the root of the p set to the root of the q set.
	p_root := wuf_root_of(set, p)
	q_root := wuf_root_of(set, q)
	if set.sizes[p_root] < set.sizes[q_root] {
		set.parents[p_root] = q_root
		set.sizes[q_root] += set.sizes[p_root]
	} else {
		set.parents[q_root] = p_root
		set.sizes[p_root] += set.sizes[q_root]
	}
}

// Check if the nodes p and q are connected.
wuf_is_connected :: proc(set: ^Weighted_Union_Find, p, q: int) -> bool {

	return wuf_root_of(set, p) == wuf_root_of(set, q)
}

// --------------------------------------------
// Tests
// --------------------------------------------

import "core:slice"
import "core:testing"

@(test)
test_wuf_union_2_elements :: proc(t: ^testing.T) {

	set := wuf_create(10)
	defer wuf_destroy(&set)
	wuf_union(&set, 4, 3)
	expected := []int{0, 1, 2, 4, 4, 5, 6, 7, 8, 9}

	if !slice.equal(set.parents, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, set.parents)
	}
}

@(test)
test_wuf_union_3_elements :: proc(t: ^testing.T) {

	set := wuf_create(10, context.allocator)
	defer wuf_destroy(&set)
	wuf_union(&set, 4, 3)
	wuf_union(&set, 3, 8)
	expected := []int{0, 1, 2, 4, 4, 5, 6, 7, 4, 9}

	if !slice.equal(set.parents, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, set.parents)
	}
}

@(test)
test_wuf_union_many_elements :: proc(t: ^testing.T) {

	set := wuf_create(10, context.allocator)
	defer wuf_destroy(&set)
	wuf_union(&set, 4, 3)
	wuf_union(&set, 3, 8)
	wuf_union(&set, 6, 5)
	wuf_union(&set, 9, 4)
	wuf_union(&set, 2, 1)
	wuf_union(&set, 5, 0)
	wuf_union(&set, 7, 2)
	wuf_union(&set, 6, 1)
	wuf_union(&set, 7, 3)
	expected := []int{6, 2, 6, 4, 6, 6, 6, 2, 4, 4}

	if !slice.equal(set.parents, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, set.parents)
	}
}

@(test)
test_wuf_connected :: proc(t: ^testing.T) {

	set := wuf_create(10, context.allocator)
	defer wuf_destroy(&set)
	wuf_union(&set, 4, 3)
	wuf_union(&set, 3, 8)
	wuf_union(&set, 6, 5)
	wuf_union(&set, 9, 4)
	wuf_union(&set, 2, 1)

	testing.expect(t, wuf_is_connected(&set, 8, 9), "8 and 9 are connected")
	testing.expect(t, !wuf_is_connected(&set, 0, 5), "0 and 5 are not connected")
}

