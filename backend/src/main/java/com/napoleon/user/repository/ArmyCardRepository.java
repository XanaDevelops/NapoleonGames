package com.napoleon.user.repository;

import com.napoleon.user.entity.ArmyCardEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ArmyCardRepository extends JpaRepository<ArmyCardEntity, ArmyCardEntity.ArmyCardId> {

    List<ArmyCardEntity> findByIdArmyId(Long armyId);

    void deleteByIdArmyId(Long armyId);
}