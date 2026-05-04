// This file implements a classic Stack data structure using a linked list.
package midgard

import "core:testing"

Node :: struct($T: typeid) {
	item: T,
	next: ^Node(T),
}

Stack :: struct($T: typeid) {
	first: ^Node(T),
}

st_destroy_with_item_destroy :: proc(s: ^Stack($T), item_destroy: proc(item: T)) {

	for {
		item, ok := st_pop(s)
		if !ok {break}
		item_destroy(item)
	}
}

st_destroy_simple :: proc(s: ^Stack($T)) {

	for {
		item, ok := st_pop(s)
		if !ok {break}
	}
}

st_destroy :: proc {
	st_destroy_simple,
	st_destroy_with_item_destroy,
}

st_pop :: proc(s: ^Stack($T)) -> (item: T, ok: bool) {

	if s.first == nil {return}
	first := s.first
	defer free(first)
	s.first = first.next
	return first.item, true
}

st_push :: proc(s: ^Stack($T), item: T) {

	new_first := new_clone(Node(T){item = item, next = s.first})
	s.first = new_first
}

st_is_empty :: proc(s: Stack($T)) -> bool {

	return s.first == nil
}

// ----------------------------------------
// Tests
// ----------------------------------------

@(test)
test_st_is_empty :: proc(t: ^testing.T) {

	s: Stack(int)
	testing.expect(t, st_is_empty(s))
}

@(test)
test_st_is_not_empty :: proc(t: ^testing.T) {

	s: Stack(int)
	defer st_destroy(&s)
	st_push(&s, 1)
	testing.expect(t, !st_is_empty(s))
}

@(test)
test_st_pop_empty :: proc(t: ^testing.T) {

	s: Stack(int)
	value, ok := st_pop(&s)
	testing.expect(t, !ok)
}

@(test)
test_st_pop_not_empty :: proc(t: ^testing.T) {

	s: Stack(int)
	defer st_destroy(&s)
	st_push(&s, 1)
	st_push(&s, 2)
	value, ok := st_pop(&s)
	testing.expect(t, ok)
	testing.expect_value(t, 2, value)
	value, ok = st_pop(&s)
	testing.expect(t, ok)
	testing.expect_value(t, 1, value)
}

@(test)
test_st_destroy_with_item_destroy :: proc(t: ^testing.T) {

	free_int :: proc(n: ^int) {
		free(n)
	}

	s: Stack(^int)
	n1 := new_clone(1)
	st_push(&s, n1)
	n2 := new_clone(2)
	st_push(&s, n2)
	st_destroy(&s, free_int)
	testing.expect(t, st_is_empty(s))
}
