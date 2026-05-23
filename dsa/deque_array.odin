// This file implements a classic Deque data structure using a slice.
// The deque combines a stack (First In - Last Out) and a Queue (First In - First Out).
//
// Using a backing array, because the `dequeue` operation removes elements
// from the front of the array, the array must be treated as a circular buffer
// and there are cases where the populated portion of the array wraps from the
// end to the beginning.
//
// Reference: Algorithms by Sedgewick and Wayne, Lecture 3.
package dsa

// Minimum size for the array backing the Deque.
ADQ_MIN_SIZE :: 8

// The Deque defines a Stack/Queue data structure.
// It is initialized by default.
Array_Deque :: struct($T: typeid) {
	elements:    []T,
	// The first index represents the oldest value inserted in
	// the queue. The first index increases as elements are dequeued.
	first_index: int,
	// The next_index represents the next available spot in the deque.
	// The most recently inserted value is at next_index-1.
	// The next_index increases as elements are pushed and enqueued,
	// it decreases as elements are popped.
	next_index:  int,
	// The count represents the number of elements currently in the queue.
	count:       int,
}

// Destroy a Deque containing dynamically managed elements.
adq_destroy_managed_elements :: proc(d: ^Array_Deque($T), destroy: proc(value: T)) {

	if d.first_index <= d.next_index {
		for i in d.first_index ..< d.next_index {
			destroy(d.elements[i])
		}
	} else {
		for i in d.first_index ..< len(d.elements) {
			destroy(d.elements[i])
		}
		for i in 0 ..< d.next_index {
			destroy(d.elements[i])
		}
	}
	delete(d.elements)
	d.first_index = 0
	d.next_index = 0
	d.count = 0
}

// Destroy a Deque of non managed elements.
adq_destroy_unmanaged_elements :: proc(d: ^Array_Deque($T)) {

	delete(d.elements)
	d.first_index = 0
	d.next_index = 0
	d.count = 0
}

// Destroy a Deque.
adq_destroy :: proc {
	adq_destroy_managed_elements,
	adq_destroy_unmanaged_elements,
}

// Resize the Deque by shrinking/growing the backing array.
// It takes cares of cases when the circular buffer wraps from the back to the front.
// It also reset the indexes in the new copy of the array.
@(private = "file")
adq_resize :: proc(d: ^Array_Deque($T), new_size: int) {

	// In the cases where the
	old_elements := d.elements
	d.elements = make([]T, new_size)
	if len(old_elements) > 0 {
		if d.first_index <= d.next_index {
			copy(d.elements, old_elements[d.first_index:d.next_index])
		} else {
			n := copy(d.elements, old_elements[d.first_index:])
			copy(d.elements[n:], old_elements[:d.next_index])
		}
		delete(old_elements)
		d.first_index = 0
		d.next_index = d.count
	}
}

// Pop an element from the Deque, the success return value
// is set to false if there is no element to pop.
adq_pop :: proc(d: ^Array_Deque($T)) -> (value: T, success: bool) {

	if d.next_index == 0 {return}
	d.next_index = (d.next_index - 1) %% len(d.elements)
	value = d.elements[d.next_index]
	shrink_len := len(d.elements) / 4
	if shrink_len >= ADQ_MIN_SIZE && d.next_index < shrink_len {
		adq_resize(d, shrink_len)
	}
	return value, true
}

// Push an element on the stack.
// // This is the same as enqueuing an element since we add it to the back of the Deque.
adq_push :: adq_enqueue

// Dequeue a value from the Deque, the success return value
// is set to false if there is no element to dequeue.
adq_dequeue :: proc(d: ^Array_Deque($T)) -> (value: T, success: bool) {

	if d.count == 0 {return}
	value = d.elements[d.first_index]
	d.first_index = (d.first_index + 1) %% len(d.elements)
	d.count -= 1
	shrink_len := len(d.elements) / 4
	if shrink_len >= ADQ_MIN_SIZE && d.count < shrink_len {
		adq_resize(d, shrink_len)
	}
	return value, true
}

// Enqueue a value on the Deque.
adq_enqueue :: proc(d: ^Array_Deque($T), value: T) {

	// When next_index reaches the end of the elements array
	// We need to reset it to 0 (%% len(q.elements)).
	// But we want to wait until we are actually inserted
	// because growing or shrinking the array when next_index
	// has reached the end of the elements array
	// need to consider it at len(q.elements), not 0.
	if d.count >= len(d.elements) {
		adq_resize(d, max(len(d.elements) * 2, ADQ_MIN_SIZE))
	}
	d.elements[d.next_index] = value
	d.next_index += 1
	d.count += 1
}

// Return the size of the Deque
adq_size :: proc(d: Array_Deque($T)) -> int {

	return d.count
}

// ---------------------------------------
// Tests
// ---------------------------------------

import "core:testing"

@(test)
test_adq_is_empty :: proc(t: ^testing.T) {

	d: Array_Deque(int)
	testing.expect_value(t, adq_size(d), 0)
}

@(test)
test_adq_is_not_empty_push :: proc(t: ^testing.T) {

	d: Array_Deque(int)
	defer adq_destroy(&d)
	adq_push(&d, 1)
	testing.expect_value(t, adq_size(d), 1)
}

@(test)
test_adq_is_not_empty_enqueue :: proc(t: ^testing.T) {

	d: Array_Deque(int)
	defer adq_destroy(&d)
	adq_enqueue(&d, 1)
	testing.expect_value(t, adq_size(d), 1)
}

@(test)
test_adq_pop_empty :: proc(t: ^testing.T) {

	d: Array_Deque(int)
	_, success := adq_pop(&d)
	testing.expect(t, !success)
}

@(test)
test_adq_dequeue_empty :: proc(t: ^testing.T) {

	d: Array_Deque(int)
	_, success := adq_dequeue(&d)
	testing.expect(t, !success)
}

@(test)
test_adq_pop_not_empty :: proc(t: ^testing.T) {

	d: Array_Deque(int)
	defer adq_destroy(&d)
	adq_push(&d, 1)
	adq_push(&d, 2)
	value, success := adq_pop(&d)
	testing.expect(t, success)
	testing.expect_value(t, 2, value)
	value, success = adq_pop(&d)
	testing.expect(t, success)
	testing.expect_value(t, 1, value)
	_, success = adq_pop(&d)
	testing.expect(t, !success)
}

@(test)
test_adq_dequeue_not_empty :: proc(t: ^testing.T) {

	d: Array_Deque(int)
	defer adq_destroy(&d)
	adq_enqueue(&d, 1)
	adq_enqueue(&d, 2)
	value, success := adq_dequeue(&d)
	testing.expect(t, success)
	testing.expect_value(t, 1, value)
	value, success = adq_dequeue(&d)
	testing.expect(t, success)
	testing.expect_value(t, 2, value)
	_, success = adq_dequeue(&d)
	testing.expect(t, !success)
}

@(test)
test_adq_destroy_with_managed_elements :: proc(t: ^testing.T) {

	free_int :: proc(n: ^int) {free(n)}

	d: Array_Deque(^int)
	n1 := new_clone(1)
	adq_push(&d, n1)
	n2 := new_clone(2)
	adq_push(&d, n2)
	adq_destroy(&d, free_int)
	testing.expect_value(t, adq_size(d), 0)
}

