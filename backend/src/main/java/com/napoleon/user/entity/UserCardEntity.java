package com.napoleon.user.entity;

import jakarta.persistence.*;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.Objects;

@Entity
@Table(name = "user_cards")
public class UserCardEntity {

    @EmbeddedId
    private UserCardId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("userId")
    @JoinColumn(name = "user_id", nullable = false)
    private UserEntity user;

    @Column(nullable = false)
    private Integer quantity;

    @Column(name = "unlocked_at", nullable = false)
    private LocalDateTime unlockedAt;

    protected UserCardEntity() {
    }

    public UserCardId getId() {
        return id;
    }

    public UserEntity getUser() {
        return user;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public LocalDateTime getUnlockedAt() {
        return unlockedAt;
    }

    @Embeddable
    public static class UserCardId implements Serializable {

        @Column(name = "user_id")
        private Long userId;

        @Column(name = "card_id")
        private Long cardId;

        protected UserCardId() {
        }

        public Long getUserId() {
            return userId;
        }

        public Long getCardId() {
            return cardId;
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (!(o instanceof UserCardId that)) return false;
            return Objects.equals(userId, that.userId)
                    && Objects.equals(cardId, that.cardId);
        }

        @Override
        public int hashCode() {
            return Objects.hash(userId, cardId);
        }
    }
}