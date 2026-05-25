package com.napoleon.card.entity;

import jakarta.persistence.*;

import java.math.BigDecimal;

@Entity
@Table(name = "abilities")
public class AbilityEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "card_id", nullable = false)
    private Long cardId;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(length = 1000)
    private String description;

    @Column(name = "statistic_id", nullable = false)
    private Long statisticId;

    @Column(nullable = false, precision = 10, scale = 4)
    private BigDecimal value;

    @Column(precision = 5, scale = 4)
    private BigDecimal accuracy;

    @Column(name = "mana_cost")
    private Integer manaCost;

    @Column(name = "range_min", nullable = false)
    private Integer rangeMin;

    @Column(name = "range_max", nullable = false)
    private Integer rangeMax;

    @Column
    private Integer duration;

    @Column(name = "is_passive", nullable = false)
    private Boolean isPassive;

    protected AbilityEntity() {
    }

    public Long getId() {
        return id;
    }

    public Long getCardId() {
        return cardId;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public Long getStatisticId() {
        return statisticId;
    }

    public BigDecimal getValue() {
        return value;
    }

    public BigDecimal getAccuracy() {
        return accuracy;
    }

    public Integer getManaCost() {
        return manaCost;
    }

    public Integer getRangeMin() {
        return rangeMin;
    }

    public Integer getRangeMax() {
        return rangeMax;
    }

    public Integer getDuration() {
        return duration;
    }

    public Boolean getIsPassive() {
        return isPassive;
    }
}