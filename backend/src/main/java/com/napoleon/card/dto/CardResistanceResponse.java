package com.napoleon.card.dto;

import java.math.BigDecimal;

public record CardResistanceResponse(
        Long attackTypeId,
        String attackTypeName,
        BigDecimal value
) {
}