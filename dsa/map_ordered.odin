/*
This files implement a Ordered_Map using Binary Search to lookup keys.

References:
- Algorithms by Sedgewick and Wayne, Lecture 8

The Ordered_Map structure stores (key, value) pairs in an array sorted by keys.
The (key, value) pairs are sorted as they are inserted in the array so that keys can be looked up
with a simple and efficient binary search.
However, insertion in sorted order may require shifting part of the array which is inefficient.

This implementation doesn't support dynamically allocated keys, only dynamically allocated values.

If the type of the values is dynamically allocated and a value is returned
by a procedure, it is the responsibility of the caller to destroy it.

The search and insert have a worst case of O(lg(N)).
*/
package dsa

import "base:intrinsics"

// `OM_Pair` represents the (key, value) pair stored in the map.
OM_Pair :: struct($K: typeid, $V: typeid) {
	key:   K,
	value: V,
}

// `Ordered_Map` defines the type holding the set of (key, value) pairs.
Ordered_Map :: struct($K: typeid, $V: typeid) where intrinsics.type_is_ordered(K) {
	data: [dynamic]OM_Pair(K, V),
}

// `om_destroy_unmanaged` destroys a Map containing non-dynamically allocated elements.
om_destroy_unmanaged :: proc(m: ^Ordered_Map($K, $V)) {

	delete(m.data)
}

// `om_destroy_managed` destroys a Map containing dynamically allocated values.
om_destroy_managed :: proc(s: ^Ordered_Map($K, $V), destroy: proc(value: ^V)) {

	for pair in m.data {
		destroy(&pair.value)
	}
	delete(m.data)
}

om_destroy :: proc {
	om_destroy_unmanaged,
	om_destroy_managed,
}

// `om_rank` returns either the index of the (key, value) in the ordered array
// which is equal to the given key. If the key is not in the map, it returns the
// index of the first key greater than the specified key.
@(private = "file")
om_rank :: proc(m: Ordered_Map($K, $V), key: K) -> int {

	lo := 0
	hi := len(m.data) - 1
	for lo <= hi {
		mid := lo + (hi - lo) / 2
		current_key := m.data[mid].key
		if key < current_key {
			hi = mid - 1
		} else if key > current_key {
			lo = mid + 1
		} else {
			return mid
		}
	}
	return lo
}

// `om_shift_up` shifts all positions in the array up, starting at index 'start' included
// by one position up. This will increase the size of the array by one.
@(private = "file")
om_shift_up :: proc(m: ^Ordered_Map($K, $V), start: int) {

	// Add a dummy element to increase the size of the array first
	append(&m.data, OM_Pair(K, V){})
	// Shift the elements up, starting from the top to avoid overwriting existing values.
	for i := len(m.data) - 1; i > start; i -= 1 {
		m.data[i] = m.data[i - 1]
	}
}

// `om_shift_down` shifts all positions in the array down, all the way to the index 'start; included'.
// This will decrease the size of the array by one.
@(private = "file")
om_shift_down :: proc(m: ^Ordered_Map($K, $V), start: int) {

	// Shift the elements down, going up to avoid overwriting existing values.
	for i := start; i < len(m.data) - 1; i += 1 {
		m.data[i] = m.data[i + 1]
	}
	// Delete the last element
	pop(&m.data)
}

// `om_put` adds a (key, value) pair to the Ordered_Map. If the key already
// exists, it replaces the associated value.
// It returns the old value if it exists. If it doesn't, it set ok to false.
om_put :: proc(m: ^Ordered_Map($K, $V), key: K, value: V) -> (old_value: V, ok: bool) {

	count := len(m.data)
	// Array is empty, just store the (key, value) pair.
	if count == 0 {
		append(&m.data, OM_Pair(K, V){key, value})
		return
	}
	index := om_rank(m^, key)
	// max key in the array is less than key, append the (key, value) pair at the end.
	if index == count {
		append(&m.data, OM_Pair(K, V){key, value})
		return
	}
	// key was found in the map, replace the value
	if m.data[index].key == key {
		old_value = m.data[index].value
		m.data[index].value = value
		return old_value, true
	}
	// key was not found in the map, index points to the first pair with a key
	// greater than key, append at that position.
	om_shift_up(m, index)
	m.data[index].key = key
	m.data[index].value = value
	return
}

// `om_get` lookups an element from the Ordered_Map based on its key. The 'ok'
// return value is false if the key is not in the Ordered_Map.
om_get :: proc(m: Ordered_Map($K, $V), key: K) -> (value: V, ok: bool) {

	count := len(m.data)
	if count == 0 {return}
	index := om_rank(m, key)
	if index >= 0 && index < count && m.data[index].key == key {
		return m.data[index].value, true
	}
	return
}

// `om_delete` deletes an element from the Ordered_Map based on its key. If
// the element is found, its value is returned. If the element
// is not found, the ok return value is false.
om_delete :: proc(m: ^Ordered_Map($K, $V), key: K) -> (value: V, ok: bool) {

	count := len(m.data)
	if count == 0 {return}
	index := om_rank(m^, key)
	if index >= 0 && index < count && m.data[index].key == key {
		value = m.data[index].value
		om_shift_down(m, index)
		return value, true
	}
	return
}

