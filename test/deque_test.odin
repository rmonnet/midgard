package test

import alg ".."
import "core:testing"

@(test)
test_deque_is_empty :: proc(t: ^testing.T) {

	d: alg.Deque(int)
	testing.expect_value(t, alg.deque_size(d), 0)
}

@(test)
test_deque_is_not_empty_push :: proc(t: ^testing.T) {

	d: alg.Deque(int)
	defer alg.deque_destroy(&d)
	alg.deque_push(&d, 1)
	testing.expect_value(t, alg.deque_size(d), 1)
}

@(test)
test_deque_is_not_empty_enqueue :: proc(t: ^testing.T) {

	d: alg.Deque(int)
	defer alg.deque_destroy(&d)
	alg.deque_enqueue(&d, 1)
	testing.expect_value(t, alg.deque_size(d), 1)
}

@(test)
test_deque_pop_empty :: proc(t: ^testing.T) {

	d: alg.Deque(int)
	_, success := alg.deque_pop(&d)
	testing.expect(t, !success)
}

@(test)
test_deque_dequeue_empty :: proc(t: ^testing.T) {

	d: alg.Deque(int)
	_, success := alg.deque_dequeue(&d)
	testing.expect(t, !success)
}

@(test)
test_deque_pop_not_empty :: proc(t: ^testing.T) {

	d: alg.Deque(int)
	defer alg.deque_destroy(&d)
	alg.deque_push(&d, 1)
	alg.deque_push(&d, 2)
	value, success := alg.deque_pop(&d)
	testing.expect(t, success)
	testing.expect_value(t, 2, value)
	value, success = alg.deque_pop(&d)
	testing.expect(t, success)
	testing.expect_value(t, 1, value)
	_, success = alg.deque_pop(&d)
	testing.expect(t, !success)
}

@(test)
test_deque_dequeue_not_empty :: proc(t: ^testing.T) {

	d: alg.Deque(int)
	defer alg.deque_destroy(&d)
	alg.deque_enqueue(&d, 1)
	alg.deque_enqueue(&d, 2)
	value, success := alg.deque_dequeue(&d)
	testing.expect(t, success)
	testing.expect_value(t, 1, value)
	value, success = alg.deque_dequeue(&d)
	testing.expect(t, success)
	testing.expect_value(t, 2, value)
	_, success = alg.deque_dequeue(&d)
	testing.expect(t, !success)
}

@(test)
test_deque_destroy_with_managed_values :: proc(t: ^testing.T) {

	free_int :: proc(n: ^int) {
		free(n)
	}

	d: alg.Deque(^int)
	n1 := new_clone(1)
	alg.deque_push(&d, n1)
	n2 := new_clone(2)
	alg.deque_push(&d, n2)
	alg.deque_destroy_with_managed_values(&d, free_int)
	testing.expect_value(t, alg.deque_size(d), 0)
}

