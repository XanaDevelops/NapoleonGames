# Estructura del Projecte

Al repositori principal es troben les dues carpetes fonamentals per poder executar el projecte:

- **`godot/`** — tot el codi pertinent al client del joc
- **`backend/`** — tot el codi referent al servidor

A continuació es detalla l'estructura de cada carpeta amb una breu explicació del seu contingut i, just a sota, trobareu totes les instruccions necessàries per executar cadascuna de les parts.

---

## 1. Client del joc (Godot)

### 1.1 Estructura

```
godot/
├── addons/                     # Plugins i extensions de l'editor (ex. GUT per a tests)
├── assets/                     # Tots els recursos multimèdia del projecte
├── resources/                  # Dades de joc serialitzades (.tres) — el "game data" del projecte
│   ├── alter_states/           # Estats alterats que afecten les unitats (cremat, verí...)
│   ├── animaciones/            # Dades d'animacions VFX per tipus d'efecte
│   ├── armies/                 # Definició d'exèrcits jugables
│   ├── attack_types/           # Tipus d'atac: físic, foc, verí, etc.
│   ├── card_army_groups/       # Grups de cartes que componen un exèrcit
│   ├── card_types/             # Tipus de carta (cos a cos, distància...)
│   ├── cards/                  # Cartes individuals amb les seves estadístiques i habilitats
│   ├── habilities/             # Habilitats actives i passives de les unitats
│   ├── maps/                   # Mapes jugables
│   ├── shaders/                # Shaders GLSL per a efectes visuals (hex, verí, curació...)
│   ├── stat_datas/             # Definicions d'estadístiques (vida, velocitat, atac, alçada)
│   ├── tile_mods/              # Modificadors aplicables a caselles del mapa
│   ├── tile_types/             # Tipus de terreny (gespa, muntanya, aigua...)
│   ├── tiles/                  # Instàncies de caselles de mapa (~600 hexàgons)
│   └── users/                  # Perfils d'usuari serialitzats
├── scenes/                     # Escenes (.tscn + .gd) — cada pantalla i component visual
│   ├── ingame/                 # Escenes actives durant la partida (mapa, torns, panells, VFX)
│   └── server/                 # Escenes del procés del servidor headless (peers, partides actives)
├── scripts/                    # Lògica pura del joc, desacoblada de les escenes
│   ├── API/                    # Adaptador HTTP per a la comunicació amb el backend REST
│   ├── game/                   # Nucli de la partida: mapa, unitats, torns, accions
│   │   └── turn_actions/       # Accions de torn com a patró Command (moure, desplegar, habilitat, passar)
│   ├── managers/               # Singletons/autoloads: àudio, IU, sessió d'usuari, ajustos
│   ├── online/                 # Capa de xarxa per al multijugador (client, servidor, paquets)
│   │   └── packets/            # Paquets de xarxa tipats (ping, lobby, torn, emparellament...)
│   ├── resources/              # Classes de GDScript que defineixen els tipus de recurs del joc
│   ├── ui/                     # Scripts de components d'IU reutilitzables (botons, panells, formularis)
│   ├── utils/                  # Utilitats genèriques: cua de prioritat, rutes d'escenes
│   └── editor/                 # Scripts d'eines d'editor (només en desenvolupament, no en temps d'execució)
├── test/                       # Suite de tests — framework GUT
│   ├── unit/                   # Tests unitaris: habilitats, mapa, torns, xarxa, replay
│   ├── integration/            # Tests d'integració: càrrega d'escenes i recursos complets
│   └── scenes/                 # Tests que instancien escenes reals (partida, desplegament, exèrcits)
├── test_res/                   # Recursos .tres de prova (mapes, cartes, habilitats, torns)
│   └── turns/                  # Seqüències de torns desades per a tests de replay
├── test_backend/               # Tests de comunicació contra l'API REST
└── server_placeholder_test/    # Servidor HTTP mock en Python per desenvolupar sense backend
```

### 1.2 Execució

#### Mode local

1. **Descàrrega de l'editor** — descarrega la versió de Godot per al teu sistema operatiu des de l'arxiu oficial: https://godotengine.org/download/archive/4.6.1-stable/
2. **Descompressió i execució** — descomprimeix el fitxer ZIP i executa l'aplicació (ex. `Godot_v4.6.1-stable_win64.exe`)
3. **Importació del projecte** — obre Godot, fes clic a *Importar* i selecciona la carpeta `godot/` del repositori
4. **Execució del joc** — prem el botó de reproducció (**Play** / `F5`) a la part superior dreta

