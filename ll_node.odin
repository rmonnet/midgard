// This file contains the Node used by Linked List Implementations.
package midgard


//@(private)
Linked_List_Node :: struct($T: typeid) {
	element: T,
	next:    ^Linked_List_Node(T),
}
