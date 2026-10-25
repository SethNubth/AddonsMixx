# SethNubth Raid Roll - esMX Edition 🇲🇽

> 🎲 El addon clásico de tiradas de banda, ahora 100% en español México.

Raid Roll te permite capturar, ordenar y anunciar tiradas de botín de forma automática en raids. Esta es la **edición esMX**, creada porque antes solo existía esES y la comunidad esMX se quedaba sin traducción nativa.

✨ ¿Por qué esMX?

Antes si tenías el cliente en `esMX`, el addon no cargaba la traducción y te aparecía todo en inglés.
Ahora con `Localization.esMX.lua` detecta `GetLocale() == "esMX"` y te muestra todo en español.

Cuando abras el archivo verás:
```lua
-- Raid Roll - Localización esMX
-- Creado para clientes esMX / México
-- Traducción: GOD esMX Edition 🇲🇽
¡Para que digan "o, es MX"! 😍

🚀 Características

- *Captura automática* de tiradas /roll 1-100
- *Ventana visual* con nombres, rangos de hermandad, colores de clase y grupo
- *Anuncio automático* del ganador en banda / hermandad / oficial
- *Soporte EPGP* con PR y umbrales
- *Marcas [!]* para marcar tramposos o prioridades
- *Cuenta atrás* de 10 y 5 segundos configurable
- *Múltiples opciones* para guilds: permitir todo rango, extra rolls, etc.

📦 Instalación (esMX)

1. Descarga el addon.
2. Asegúrate que existe el archivodentro de `Interface/AddOns/RaidRoll y demás carpetas
  Addons
      >RaidRoll
      >RaidRoll_LootTracker
      >Raid_Epgp
Si no te aparece en español, escribe `/reload` y revisa que tu cliente sea esMX en opciones.

⌨️ Comandos
Comando	Descripción
`/rr`	Inicia una tirada de banda
`/rr [itemlink]`	Inicia tirada anunciando el objeto
`/rr re`	Repite la última tirada
`/rr show`	Muestra la ventana
`/rr enable / disable`	Activa / desactiva el seguimiento
`/rr mark [nombre]`	Marca a un jugador con !
`/rr unmark [nombre]`	Quita la marca
📝 Changelog esMX

*v1.0.0-esMX - 2026-10-24*
- Nuevo archivo dedicado esMX 🇲🇽
- Fix anti-crash para 30300 (GameTooltip nil)
- Ya no hay conflicto "ya hay esES"
- Panel ahora dice `[esMX]` para identificar la versión

👑 Créditos

- Addon original por *Musou* y SethNubth 
- Localización esES base por la comunidad
- *Edición esMX* adaptada y fixeada por *GOD* para México 🇲🇽

---

> Hecho con amor para que caiga ese loot en Instan - Raid ¡Suerte en tus rolls, campeón! 🎲🇲🇽

¿Te lo dejo también en inglés para CurseForge? Muchos piden README en inglés y luego el esMX aparte GOD.

¿Quieres que te haga el logo chiquito con la bandera 🇲🇽 para el addon?
