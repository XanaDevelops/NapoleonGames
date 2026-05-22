package com.napoleon.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class JwtProperties {

    private final String secret;
    private final long ttlMinutes;

    public JwtProperties(
            @Value("${security.jwt.secret}") String secret,
            @Value("${security.jwt.ttl-minutes}") long ttlMinutes
    ) {
        this.secret = secret;
        this.ttlMinutes = ttlMinutes;
    }

    public String secret() {
        return secret;
    }

    public long ttlMinutes() {
        return ttlMinutes;
    }
}