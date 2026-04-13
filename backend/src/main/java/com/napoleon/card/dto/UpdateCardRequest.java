package com.napoleon.card.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;

public record UpdateCardRequest(
        @NotNull(message = "Card id is required")
        Long id,

        @Size(max = 100, message = "Name must have at most 100 characters")
        String name,

        @Size(max = 1000, message = "Description must have at most 1000 characters")
        String description,

        @Positive(message = "HP must be greater than 0")
        Integer hp,

        @PositiveOrZero(message = "Attack must be greater than or equal to 0")
        Integer attack,

        @PositiveOrZero(message = "Defense must be greater than or equal to 0")
        Integer defense,

        @PositiveOrZero(message = "Damage must be greater than or equal to 0")
        Integer damage,

        @PositiveOrZero(message = "Movement must be greater than or equal to 0")
        Integer movement,

        @DecimalMin(value = "0.0", inclusive = true, message = "Dodge must be between 0 and 1")
        @DecimalMax(value = "1.0", inclusive = true, message = "Dodge must be between 0 and 1")
        BigDecimal dodge,

        @Positive(message = "Weight must be greater than 0")
        Integer weight,

        @PositiveOrZero(message = "Mana must be greater than or equal to 0")
        Integer mana
) {
}