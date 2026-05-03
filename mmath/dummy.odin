package mmath

import "core:testing"

add :: proc(a: int, b: int) -> int {
    return a + b
}

@(test)
test_add :: proc(t: ^testing.T) {
    result := add(2, 3)
    testing.expect_value(t, result, 5)
}

