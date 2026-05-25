package com.napoleon.user.repository;

import com.napoleon.user.entity.UserCardEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UserCardRepository extends JpaRepository<UserCardEntity, UserCardEntity.UserCardId> {

    List<UserCardEntity> findByUser_Id(Long userId);
}