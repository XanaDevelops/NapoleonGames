package com.napoleon.user.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record UpdateUserRequest(
        @NotNull(message = "User id is required")
        Long id,

        @Email(message = "Email format is invalid")
        @Size(max = 150, message = "Email must have at most 150 characters")
        String email,

        @Size(max = 100, message = "Display name must have at most 100 characters")
        String displayName,

        @Size(max = 255, message = "Profile image path must have at most 255 characters")
        String profileImg
) {
}