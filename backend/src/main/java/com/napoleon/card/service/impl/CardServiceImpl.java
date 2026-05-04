package com.napoleon.card.service.impl;

import com.napoleon.card.dto.*;
import com.napoleon.card.entity.*;
import com.napoleon.card.repository.*;
import com.napoleon.card.service.CardService;
import com.napoleon.common.exception.ResourceNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class CardServiceImpl implements CardService {

    private final CardRepository cardRepository;
    private final AbilityRepository abilityRepository;
    private final CardResistanceRepository cardResistanceRepository;
    private final CardCardTypeRepository cardCardTypeRepository;
    private final AttackTypeRepository attackTypeRepository;
    private final CardTypeRepository cardTypeRepository;

    public CardServiceImpl(
            CardRepository cardRepository,
            AbilityRepository abilityRepository,
            CardResistanceRepository cardResistanceRepository,
            CardCardTypeRepository cardCardTypeRepository,
            AttackTypeRepository attackTypeRepository,
            CardTypeRepository cardTypeRepository
    ) {
        this.cardRepository = cardRepository;
        this.abilityRepository = abilityRepository;
        this.cardResistanceRepository = cardResistanceRepository;
        this.cardCardTypeRepository = cardCardTypeRepository;
        this.attackTypeRepository = attackTypeRepository;
        this.cardTypeRepository = cardTypeRepository;
    }

    @Override
    public CardResponse getCard(Long id) {
        CardEntity card = cardRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Card not found"));

        return buildCardResponse(card);
    }

    @Override
    @Transactional
    public CardResponse updateCard(UpdateCardRequest request) {
        CardEntity card = cardRepository.findById(request.id())
                .orElseThrow(() -> new ResourceNotFoundException("Card not found"));

        card.update(
                request.name(),
                request.description(),
                request.hp(),
                request.attack(),
                request.defense(),
                request.damage(),
                request.movement(),
                request.dodge(),
                request.weight(),
                request.mana()
        );

        CardEntity updatedCard = cardRepository.save(card);
        return buildCardResponse(updatedCard);
    }

    private CardResponse buildCardResponse(CardEntity card) {
        List<CardResistanceResponse> resistances = cardResistanceRepository.findByIdCardId(card.getId())
                .stream()
                .map(this::mapResistance)
                .toList();

        List<CardAbilityResponse> abilities = abilityRepository.findByCardId(card.getId())
                .stream()
                .map(this::mapAbility)
                .toList();

        List<CardTypeResponse> types = cardCardTypeRepository.findByIdCardId(card.getId())
                .stream()
                .map(this::mapType)
                .toList();

        return new CardResponse(
                card.getId(),
                card.getName(),
                card.getDescription(),
                card.getHp(),
                card.getAttack(),
                card.getDefense(),
                card.getDamage(),
                card.getMovement(),
                card.getDodge(),
                card.getWeight(),
                card.getMana(),
                resistances,
                abilities,
                types
        );
    }

    private CardResistanceResponse mapResistance(CardResistanceEntity entity) {
        AttackTypeEntity attackType = attackTypeRepository.findById(entity.getId().getAttackTypeId())
                .orElseThrow(() -> new ResourceNotFoundException("Attack type not found"));

        return new CardResistanceResponse(
                attackType.getId(),
                attackType.getName(),
                entity.getValue()
        );
    }

    private CardAbilityResponse mapAbility(AbilityEntity entity) {
        return new CardAbilityResponse(
                entity.getId(),
                entity.getName(),
                entity.getDescription()
        );
    }

    private CardTypeResponse mapType(CardCardTypeEntity entity) {
        CardTypeEntity cardType = cardTypeRepository.findById(entity.getId().getCardTypeId())
                .orElseThrow(() -> new ResourceNotFoundException("Card type not found"));

        return new CardTypeResponse(
                cardType.getId(),
                cardType.getName()
        );
    }
}