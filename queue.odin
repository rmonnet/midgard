// This file implements a classic Queue data structure using a linked list.
//
// We add (queue) elements at the end of the list and remove (dequeue)
// elements from the front of the list.
package midgard

import "core:testing"

// The Qeueue defines a FIFO data structure.
// It is initialized by default.
Queue :: struct($T: typeid) {
	first: ^Linked_List_Node(T),
	last:  ^Linked_List_Node(T),
}

// Destroy a Queue containing dynamically allocated elements.
q_destroy_with_element_destroy :: proc(q: ^Queue($T), element_destroy: proc(element: T)) {

	for {
		element, ok := q_dequeue(q)
		if !ok {break}
		element_destroy(element)
	}
}

// Destroy a Queue of elements which don't use dynamic allocation.
q_destroy_simple :: proc(q: ^Queue($T)) {

	for {
		_, ok := q_dequeue(q)
		if !ok {break}
	}
}

// Destroy a Queue.
q_destroy :: proc {
	q_destroy_simple,
	q_destroy_with_element_destroy,
}

// Remove an element from the queue, the ok return value
// is set to false if there is no element to remove.
q_dequeue :: proc(q: ^Queue($T)) -> (element: T, ok: bool) {

	if q.first == nil {return}
	first := q.first
	defer free(first)
	q.first = first.next
	// The only case we need to update the last pointer is
	// when we only have one element in the queue.
	if q.first == nil {
		q.last = nil
	}
	return first.element, true
}

// Add an element on the queue.
q_enqueue :: proc(q: ^Queue($T), element: T) {

	new_last := new_clone(Linked_List_Node(T){element = element, next = nil})
	if q.last != nil {
		q.last.next = new_last
	}
	q.last = new_last
	// The only case we need to update the first pointer is
	// when the add the first element to the queue.
	if q.first == nil {
		q.first = new_last
	}
}

// Check if the queue is empty.
q_is_empty :: proc(q: Queue($T)) -> bool {

	return q.first == nil
}

// ----------------------------------------
// Tests
// ----------------------------------------


@(test)
test_q_is_empty :: proc(t: ^testing.T) {

	q: Queue(int)
	testing.expect(t, q_is_empty(q))
}

@(test)
test_q_is_not_empty :: proc(t: ^testing.T) {

	q: Queue(int)
	defer q_destroy(&q)
	q_enqueue(&q, 1)
	testing.expect(t, !q_is_empty(q))
}

@(test)
test_q_pop_empty :: proc(t: ^testing.T) {

	q: Queue(int)
	_, ok := q_dequeue(&q)
	testing.expect(t, !ok)
}

//@(test)
test_q_pop_not_empty :: proc(t: ^testing.T) {

	q: Queue(int)
	defer q_destroy(&q)
	q_enqueue(&q, 1)
	q_enqueue(&q, 2)
	value, ok := q_dequeue(&q)
	testing.expect(t, ok)
	testing.expect_value(t, 1, value)
	value, ok = q_dequeue(&q)
	testing.expect(t, ok)
	testing.expect_value(t, 1, value)
	_, ok = q_dequeue(&q)
	testing.expect(t, !ok)
}

@(test)
test_q_destroy_with_element_destroy :: proc(t: ^testing.T) {

	free_int :: proc(n: ^int) {
		free(n)
	}

	q: Queue(^int)
	n1 := new_clone(1)
	q_enqueue(&q, n1)
	n2 := new_clone(2)
	q_enqueue(&q, n2)
	q_destroy(&q, free_int)
	testing.expect(t, q_is_empty(q))
}

