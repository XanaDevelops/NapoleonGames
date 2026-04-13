package com.napoleon.auth.token;

import com.napoleon.user.entity.UserEntity;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class JwtService {

    public String generateToken(UserEntity user) {
        return "mock-token-" + user.getId() + "-" + UUID.randomUUID();
    }
}