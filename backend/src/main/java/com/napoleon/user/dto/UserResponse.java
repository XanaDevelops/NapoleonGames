package com.napoleon.user.dto;

import java.util.List;

public record UserResponse(
        Long id,
        String name,
        String username,
        String email,
        String profileImg,
        List<UserCardSummaryResponse> availableCards,
        List<UserMapSummaryResponse> availableMaps,
        List<UserArmySummaryResponse> userArmies,
        List<UserFriendSummaryResponse> friends
) {
}