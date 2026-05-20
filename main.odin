package midgard

import "core:fmt"

main :: proc() {

	sentence := "SEARCHEXAMPLE"
	m: Ordered_Map(rune, int)
	defer ordered_map_destroy(&m)

	for letter, index in sentence {
		ordered_map_put(&m, letter, index)
	}
	fmt.println(ordered_map_keys(m))
}

