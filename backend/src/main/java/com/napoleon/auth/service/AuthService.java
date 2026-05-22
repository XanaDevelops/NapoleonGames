package com.napoleon.auth.service;

import com.napoleon.auth.dto.AuthResponse;
import com.napoleon.auth.dto.LoginRequest;
import com.napoleon.auth.dto.SignInRequest;

public interface AuthService {
    AuthResponse login(LoginRequest request);
    AuthResponse signIn(SignInRequest request);
}