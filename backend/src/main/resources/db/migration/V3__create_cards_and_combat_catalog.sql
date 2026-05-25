CREATE TABLE attack_types (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255) NULL,
    PRIMARY KEY (id),
    CONSTRAINT uk_attack_types_name UNIQUE (name)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE card_types (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255) NULL,
    parent_type_id BIGINT UNSIGNED NULL,
    PRIMARY KEY (id),
    CONSTRAINT uk_card_types_name UNIQUE (name),
    CONSTRAINT fk_card_types_parent
        FOREIGN KEY (parent_type_id) REFERENCES card_types(id)
        ON DELETE SET NULL
        ON UPDATE RESTRICT
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

CREATE INDEX idx_card_types_parent_type_id
    ON card_types(parent_type_id);

CREATE TABLE status_effects (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255) NULL,
    duration INT NULL,
    PRIMARY KEY (id),
    CONSTRAINT uk_status_effects_name UNIQUE (name),
    CONSTRAINT chk_status_effects_duration CHECK (duration IS NULL OR duration >= 0)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE cards (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(1000) NULL,
    image_path VARCHAR(255) NULL,
    hp INT NOT NULL,
    attack INT NOT NULL,
    defense INT NOT NULL,
    damage INT NOT NULL,
    movement INT NOT NULL,
    dodge DECIMAL(5,4) NOT NULL,
    weight INT NOT NULL,
    mana INT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT uk_cards_name UNIQUE (name),
    CONSTRAINT chk_cards_hp CHECK (hp > 0),
    CONSTRAINT chk_cards_attack CHECK (attack >= 0),
    CONSTRAINT chk_cards_defense CHECK (defense >= 0),
    CONSTRAINT chk_cards_damage CHECK (damage >= 0),
    CONSTRAINT chk_cards_movement CHECK (movement >= 0),
    CONSTRAINT chk_cards_dodge CHECK (dodge >= 0 AND dodge <= 1),
    CONSTRAINT chk_cards_weight CHECK (weight > 0),
    CONSTRAINT chk_cards_mana CHECK (mana IS NULL OR mana >= 0)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE abilities (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    card_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(1000) NULL,
    statistic_id BIGINT UNSIGNED NOT NULL,
    value DECIMAL(10,4) NOT NULL,
    accuracy DECIMAL(5,4) NULL,
    mana_cost INT NULL,
    range_min INT NOT NULL DEFAULT 0,
    range_max INT NOT NULL DEFAULT 0,
    duration INT NULL,
    is_passive BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (id),
    CONSTRAINT fk_abilities_card
        FOREIGN KEY (card_id) REFERENCES cards(id)
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT fk_abilities_statistic
        FOREIGN KEY (statistic_id) REFERENCES statistics(id)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,
    CONSTRAINT chk_abilities_accuracy CHECK (accuracy IS NULL OR (accuracy >= 0 AND accuracy <= 1)),
    CONSTRAINT chk_abilities_mana_cost CHECK (mana_cost IS NULL OR mana_cost >= 0),
    CONSTRAINT chk_abilities_range_min CHECK (range_min >= 0),
    CONSTRAINT chk_abilities_range_max CHECK (range_max >= range_min),
    CONSTRAINT chk_abilities_duration CHECK (duration IS NULL OR duration >= 0)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

CREATE INDEX idx_abilities_card_id ON abilities(card_id);
CREATE INDEX idx_abilities_statistic_id ON abilities(statistic_id);

CREATE TABLE card_card_types (
    card_id BIGINT UNSIGNED NOT NULL,
    card_type_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (card_id, card_type_id),
    CONSTRAINT fk_cct_card
        FOREIGN KEY (card_id) REFERENCES cards(id)
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT fk_cct_card_type
        FOREIGN KEY (card_type_id) REFERENCES card_types(id)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE card_resistances (
    card_id BIGINT UNSIGNED NOT NULL,
    attack_type_id BIGINT UNSIGNED NOT NULL,
    value DECIMAL(10,4) NOT NULL,
    PRIMARY KEY (card_id, attack_type_id),
    CONSTRAINT fk_card_resistances_card
        FOREIGN KEY (card_id) REFERENCES cards(id)
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT fk_card_resistances_attack_type
        FOREIGN KEY (attack_type_id) REFERENCES attack_types(id)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

CREATE INDEX idx_card_resistances_attack_type_id
    ON card_resistances(attack_type_id);

CREATE TABLE ability_status_effects (
    ability_id BIGINT UNSIGNED NOT NULL,
    status_effect_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (ability_id, status_effect_id),
    CONSTRAINT fk_ase_ability
        FOREIGN KEY (ability_id) REFERENCES abilities(id)
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT fk_ase_status_effect
        FOREIGN KEY (status_effect_id) REFERENCES status_effects(id)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;