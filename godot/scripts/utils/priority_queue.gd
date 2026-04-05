class_name PriorityQueue
extends RefCounted

# taken from https://github.com/beobf/GodotUtilities
# modified to use lambdas instead
# Priority Queue implementation in GDScript
# (see: https://www.programiz.com/dsa/priority-inner_array)
# NOTE: the queue works with objects with an orderable (ie
# "less than comparable") priority property,  
# whose name can be specified (default: "priority")
var max_heap: bool # =true/false then queue in descending/ascending
var priority: Callable
var inner_array: Array
		
		
func _init(p_max_heap:bool=true, new_arr:Array=[],
		f_priority: Callable = func (x): return x.get("priority")):
	max_heap = p_max_heap
	priority = f_priority
	inner_array = []
	for item in new_arr:
		insert(item)
	
# Function to insert an element into the tree
func insert(obj):
	if not (priority.call(obj) is int):
		push_warning("Object '", obj, "' cannot be inserted in the queue!")
		return
	var arr_size:int = inner_array.size()
	inner_array.append(obj)
	if arr_size != 0:
		for i in range((arr_size / 2) - 1, -1, -1):
			_heapify(arr_size, i)

# Function to delete an element from the tree
func delete_node(obj):
	if not (priority.call(obj) is int):
		push_warning("Object '", obj, "' cannot be deleted from the queue!")
		return
	var arr_size:int = inner_array.size()
	var i = 0
	while i < arr_size:
		if priority.call(obj) == priority.call(inner_array[i]):
			break
		i += 1
	# Swap the element to delete with the last element
	var inner_array_i = inner_array[i]
	inner_array[i] = inner_array[arr_size - 1]
	inner_array[arr_size - 1] = inner_array_i
	# Remove the last element (the one we want to delete) = obj
	inner_array.pop_back()
	# Rebuild the heap
	arr_size = inner_array.size()
	for y in range((arr_size / 2) - 1, -1, -1):
		_heapify(arr_size, y)

func head():
	return inner_array[0]

func size():
	return inner_array.size()

# Function to heapify the tree
func _heapify(n, i):
	# Find the head (largest/lowest) among root, left child, and right child
	var head = i
	var l = 2 * i + 1
	var r = 2 * i + 2
	if max_heap:
		if l < n and priority.call(inner_array[i]) < priority.call(inner_array[l]):
			head = l
		if r < n and priority.call(inner_array[head]) < priority.call(inner_array[r]):
			head = r
	else:
		# min_heap
		if l < n and priority.call(inner_array[i]) > priority.call(inner_array[l]):
			head = l
		if r < n and priority.call(inner_array[head]) > priority.call(inner_array[r]):
			head = r
	# Swap and continue heapifying if root is not the head
	if head != i:
		var inner_array_i = inner_array[i]
		inner_array[i] = inner_array[head]
		inner_array[head] = inner_array_i
		_heapify(n, head)
		
		
