package com.napoleon.user.repository;

import com.napoleon.user.entity.UserMapEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UserMapRepository extends JpaRepository<UserMapEntity, UserMapEntity.UserMapId> {

    List<UserMapEntity> findByUser_Id(Long userId);
}