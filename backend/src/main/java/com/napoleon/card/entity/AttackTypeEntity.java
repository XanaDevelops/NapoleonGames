package com.napoleon.card.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "attack_types")
public class AttackTypeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String name;

    protected AttackTypeEntity() {
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }
}