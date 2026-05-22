// This file implements a classic Deque data structure using a slice.
// The deque combines a stack (First In - Last Out) and a Queue (First In - First Out).
//
// Reference: Algorithms by Sedgewick and Wayne, Lecture 3.
package midgard

@(private = "file")
AST_MIN_SIZE :: 8

// The Deque defines a Stack/Queue data structure.
// It is initialized by default.
Array_Deque :: struct($T: typeid) {
	values:      []T,
	// The first index represents the oldest value inserted in
	// the queue. The first index increases as values are dequeued.
	first_index: int,
	// The next_index represents the next available spot in the deque.
	// The most recently inserted value is at next_index-1.
	// The next_index increases as values are pushed and enqueued,
	// it decreases as values are popped.
	next_index:  int,
	// The count represents the number of elements currently in the queue.
	count:       int,
}

// Destroy a Deque containing dynamically managed values.
array_deque_destroy_with_managed_values :: proc(d: ^Array_Deque($T), destroy: proc(value: T)) {

	if d.first_index <= d.next_index {
		for i in d.first_index ..< d.next_index {
			destroy(d.values[i])
		}
	} else {
		for i in d.first_index ..< len(d.values) {
			destroy(d.values[i])
		}
		for i in 0 ..< d.next_index {
			destroy(d.values[i])
		}
	}
	delete(d.values)
	d.first_index = 0
	d.next_index = 0
	d.count = 0
}

// Destroy a Deque of non managed values.
array_deque_destroy_simple :: proc(d: ^Array_Deque($T)) {

	delete(d.values)
	d.first_index = 0
	d.next_index = 0
	d.count = 0
}

// Destroy a Deque.
array_deque_destroy :: proc {
	array_deque_destroy_simple,
	array_deque_destroy_with_managed_values,
}

@(private = "file")
array_deque_resize :: proc(d: ^Array_Deque($T), new_size: int) {

	old_values := d.values
	d.values = make([]T, new_size)
	if len(old_values) > 0 {
		if d.first_index <= d.next_index {
			copy(d.values, old_values[d.first_index:d.next_index])
		} else {
			n := copy(d.values, old_values[d.first_index:])
			copy(d.values[n:], old_values[:d.next_index])
		}
		delete(old_values)
		d.first_index = 0
		d.next_index = d.count
	}
}

// Pop an element from the Deque, the success return value
// is set to false if there is no element to pop.
array_deque_pop :: proc(d: ^Array_Deque($T)) -> (value: T, success: bool) {

	if d.next_index == 0 {return}
	d.next_index = (d.next_index - 1) %% len(d.values)
	value = d.values[d.next_index]
	shrink_len := len(d.values) / 4
	if shrink_len >= AST_MIN_SIZE && d.next_index < shrink_len {
		array_deque_resize(d, shrink_len)
	}
	return value, true
}

// Push an element on the stack.
// // This is the same as enqueuing an element since we add it to the back of the Deque.
array_deque_push :: array_deque_enqueue

// Dequeue a value from the Deque, the success return value
// is set to false if there is no element to dequeue.
array_deque_dequeue :: proc(d: ^Array_Deque($T)) -> (value: T, success: bool) {

	if d.count == 0 {return}
	value = d.values[d.first_index]
	d.first_index = (d.first_index + 1) %% len(d.values)
	d.count -= 1
	shrink_len := len(d.values) / 4
	if shrink_len >= AST_MIN_SIZE && d.count < shrink_len {
		array_deque_resize(d, shrink_len)
	}
	return value, true
}

// Enqueue a value on the Deque.
array_deque_enqueue :: proc(d: ^Array_Deque($T), value: T) {

	// When next_index reaches the end of the elements array
	// We need to reset it to 0 (%% len(q.elements)).
	// But we want to wait until we are actually inserted
	// because growing or shrinking the array when next_index
	// has reached the end of the elements array
	// need to consider it at len(q.elements), not 0.
	if d.count >= len(d.values) {
		array_deque_resize(d, max(len(d.values) * 2, AST_MIN_SIZE))
	}
	d.values[d.next_index] = value
	d.next_index += 1
	d.count += 1
}

// Return the size of the Deque
array_deque_size :: proc(d: Array_Deque($T)) -> int {

	return d.count
}

