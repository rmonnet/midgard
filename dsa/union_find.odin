// This file implements the Union_Find data structure managing a set of connected nodes.
// Inspired by Algorithms, Video Lecture, Robert Sedgewick, Kevin Wayne (Lecture 1).
package dsa

import "core:mem"

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

// Create an Union_Find structure of n (initially) unconnected nodes.
uf_create :: proc(n: int, allocator: mem.Allocator = context.allocator) -> Union_Find {

	ids := make([]int, n, allocator)
	for i in 0 ..< n {
		ids[i] = i
	}
	return Union_Find{ids}
}

// Release the memory associated with the UF structure.
uf_destroy :: proc(set: ^Union_Find) {

	delete(set.ids)
}

// Connect the nodes p and q.
uf_union :: proc(set: ^Union_Find, p, q: int) {

	// Each node (p and q) is part of a pre-existing connection set.
	// Each connection set is defined by a specific id.
	// We connect both sets by replacing the id of the p set with the id of q set.
	p_id := set.ids[p]
	q_id := set.ids[q]
	if p_id == q_id {return}
	for i in 0 ..< len(set.ids) {
		if set.ids[i] == p_id {
			set.ids[i] = q_id
		}
	}
}

// Check if the nodes p and q are connected.
uf_is_connected :: proc(set: ^Union_Find, p, q: int) -> bool {

	return set.ids[p] == set.ids[q]
}

// Tests
// -----

import "core:slice"
import "core:testing"

@(test)
test_uf_union_2_elements :: proc(t: ^testing.T) {

	set := uf_create(10)
	defer uf_destroy(&set)
	uf_union(&set, 4, 3)
	expected := []int{0, 1, 2, 3, 3, 5, 6, 7, 8, 9}

	if !slice.equal(set.ids, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, set.ids)
	}
}

@(test)
test_uf_union_3_elements :: proc(t: ^testing.T) {

	set := uf_create(10)
	defer uf_destroy(&set)
	uf_union(&set, 4, 3)
	uf_union(&set, 3, 8)
	expected := []int{0, 1, 2, 8, 8, 5, 6, 7, 8, 9}

	if !slice.equal(set.ids, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, set.ids)
	}
}

@(test)
test_uf_union_many_elements :: proc(t: ^testing.T) {

	set := uf_create(10)
	defer uf_destroy(&set)
	uf_union(&set, 4, 3)
	uf_union(&set, 3, 8)
	uf_union(&set, 6, 5)
	uf_union(&set, 9, 4)
	uf_union(&set, 2, 1)
	expected := []int{0, 1, 1, 8, 8, 5, 5, 7, 8, 8}

	if !slice.equal(set.ids, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, set.ids)
	}
}

@(test)
test_uf_connected :: proc(t: ^testing.T) {

	set := uf_create(10)
	defer uf_destroy(&set)
	uf_union(&set, 4, 3)
	uf_union(&set, 3, 8)
	uf_union(&set, 6, 5)
	uf_union(&set, 9, 4)
	uf_union(&set, 2, 1)

	testing.expect(t, uf_is_connected(&set, 8, 9), "8 and 9 are connected")
	testing.expect(t, !uf_is_connected(&set, 0, 5), "0 and 5 are not connected")
}

