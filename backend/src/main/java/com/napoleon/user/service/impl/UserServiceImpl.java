package com.napoleon.user.service.impl;

import com.napoleon.common.exception.DuplicateResourceException;
import com.napoleon.common.exception.ResourceNotFoundException;
import com.napoleon.user.dto.*;
import com.napoleon.user.entity.ArmyEntity;
import com.napoleon.user.entity.UserCardEntity;
import com.napoleon.user.entity.UserEntity;
import com.napoleon.user.entity.UserMapEntity;
import com.napoleon.user.repository.ArmyRepository;
import com.napoleon.user.repository.UserCardRepository;
import com.napoleon.user.repository.UserMapRepository;
import com.napoleon.user.repository.UserRepository;
import com.napoleon.user.service.UserService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final UserCardRepository userCardRepository;
    private final UserMapRepository userMapRepository;
    private final ArmyRepository armyRepository;

    public UserServiceImpl(
            UserRepository userRepository,
            UserCardRepository userCardRepository,
            UserMapRepository userMapRepository,
            ArmyRepository armyRepository
    ) {
        this.userRepository = userRepository;
        this.userCardRepository = userCardRepository;
        this.userMapRepository = userMapRepository;
        this.armyRepository = armyRepository;
    }

    @Override
    public UserResponse getUser(Long id, String username) {
        if (id == null && (username == null || username.isBlank())) {
            throw new IllegalArgumentException("Either id or username must be provided");
        }

        UserEntity user = resolveUser(id, username);
        return buildUserResponse(user);
    }

    @Override
    @Transactional
    public UserResponse updateUser(UpdateUserRequest request) {
        UserEntity user = userRepository.findById(request.id())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (request.email() != null
                && !request.email().isBlank()
                && userRepository.existsByEmailAndIdNot(request.email(), user.getId())) {
            throw new DuplicateResourceException("Email already exists");
        }

        user.updateProfile(
                request.email(),
                request.displayName(),
                request.profileImg()
        );

        UserEntity updatedUser = userRepository.save(user);
        return buildUserResponse(updatedUser);
    }

    private UserEntity resolveUser(Long id, String username) {
        if (id != null) {
            return userRepository.findById(id)
                    .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        }

        return userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }

    private UserResponse buildUserResponse(UserEntity user) {
        List<UserCardSummaryResponse> availableCards = userCardRepository.findByUser_Id(user.getId())
                .stream()
                .map(this::mapUserCard)
                .toList();

        List<UserMapSummaryResponse> availableMaps = userMapRepository.findByUser_Id(user.getId())
                .stream()
                .map(this::mapUserMap)
                .toList();

        List<UserArmySummaryResponse> userArmies = armyRepository.findByUserId(user.getId())
                .stream()
                .map(this::mapArmy)
                .toList();

        return new UserResponse(
                user.getId(),
                user.getDisplayName(),
                user.getUsername(),
                user.getEmail(),
                user.getProfileImg(),
                availableCards,
                availableMaps,
                userArmies,
                List.of()
        );
    }

    private UserCardSummaryResponse mapUserCard(UserCardEntity entity) {
        return new UserCardSummaryResponse(
                entity.getId().getCardId(),
                entity.getQuantity()
        );
    }

    private UserMapSummaryResponse mapUserMap(UserMapEntity entity) {
        return new UserMapSummaryResponse(
                entity.getId().getMapId()
        );
    }

    private UserArmySummaryResponse mapArmy(ArmyEntity entity) {
        return new UserArmySummaryResponse(
                entity.getId()
        );
    }
}