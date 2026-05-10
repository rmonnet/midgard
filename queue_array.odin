// This file implements a classic Queue FIFO data structure using a slice.
package midgard

import "core:testing"

@(private = "file")
aq_MIN_SIZE :: 8

// The Queue defines a FIFO data structure.
// It is initialized by default.
ArrayQueue :: struct($T: typeid) {
	elements:    []T,
	// The first index represents the oldest element inserted in
	// the queue. The first index increases as elements are removed (dequeued).
	first_index: int,
	// The next_index represents the next available spot in the queue.
	// The most recently inserted element is at next_index-1.
	next_index:  int,
	// The count represents the number of elements currently in the queue.
	count:       int,
}

// Destroy a Stack containing elements that need to be destroyed themselves.
aq_destroy_with_element_destroy :: proc(q: ^ArrayQueue($T), element_destroy: proc(element: T)) {

	if q.first_index <= q.next_index {
		for i in q.first_index ..< q.next_index {
			element_destroy(q.elements[i])
		}
	} else {
		for i in q.first_index ..< len(q.elements) {
			element_destroy(q.elements[i])
		}
		for i in 0 ..< q.next_index {
			element_destroy(q.elements[i])
		}
	}
	delete(q.elements)
	q.next_index = 0
	q.count = 0
}

// Destroy a Stack of elements which don't use dynamic allocation.
aq_destroy_simple :: proc(q: ^ArrayQueue($T)) {

	delete(q.elements)
	q.next_index = 0
	q.count = 0
}

// Destroy a stack.
aq_destroy :: proc {
	aq_destroy_simple,
	aq_destroy_with_element_destroy,
}

@(private = "file")
aq_resize :: proc(q: ^ArrayQueue($T), new_size: int) {

	old_elements := q.elements
	q.elements = make([]T, new_size)
	if len(old_elements) > 0 {
		if q.first_index <= q.next_index {
			copy(q.elements, old_elements[q.first_index:q.next_index])
		} else {
			n := copy(q.elements, old_elements[q.first_index:])
			copy(q.elements[n:], old_elements[:q.next_index])
		}
		delete(old_elements)
		q.first_index = 0
		q.next_index = q.count
	}
}

// Pop an element from the stack, the ok return value
// is set to false if there is no element to pop.
aq_dequeue :: proc(q: ^ArrayQueue($T)) -> (element: T, ok: bool) {

	if q.count == 0 {return}
	element = q.elements[q.first_index]
	q.first_index = (q.first_index + 1) %% len(q.elements)
	q.count -= 1
	shrink_len := len(q.elements) / 4
	if shrink_len >= aq_MIN_SIZE && q.count < shrink_len {
		aq_resize(q, shrink_len)
	}
	return element, true
}

// Push an element on the stack.
aq_enqueue :: proc(q: ^ArrayQueue($T), element: T) {

	// When next_index reaches the end of the elements array
	// We need to reset it to 0 (%% len(q.elements)).
	// But we want to wait until we are actually inserted
	// because growing or shrinking the array when next_index
	// has reached the end of the elements array
	// need to consider it at len(q.elements), not 0.
	if q.count >= len(q.elements) {
		aq_resize(q, max(len(q.elements) * 2, aq_MIN_SIZE))
	}
	q.next_index = q.next_index %% len(q.elements)
	q.elements[q.next_index] = element
	q.next_index += 1
	q.count += 1
}

// Check if the stack is empty.
aq_is_empty :: proc(q: ArrayQueue($T)) -> bool {

	return q.count == 0
}

// ----------------------------------------
// Tests
// ----------------------------------------

@(test)
test_aq_is_empty :: proc(t: ^testing.T) {

	q: ArrayQueue(int)
	testing.expect(t, aq_is_empty(q))
}

@(test)
test_aq_is_not_empty :: proc(t: ^testing.T) {

	q: ArrayQueue(int)
	defer aq_destroy(&q)
	aq_enqueue(&q, 1)
	testing.expect(t, !aq_is_empty(q))
}

@(test)
test_aq_dequeue_empty :: proc(t: ^testing.T) {

	q: ArrayQueue(int)
	_, ok := aq_dequeue(&q)
	testing.expect(t, !ok)
}

@(test)
test_aq_dequeue_not_empty :: proc(t: ^testing.T) {

	q: ArrayQueue(int)
	defer aq_destroy(&q)
	aq_enqueue(&q, 1)
	aq_enqueue(&q, 2)
	value, ok := aq_dequeue(&q)
	testing.expect(t, ok)
	testing.expect_value(t, 1, value)
	value, ok = aq_dequeue(&q)
	testing.expect(t, ok)
	testing.expect_value(t, 2, value)
	_, ok = aq_dequeue(&q)
	testing.expect(t, !ok)
}

@(test)
test_aq_resize_down :: proc(t: ^testing.T) {

	q: ArrayQueue(int)
	defer aq_destroy(&q)
	testing.expect_value(t, len(q.elements), 0)
	for i in 1 ..= 17 {
		aq_enqueue(&q, i)
	}
	testing.expect_value(t, len(q.elements), 32)
	value, ok := aq_dequeue(&q)
	testing.expect(t, ok)
	testing.expect_value(t, value, 1)
	value, ok = aq_dequeue(&q)
	testing.expect(t, ok)
	testing.expect_value(t, value, 2)
	for {
		_, ok = aq_dequeue(&q)
		if !ok {break}
	}
	testing.expect_value(t, len(q.elements), 8)
}

@(test)
test_aq_resize_up :: proc(t: ^testing.T) {

	q: ArrayQueue(int)
	defer aq_destroy(&q)
	testing.expect_value(t, len(q.elements), 0)
	aq_enqueue(&q, 1)
	testing.expect_value(t, len(q.elements), 8)
	for i in 2 ..= 8 {
		aq_enqueue(&q, i)
	}
	testing.expect_value(t, len(q.elements), 8)
	aq_enqueue(&q, 9)
	testing.expect_value(t, len(q.elements), 16)
}

@(test)
test_aq_destroy_with_element_destroy :: proc(t: ^testing.T) {

	free_int :: proc(n: ^int) {
		free(n)
	}

	q: ArrayQueue(^int)
	n1 := new_clone(1)
	aq_enqueue(&q, n1)
	n2 := new_clone(2)
	aq_enqueue(&q, n2)
	aq_destroy(&q, free_int)
	testing.expect(t, aq_is_empty(q))
}

