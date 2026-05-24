/*
This file implements a classic Deque data structure using a linked list.

References:
- Algorithms by Sedgewick and Wayne, Lecture 3.
- [Geek for Geek - Deque Data Structure](https://www.geeksforgeeks.org/dsa/deque-set-1-introduction-applications)

The Deque combines a Stack (Last In - First Out) and a Queue (Fist In - First Out).
The Stack semantic is `push` to add an element and `pop` to remove an element.
The Queue semantic is `enqueue` to add an element and `dequeue` to remove an element.

We will use a linked-list to represent the Deque.
The advantage of the linked-list is that it can naturally grow and shrink when we add and remove elements.
We will add elements at the front of the list, this will push the previous element further toward the back of the list with the first element at the back.
- `push` and `enqueue` both add an element to the front of the list.
- `pop` removes the element at the front of the list (LIFO)
- `dequeue` removes the element at the back of the list (FIFO)

Because, when removing the back element of the list, we need to rebuild the `next` pointer on the next-to-last element, we need a double linked-list.
*/
package dsa

// `Deque_Node` represents a node of the single Linked List.
Deque_Node :: struct($T: typeid) {
	element:  T,
	previous: ^Deque_Node(T),
	next:     ^Deque_Node(T),
}

// `Deque` defines a Stack/Queue data structure.
// In Odin, it is initialized by default, no need for a constructor.
Deque :: struct($T: typeid) {
	first: ^Deque_Node(T),
	last:  ^Deque_Node(T),
	count: int,
}

// `dq_destroy_unmanaged` destroys a Deque of elements which don't use dynamic allocation.
// Because there is no constructor, the Deque could be reused after a call to `destroy`.
dq_destroy_unmanaged :: proc(d: ^Deque($T)) {

	for node := d.first; node != nil; node = node.next {
		free(node)
	}
	// Avoid problems if the Deque is reused after it is destroyed.
	d.first = nil
	d.last = nil
	d.count = 0
}

// `dq_destroy_managed` destroys a Deque of elements which use dynamic allocation.
// The caller must pass the procedure `destroy_element` to deallocate
// the individual elements.
// Because there is no constructor, the Deque could be reused after a call to `destroy`.
dq_destroy_managed :: proc(d: ^Deque($T), destroy_element: proc(element: T)) {

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
	dq_destroy_unmanaged,
	dq_destroy_managed,
}

// `dq_pop` retrieves an element from the Deque (LIFO).
// The success return value indicates if the retrieval succeeded.
// The value to retrieve is at the front of the list.
dq_pop :: proc(d: ^Deque($T)) -> (element: T, success: bool) {

	if d.first == nil {return}
	old_first := d.first
	defer free(old_first)
	d.first = old_first.next
	if d.first == nil {
		d.last = nil
	} else {
		d.first.previous = nil
	}
	d.count -= 1
	return old_first.element, true
}

// `dq_dequeue` retrieves an element from the Deque (LIFO).
// The success return value indicates if the retrieval succeeded.
// The value to retrieve is at the back of the list.
dq_dequeue :: proc(d: ^Deque($T)) -> (element: T, success: bool) {

	if d.last == nil {return}
	old_last := d.last
	defer free(old_last)
	d.last = old_last.previous
	if d.last == nil {
		d.first = nil
	} else {
		d.last.next = nil
	}
	d.count -= 1
	return old_last.element, true
}

// `dq_push` add an element to the Deque.
// The value is inserted at the front of the list.
dq_push :: proc(d: ^Deque($T), value: T) {

	new_first := new_clone(Deque_Node(T){element = value, next = d.first})
	if d.first != nil {
		d.first.previous = new_first
	}
	d.first = new_first
	if d.last == nil {
		d.last = new_first
	}
	d.count += 1
}

// `dq_enqueue` add an element to the Deque.
// The value is inserted at the front of the list.
dq_enqueue :: dq_push

// `dq_size` returns the number of elements in the Deque.
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
	element, success := dq_pop(&d)
	testing.expect(t, success)
	testing.expect_value(t, 2, element)
	element, success = dq_pop(&d)
	testing.expect(t, success)
	testing.expect_value(t, 1, element)
	_, success = dq_pop(&d)
	testing.expect(t, !success)
}

@(test)
test_dq_dequeue_not_empty :: proc(t: ^testing.T) {

	d: Deque(int)
	defer dq_destroy(&d)
	dq_enqueue(&d, 1)
	dq_enqueue(&d, 2)
	element, success := dq_dequeue(&d)
	testing.expect(t, success)
	testing.expect_value(t, 1, element)
	element, success = dq_dequeue(&d)
	testing.expect(t, success)
	testing.expect_value(t, 2, element)
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

