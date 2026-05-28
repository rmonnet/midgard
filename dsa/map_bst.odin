// This files implement a Map.
package dsa

import "base:intrinsics"

/*
# Binary Search Tree Data Structure

## Summary

The Map structure stores (key, value) pairs
where the keys are considered immutable. This implementation stores
all the values using a Binary Search Tree. It doesn't support
dynamically allocated keys, only dynamically allocated values.

If the type of the values is dynamically allocated and a value is returned
by a procedure, it is the responsibility of the caller to destroy it.

## Properties

The search and insert have a worst case of O(lg N) if the inputs are randomly ordered
but can degenerate to a O(N) if the inputs are strictly in order. In addition, a combination
of delete and add may result in an unbalanced tree making the performances trending towards
the worst case.
*/

BST_Map_Node :: struct($K: typeid, $V: typeid) where intrinsics.type_is_comparable(K) {
	key:   K,
	value: V,
	left:  ^BST_Map_Node(K, V),
	right: ^BST_Map_Node(K, V),
	count: int,
}

// Map defines the type holding the set of (key, value) pairs.
BST_Map :: struct($K: typeid, $V: typeid) where intrinsics.type_is_comparable(K) {
	head: ^BST_Map_Node(K, V),
}

// Destroys a Map containing non-dynamically allocated elements.
bst_map_destroy_simple :: proc(m: ^BST_Map($K, $V)) {

	destroy_tree :: proc(t: ^BST_Map_Node(K, V)) {

		if t == nil {return}
		if t.left != nil {destroy_tree(t.left)}
		if t.right != nil {destroy_tree(t.right)}
		free(t)
	}

	destroy_tree(m.head)
}

// Destroys a Map containing dynamically allocated values.
bst_map_destroy_with_value_destroy :: proc(s: ^BST_Map($K, $V), destroy: proc(value: ^V)) {

	destroy_tree :: proc(t: ^BST_Map_Node(K, V)) {

		if t == nil {return}
		if t.left != nil {destroy_tree(t.left)}
		if t.right != nil {destroy_tree(t.right)}
		destroy(t.value)
		free(t)
	}

	destroy_tree(m.head)
}

// Destroys a Map.
bst_map_destroy :: proc {
	bst_map_destroy_simple,
	bst_map_destroy_with_value_destroy,
}

// Add a (key, value) pair to the map. If the key already
// exists, replace the associated value. It returns the old
// value if it exists. If it doesn't, it set ok to false.
bst_map_put :: proc(m: ^BST_Map($K, $V), key: K, value: V) -> (old_value: V, ok: bool) {

	put_tree :: proc(
		t: ^BST_Map_Node(K, V),
		key: K,
		value: V,
	) -> (
		new_t: ^BST_Map_Node(K, V),
		old_value: V,
		ok: bool,
	) {

		if t == nil {
			new_t = new(BST_Map_Node(K, V))
			new_t.key = key
			new_t.value = value
			new_t.count = 1
			return
		}

		if key < t.key {
			t.left, old_value, ok = put_tree(t.left, key, value)
		} else if key > t.key {
			t.right, old_value, ok = put_tree(t.right, key, value)
		} else {
			old_value = value
			t.value = value
			ok = true
		}
		t.count = 1 + bst_map_node_size(t.left) + bst_map_node_size(t.right)
		return t, old_value, ok
	}

	m.head, old_value, ok = put_tree(m.head, key, value)
	return
}

// Lookup an element from the map based on its key. The 'ok'
// return value is false if the key is not in the map.
bst_map_get :: proc(m: BST_Map($K, $V), key: K) -> (value: V, ok: bool) {

	node := m.head
	for node != nil {
		if key < node.key {
			node = node.left
		} else if key > node.key {
			node = node.right
		} else {
			return node.value, true
		}
	}
	return
}

// Delete an element from the map based on its key. If
// the element is found, its value is returned. If the element
// is not found, the ok return value is false.
bst_map_delete :: proc(m: ^BST_Map($K, $V), key: K) -> (value: V, ok: bool) {

	delete_tree :: proc(
		t: ^BST_Map_Node($K, $V),
		key: K,
	) -> (
		new_t: ^BST_Map_Node(K, V),
		value: V,
		ok: bool,
	) {

		if t == nil {return}
		if key < t.key {
			t.left, value, ok = delete_tree(t.left, key)
		} else if key > t.key {
			t.right, value, ok = delete_tree(t.right, key)
		} else {
			if t.right == nil {
				// easy case there is zero or 1 child
				defer free(t)
				return t.left, t.value, true
			}
			value = t.value
			ok = true
			new_right_t, min_key, min_value, delete_min_ok := bst_map_node_delete_min(t.right)
			if !delete_min_ok {
				panic("Right subtree was not empty but delete-min failed")
			}
			t.key = min_key
			t.value = min_value
			t.right = new_right_t
		}
		t.count = 1 + bst_map_node_size(t.left) + bst_map_node_size(t.right)
		return t, value, ok
	}

	m.head, value, ok = delete_tree(m.head, key)
	return
}