**Configuració de la partida:** al menú principal, selecciona *Joc Local → JvsJ* i segueix la seqüència per escollir mapa i enemic. L'enemic ve preseleccionat per defecte amb la primera opció de la llista i el seu exèrcit principal.

**Edició d'exèrcits:** accedeix a la secció *Cuartel* des de la pantalla principal. A la part superior trobaràs una icona per obrir el menú d'usuaris, des d'on podràs seleccionar i editar l'exèrcit.

---

#### Mode en línia

El mode en línia requereix executar **tres instàncies simultànies**: un servidor i dos clients.

**1. Configura les instàncies**

Des del menú superior de l'editor: `Debug → Run Multiple Instances`. Activa *Enable Multiple Instances* i estableix el nombre a **3**. A continuació, habilita *Override Main Run Args* per a una de les instàncies i introdueix l'argument `--server` — aquesta instància actuarà com a servidor.

**2. Executa el projecte**

Prem `F5`. S'obriran les tres finestres simultàniament amb la configuració establerta.

**3. Inicia una partida en línia**

Des de les dues instàncies de client, accedeix al mode en línia i emparella les sessions buscant partida aleatòria o convidant un amic. Cada instància ha d'iniciar sessió amb un **usuari diferent**.

---

## 2. Backend (Spring Boot)

### 2.1 Estructura

```
backend/
├── .gitignore
├── Dockerfile                  # Configuració per crear la imatge del contenidor Docker
├── pom.xml                     # Dependències (Spring, MySQL, Flyway, JWT) i build de Maven
├── README.md
└── src/
    ├── main/
    │   ├── java/com/napoleon/
    │   │   ├── Application.java
    │   │   ├── auth/           # Autenticació i seguretat
    │   │   │   ├── controller/ # Endpoints REST (/api/auth/login, /signin)
    │   │   │   ├── dto/
    │   │   │   ├── security/   # Filtres de Spring Security (interceptor JWT)
    │   │   │   ├── service/    # Lògica de negoci (login, registre)
    │   │   │   └── token/      # Generació i validació de tokens JWT
    │   │   ├── card/           # Catàleg de cartes, habilitats i combat
    │   │   │   ├── controller/ # Endpoints REST (/api/card)
    │   │   │   ├── dto/
    │   │   │   ├── entity/     # Models JPA (Card, Ability, AttackType...)
    │   │   │   ├── repository/
    │   │   │   └── service/
    │   │   ├── common/
    │   │   │   ├── dto/        # DTOs genèrics (respostes d'error estàndard)
    │   │   │   └── exception/  # GlobalExceptionHandler
    │   │   ├── config/         # Configuració global (seguretat web, propietats JWT)
    │   │   └── user/           # Gestió d'usuaris, progrés i exèrcits
    │   │       ├── controller/ # Endpoints REST (/api/user, /api/army)
    │   │       ├── dto/
    │   │       ├── entity/     # Models relacionals (User, Army, UserCard, UserMap...)
    │   │       ├── repository/
    │   │       └── service/
    │   └── resources/
    │       ├── application.yml # Propietats (MySQL, Hibernate, JWT)
    │       └── db/migration/   # Scripts SQL de Flyway (V1–V6)
    └── test/
        └── java/com/napoleon/
            └── ApplicationTest.java
```

### 2.2 Execució

Requereix **Docker** instal·lat (Docker Desktop o WSL2 amb Ubuntu).

#### Opció 1 — Windows

```bash
# Comprova que Docker està en execució
docker ps

# Construeix i aixeca tots els contenidors
docker compose up --build
```

Quan aparegui `Started Application` al terminal, l'API estarà disponible al port indicat.

#### Opció 2 — WSL (Ubuntu)

```bash
# Obre WSL i accedeix a la carpeta del projecte
wsl

# Comprova Docker; si no està actiu:
sudo service docker start

# Construeix i aixeca els contenidors
docker compose up --build
```

L'API quedarà disponible al port `:8080`.

---

### Aturar el backend

| Acció | Comanda |
|---|---|
| Aturar els contenidors | `Ctrl + C` o `docker compose down` |
| Aturar i eliminar xarxes | `docker compose down` |
| Reiniciar la BD des de zero | `docker compose down -v` ⚠️ elimina tots els volums |