// `om_contains` checks if the Ordered_Map contains an element with the given key.
om_contains :: proc(m: Ordered_Map($K, $V), key: K) -> bool {

	count := len(m.data)
	if count == 0 {return false}
	index := om_rank(m, key)
	if index >= 0 && index < count && m.data[index].key == key {
		return true
	}
	return false
}

// `om_is_empty` checks if the Ordered_Map is empty.
om_is_empty :: proc(m: Ordered_Map($K, $V)) -> bool {

	return len(m.data) == 0
}

// `om_size` returns the number of elements in the Ordered_Map.
om_size :: proc(m: Ordered_Map($K, $V)) -> int {

	return len(m.data)
}

// `om_keys` returns a slice containing all the keys in the Ordered_Map.
om_keys :: proc(m: Ordered_Map($K, $V)) -> []K {

	keys := make([]K, len(m.data))
	for i in 0 ..< len(m.data) {
		keys[i] = m.data[i].key
	}
	return keys[:]
}

// Tests
// -----

import "core:slice"
import "core:testing"

@(test)
test_om_is_empty :: proc(t: ^testing.T) {

	m: Ordered_Map(int, string)
	defer om_destroy(&m)

	testing.expect(t, om_is_empty(m))
}

@(test)
test_om_is_not_empty :: proc(t: ^testing.T) {

	m: Ordered_Map(int, string)
	defer om_destroy(&m)
	om_put(&m, 1, "one")

	testing.expect(t, !om_is_empty(m))
}

@(test)
test_om_size :: proc(t: ^testing.T) {

	m: Ordered_Map(int, string)
	defer om_destroy(&m)
	om_put(&m, 1, "one")
	om_put(&m, 2, "two")
	om_put(&m, 3, "three")
	om_put(&m, 2, "two_again")

	testing.expect_value(t, om_size(m), 3)
}

@(test)
test_om_get_when_empty :: proc(t: ^testing.T) {

	m: Ordered_Map(int, string)
	defer om_destroy(&m)

	_, ok := om_get(m, 1)
	testing.expect(t, !ok)
}

@(test)
test_om_contains :: proc(t: ^testing.T) {

	m: Ordered_Map(int, string)
	defer om_destroy(&m)
	om_put(&m, 1, "one")
	om_put(&m, 2, "two")
	om_put(&m, 3, "three")

	testing.expect(t, om_contains(m, 1))

	testing.expect(t, !om_contains(m, 0))
}

@(test)
test_om_get :: proc(t: ^testing.T) {

	m: Ordered_Map(int, string)
	defer om_destroy(&m)
	om_put(&m, 1, "one")
	om_put(&m, 2, "two")
	om_put(&m, 3, "three")

	value, ok := om_get(m, 1)
	testing.expect(t, ok)
	testing.expect_value(t, value, "one")

	value, ok = om_get(m, 3)
	testing.expect(t, ok)
	testing.expect_value(t, value, "three")

	value, ok = om_get(m, 0)
	testing.expect(t, !ok)
}

@(test)
test_om_delete :: proc(t: ^testing.T) {

	m: Ordered_Map(int, string)
	defer om_destroy(&m)
	om_put(&m, 1, "one")
	om_put(&m, 2, "two")
	om_put(&m, 3, "three")

	value, ok := om_delete(&m, 1)
	testing.expect(t, ok)
	testing.expect_value(t, value, "one")
	testing.expect(t, !om_contains(m, 1))
	testing.expect_value(t, om_size(m), 2)

	value, ok = om_delete(&m, 1)
	testing.expect(t, !ok)

	value, ok = om_delete(&m, 0)
	testing.expect(t, !ok)

	value, ok = om_delete(&m, 3)
	testing.expect(t, ok)
	testing.expect_value(t, value, "three")
	testing.expect(t, !om_contains(m, 3))
	testing.expect_value(t, om_size(m), 1)
}

@(test)
test_om_keys :: proc(t: ^testing.T) {

	m: Ordered_Map(int, string)
	defer om_destroy(&m)
	om_put(&m, 1, "one")
	om_put(&m, 2, "two")
	om_put(&m, 3, "three")

	keys := om_keys(m)
	defer delete(keys)
	slice.sort(keys)

	expected := []int{1, 2, 3}
	if !slice.equal(keys, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, keys)
	}
}

@(test)
test_om_duplicate_keys :: proc(t: ^testing.T) {

	m: Ordered_Map(int, string)
	defer om_destroy(&m)
	om_put(&m, 1, "one")
	om_put(&m, 2, "two")
	om_put(&m, 3, "three")
	om_put(&m, 1, "one_again")

	value, ok := om_get(m, 1)
	testing.expect(t, ok)
	testing.expect_value(t, value, "one_again")
}

@(test)
test_om_frequency :: proc(t: ^testing.T) {

	sentence := "SEARCHEXAMPLE"
	m: Ordered_Map(rune, int)
	defer om_destroy(&m)

	for letter, index in sentence {
		om_put(&m, letter, index)
	}

	value, ok := om_get(m, 'E')
	testing.expect(t, ok)
	testing.expect_value(t, value, 12)

	value, ok = om_get(m, 'H')
	testing.expect(t, ok)
	testing.expect_value(t, value, 5)

	value, ok = om_get(m, 'S')
	testing.expect(t, ok)
	testing.expect_value(t, value, 0)

	// There are 3 'E' so the size is len(sentence)-2.
	testing.expect_value(t, om_size(m), 10)
}

