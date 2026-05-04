package com.napoleon.auth.controller;

import com.napoleon.auth.dto.AuthResponse;
import com.napoleon.auth.dto.LoginRequest;
import com.napoleon.auth.dto.SignInRequest;
import com.napoleon.auth.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest request) {
        return authService.login(request);
    }

    @PostMapping("/signin")
    public AuthResponse signIn(@Valid @RequestBody SignInRequest request) {
        return authService.signIn(request);
    }
}