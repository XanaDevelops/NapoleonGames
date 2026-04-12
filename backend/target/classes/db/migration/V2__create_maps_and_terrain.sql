CREATE TABLE maps (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(500) NULL,
    size_x INT NOT NULL,
    size_y INT NOT NULL,
    image_path VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT uk_maps_name UNIQUE (name),
    CONSTRAINT chk_maps_size_x CHECK (size_x > 0),
    CONSTRAINT chk_maps_size_y CHECK (size_y > 0)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE tile_types (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255) NULL,
    PRIMARY KEY (id),
    CONSTRAINT uk_tile_types_name UNIQUE (name)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE statistics (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255) NULL,
    is_percentage BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (id),
    CONSTRAINT uk_statistics_name UNIQUE (name)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE tile_modifiers (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    statistic_id BIGINT UNSIGNED NOT NULL,
    value DECIMAL(10,4) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_tile_modifiers_statistic
        FOREIGN KEY (statistic_id) REFERENCES statistics(id)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

CREATE INDEX idx_tile_modifiers_statistic_id
    ON tile_modifiers(statistic_id);

CREATE TABLE tile_type_modifiers (
    tile_type_id BIGINT UNSIGNED NOT NULL,
    tile_modifier_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (tile_type_id, tile_modifier_id),
    CONSTRAINT fk_ttm_tile_type
        FOREIGN KEY (tile_type_id) REFERENCES tile_types(id)
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT fk_ttm_modifier
        FOREIGN KEY (tile_modifier_id) REFERENCES tile_modifiers(id)
        ON DELETE CASCADE
        ON UPDATE RESTRICT
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE tiles (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    map_id BIGINT UNSIGNED NOT NULL,
    tile_type_id BIGINT UNSIGNED NOT NULL,
    pos_x INT NOT NULL,
    pos_y INT NOT NULL,
    height INT NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    CONSTRAINT uk_tiles_map_position UNIQUE (map_id, pos_x, pos_y),
    CONSTRAINT fk_tiles_map
        FOREIGN KEY (map_id) REFERENCES maps(id)
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT fk_tiles_tile_type
        FOREIGN KEY (tile_type_id) REFERENCES tile_types(id)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

CREATE INDEX idx_tiles_map_id ON tiles(map_id);
CREATE INDEX idx_tiles_tile_type_id ON tiles(tile_type_id);