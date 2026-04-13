package com.napoleon.card.repository;

import com.napoleon.card.entity.AttackTypeEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AttackTypeRepository extends JpaRepository<AttackTypeEntity, Long> {
}