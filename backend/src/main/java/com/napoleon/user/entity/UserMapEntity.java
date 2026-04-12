package com.napoleon.user.entity;

import jakarta.persistence.*;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.Objects;

@Entity
@Table(name = "user_maps")
public class UserMapEntity {

    @EmbeddedId
    private UserMapId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("userId")
    @JoinColumn(name = "user_id", nullable = false)
    private UserEntity user;

    @Column(name = "unlocked_at", nullable = false)
    private LocalDateTime unlockedAt;

    protected UserMapEntity() {
    }

    public UserMapId getId() {
        return id;
    }

    public UserEntity getUser() {
        return user;
    }

    public LocalDateTime getUnlockedAt() {
        return unlockedAt;
    }

    @Embeddable
    public static class UserMapId implements Serializable {

        @Column(name = "user_id")
        private Long userId;

        @Column(name = "map_id")
        private Long mapId;

        protected UserMapId() {
        }

        public Long getUserId() {
            return userId;
        }

        public Long getMapId() {
            return mapId;
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (!(o instanceof UserMapId that)) return false;
            return Objects.equals(userId, that.userId)
                    && Objects.equals(mapId, that.mapId);
        }

        @Override
        public int hashCode() {
            return Objects.hash(userId, mapId);
        }
    }
}