extends GutTest

class ObjPrio extends RefCounted:
	var prio:int
	func _init(p_prio:int):
		prio = p_prio

func prio(o: ObjPrio) -> int:
	return o.prio

func test_pq():  
	const OBJ_NUM = 20
	var prio_queue_max = PriorityQueue.new(true, [], prio)
	var prio_queue_min = PriorityQueue.new(false, [], prio)
	
	var test_arr : Array[int] = []
	
	for i in OBJ_NUM:
		var n = randi_range(-100, 100)
		var obj = ObjPrio.new(n)
		prio_queue_max.insert(obj)
		prio_queue_min.insert(obj)
		test_arr.append(n)
		
	print("descending ordered")
	test_arr.sort_custom(func(a, b): return a > b)
	var i := 0
	while prio_queue_max.size() > 0:
		var head_node = prio_queue_max.head()
		print("\t", head_node.prio)
		assert_eq(head_node.prio, test_arr[i], "desc")
		i+=1
		prio_queue_max.delete_node(head_node)
		
	print("ascending ordered")
	test_arr.sort_custom(func(a, b): return a < b)
	i = 0
	while prio_queue_min.size() > 0:
		var head_node = prio_queue_min.head()
		print("\t", head_node.prio)
		assert_eq(head_node.prio, test_arr[i], "asc")
		i+=1
		prio_queue_min.delete_node(head_node)
		
