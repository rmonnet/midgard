// This file implements a classic Deque data structure using a linked list.
// The deque combines a stack (First In - Last Out) and a Queue (First In - First Out).
//
// Reference: Algorithms by Sedgewick and Wayne, Lecture 3.
package midgard

// The Linked_List_Node represents a node of a single Linked List.
Deque_Node :: struct($T: typeid) {
	value: T,
	next:  ^Deque_Node(T),
}

// The Deque defines a Stack/Queue data structure.
// It is initialized by default.
Deque :: struct($T: typeid) {
	first: ^Deque_Node(T),
	last:  ^Deque_Node(T),
	count: int,
}

// Destroy a Deque containing elements that are dynamically managed.
deque_destroy_with_managed_values :: proc(d: ^Deque($T), destroy: proc(value: T)) {

	for node := d.first; node != nil; node = node.next {
		destroy(node.value)
		free(node)
	}
	// Avoid problems if the Deque is reused after it is destroyed.
	d.first = nil
	d.last = nil
	d.count = 0
}

// Destroy a Deque of elements which don't use dynamic allocation.
deque_destroy_simple :: proc(d: ^Deque($T)) {

	for node := d.first; node != nil; node = node.next {
		free(node)
	}
	// Avoid problems if the Deque is reused after it is destroyed.
	d.first = nil
	d.last = nil
	d.count = 0
}

// Destroy a Deque.
deque_destroy :: proc {
	deque_destroy_simple,
	deque_destroy_with_managed_values,
}

// Pop a value from the deque, the success return value
// is set to false if there is no element to pop.
deque_pop :: proc(d: ^Deque($T)) -> (value: T, success: bool) {

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
	return first.value, true
}

// Remove a value from the Deque, the ok return value
// is set to false if there is no element to remove.
//
// Since we pop and dequeue from the front of the Deque,
// the two procedures are synonymous.
deque_dequeue :: deque_pop

/*
deque_dequeue :: proc(d: ^Deque($T)) -> (value: T, success: bool) {

	// For the Queue behavior, the values are queued onto the back
	//  and dequeued from the front.
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
	return first.value, true
}
*/

// Push a value on the Deque.
deque_push :: proc(d: ^Deque($T), value: T) {

	// For the Stack behavior, the values are pushed on the front
	//  and popped from the front.
	new_first := new_clone(Deque_Node(T){value = value, next = d.first})
	d.first = new_first
	// The only case we need to update the last pointer is
	// when we add the first element to the queue.
	if d.last == nil {
		d.last = new_first
	}
	d.count += 1
}


// Add an element on the queue.
deque_enqueue :: proc(d: ^Deque($T), value: T) {

	// For the Queue behavior, the values are queued onto the back
	//  and dequeued from the front.
	new_last := new_clone(Deque_Node(T){value = value, next = nil})
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
deque_size :: proc(d: Deque($T)) -> int {

	return d.count
}

