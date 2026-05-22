package com.napoleon.user.repository;

import com.napoleon.user.entity.ArmyEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ArmyRepository extends JpaRepository<ArmyEntity, Long> {

    List<ArmyEntity> findByUserId(Long userId);
}