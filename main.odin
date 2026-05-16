package midgard

import "base:intrinsics"
import "core:fmt"
import "core:math/rand"
import "core:slice"
import "core:time"

import "./math"

merge_sort_2 :: proc(xs: []$T) where intrinsics.type_is_ordered(T) {

	less :: #force_inline proc(a, b: T) -> bool {
		return a < b
	}
	merge_sort_by(xs, less)
}

merge_sort_3 :: proc(xs: []f64) {

	less :: #force_inline proc(a, b: f64) -> bool {
		return a < b
	}
	merge_sort_by(xs, less)
}

// main2 :: proc() {

// 	xs: [1000]f64
// 	for i in 0 ..< len(xs) {
// 		xs[i] = rand.float64()
// 	}

// 	ys := slice.clone(xs[:])
// 	defer delete(ys)
// 	start := time.now()
// 	merge_sort(ys)
// 	elapsed := time.since(start)
// 	fmt.printf("merge_sort 1: %v\n", elapsed)

// 	zs := slice.clone(xs[:])
// 	defer delete(zs)
// 	start = time.now()
// 	merge_sort_2(zs)
// 	elapsed = time.since(start)
// 	fmt.printf("merge_sort 2: %v\n", elapsed)

// 	as := slice.clone(xs[:])
// 	defer delete(as)
// 	start = time.now()
// 	merge_sort_3(as)
// 	elapsed = time.since(start)
// 	fmt.printf("merge_sort 3: %v\n", elapsed)

// 	fmt.printf("add(%d, %d)=%d\n", 1, 2, math.add(1, 2))
// }

main :: proc() {

	string_lt :: proc(a, b: string) -> bool {

		return a < b
	}

	xs := [?]string {
		"q",
		"e",
		"t",
		"a",
		"l",
		"j",
		"r",
		"c",
		"i",
		"p",
		"b",
		"m",
		"n",
		"h",
		"g",
		"f",
		"d",
		"l",
		"b",
		"s",
		"o",
		"k",
	}
	expected := [?]string {
		"a",
		"b",
		"b",
		"c",
		"d",
		"e",
		"f",
		"g",
		"h",
		"i",
		"j",
		"k",
		"l",
		"l",
		"m",
		"n",
		"o",
		"p",
		"q",
		"r",
		"s",
		"t",
	}
	quick_sort_by(xs[:], string_lt)
	fmt.printf("> %v", xs)
}

