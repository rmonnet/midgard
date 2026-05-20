// This files implement a Map. The Map structure stores (key, value) pairs
// where the keys are considered immutable. This implementation stores
// all the values as a linked list. It doesn't support
// dynamically allocated keys, only dynamically allocated values.
//
// If the type of the values is dynamically allocated and a value is returned
// by a procedure, it is the responsibility of the caller to destroy it.
//
// The search and insert have a worst case of O(N).
package midgard

import "base:intrinsics"
import "core:slice"
import "core:testing"

// Map defines the type holding the set of (key, value) pairs.
Map :: struct($K: typeid, $V: typeid) where intrinsics.type_is_comparable(K) {
	head: ^Linked_List_Node(Pair(K, V)),
}

// Destroys a Map containing non-dynamically allocated elements.
map_destroy_simple :: proc(m: ^Map($K, $V)) {


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
map_destroy_with_value_destroy :: proc(s: ^Map($K, $V), destroy: proc(value: ^V)) {

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

// Destroys a Map.
map_destroy :: proc {
	map_destroy_simple,
	map_destroy_with_value_destroy,
}

// Add a (key, value) pair to the map. If the key already
// exists, replace the associated value. It returns the old
// value if it exists. If it doesn't, it set ok to false.
map_put :: proc(m: ^Map($K, $V), key: K, value: V) -> (old_value: V, ok: bool) {

	for node := m.head; node != nil; node = node.next {
		if node.element.first == key {
			old_value = node.element.second
			node.element.second = value
			return old_value, true
		}
	}
	new_node := new(Linked_List_Node(Pair(K, V)))
	new_node.element = {
		first  = key,
		second = value,
	}
	new_node.next = m.head
	m.head = new_node
	return
}

// Lookup an element from the map based on its key. The 'ok'
// return value is false if the key is not in the map.
map_get :: proc(m: Map($K, $V), key: K) -> (value: V, ok: bool) {

	for node := m.head; node != nil; node = node.next {
		if node.element.first == key {
			return node.element.second, true
		}
	}
	return
}

// Delete an element from the map based on its key. If
// the element is found, its value is returned. If the element
// is not found, the ok return value is false.
map_delete :: proc(m: ^Map($K, $V), key: K) -> (value: V, ok: bool) {

	prev_node: ^Linked_List_Node(Pair(K, V))
	for node := m.head; node != nil; node = node.next {
		if node.element.first == key {
			value = node.element.second
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
map_contains :: proc(m: Map($K, $V), key: K) -> bool {

	for node := m.head; node != nil; node = node.next {
		if node.element.first == key {return true}
	}
	return false
}

// Checks if the map is empty.
map_is_empty :: proc(m: Map($K, $V)) -> bool {

	return m.head == nil
}

// Return the number of elements in the map.
map_size :: proc(m: Map($K, $V)) -> int {

	count := 0
	for node := m.head; node != nil; node = node.next {
		count += 1
	}
	return count
}

// Return a slice containing all the keys in the map.
map_keys :: proc(m: Map($K, $V)) -> []K {

	keys := make([dynamic]K)
	for node := m.head; node != nil; node = node.next {
		append(&keys, node.element.first)
	}
	return keys[:]
}

// -------------------------------
// Tests
// -------------------------------

@(test)
test_map_is_empty :: proc(t: ^testing.T) {

	m: Map(int, string)
	defer map_destroy(&m)

	testing.expect(t, map_is_empty(m))
}

@(test)
test_map_is_not_empty :: proc(t: ^testing.T) {

	m: Map(int, string)
	defer map_destroy(&m)
	map_put(&m, 1, "one")

	testing.expect(t, !map_is_empty(m))
}

@(test)
test_map_size :: proc(t: ^testing.T) {

	m: Map(int, string)
	defer map_destroy(&m)
	map_put(&m, 1, "one")
	map_put(&m, 2, "two")
	map_put(&m, 3, "three")
	map_put(&m, 2, "two_again")

	testing.expect_value(t, map_size(m), 3)
}

@(test)
test_map_get_when_empty :: proc(t: ^testing.T) {

	m: Map(int, string)
	defer map_destroy(&m)

	_, ok := map_get(m, 1)
	testing.expect(t, !ok)
}

@(test)
test_map_contains :: proc(t: ^testing.T) {

	m: Map(int, string)
	defer map_destroy(&m)
	map_put(&m, 1, "one")
	map_put(&m, 2, "two")
	map_put(&m, 3, "three")

	testing.expect(t, map_contains(m, 1))

	testing.expect(t, !map_contains(m, 0))
}

@(test)
test_map_get :: proc(t: ^testing.T) {

	m: Map(int, string)
	defer map_destroy(&m)
	map_put(&m, 1, "one")
	map_put(&m, 2, "two")
	map_put(&m, 3, "three")

	value, ok := map_get(m, 1)
	testing.expect(t, ok)
	testing.expect_value(t, value, "one")

	value, ok = map_get(m, 3)
	testing.expect(t, ok)
	testing.expect_value(t, value, "three")

	value, ok = map_get(m, 0)
	testing.expect(t, !ok)
}

@(test)
test_map_delete :: proc(t: ^testing.T) {

	m: Map(int, string)
	defer map_destroy(&m)
	map_put(&m, 1, "one")
	map_put(&m, 2, "two")
	map_put(&m, 3, "three")

	value, ok := map_delete(&m, 1)
	testing.expect(t, ok)
	testing.expect_value(t, value, "one")
	testing.expect(t, !map_contains(m, 1))
	testing.expect_value(t, map_size(m), 2)

	value, ok = map_delete(&m, 1)
	testing.expect(t, !ok)

	value, ok = map_delete(&m, 0)
	testing.expect(t, !ok)

	value, ok = map_delete(&m, 3)
	testing.expect(t, ok)
	testing.expect_value(t, value, "three")
	testing.expect(t, !map_contains(m, 3))
	testing.expect_value(t, map_size(m), 1)
}

@(test)
test_map_keys :: proc(t: ^testing.T) {

	m: Map(int, string)
	defer map_destroy(&m)
	map_put(&m, 1, "one")
	map_put(&m, 2, "two")
	map_put(&m, 3, "three")

	keys := map_keys(m)
	defer delete(keys)
	slice.sort(keys)

	expect_slices(t, keys, []int{1, 2, 3})
}

@(test)
test_map_duplicate_keys :: proc(t: ^testing.T) {

	m: Map(int, string)
	defer map_destroy(&m)
	map_put(&m, 1, "one")
	map_put(&m, 2, "two")
	map_put(&m, 3, "three")
	map_put(&m, 1, "one_again")

	value, ok := map_get(m, 1)
	testing.expect(t, ok)
	testing.expect_value(t, value, "one_again")
}

@(test)
test_map_frequency :: proc(t: ^testing.T) {

	sentence := "SEARCHEXAMPLE"
	m: Map(rune, int)
	defer map_destroy(&m)

	for letter, index in sentence {
		map_put(&m, letter, index)
	}

	value, ok := map_get(m, 'E')
	testing.expect(t, ok)
	testing.expect_value(t, value, 12)

	value, ok = map_get(m, 'H')
	testing.expect(t, ok)
	testing.expect_value(t, value, 5)

	value, ok = map_get(m, 'S')
	testing.expect(t, ok)
	testing.expect_value(t, value, 0)

	// There are 3 'E' so the size is len(sentence)-2.
	testing.expect_value(t, map_size(m), 10)
}

