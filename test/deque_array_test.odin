package test

import alg ".."
import "core:testing"

@(test)
test_array_deque_is_empty :: proc(t: ^testing.T) {

	d: alg.Array_Deque(int)
	testing.expect_value(t, alg.array_deque_size(d), 0)
}

@(test)
test_array_deque_is_not_empty_push :: proc(t: ^testing.T) {

	d: alg.Array_Deque(int)
	defer alg.array_deque_destroy(&d)
	alg.array_deque_push(&d, 1)
	testing.expect_value(t, alg.array_deque_size(d), 1)
}

// @(test)
// test_array_deque_is_not_empty_enqueue :: proc(t: ^testing.T) {

// 	d: alg.Array_Deque(int)
// 	defer alg.array_deque_destroy(&d)
// 	alg.array_deque_enqueue(&d, 1)
// 	testing.expect_value(t, alg.array_deque_size(d), 1)
// }

@(test)
test_array_deque_pop_empty :: proc(t: ^testing.T) {

	d: alg.Array_Deque(int)
	_, success := alg.array_deque_pop(&d)
	testing.expect(t, !success)
}

@(test)
test_array_deque_dequeue_empty :: proc(t: ^testing.T) {

	d: alg.Array_Deque(int)
	_, success := alg.array_deque_dequeue(&d)
	testing.expect(t, !success)
}

@(test)
test_array_deque_pop_not_empty :: proc(t: ^testing.T) {

	d: alg.Array_Deque(int)
	defer alg.array_deque_destroy(&d)
	alg.array_deque_push(&d, 1)
	alg.array_deque_push(&d, 2)
	value, success := alg.array_deque_pop(&d)
	testing.expect(t, success)
	testing.expect_value(t, 2, value)
	value, success = alg.array_deque_pop(&d)
	testing.expect(t, success)
	testing.expect_value(t, 1, value)
	_, success = alg.array_deque_pop(&d)
	testing.expect(t, !success)
}

@(test)
test_array_deque_dequeue_not_empty :: proc(t: ^testing.T) {

	d: alg.Array_Deque(int)
	defer alg.array_deque_destroy(&d)
	alg.array_deque_enqueue(&d, 1)
	alg.array_deque_enqueue(&d, 2)
	value, success := alg.array_deque_dequeue(&d)
	testing.expect(t, success)
	testing.expect_value(t, 1, value)
	value, success = alg.array_deque_dequeue(&d)
	testing.expect(t, success)
	testing.expect_value(t, 2, value)
	_, success = alg.array_deque_dequeue(&d)
	testing.expect(t, !success)
}

@(test)
test_array_deque_destroy_with_managed_values :: proc(t: ^testing.T) {

	free_int :: proc(n: ^int) {
		free(n)
	}

	d: alg.Array_Deque(^int)
	n1 := new_clone(1)
	alg.array_deque_push(&d, n1)
	n2 := new_clone(2)
	alg.array_deque_push(&d, n2)
	alg.array_deque_destroy_with_managed_values(&d, free_int)
	testing.expect_value(t, alg.array_deque_size(d), 0)
}

