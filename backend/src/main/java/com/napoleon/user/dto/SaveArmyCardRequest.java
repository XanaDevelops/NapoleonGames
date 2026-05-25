package com.napoleon.user.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record SaveArmyCardRequest(

        @NotNull(message = "Card id is required")
        Long cardId,

        @NotNull(message = "Quantity is required")
        @Min(value = 1, message = "Quantity must be greater than 0")
        Integer quantity
) {
}