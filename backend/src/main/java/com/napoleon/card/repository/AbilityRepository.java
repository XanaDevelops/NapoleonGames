package com.napoleon.card.repository;

import com.napoleon.card.entity.AbilityEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AbilityRepository extends JpaRepository<AbilityEntity, Long> {

    List<AbilityEntity> findByCardId(Long cardId);
}