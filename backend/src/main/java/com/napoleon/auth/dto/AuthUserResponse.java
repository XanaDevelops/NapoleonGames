package com.napoleon.auth.dto;

public record AuthUserResponse(
        Long id,
        String username,
        String displayName,
        String email,
        String profileImg,
        String role
) {
}