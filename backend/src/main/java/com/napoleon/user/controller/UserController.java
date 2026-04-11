package com.napoleon.user.controller;

import com.napoleon.user.dto.UpdateUserRequest;
import com.napoleon.user.dto.UserResponse;
import com.napoleon.user.service.UserService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping
    public UserResponse getUser(
            @RequestParam(required = false) Long id,
            @RequestParam(required = false) String username
    ) {
        return userService.getUser(id, username);
    }

    @PostMapping
    public UserResponse updateUser(@Valid @RequestBody UpdateUserRequest request) {
        return userService.updateUser(request);
    }
}