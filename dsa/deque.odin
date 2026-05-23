// This file implements a classic Deque data structure using a linked list.
// The deque combines a stack (Last In - First Out) and a Queue (First In - First Out).
//
// Reference: Algorithms by Sedgewick and Wayne, Lecture 3.
package dsa

// The Linked_List_Node represents a node of a single Linked List.
Deque_Node :: struct($T: typeid) {
	element: T,
	next:    ^Deque_Node(T),
}

// The Deque defines a Stack/Queue data structure.
// It is initialized by default.
Deque :: struct($T: typeid) {
	first: ^Deque_Node(T),
	last:  ^Deque_Node(T),
	count: int,
}

// Destroy a Deque of elements which don't use dynamic allocation.
dq_destroy_unmanaged_elements :: proc(d: ^Deque($T)) {

	for node := d.first; node != nil; node = node.next {
		free(node)
	}
	// Avoid problems if the Deque is reused after it is destroyed.
	d.first = nil
	d.last = nil
	d.count = 0
}

// Destroy a Deque of elements which use dynamic allocation.
// The caller must pass a procedure to deallocate the individual
// elements.
dq_destroy_managed_elements :: proc(d: ^Deque($T), destroy_element: proc(element: T)) {

	for node := d.first; node != nil; node = node.next {
		destroy_element(node.element)
		free(node)
	}
	// Avoid problems if the Deque is reused after it is destroyed.
	d.first = nil
	d.last = nil
	d.count = 0
}

dq_destroy :: proc {
	dq_destroy_unmanaged_elements,
	dq_destroy_managed_elements,
}

// Pop a value from the deque, the success return value
// is set to false if there is no element to pop.
dq_pop :: proc(d: ^Deque($T)) -> (value: T, success: bool) {

	// For the Stack behavior, the values are pushed on the front
	//  and popped from the front.
	if d.first == nil {return}
	first := d.first
	defer free(first)
	d.first = first.next
	// The only case we need to update the last pointer is
	// when we only have one element in the queue.
	if d.first == nil {
		d.last = nil
	}
	d.count -= 1
	return first.element, true
}

// Remove a value from the Deque, the ok return value
// is set to false if there is no element to remove.
//
// Since we pop and dequeue from the front of the Deque,
// the two procedures are synonymous.
dq_dequeue :: dq_pop

// Push a value on the Deque.
dq_push :: proc(d: ^Deque($T), value: T) {

	// For the Stack behavior, the values are pushed on the front
	//  and popped from the front.
	new_first := new_clone(Deque_Node(T){element = value, next = d.first})
	d.first = new_first
	// The only case we need to update the last pointer is
	// when we add the first element to the queue.
	if d.last == nil {
		d.last = new_first
	}
	d.count += 1
}

// Add an element on the queue.
dq_enqueue :: proc(d: ^Deque($T), value: T) {

	// For the Queue behavior, the values are queued onto the back
	//  and dequeued from the front.
	new_last := new_clone(Deque_Node(T){element = value, next = nil})
	if d.last != nil {
		d.last.next = new_last
	}
	d.last = new_last
	// The only case we need to update the first pointer is
	// when we add the first element to the queue.
	if d.first == nil {
		d.first = new_last
	}
	d.count += 1
}

// Returns the number of values in the Deque.
dq_size :: proc(d: Deque($T)) -> int {

	return d.count
}

// ---------------------------------------
// Tests
// ---------------------------------------

import "core:testing"

@(test)
test_dq_is_empty :: proc(t: ^testing.T) {

	d: Deque(int)
	testing.expect_value(t, dq_size(d), 0)
}

@(test)
test_dq_is_not_empty_push :: proc(t: ^testing.T) {

	d: Deque(int)
	defer dq_destroy(&d)
	dq_push(&d, 1)
	testing.expect_value(t, dq_size(d), 1)
}

@(test)
test_dq_is_not_empty_enqueue :: proc(t: ^testing.T) {

	d: Deque(int)
	defer dq_destroy(&d)
	dq_enqueue(&d, 1)
	testing.expect_value(t, dq_size(d), 1)
}

@(test)
test_dq_pop_empty :: proc(t: ^testing.T) {

	d: Deque(int)
	_, success := dq_pop(&d)
	testing.expect(t, !success)
}

@(test)
test_dq_dequeue_empty :: proc(t: ^testing.T) {

	d: Deque(int)
	_, success := dq_dequeue(&d)
	testing.expect(t, !success)
}

@(test)
test_dq_pop_not_empty :: proc(t: ^testing.T) {

	d: Deque(int)
	defer dq_destroy(&d)
	dq_push(&d, 1)
	dq_push(&d, 2)
	value, success := dq_pop(&d)
	testing.expect(t, success)
	testing.expect_value(t, 2, value)
	value, success = dq_pop(&d)
	testing.expect(t, success)
	testing.expect_value(t, 1, value)
	_, success = dq_pop(&d)
	testing.expect(t, !success)
}

@(test)
test_dq_dequeue_not_empty :: proc(t: ^testing.T) {

	d: Deque(int)
	defer dq_destroy(&d)
	dq_enqueue(&d, 1)
	dq_enqueue(&d, 2)
	value, success := dq_dequeue(&d)
	testing.expect(t, success)
	testing.expect_value(t, 1, value)
	value, success = dq_dequeue(&d)
	testing.expect(t, success)
	testing.expect_value(t, 2, value)
	_, success = dq_dequeue(&d)
	testing.expect(t, !success)
}

@(test)
test_dq_destroy_with_managed_values :: proc(t: ^testing.T) {

	free_int :: proc(n: ^int) {free(n)}

	d: Deque(^int)
	n1 := new_clone(1)
	dq_push(&d, n1)
	n2 := new_clone(2)
	dq_push(&d, n2)
	dq_destroy(&d, free_int)
	testing.expect_value(t, dq_size(d), 0)
}

