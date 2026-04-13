package com.napoleon.card.repository;

import com.napoleon.card.entity.CardCardTypeEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CardCardTypeRepository extends JpaRepository<CardCardTypeEntity, CardCardTypeEntity.CardCardTypeId> {

    List<CardCardTypeEntity> findByIdCardId(Long cardId);
}