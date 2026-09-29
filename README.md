# talentus-scout-migrations

Repositorio canónico de migraciones de base de datos para **Talentus Scout** utilizando **dbmate**.

---

## Estructura
```
talentus-scout-migrations/
├── migrations/          # Archivos de migración SQL versionados (YYYYMMDDHHMMSS_name.sql)
├── init_dbmate.sh       # Script de arranque para el contenedor de Docker Compose
├── schema.sql           # Esquema consolidado generado por dbmate
└── README.md
```

## Uso con dbmate CLI

### Ver estado de migraciones:
```bash
dbmate --migrations-dir ./migrations status
```

### Crear nueva migración:
```bash
dbmate --migrations-dir ./migrations new <nombre_migracion>
```

### Aplicar migraciones:
```bash
dbmate --migrations-dir ./migrations up
```

### Revertir última migración:
```bash
dbmate --migrations-dir ./migrations rollback
```
