package com.napoleon.card.dto;

import java.math.BigDecimal;
import java.util.List;

public record CardResponse(
        Long id,
        String name,
        String description,
        Integer hp,
        Integer attack,
        Integer defense,
        Integer damage,
        Integer movement,
        BigDecimal dodge,
        Integer weight,
        Integer mana,
        List<CardResistanceResponse> resistances,
        List<CardAbilityResponse> abilities,
        List<CardTypeResponse> types
) {
}