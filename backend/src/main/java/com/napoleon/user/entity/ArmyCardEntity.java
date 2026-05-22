package com.napoleon.user.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

import java.io.Serializable;
import java.util.Objects;

@Entity
@Table(name = "army_cards")
public class ArmyCardEntity {

    @EmbeddedId
    private ArmyCardId id;

    @Column(nullable = false)
    private Integer quantity;

    protected ArmyCardEntity() {
    }

    public ArmyCardEntity(Long armyId, Long cardId, Integer quantity) {
        if (quantity == null || quantity <= 0) {
            throw new IllegalArgumentException("Army card quantity must be greater than 0");
        }

        this.id = new ArmyCardId(armyId, cardId);
        this.quantity = quantity;
    }

    public ArmyCardId getId() {
        return id;
    }

    public Long getArmyId() {
        return id.getArmyId();
    }

    public Long getCardId() {
        return id.getCardId();
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void updateQuantity(Integer quantity) {
        if (quantity == null || quantity <= 0) {
            throw new IllegalArgumentException("Army card quantity must be greater than 0");
        }

        this.quantity = quantity;
    }

    @Embeddable
    public static class ArmyCardId implements Serializable {

        @Column(name = "army_id", nullable = false)
        private Long armyId;

        @Column(name = "card_id", nullable = false)
        private Long cardId;

        protected ArmyCardId() {
        }

        public ArmyCardId(Long armyId, Long cardId) {
            this.armyId = armyId;
            this.cardId = cardId;
        }

        public Long getArmyId() {
            return armyId;
        }

        public Long getCardId() {
            return cardId;
        }

        @Override
        public boolean equals(Object object) {
            if (this == object) {
                return true;
            }

            if (!(object instanceof ArmyCardId that)) {
                return false;
            }

            return Objects.equals(armyId, that.armyId)
                    && Objects.equals(cardId, that.cardId);
        }

        @Override
        public int hashCode() {
            return Objects.hash(armyId, cardId);
        }
    }
}