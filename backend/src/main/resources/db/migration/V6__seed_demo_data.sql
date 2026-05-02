-- Usuarios demo
-- password = 1234 (bcrypt)
INSERT INTO users (
    id,
    username,
    email,
    password_hash,
    display_name,
    profile_img,
    role,
    created_at,
    updated_at
) VALUES
(
    1,
    'jose',
    'jose@test.com',
    '$2a$10$HfZkm9tB5QrQjWYg9kZ6Ne9lZV/fF5n.cNKN4GDBD4DovF0h.EfbW',
    'José',
    '/profiles/jose.png',
    'PLAYER',
    NOW(),
    NOW()
),
(
    2,
    'pere',
    'pere@test.com',
    '$2a$10$HfZkm9tB5QrQjWYg9kZ6Ne9lZV/fF5n.cNKN4GDBD4DovF0h.EfbW',
    'Pere',
    '/profiles/pere.png',
    'PLAYER',
    NOW(),
    NOW()
);

-- Mapas
INSERT INTO maps (id, name, description, size_x, size_y, image_path, created_at) VALUES
(1, 'Llanuras Verdes', 'Mapa equilibrado para principiantes', 4, 4, '/maps/llanuras.png', NOW()),
(2, 'Valle de Piedra', 'Mapa con zonas elevadas y bosques', 4, 4, '/maps/valle.png', NOW());

-- Cartas
INSERT INTO cards (
    id, name, description, image_path,
    hp, attack, defense, damage, movement, dodge,
    weight, mana, created_at
) VALUES
(
    1,
    'Espadachin',
    'Unidad básica de combate cercano',
    '/cards/espadachin.png',
    100, 12, 8, 15, 3, 0.10,
    2, NULL, NOW()
),
(
    2,
    'Arquero',
    'Unidad de ataque a distancia precisa',
    '/cards/arquero.png',
    70, 10, 4, 12, 3, 0.15,
    2, NULL, NOW()
),
(
    3,
    'Caballero',
    'Unidad pesada de caballería',
    '/cards/caballero.png',
    120, 16, 12, 20, 4, 0.05,
    4, NULL, NOW()
);

-- Tipos de carta
INSERT INTO card_card_types (card_id, card_type_id) VALUES
(1, 1), (1, 4),
(2, 2), (2, 4),
(3, 1), (3, 3);

-- Resistencias
INSERT INTO card_resistances (card_id, attack_type_id, value) VALUES
(1, 1, 0.10),
(1, 2, 0.05),
(2, 2, 0.10),
(3, 1, 0.20),
(3, 3, 0.15);

-- Habilidades
INSERT INTO abilities (
    id, card_id, name, description,
    statistic_id, value, accuracy,
    mana_cost, range_min, range_max,
    duration, is_passive
) VALUES
(
    1,
    1,
    'Golpe de espada',
    'Ataque cuerpo a cuerpo',
    4,
    15,
    0.90,
    NULL,
    1,
    1,
    NULL,
    FALSE
),
(
    2,
    2,
    'Disparo de flecha',
    'Ataque a distancia',
    4,
    12,
    0.85,
    NULL,
    2,
    4,
    NULL,
    FALSE
),
(
    3,
    3,
    'Carga',
    'Ataque potente de caballería',
    4,
    20,
    0.80,
    NULL,
    1,
    2,
    NULL,
    FALSE
),
(
    4,
    2,
    'Flecha incendiaria',
    'Ataque con posibilidad de quemar',
    4,
    10,
    0.75,
    2,
    2,
    4,
    2,
    FALSE
);

INSERT INTO ability_status_effects (ability_id, status_effect_id) VALUES
(4, 1);

-- Mapas desbloqueados
INSERT INTO user_maps (user_id, map_id, unlocked_at) VALUES
(1, 1, NOW()),
(1, 2, NOW()),
(2, 1, NOW());

-- Cartas disponibles
INSERT INTO user_cards (user_id, card_id, quantity, unlocked_at) VALUES
(1, 1, 4, NOW()),
(1, 2, 3, NOW()),
(1, 3, 2, NOW()),
(2, 1, 2, NOW()),
(2, 2, 4, NOW());

-- Ejércitos<
INSERT INTO armies (
    id, user_id, slot_number, name,
    is_active, created_at, updated_at
) VALUES
(1, 1, 1, 'Ejercito Inicial', TRUE, NOW(), NOW()),
(2, 1, 2, 'Ejercito Distancia', FALSE, NOW(), NOW()),
(3, 2, 1, 'Ejercito Principal', TRUE, NOW(), NOW());

INSERT INTO army_cards (army_id, card_id, quantity) VALUES
(1, 1, 2),
(1, 2, 1),
(2, 2, 2),
(2, 3, 1),
(3, 1, 1),
(3, 2, 2);