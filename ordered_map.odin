// This files implement a Ordered_Map using Binary Search to lookup keys.
// The Ordered_Map structure stores (key, value) pairs in an array sorted by keys.
// This implementation doesn't support dynamically allocated keys,
// only dynamically allocated values.
//
// If the type of the values is dynamically allocated and a value is returned
// by a procedure, it is the responsibility of the caller to destroy it.
//
// The search and insert have a worst case of O(lg(N)).
package midgard

import "base:intrinsics"
import "core:slice"
import "core:testing"

// Ordered_Map defines the type holding the set of (key, value) pairs.
Ordered_Map :: struct($K: typeid, $V: typeid) where intrinsics.type_is_ordered(K) {
	data: [dynamic]Pair(K, V),
}

// Destroys a Map containing non-dynamically allocated elements.
ordered_map_destroy_simple :: proc(m: ^Ordered_Map($K, $V)) {

	delete(m.data)
}

// Destroys a OMap containing dynamically allocated values.
ordered_map_destroy_with_value_destroy :: proc(s: ^Ordered_Map($K, $V), destroy: proc(value: ^V)) {

	for pair in m.data {
		destroy(&pair.second)
	}
	delete(m.data)
}

// Destroys a Ordered_Map.
ordered_map_destroy :: proc {
	ordered_map_destroy_simple,
	ordered_map_destroy_with_value_destroy,
}

