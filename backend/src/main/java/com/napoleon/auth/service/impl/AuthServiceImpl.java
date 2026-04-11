package com.napoleon.auth.service.impl;

import com.napoleon.auth.dto.AuthResponse;
import com.napoleon.auth.dto.AuthUserResponse;
import com.napoleon.auth.dto.LoginRequest;
import com.napoleon.auth.dto.SignInRequest;
import com.napoleon.auth.service.AuthService;
import com.napoleon.auth.token.JwtService;
import com.napoleon.common.exception.DuplicateResourceException;
import com.napoleon.common.exception.InvalidCredentialsException;
import com.napoleon.user.entity.UserEntity;
import com.napoleon.user.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthServiceImpl implements AuthService {

    private static final String DEFAULT_ROLE = "PLAYER";

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthServiceImpl(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService
    ) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    @Override
    public AuthResponse login(LoginRequest request) {
        UserEntity user = userRepository.findByUsername(request.username())
                .orElseThrow(() -> new InvalidCredentialsException("Invalid username or password"));

        boolean passwordMatches = passwordEncoder.matches(request.password(), user.getPasswordHash());

        if (!passwordMatches) {
            throw new InvalidCredentialsException("Invalid username or password");
        }

        return buildAuthResponse(user);
    }

    @Override
    public AuthResponse signIn(SignInRequest request) {
        if (userRepository.existsByUsername(request.username())) {
            throw new DuplicateResourceException("Username already exists");
        }

        if (userRepository.existsByEmail(request.email())) {
            throw new DuplicateResourceException("Email already exists");
        }

        String encodedPassword = passwordEncoder.encode(request.password());

        UserEntity userToCreate = UserEntity.create(
                request.username(),
                request.email(),
                encodedPassword,
                request.displayName(),
                request.profileImg(),
                DEFAULT_ROLE
        );

        UserEntity savedUser = userRepository.save(userToCreate);
        return buildAuthResponse(savedUser);
    }

    private AuthResponse buildAuthResponse(UserEntity user) {
        AuthUserResponse userResponse = new AuthUserResponse(
                user.getId(),
                user.getUsername(),
                user.getDisplayName(),
                user.getEmail(),
                user.getProfileImg(),
                user.getRole()
        );

        String token = jwtService.generateToken(user);
        return new AuthResponse(token, userResponse);
    }
}