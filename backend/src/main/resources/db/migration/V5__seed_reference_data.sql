INSERT INTO statistics (id, name, description, is_percentage) VALUES
(1, 'SALUD', 'Puntos de vida base', FALSE),
(2, 'ATAQUE', 'Estadística base de ataque', FALSE),
(3, 'DEFENSA', 'Estadística base de defensa', FALSE),
(4, 'DANO', 'Daño infligido por ataques o habilidades', FALSE),
(5, 'MOVIMIENTO', 'Casillas que puede moverse la unidad', FALSE),
(6, 'ESQUIVA', 'Probabilidad de esquivar un ataque', TRUE),
(7, 'PRECISION', 'Probabilidad de acertar un ataque', TRUE),
(8, 'CURACION', 'Cantidad de vida recuperada', FALSE);

INSERT INTO attack_types (id, name, description) VALUES
(1, 'CORTE', 'Ataque físico cortante'),
(2, 'PERFORANTE', 'Ataque físico perforante'),
(3, 'CONTUNDENTE', 'Ataque físico contundente'),
(4, 'FUEGO', 'Ataque elemental de fuego'),
(5, 'HIELO', 'Ataque elemental de hielo'),
(6, 'MAGIA', 'Ataque mágico');

INSERT INTO tile_types (id, name, description) VALUES
(1, 'LLANURA', 'Terreno estándar sin penalización'),
(2, 'BOSQUE', 'Terreno que mejora la defensa'),
(3, 'COLINA', 'Terreno elevado con ventaja táctica'),
(4, 'AGUA', 'Terreno que penaliza el movimiento');

INSERT INTO card_types (id, name, description, parent_type_id) VALUES
(1, 'MELE', 'Unidades de combate cercano', NULL),
(2, 'DISTANCIA', 'Unidades de combate a distancia', NULL),
(3, 'CABALLERIA', 'Unidades montadas rápidas', NULL),
(4, 'INFANTERIA', 'Unidades de infantería', NULL);

INSERT INTO status_effects (id, name, description, duration) VALUES
(1, 'QUEMADURA', 'Inflige daño con el tiempo', 2),
(2, 'LENTO', 'Reduce el movimiento temporalmente', 1),
(3, 'DEBILIDAD', 'Reduce el ataque temporalmente', 2);

INSERT INTO tile_modifiers (id, statistic_id, value) VALUES
(1, 3, 2.0000),   -- DEFENSA +2
(2, 5, -1.0000),  -- MOVIMIENTO -1
(3, 7, 0.1000);   -- PRECISION +10%

INSERT INTO tile_type_modifiers (tile_type_id, tile_modifier_id) VALUES
(2, 1), -- BOSQUE
(4, 2), -- AGUA
(3, 3); -- COLINA