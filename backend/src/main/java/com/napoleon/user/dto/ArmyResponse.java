package com.napoleon.user.dto;

import java.util.List;

public record ArmyResponse(
        Long armyId,
        Long userId,
        String name,
        Boolean isActive,
        List<SaveArmyCardRequest> cards
) {
}