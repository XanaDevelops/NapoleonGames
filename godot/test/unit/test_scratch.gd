extends GutTest


func test_scratch() -> void:
	var carta_test := CardRes.new()
	carta_test.uid = 123
	var carta_test2 := CardRes.new()
	carta_test2.uid = 456
	var carta_test3 := CardRes.new()
	carta_test3.uid = 123
	
	var otro_test := UserRes.new()
	otro_test.uid = 123
	
	gut.logger.log(str(carta_test.get_script()))
	gut.logger.log(str(otro_test.get_script()))
	
	assert_true(carta_test.compare(carta_test))
	assert_true(carta_test.compare(carta_test3))
	assert_false(carta_test2.compare(carta_test))
	assert_false(carta_test.compare(otro_test))
	assert_true(true)
