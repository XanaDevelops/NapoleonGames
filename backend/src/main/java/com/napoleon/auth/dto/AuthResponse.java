package com.napoleon.auth.dto;

public record AuthResponse(
        String token,
        AuthUserResponse user
) {
}