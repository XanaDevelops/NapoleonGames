package com.napoleon.card.repository;

import com.napoleon.card.entity.CardTypeEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CardTypeRepository extends JpaRepository<CardTypeEntity, Long> {
}