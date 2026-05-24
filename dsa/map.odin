/*
This files implement a Map, also called a dictionary.

References:
- Algorithms by Sedgewick and Wayne, Lecture 8

The Map structure stores (key, value) pairs where the keys are considered immutable.
This implementation stores all the values as a linked list.

It doesn't support dynamically allocated keys, only dynamically allocated values.
If the type of the values is dynamically allocated and a value is returned
by a procedure, it is the responsibility of the caller to destroy it.

The search and insert have a worst case of O(N).
*/
package dsa

import "base:intrinsics"

// `Map_Node` defines the node used in the Map.
// They store the (key, value) pair and a link to the next node.
Map_Node :: struct($K: typeid, $V: typeid) {
	key:   K,
	value: V,
	next:  ^Map_Node(K, V),
}
// Map defines the type holding the set of (key, value) pairs.
Map :: struct($K: typeid, $V: typeid) where intrinsics.type_is_comparable(K) {
	head: ^Map_Node(K, V),
}

// `map_destroy_unmanaged` destroys a Map containing non-dynamically allocated elements.
lm_destroy_unmanaged :: proc(m: ^Map($K, $V)) {

	for node := m.head; node != nil; {
		// We could technically free the node and grab the next
		// field without a temporary variable since there is no
		// allocation between the free and the free'd data lookup, but ...
		next_node := node.next
		free(node)
		node = next_node
	}
}

// Destroys a Map containing dynamically allocated values.
lm_destroy_managed :: proc(s: ^Map($K, $V), destroy: proc(value: ^V)) {

	for node := m.head; node != nil; {
		// We could technically free the node and grab the next
		// field without a temporary variable since there is no
		// allocation between the free and the free'd data lookup, but ...
		next_node := node.next
		destroy(&node.element.second)
		free(node)
		node = next_node
	}
}

lm_destroy :: proc {
	lm_destroy_unmanaged,
	lm_destroy_managed,
}

// Add a (key, value) pair to the map. If the key already
// exists, replace the associated value. It returns the old
// value if it exists. If it doesn't, it set ok to false.
lm_put :: proc(m: ^Map($K, $V), key: K, value: V) -> (old_value: V, ok: bool) {

	for node := m.head; node != nil; node = node.next {
		if node.key == key {
			old_value = node.value
			node.value = value
			return old_value, true
		}
	}
	new_node := new(Map_Node(K, V))
	new_node.key = key
	new_node.value = value
	new_node.next = m.head
	m.head = new_node
	return
}

// Lookup an element from the map based on its key. The 'ok'
// return value is false if the key is not in the map.
lm_get :: proc(m: Map($K, $V), key: K) -> (value: V, ok: bool) {

	for node := m.head; node != nil; node = node.next {
		if node.key == key {
			return node.value, true
		}
	}
	return
}

// Delete an element from the map based on its key. If
// the element is found, its value is returned. If the element
// is not found, the ok return value is false.
lm_delete :: proc(m: ^Map($K, $V), key: K) -> (value: V, ok: bool) {

	prev_node: ^Map_Node(K, V)
	for node := m.head; node != nil; node = node.next {
		if node.key == key {
			value = node.value
			if prev_node == nil {
				m.head = node.next
			} else {
				prev_node.next = node.next
			}
			free(node)
			return value, true
		}
		prev_node = node
	}
	return
}

// Checks if the Map contains an element with the given key.
lm_contains :: proc(m: Map($K, $V), key: K) -> bool {

	for node := m.head; node != nil; node = node.next {
		if node.key == key {return true}
	}
	return false
}

// Checks if the map is empty.
lm_is_empty :: proc(m: Map($K, $V)) -> bool {

	return m.head == nil
}

// Return the number of elements in the map.
lm_size :: proc(m: Map($K, $V)) -> int {

	count := 0
	for node := m.head; node != nil; node = node.next {
		count += 1
	}
	return count
}

// Return a slice containing all the keys in the map.
lm_keys :: proc(m: Map($K, $V)) -> []K {

	keys := make([dynamic]K)
	for node := m.head; node != nil; node = node.next {
		append(&keys, node.key)
	}
	return keys[:]
}

// -------------------------------
// Tests
// -------------------------------

import "core:slice"
import "core:testing"

@(test)
test_lm_is_empty :: proc(t: ^testing.T) {

	m: Map(int, string)
	defer lm_destroy(&m)

	testing.expect(t, lm_is_empty(m))
}

