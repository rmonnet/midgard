package midgard

import "core:fmt"

main :: proc() {

	m: Map(int, string)
	defer map_destroy(&m)
	map_put(&m, 1, "one")
	map_put(&m, 2, "two")
	map_put(&m, 3, "three")
	fmt.println(map_size(m))
}

