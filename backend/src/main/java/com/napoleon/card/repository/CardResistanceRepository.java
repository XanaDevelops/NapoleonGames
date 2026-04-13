package com.napoleon.card.repository;

import com.napoleon.card.entity.CardResistanceEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CardResistanceRepository extends JpaRepository<CardResistanceEntity, CardResistanceEntity.CardResistanceId> {

    List<CardResistanceEntity> findByIdCardId(Long cardId);
}