// Returns either the index of the key in the ordered array or the index
// of the first value greater than the key.
@(private = "file")
ordered_map_rank :: proc(m: Ordered_Map($K, $V), key: K) -> int {

	lo := 0
	hi := len(m.data) - 1
	for lo <= hi {
		mid := lo + (hi - lo) / 2
		current_key := m.data[mid].first
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

// Shift all positions in the array up, starting at index 'start' included
// by one position up. This will increase the size of the array by one.
@(private = "file")
ordered_map_shift_up :: proc(m: ^Ordered_Map($K, $V), start: int) {

	// Add a dummy element to increase the size of the array first
	append(&m.data, Pair(K, V){})
	// Shift the elements up, starting from the top to avoid overwriting existing values.
	for i := len(m.data) - 1; i > start; i -= 1 {
		m.data[i] = m.data[i - 1]
	}
}

// Shift all positions in the array down, all the way to the index 'start; included'.
// This will decrease the size of the array by one.
@(private = "file")
ordered_map_shift_down :: proc(m: ^Ordered_Map($K, $V), start: int) {

	// Shift the elements down, going up to avoid overwriting existing values.
	for i := start; i < len(m.data) - 1; i += 1 {
		m.data[i] = m.data[i + 1]
	}
	// Delete the end element
	pop(&m.data)
}

// Add a (key, value) pair to the Ordered_Map. If the key already
// exists, replace the associated value. It returns the old
// value if it exists. If it doesn't, it set ok to false.
ordered_map_put :: proc(m: ^Ordered_Map($K, $V), key: K, value: V) -> (old_value: V, ok: bool) {

	count := len(m.data)
	// Array is empty, just store the (key, value) pair.
	if count == 0 {
		append(&m.data, Pair(K, V){key, value})
		return
	}
	index := ordered_map_rank(m^, key)
	// max key in the array is less than key, append the (key, value) pair at the end.
	if index == count {
		append(&m.data, Pair(K, V){key, value})
		return
	}
	// key was found in the map, replace the value
	if m.data[index].first == key {
		old_value = m.data[index].second
		m.data[index].second = value
		return old_value, true
	}
	// key was not found in the map, index points to the first pair with a key
	// greater than key, append at that position.
	ordered_map_shift_up(m, index)
	m.data[index].first = key
	m.data[index].second = value
	return
}

// Lookup an element from the Ordered_Map based on its key. The 'ok'
// return value is false if the key is not in the Ordered_Map.
ordered_map_get :: proc(m: Ordered_Map($K, $V), key: K) -> (value: V, ok: bool) {

	count := len(m.data)
	if count == 0 {return}
	index := ordered_map_rank(m, key)
	if index >= 0 && index < count && m.data[index].first == key {
		return m.data[index].second, true
	}
	return
}

// Delete an element from the Ordered_Map based on its key. If
// the element is found, its value is returned. If the element
// is not found, the ok return value is false.
ordered_map_delete :: proc(m: ^Ordered_Map($K, $V), key: K) -> (value: V, ok: bool) {

	count := len(m.data)
	if count == 0 {return}
	index := ordered_map_rank(m^, key)
	if index >= 0 && index < count && m.data[index].first == key {
		value = m.data[index].second
		ordered_map_shift_down(m, index)
		return value, true
	}
	return
}

// Checks if the Ordered_Map contains an element with the given key.
ordered_map_contains :: proc(m: Ordered_Map($K, $V), key: K) -> bool {

	count := len(m.data)
	if count == 0 {return false}
	index := ordered_map_rank(m, key)
	if index >= 0 && index < count && m.data[index].first == key {
		return true
	}
	return false
}

// Checks if the Ordered_Map is empty.
ordered_map_is_empty :: proc(m: Ordered_Map($K, $V)) -> bool {

	return len(m.data) == 0
}

// Return the number of elements in the Ordered_Map.
ordered_map_size :: proc(m: Ordered_Map($K, $V)) -> int {

	return len(m.data)
}

// Return a slice containing all the keys in the Ordered_Map.
ordered_map_keys :: proc(m: Ordered_Map($K, $V)) -> []K {

	keys := make([]K, len(m.data))
	for i in 0 ..< len(m.data) {
		keys[i] = m.data[i].first
	}
	return keys[:]
}

// -------------------------------
// Tests
// -------------------------------

@(test)
test_ordered_map_is_empty :: proc(t: ^testing.T) {

	m: Ordered_Map(int, string)
	defer ordered_map_destroy(&m)

	testing.expect(t, ordered_map_is_empty(m))
}

@(test)
test_ordered_map_is_not_empty :: proc(t: ^testing.T) {

	m: Ordered_Map(int, string)
	defer ordered_map_destroy(&m)
	ordered_map_put(&m, 1, "one")

	testing.expect(t, !ordered_map_is_empty(m))
}

@(test)
test_ordered_map_size :: proc(t: ^testing.T) {

	m: Ordered_Map(int, string)
	defer ordered_map_destroy(&m)
	ordered_map_put(&m, 1, "one")
	ordered_map_put(&m, 2, "two")
	ordered_map_put(&m, 3, "three")
	ordered_map_put(&m, 2, "two_again")

	testing.expect_value(t, ordered_map_size(m), 3)
}

@(test)
test_ordered_map_get_when_empty :: proc(t: ^testing.T) {

	m: Ordered_Map(int, string)
	defer ordered_map_destroy(&m)

	_, ok := ordered_map_get(m, 1)
	testing.expect(t, !ok)
}

@(test)
test_ordered_map_contains :: proc(t: ^testing.T) {

	m: Ordered_Map(int, string)
	defer ordered_map_destroy(&m)
	ordered_map_put(&m, 1, "one")
	ordered_map_put(&m, 2, "two")
	ordered_map_put(&m, 3, "three")

	testing.expect(t, ordered_map_contains(m, 1))

	testing.expect(t, !ordered_map_contains(m, 0))
}

@(test)
test_ordered_map_get :: proc(t: ^testing.T) {

	m: Ordered_Map(int, string)
	defer ordered_map_destroy(&m)
	ordered_map_put(&m, 1, "one")
	ordered_map_put(&m, 2, "two")
	ordered_map_put(&m, 3, "three")

	value, ok := ordered_map_get(m, 1)
	testing.expect(t, ok)
	testing.expect_value(t, value, "one")

	value, ok = ordered_map_get(m, 3)
	testing.expect(t, ok)
	testing.expect_value(t, value, "three")

	value, ok = ordered_map_get(m, 0)
	testing.expect(t, !ok)
}

@(test)
test_ordered_map_delete :: proc(t: ^testing.T) {

	m: Ordered_Map(int, string)
	defer ordered_map_destroy(&m)
	ordered_map_put(&m, 1, "one")
	ordered_map_put(&m, 2, "two")
	ordered_map_put(&m, 3, "three")

	value, ok := ordered_map_delete(&m, 1)
	testing.expect(t, ok)
	testing.expect_value(t, value, "one")
	testing.expect(t, !ordered_map_contains(m, 1))
	testing.expect_value(t, ordered_map_size(m), 2)

	value, ok = ordered_map_delete(&m, 1)
	testing.expect(t, !ok)

	value, ok = ordered_map_delete(&m, 0)
	testing.expect(t, !ok)

	value, ok = ordered_map_delete(&m, 3)
	testing.expect(t, ok)
	testing.expect_value(t, value, "three")
	testing.expect(t, !ordered_map_contains(m, 3))
	testing.expect_value(t, ordered_map_size(m), 1)
}

@(test)
test_ordered_map_keys :: proc(t: ^testing.T) {

	m: Ordered_Map(int, string)
	defer ordered_map_destroy(&m)
	ordered_map_put(&m, 1, "one")
	ordered_map_put(&m, 2, "two")
	ordered_map_put(&m, 3, "three")

	keys := ordered_map_keys(m)
	defer delete(keys)
	slice.sort(keys)

	expect_slices(t, keys, []int{1, 2, 3})
}

@(test)
test_ordered_map_duplicate_keys :: proc(t: ^testing.T) {

	m: Ordered_Map(int, string)
	defer ordered_map_destroy(&m)
	ordered_map_put(&m, 1, "one")
	ordered_map_put(&m, 2, "two")
	ordered_map_put(&m, 3, "three")
	ordered_map_put(&m, 1, "one_again")

	value, ok := ordered_map_get(m, 1)
	testing.expect(t, ok)
	testing.expect_value(t, value, "one_again")
}

@(test)
test_ordered_map_frequency :: proc(t: ^testing.T) {

	sentence := "SEARCHEXAMPLE"
	m: Ordered_Map(rune, int)
	defer ordered_map_destroy(&m)

	for letter, index in sentence {
		ordered_map_put(&m, letter, index)
	}

	value, ok := ordered_map_get(m, 'E')
	testing.expect(t, ok)
	testing.expect_value(t, value, 12)

	value, ok = ordered_map_get(m, 'H')
	testing.expect(t, ok)
	testing.expect_value(t, value, 5)

	value, ok = ordered_map_get(m, 'S')
	testing.expect(t, ok)
	testing.expect_value(t, value, 0)

	// There are 3 'E' so the size is len(sentence)-2.
	testing.expect_value(t, ordered_map_size(m), 10)
}

