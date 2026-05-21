package midgard

import "core:fmt"

main :: proc() {

	m: BST_Map(int, string)
	defer bst_map_destroy(&m)
	bst_map_put(&m, 3, "three")
	bst_map_put(&m, 1, "one")
	bst_map_put(&m, 4, "four")
	bst_map_put(&m, 2, "two")

	key, value, ok := bst_map_delete_min(&m)
	fmt.printf(
		"delete min %d, '%s', %t, %t, %d\n",
		key,
		value,
		ok,
		bst_map_contains(m, 1),
		bst_map_size(m),
	)

	key, value, ok = bst_map_delete_min(&m)
	fmt.printf(
		"delete min %d, '%s', %t, %t, %d\n",
		key,
		value,
		ok,
		bst_map_contains(m, 2),
		bst_map_size(m),
	)
	fmt.printf("%#v\n", m)
	fmt.printf("%#v\n", m.head.left)
	fmt.printf("%#v\n", m.head.right)
}

