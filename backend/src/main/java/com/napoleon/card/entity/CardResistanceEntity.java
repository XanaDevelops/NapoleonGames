package com.napoleon.card.entity;

import jakarta.persistence.*;

import java.io.Serializable;
import java.math.BigDecimal;

@Entity
@Table(name = "card_resistances")
public class CardResistanceEntity {

    @EmbeddedId
    private CardResistanceId id;

    @Column(nullable = false, precision = 10, scale=4)
    private BigDecimal value;

    protected CardResistanceEntity() {
    }

    public CardResistanceId getId() {
        return id;
    }

    public BigDecimal getValue() {
        return value;
    }

    @Embeddable
    public static class CardResistanceId implements Serializable {

        @Column(name = "card_id")
        private Long cardId;

        @Column(name = "attack_type_id")
        private Long attackTypeId;

        protected CardResistanceId() {
        }

        public Long getCardId() {
            return cardId;
        }

        public Long getAttackTypeId() {
            return attackTypeId;
        }
    }
}