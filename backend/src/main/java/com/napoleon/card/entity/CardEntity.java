package com.napoleon.card.entity;

import jakarta.persistence.*;

import java.math.BigDecimal;

@Entity
@Table(name = "cards")
public class CardEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(length = 1000)
    private String description;

    @Column(name = "image_path", length = 255)
    private String imagePath;

    @Column(nullable = false)
    private Integer hp;

    @Column(nullable = false)
    private Integer attack;

    @Column(nullable = false)
    private Integer defense;

    @Column(nullable = false)
    private Integer damage;

    @Column(nullable = false)
    private Integer movement;

    @Column(nullable = false, precision = 5, scale = 4)
    private BigDecimal dodge;

    @Column(nullable = false)
    private Integer weight;

    @Column
    private Integer mana;

    protected CardEntity() {
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public String getImagePath() {
        return imagePath;
    }

    public Integer getHp() {
        return hp;
    }

    public Integer getAttack() {
        return attack;
    }

    public Integer getDefense() {
        return defense;
    }

    public Integer getDamage() {
        return damage;
    }

    public Integer getMovement() {
        return movement;
    }

    public BigDecimal getDodge() {
        return dodge;
    }

    public Integer getWeight() {
        return weight;
    }

    public Integer getMana() {
        return mana;
    }

    public void update(
            String name,
            String description,
            Integer hp,
            Integer attack,
            Integer defense,
            Integer damage,
            Integer movement,
            BigDecimal dodge,
            Integer weight,
            Integer mana
    ) {
        if (name != null && !name.isBlank()) {
            this.name = name;
        }

        if (description != null) {
            this.description = description;
        }

        if (hp != null) {
            this.hp = hp;
        }

        if (attack != null) {
            this.attack = attack;
        }

        if (defense != null) {
            this.defense = defense;
        }

        if (damage != null) {
            this.damage = damage;
        }

        if (movement != null) {
            this.movement = movement;
        }

        if (dodge != null) {
            this.dodge = dodge;
        }

        if (weight != null) {
            this.weight = weight;
        }

        this.mana = mana;
    }
}