extends GutTest


func test_login():
	var username := "TEST_user" + str(randi_range(1000, 1000000))
	ApiAdapter.signin(
		username,
		username+"@test.com",
		"1234",
		username,
		"null"
	)
	ApiAdapter.login(username, "1234")