@(test)
test_lm_is_not_empty :: proc(t: ^testing.T) {

	m: Map(int, string)
	defer lm_destroy(&m)
	lm_put(&m, 1, "one")

	testing.expect(t, !lm_is_empty(m))
}

@(test)
test_lm_size :: proc(t: ^testing.T) {

	m: Map(int, string)
	defer lm_destroy(&m)
	lm_put(&m, 1, "one")
	lm_put(&m, 2, "two")
	lm_put(&m, 3, "three")
	lm_put(&m, 2, "two_again")

	testing.expect_value(t, lm_size(m), 3)
}

@(test)
test_lm_get_when_empty :: proc(t: ^testing.T) {

	m: Map(int, string)
	defer lm_destroy(&m)

	_, ok := lm_get(m, 1)
	testing.expect(t, !ok)
}

@(test)
test_lm_contains :: proc(t: ^testing.T) {

	m: Map(int, string)
	defer lm_destroy(&m)
	lm_put(&m, 1, "one")
	lm_put(&m, 2, "two")
	lm_put(&m, 3, "three")

	testing.expect(t, lm_contains(m, 1))

	testing.expect(t, !lm_contains(m, 0))
}

@(test)
test_lm_get :: proc(t: ^testing.T) {

	m: Map(int, string)
	defer lm_destroy(&m)
	lm_put(&m, 1, "one")
	lm_put(&m, 2, "two")
	lm_put(&m, 3, "three")

	value, ok := lm_get(m, 1)
	testing.expect(t, ok)
	testing.expect_value(t, value, "one")

	value, ok = lm_get(m, 3)
	testing.expect(t, ok)
	testing.expect_value(t, value, "three")

	value, ok = lm_get(m, 0)
	testing.expect(t, !ok)
}

@(test)
test_lm_delete :: proc(t: ^testing.T) {

	m: Map(int, string)
	defer lm_destroy(&m)
	lm_put(&m, 1, "one")
	lm_put(&m, 2, "two")
	lm_put(&m, 3, "three")

	value, ok := lm_delete(&m, 1)
	testing.expect(t, ok)
	testing.expect_value(t, value, "one")
	testing.expect(t, !lm_contains(m, 1))
	testing.expect_value(t, lm_size(m), 2)

	value, ok = lm_delete(&m, 1)
	testing.expect(t, !ok)

	value, ok = lm_delete(&m, 0)
	testing.expect(t, !ok)

	value, ok = lm_delete(&m, 3)
	testing.expect(t, ok)
	testing.expect_value(t, value, "three")
	testing.expect(t, !lm_contains(m, 3))
	testing.expect_value(t, lm_size(m), 1)
}

@(test)
test_lm_keys :: proc(t: ^testing.T) {

	m: Map(int, string)
	defer lm_destroy(&m)
	lm_put(&m, 1, "one")
	lm_put(&m, 2, "two")
	lm_put(&m, 3, "three")

	keys := lm_keys(m)
	defer delete(keys)
	slice.sort(keys)

	expected := []int{1, 2, 3}
	if !slice.equal(keys, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, keys)
	}
}

@(test)
test_lm_duplicate_keys :: proc(t: ^testing.T) {

	m: Map(int, string)
	defer lm_destroy(&m)
	lm_put(&m, 1, "one")
	lm_put(&m, 2, "two")
	lm_put(&m, 3, "three")
	lm_put(&m, 1, "one_again")

	value, ok := lm_get(m, 1)
	testing.expect(t, ok)
	testing.expect_value(t, value, "one_again")
}

@(test)
test_lm_frequency :: proc(t: ^testing.T) {

	sentence := "SEARCHEXAMPLE"
	m: Map(rune, int)
	defer lm_destroy(&m)

	for letter, index in sentence {
		lm_put(&m, letter, index)
	}

	value, ok := lm_get(m, 'E')
	testing.expect(t, ok)
	testing.expect_value(t, value, 12)

	value, ok = lm_get(m, 'H')
	testing.expect(t, ok)
	testing.expect_value(t, value, 5)

	value, ok = lm_get(m, 'S')
	testing.expect(t, ok)
	testing.expect_value(t, value, 0)

	// There are 3 'E' so the size is len(sentence)-2.
	testing.expect_value(t, lm_size(m), 10)
}

