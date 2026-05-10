// This file implements a classic Stack LIFO data structure using a slice.
package midgard

import "core:testing"

@(private = "file")
AST_MIN_SIZE :: 8

// The Stack defines a LIFO data structure.
// It is initialized by default.
ArrayStack :: struct($T: typeid) {
	elements:   []T,
	// The next_index represents the next available spot in the stack.
	// The most recently inserted element is at next_index-1.
	next_index: int,
}

// Destroy a Stack containing elements that need to be destroyed themselves.
ast_destroy_with_element_destroy :: proc(s: ^ArrayStack($T), element_destroy: proc(element: T)) {

	for i in 0 ..< s.next_index {
		element_destroy(s.elements[i])
	}
	delete(s.elements)
	s.next_index = 0
}

// Destroy a Stack of elements which don't use dynamic allocation.
ast_destroy_simple :: proc(s: ^ArrayStack($T)) {

	delete(s.elements)
	s.next_index = 0
}

// Destroy a stack.
ast_destroy :: proc {
	ast_destroy_simple,
	ast_destroy_with_element_destroy,
}

@(private = "file")
ast_resize :: proc(s: ^ArrayStack($T), new_size: int) {

	old_elements := s.elements
	s.elements = make([]T, new_size)
	if len(old_elements) > 0 {
		copy(s.elements, old_elements)
		delete(old_elements)
	}
}

// Pop an element from the stack, the ok return value
// is set to false if there is no element to pop.
ast_pop :: proc(s: ^ArrayStack($T)) -> (element: T, ok: bool) {

	if s.next_index == 0 {return}
	s.next_index -= 1
	element = s.elements[s.next_index]
	shrink_len := len(s.elements) / 4
	if shrink_len >= AST_MIN_SIZE && s.next_index < shrink_len {
		ast_resize(s, shrink_len)
	}
	return element, true
}

// Push an element on the stack.
ast_push :: proc(s: ^ArrayStack($T), element: T) {

	if s.next_index >= len(s.elements) {
		ast_resize(s, max(len(s.elements) * 2, AST_MIN_SIZE))
	}
	s.elements[s.next_index] = element
	s.next_index += 1
}

// Check if the stack is empty.
ast_is_empty :: proc(s: ArrayStack($T)) -> bool {

	return s.next_index == 0
}

// ----------------------------------------
// Tests
// ----------------------------------------

@(test)
test_ast_is_empty :: proc(t: ^testing.T) {

	s: ArrayStack(int)
	testing.expect(t, ast_is_empty(s))
}

@(test)
test_ast_is_not_empty :: proc(t: ^testing.T) {

	s: ArrayStack(int)
	defer ast_destroy(&s)
	ast_push(&s, 1)
	testing.expect(t, !ast_is_empty(s))
}

@(test)
test_ast_pop_empty :: proc(t: ^testing.T) {

	s: ArrayStack(int)
	_, ok := ast_pop(&s)
	testing.expect(t, !ok)
}

@(test)
test_ast_pop_not_empty :: proc(t: ^testing.T) {

	s: ArrayStack(int)
	defer ast_destroy(&s)
	ast_push(&s, 1)
	ast_push(&s, 2)
	value, ok := ast_pop(&s)
	testing.expect(t, ok)
	testing.expect_value(t, 2, value)
	value, ok = ast_pop(&s)
	testing.expect(t, ok)
	testing.expect_value(t, 1, value)
	_, ok = ast_pop(&s)
	testing.expect(t, !ok)
}

@(test)
test_ast_resize_down :: proc(t: ^testing.T) {

	s: ArrayStack(int)
	defer ast_destroy(&s)
	testing.expect_value(t, len(s.elements), 0)
	for i in 1 ..= 17 {
		ast_push(&s, i)
	}
	testing.expect_value(t, len(s.elements), 32)
	for {
		_, ok := ast_pop(&s)
		if !ok {break}
	}
	testing.expect_value(t, len(s.elements), 8)
}

@(test)
test_ast_resize_up :: proc(t: ^testing.T) {

	s: ArrayStack(int)
	defer ast_destroy(&s)
	testing.expect_value(t, len(s.elements), 0)
	ast_push(&s, 1)
	testing.expect_value(t, len(s.elements), 8)
	for i in 2 ..= 8 {
		ast_push(&s, i)
	}
	testing.expect_value(t, len(s.elements), 8)
	ast_push(&s, 9)
	testing.expect_value(t, len(s.elements), 16)
}

@(test)
test_ast_destroy_with_element_destroy :: proc(t: ^testing.T) {

	free_int :: proc(n: ^int) {
		free(n)
	}

	s: ArrayStack(^int)
	n1 := new_clone(1)
	ast_push(&s, n1)
	n2 := new_clone(2)
	ast_push(&s, n2)
	ast_destroy(&s, free_int)
	testing.expect(t, ast_is_empty(s))
}

