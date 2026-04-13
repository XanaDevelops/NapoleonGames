package com.napoleon.card.entity;

import jakarta.persistence.*;

import java.io.Serializable;
import java.util.Objects;

@Entity
@Table(name = "card_card_types")
public class CardCardTypeEntity {

    @EmbeddedId
    private CardCardTypeId id;

    protected CardCardTypeEntity() {
    }

    public CardCardTypeId getId() {
        return id;
    }

    @Embeddable
    public static class CardCardTypeId implements Serializable {

        @Column(name = "card_id")
        private Long cardId;

        @Column(name = "card_type_id")
        private Long cardTypeId;

        protected CardCardTypeId() {
        }

        public Long getCardId() {
            return cardId;
        }

        public Long getCardTypeId() {
            return cardTypeId;
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (!(o instanceof CardCardTypeId that)) return false;
            return Objects.equals(cardId, that.cardId)
                    && Objects.equals(cardTypeId, that.cardTypeId);
        }

        @Override
        public int hashCode() {
            return Objects.hash(cardId, cardTypeId);
        }
    }
}