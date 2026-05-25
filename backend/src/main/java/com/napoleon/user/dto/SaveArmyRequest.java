package com.napoleon.user.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.List;

public record SaveArmyRequest(

        Long armyId,

        @NotNull(message = "User id is required")
        Long userId,

        @NotBlank(message = "Army name is required")
        @Size(max = 100, message = "Army name must have at most 100 characters")
        String name,

        @NotNull(message = "isActive is required")
        Boolean isActive,

        @Valid
        List<SaveArmyCardRequest> cards
) {
}