// Checks if the Map contains an element with the given key.
bst_map_contains :: proc(m: BST_Map($K, $V), key: K) -> bool {

	node := m.head
	for node != nil {
		if key < node.key {
			node = node.left
		} else if key > node.key {
			node = node.right
		} else {
			return true
		}
	}
	return false
}

// Checks if the map is empty.
bst_map_is_empty :: proc(m: BST_Map($K, $V)) -> bool {

	return bst_map_size(m) == 0
}

bst_map_node_size :: proc(t: ^BST_Map_Node($K, $V)) -> int {

	return 0 if t == nil else t.count
}

// Return the number of elements in the map.
bst_map_size :: proc(m: BST_Map($K, $V)) -> int {

	return bst_map_node_size(m.head)
}

// Return a slice containing all the keys in the map.
bst_map_keys :: proc(m: BST_Map($K, $V)) -> []K {

	bst_map_node_keys :: proc(t: ^BST_Map_Node(K, V), acc: ^[dynamic]K) {

		if t == nil {return}
		bst_map_node_keys(t.left, acc)
		append(acc, t.key)
		bst_map_node_keys(t.right, acc)
	}

	keys: [dynamic]K
	bst_map_node_keys(m.head, &keys)
	return keys[:]
}

bst_map_node_delete_min :: proc(
	t: ^BST_Map_Node($K, $V),
) -> (
	new_t: ^BST_Map_Node(K, V),
	min_key: K,
	min_value: V,
	ok: bool,
) {

	if t == nil {return}
	if t.left == nil {
		defer free(t)
		return t.right, t.key, t.value, true
	}
	t.left, min_key, min_value, ok = bst_map_node_delete_min(t.left)
	t.count = 1 + bst_map_node_size(t.left) + bst_map_node_size(t.right)
	return t, min_key, min_value, ok
}

// Delete the minimum element in the tree.
// This is used when deleting a node with both left and right children.
bst_map_delete_min :: proc(m: ^BST_Map($K, $V)) -> (min_key: K, min_value: V, ok: bool) {

	m.head, min_key, min_value, ok = bst_map_node_delete_min(m.head)
	return
}

// Tests
// -----

import "core:slice"
import "core:testing"

@(test)
test_bst_map_is_empty :: proc(t: ^testing.T) {

	m: BST_Map(int, string)
	defer bst_map_destroy(&m)

	testing.expect(t, bst_map_is_empty(m))
}

@(test)
test_bst_map_is_not_empty :: proc(t: ^testing.T) {

	m: BST_Map(int, string)
	defer bst_map_destroy(&m)
	bst_map_put(&m, 1, "one")

	testing.expect(t, !bst_map_is_empty(m))
}

@(test)
test_bst_map_size :: proc(t: ^testing.T) {

	m: BST_Map(int, string)
	defer bst_map_destroy(&m)
	bst_map_put(&m, 3, "three")
	bst_map_put(&m, 1, "one")
	bst_map_put(&m, 4, "four")
	bst_map_put(&m, 2, "two")
	bst_map_put(&m, 2, "two_again")

	testing.expect_value(t, bst_map_size(m), 4)
}

@(test)
test_bst_map_get_when_empty :: proc(t: ^testing.T) {

	m: BST_Map(int, string)
	defer bst_map_destroy(&m)

	_, ok := bst_map_get(m, 1)
	testing.expect(t, !ok)
}

@(test)
test_bst_map_contains :: proc(t: ^testing.T) {

	m: BST_Map(int, string)
	defer bst_map_destroy(&m)
	bst_map_put(&m, 3, "three")
	bst_map_put(&m, 1, "one")
	bst_map_put(&m, 4, "four")
	bst_map_put(&m, 2, "two")

	testing.expect(t, bst_map_contains(m, 1))

	testing.expect(t, !bst_map_contains(m, 0))
}

