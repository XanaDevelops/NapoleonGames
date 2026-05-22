package com.napoleon.card.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "card_types")
public class CardTypeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String name;

    protected CardTypeEntity() {
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }
}