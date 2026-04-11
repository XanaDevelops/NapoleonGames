CREATE TABLE user_maps (
    user_id BIGINT UNSIGNED NOT NULL,
    map_id BIGINT UNSIGNED NOT NULL,
    unlocked_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, map_id),
    CONSTRAINT fk_user_maps_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT fk_user_maps_map
        FOREIGN KEY (map_id) REFERENCES maps(id)
        ON DELETE CASCADE
        ON UPDATE RESTRICT
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

CREATE INDEX idx_user_maps_map_id ON user_maps(map_id);

CREATE TABLE user_cards (
    user_id BIGINT UNSIGNED NOT NULL,
    card_id BIGINT UNSIGNED NOT NULL,
    quantity INT NOT NULL,
    unlocked_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, card_id),
    CONSTRAINT fk_user_cards_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT fk_user_cards_card
        FOREIGN KEY (card_id) REFERENCES cards(id)
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT chk_user_cards_quantity CHECK (quantity >= 0)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

CREATE INDEX idx_user_cards_card_id ON user_cards(card_id);

CREATE TABLE armies (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    slot_number INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT uk_armies_user_slot UNIQUE (user_id, slot_number),
    CONSTRAINT chk_armies_slot_number CHECK (slot_number BETWEEN 1 AND 4),
    CONSTRAINT fk_armies_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE RESTRICT
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

CREATE INDEX idx_armies_user_id ON armies(user_id);

CREATE TABLE army_cards (
    army_id BIGINT UNSIGNED NOT NULL,
    card_id BIGINT UNSIGNED NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (army_id, card_id),
    CONSTRAINT fk_army_cards_army
        FOREIGN KEY (army_id) REFERENCES armies(id)
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT fk_army_cards_card
        FOREIGN KEY (card_id) REFERENCES cards(id)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,
    CONSTRAINT chk_army_cards_quantity CHECK (quantity > 0)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

CREATE INDEX idx_army_cards_card_id ON army_cards(card_id);