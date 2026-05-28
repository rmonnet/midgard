/*
This file implements a classic Deque data structure using a growable array.

Reference:
- Algorithms by Sedgewick and Wayne, Lecture 3.

The deque combines a Stack (Last In - First Out) and a Queue (First In - First Out).
The Stack semantic is `push` to add an element and `pop` to remove an element.
The Queue semantic is `enqueue` to add an element and `dequeue` to remove an element.

We will add elements at the front of the list, this will push the previous element further toward the back of the list with the first element at the back.
- `push` and `enqueue` both add an element to the end of the array.
- `pop` removes the element at the end of the array (LIFO)
- `dequeue` removes the element at the beginning of the array (FIFO)

If we were to just implement a Stack, elements are added and removed from the end of the array and the array will just gorw and shrink as needed.
But, because we also support a Queue, when elements are removed form the beginning, the array must be treated as a circular buffer.
There are cases where the populated portion of the array wraps from the end to the beginning.
*/
package dsa

// ADQ_MIN_SIZE is the minimum size for the array backing the Deque.
ADQ_MIN_SIZE :: 8

// `Array_Deque` defines a Stack/Queue data structure.
// It is initialized by default, no need for a constructor.
Array_Deque :: struct($T: typeid) {
	elements:    []T,
	// `first_index` index represents the first element inserted in
	// the queue. The first index increases as elements are dequeued.
	first_index: int,
	// `next_index` represents the next available spot in the deque.
	// The most recently inserted element is at next_index-1.
	// The next_index increases as elements are pushed and enqueued,
	// it decreases as elements are popped.
	next_index:  int,
	// `count` represents the number of elements currently in the queue.
	// It could be computed from `first_index` and `last_index` but it is
	// simpler to keep track of the count in the case where the array wraps.
	count:       int,
}

// `adq_destroy_managed` destroys a Deque containing dynamically managed elements.
// Because there is no constructor, the Deque could be reused after a call to `destroy`.
adq_destroy_managed :: proc(d: ^Array_Deque($T), destroy: proc(value: T)) {

	// We need to account for cases where the array wraps.
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
	// Avoid problems if the Deque is reused after it is destroyed.
	d.first_index = 0
	d.next_index = 0
	d.count = 0
}

// `adq_destroy_unmanaged` destroys a Deque of non managed elements.
// Because there is no constructor, the Deque could be reused after a call to `destroy`.
adq_destroy_unmanaged :: proc(d: ^Array_Deque($T)) {

	delete(d.elements)
	// Avoid problems if the Deque is reused after it is destroyed.
	d.first_index = 0
	d.next_index = 0
	d.count = 0
}

// Destroy a Deque.
adq_destroy :: proc {
	adq_destroy_managed,
	adq_destroy_unmanaged,
}

