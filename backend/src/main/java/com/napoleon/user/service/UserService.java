package com.napoleon.user.service;

import com.napoleon.user.dto.UserResponse;

public interface UserService {
    UserResponse getUser(Long id, String username);
}