@(test)
test_bst_map_get :: proc(t: ^testing.T) {

	m: BST_Map(int, string)
	defer bst_map_destroy(&m)
	bst_map_put(&m, 3, "three")
	bst_map_put(&m, 1, "one")
	bst_map_put(&m, 4, "four")
	bst_map_put(&m, 2, "two")

	value, ok := bst_map_get(m, 1)
	testing.expect(t, ok)
	testing.expect_value(t, value, "one")

	value, ok = bst_map_get(m, 3)
	testing.expect(t, ok)
	testing.expect_value(t, value, "three")

	value, ok = bst_map_get(m, 0)
	testing.expect(t, !ok)
}

@(test)
test_bst_map_delete :: proc(t: ^testing.T) {

	m: BST_Map(int, string)
	defer bst_map_destroy(&m)
	bst_map_put(&m, 3, "three")
	bst_map_put(&m, 1, "one")
	bst_map_put(&m, 4, "four")
	bst_map_put(&m, 2, "two")

	value, ok := bst_map_delete(&m, 1)
	testing.expect(t, ok)
	testing.expect_value(t, value, "one")
	testing.expect(t, !bst_map_contains(m, 1))
	testing.expect_value(t, bst_map_size(m), 3)

	value, ok = bst_map_delete(&m, 1)
	testing.expect(t, !ok)

	value, ok = bst_map_delete(&m, 0)
	testing.expect(t, !ok)

	value, ok = bst_map_delete(&m, 3)
	testing.expect(t, ok)
	testing.expect_value(t, value, "three")
	testing.expect(t, !bst_map_contains(m, 3))
	testing.expect_value(t, bst_map_size(m), 2)
}

@(test)
test_bst_map_delete_min :: proc(t: ^testing.T) {

	m: BST_Map(int, string)
	defer bst_map_destroy(&m)
	bst_map_put(&m, 3, "three")
	bst_map_put(&m, 1, "one")
	bst_map_put(&m, 4, "four")
	bst_map_put(&m, 2, "two")

	key, value, ok := bst_map_delete_min(&m)
	testing.expect(t, ok)
	testing.expect_value(t, key, 1)
	testing.expect_value(t, value, "one")
	testing.expect(t, !bst_map_contains(m, 1))
	testing.expect_value(t, bst_map_size(m), 3)

	key, value, ok = bst_map_delete_min(&m)
	testing.expect(t, ok)
	testing.expect_value(t, key, 2)
	testing.expect_value(t, value, "two")
	testing.expect(t, !bst_map_contains(m, 2))
	testing.expect_value(t, bst_map_size(m), 2)
}

@(test)
test_bst_map_keys :: proc(t: ^testing.T) {

	m: BST_Map(int, string)
	defer bst_map_destroy(&m)
	bst_map_put(&m, 3, "three")
	bst_map_put(&m, 1, "one")
	bst_map_put(&m, 4, "four")
	bst_map_put(&m, 2, "two")

	keys := bst_map_keys(m)
	defer delete(keys)
	expected := []int{1, 2, 3, 4}

	if !slice.equal(keys[:], expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, keys)
	}
}

@(test)
test_bst_map_duplicate_keys :: proc(t: ^testing.T) {

	m: BST_Map(int, string)
	defer bst_map_destroy(&m)
	bst_map_put(&m, 3, "three")
	bst_map_put(&m, 1, "one")
	bst_map_put(&m, 4, "four")
	bst_map_put(&m, 2, "two")
	bst_map_put(&m, 1, "one_again")

	value, ok := bst_map_get(m, 1)
	testing.expect(t, ok)
	testing.expect_value(t, value, "one_again")
}

@(test)
test_bst_map_frequency :: proc(t: ^testing.T) {

	sentence := "SEARCHEXAMPLE"
	m: BST_Map(rune, int)
	defer bst_map_destroy(&m)

	for letter, index in sentence {
		bst_map_put(&m, letter, index)
	}

	value, ok := bst_map_get(m, 'E')
	testing.expect(t, ok)
	testing.expect_value(t, value, 12)

	value, ok = bst_map_get(m, 'H')
	testing.expect(t, ok)
	testing.expect_value(t, value, 5)

	value, ok = bst_map_get(m, 'S')
	testing.expect(t, ok)
	testing.expect_value(t, value, 0)

	// There are 3 'E' so the size is len(sentence)-2.
	testing.expect_value(t, bst_map_size(m), 10)
}