// `adq_resize` resizes the Deque by shrinking/growing the backing array.
// It takes cares of cases when the circular buffer wraps from the back to the front.
// It also reset the indexes in the new copy of the backing array so `first_index` starts at 0.
@(private = "file")
adq_resize :: proc(d: ^Array_Deque($T), new_size: int) {

	// In the cases where the
	old_elements := d.elements
	d.elements = make([]T, new_size)
	if len(old_elements) > 0 {
		// We need to account for cases where the array wraps.
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

// `dq_pop` retrieves an element from the Deque (LIFO).
// The success return value indicates if the retrieval succeeded.
// The element to retrieve is at the end of the array.
adq_pop :: proc(d: ^Array_Deque($T)) -> (value: T, success: bool) {

	if d.count == 0 {return}
	d.next_index = (d.next_index - 1) %% len(d.elements)
	d.count -= 1
	value = d.elements[d.next_index]
	shrink_len := len(d.elements) / 4
	if shrink_len >= ADQ_MIN_SIZE && d.next_index < shrink_len {
		adq_resize(d, shrink_len)
	}
	return value, true
}

// `adq_dequeue` retrieves an element from the Deque (LIFO).
// The success return value indicates if the retrieval succeeded.
// The element to retrieve is at the beginning of the array.
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

// `adq_push` adds an element to the Deque.
// The element is inserted at the end of the array.
adq_push :: proc(d: ^Array_Deque($T), value: T) {

	if d.count >= len(d.elements) {
		adq_resize(d, max(len(d.elements) * 2, ADQ_MIN_SIZE))
	}
	d.elements[d.next_index] = value
	d.next_index = (d.next_index + 1) %% len(d.elements)
	d.count += 1
}

// `dq_enqueue` add an element to the Deque.
// The element is inserted at the end of the array.
adq_enqueue :: adq_push

// Return the size of the Deque
adq_size :: proc(d: Array_Deque($T)) -> int {

	return d.count
}

// Tests
// -----

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
	element, success := adq_pop(&d)
	testing.expect(t, success)
	testing.expect_value(t, 2, element)
	element, success = adq_pop(&d)
	testing.expect(t, success)
	testing.expect_value(t, 1, element)
	_, success = adq_pop(&d)
	testing.expect(t, !success)
}

@(test)
test_adq_dequeue_not_empty :: proc(t: ^testing.T) {

	d: Array_Deque(int)
	defer adq_destroy(&d)
	adq_enqueue(&d, 1)
	adq_enqueue(&d, 2)
	element, success := adq_dequeue(&d)
	testing.expect(t, success)
	testing.expect_value(t, 1, element)
	element, success = adq_dequeue(&d)
	testing.expect(t, success)
	testing.expect_value(t, 2, element)
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

// This set of tests is specific to the version of Deque backed by an array
// and make sure index wrapping performs correctly.

@(test)
test_adq_next_index_wraps_correctly_for_queue :: proc(t: ^testing.T) {

	// The Deque states are shown at the end of each operation

	// starting point: [1 2 3 4 5 6 7 _]  (count=8, len=7, first_index=0, next_index=8)
	d: Array_Deque(int)
	defer adq_destroy(&d)
	for i in 1 ..= 7 {adq_enqueue(&d, i)}
	testing.expect_value(t, adq_size(d), 7)
	testing.expect_value(t, d.first_index, 0)
	testing.expect_value(t, d.next_index, 7)

	// enqueue(8)    : [1 2 3 4 5 6 7 8]  (count=8, len=8, first_index=0, next_index=0)
	adq_enqueue(&d, 8)
	testing.expect_value(t, adq_size(d), 8)
	testing.expect_value(t, d.first_index, 0)
	testing.expect_value(t, d.next_index, 0)

	// dequeue()     : [_ 2 3 4 5 6 7 8]  (count=7, len=8, first_index=1, next_index=0)
	element, success := adq_dequeue(&d)
	testing.expect_value(t, element, 1)
	testing.expect(t, success)
	testing.expect_value(t, adq_size(d), 7)
	testing.expect_value(t, d.first_index, 1)
	testing.expect_value(t, d.next_index, 0)

	// enqueue(9)    : [9 2 3 4 5 6 7 8]  (count=8, len=8, first_index=1, next_index=1)
	adq_enqueue(&d, 9)
	testing.expect_value(t, adq_size(d), 8)
	testing.expect_value(t, d.first_index, 1)
	testing.expect_value(t, d.next_index, 1)
}

@(test)
test_adq_first_index_wraps_correctly_for_queue :: proc(t: ^testing.T) {

	// The Deque states are shown at the end of each operation.

	// starting point: [1 2 3 4 5 6 7 8]  (count=8, len=8, first_index=0, next_index=0)
	d: Array_Deque(int)
	defer adq_destroy(&d)
	for i in 1 ..= 8 {
		adq_enqueue(&d, i)
	}
	testing.expect_value(t, adq_size(d), 8)
	testing.expect_value(t, d.first_index, 0)
	testing.expect_value(t, d.next_index, 0)

	// dequeue()*7   : [_ _ _ _ _ _ _ 8]  (count=1, len=8, first_index=7, next_index=0)
	element: int
	success: bool
	for _ in 1 ..= 7 {element, success = adq_dequeue(&d)}
	testing.expect_value(t, element, 7)
	testing.expect(t, success)
	testing.expect_value(t, adq_size(d), 1)
	testing.expect_value(t, d.first_index, 7)
	testing.expect_value(t, d.next_index, 0)

	// dequeue()     : [_ _ _ _ _ _ _ _]  (count=0, len=8, first_index=0, next_index=0)
	element, success = adq_dequeue(&d)
	testing.expect_value(t, element, 8)
	testing.expect(t, success)
	testing.expect_value(t, adq_size(d), 0)
	testing.expect_value(t, d.first_index, 0)
	testing.expect_value(t, d.next_index, 0)

	// enqueue(9)    : [9 _ _ _ _ _ _ _]  (count=1, len=8, first_index=0, next_index=1)
	adq_enqueue(&d, 9)
	testing.expect_value(t, adq_size(d), 1)
	testing.expect_value(t, d.first_index, 0)
	testing.expect_value(t, d.next_index, 1)

	// dequeue()     : [_ _ _ _ _ _ _ _]  (count=0, len=8, first_index=1, next_index=1)
	element, success = adq_dequeue(&d)
	testing.expect_value(t, element, 9)
	testing.expect(t, success)
	testing.expect_value(t, adq_size(d), 0)
	testing.expect_value(t, d.first_index, 1)
	testing.expect_value(t, d.next_index, 1)
}

@(test)
test_adq_next_index_wraps_correctly_for_stack :: proc(t: ^testing.T) {

	// The Deque states are shown at the end of each operation.

	// starting point: [_ _ _ _ 5 6 7 8]  (count=4, len=8, first_index=4, next_index=0)
	d: Array_Deque(int)
	defer adq_destroy(&d)
	for i in 1 ..= 8 {
		adq_push(&d, i)
	}
	for _ in 1 ..= 4 {
		_, _ = adq_dequeue(&d)
	}
	testing.expect_value(t, adq_size(d), 4)
	testing.expect_value(t, d.first_index, 4)
	testing.expect_value(t, d.next_index, 0)

	// push(9),push(1)  : [9 1 _ _ 5 6 7 8]  (count=6, len=8, first_index=4, next_index=2)
	adq_push(&d, 9)
	adq_push(&d, 1)
	testing.expect_value(t, adq_size(d), 6)
	testing.expect_value(t, d.first_index, 4)
	testing.expect_value(t, d.next_index, 2)

	// pop()*5     : [_ _ _ _ 5 _ _ _]  (count=1, len=8, first_index=4, next_index=5)
	element, success := adq_pop(&d) // 1
	testing.expect_value(t, element, 1)
	testing.expect(t, success)
	testing.expect_value(t, adq_size(d), 5)
	testing.expect_value(t, d.next_index, 1)
	adq_pop(&d) // 9
	element, success = adq_pop(&d) //8
	testing.expect_value(t, element, 8)
	testing.expect(t, success)
	testing.expect_value(t, adq_size(d), 3)
	testing.expect_value(t, d.next_index, 7)
	adq_pop(&d) // 7
	element, success = adq_pop(&d) // 6
	testing.expect_value(t, element, 6)
	testing.expect(t, success)
	testing.expect_value(t, adq_size(d), 1)
	testing.expect_value(t, d.first_index, 4)
	testing.expect_value(t, d.next_index, 5)
}

