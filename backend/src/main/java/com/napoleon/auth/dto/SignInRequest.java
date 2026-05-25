package com.napoleon.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record SignInRequest(
        @NotBlank(message = "Username is required")
        @Size(max = 50, message = "Username must have at most 50 characters")
        String username,

        @NotBlank(message = "Email is required")
        @Email(message = "Email format is invalid")
        @Size(max = 150, message = "Email must have at most 150 characters")
        String email,

        @NotBlank(message = "Password is required")
        @Size(min = 4, max = 100, message = "Password must have between 4 and 100 characters")
        String password,

        @NotBlank(message = "Display name is required")
        @Size(max = 100, message = "Display name must have at most 100 characters")
        String displayName,

        @Size(max = 255, message = "Profile image path must have at most 255 characters")
        String profileImg
) {
}