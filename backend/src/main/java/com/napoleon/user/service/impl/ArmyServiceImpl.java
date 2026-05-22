package com.napoleon.user.service.impl;

import com.napoleon.common.exception.ResourceNotFoundException;
import com.napoleon.user.dto.ArmyResponse;
import com.napoleon.user.dto.SaveArmyCardRequest;
import com.napoleon.user.dto.SaveArmyRequest;
import com.napoleon.user.entity.ArmyCardEntity;
import com.napoleon.user.entity.ArmyEntity;
import com.napoleon.user.entity.UserEntity;
import com.napoleon.user.repository.ArmyCardRepository;
import com.napoleon.user.repository.ArmyRepository;
import com.napoleon.user.repository.UserRepository;
import com.napoleon.user.service.ArmyService;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class ArmyServiceImpl implements ArmyService {

    private final ArmyRepository armyRepository;
    private final ArmyCardRepository armyCardRepository;
    private final UserRepository userRepository;

    public ArmyServiceImpl(
            ArmyRepository armyRepository,
            ArmyCardRepository armyCardRepository,
            UserRepository userRepository
    ) {
        this.armyRepository = armyRepository;
        this.armyCardRepository = armyCardRepository;
        this.userRepository = userRepository;
    }

    @Override
    @Transactional
    public ArmyResponse saveArmy(SaveArmyRequest request) {

        UserEntity user = userRepository.findById(request.userId())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        ArmyEntity army;

        if (request.armyId() != null) {

            army = armyRepository.findById(request.armyId())
                    .orElseThrow(() -> new ResourceNotFoundException("Army not found"));

        } else {

            int nextSlot = armyRepository.findTopByUserIdOrderBySlotNumberDesc(user.getId())
                    .map(lastArmy -> lastArmy.getSlotNumber() + 1)
                    .orElse(1);

            army = new ArmyEntity(
                    user.getId(),
                    nextSlot,
                    request.name(),
                    request.isActive(),
                    LocalDateTime.now(),
                    LocalDateTime.now()
            );
        }

        army.update(
                request.name(),
                request.isActive(),
                LocalDateTime.now()
        );

        ArmyEntity savedArmy = armyRepository.save(army);

        armyCardRepository.deleteByIdArmyId(savedArmy.getId());

        if (request.cards() != null) {

            for (SaveArmyCardRequest card : request.cards()) {

                ArmyCardEntity entity = new ArmyCardEntity(
                        savedArmy.getId(),
                        card.cardId(),
                        card.quantity()
                );

                armyCardRepository.save(entity);
            }
        }

        return new ArmyResponse(
                savedArmy.getId(),
                savedArmy.getUserId(),
                savedArmy.getName(),
                savedArmy.getIsActive(),
                request.cards()
        );
    }
}