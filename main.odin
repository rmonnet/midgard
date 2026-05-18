package midgard

import "core:fmt"

main :: proc() {

	xs := []int{17, 5, 20, 1, 12, 10, 18, 3, 9, 16, 2, 13, 14, 8, 7, 6, 4, 12, 2, 19, 15, 11}
	heap_sort(xs, cmp_int)
	fmt.println(xs)
}

