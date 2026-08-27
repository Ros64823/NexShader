# NexShader

NexShader es un shader pack completo para Minecraft Java Edition con Iris Shaders. Está construido desde cero para ofrecer una mejora clara sobre vanilla sin abandonar el estilo de Minecraft: sombras reales, iluminación natural, agua mejorada, cielo atmosférico, niebla, SSAO, reflejos escalables, bloom y tonemapping.

## Instalación

1. Instala Minecraft Java Edition con Iris Shaders compatible con paquetes estilo OptiFine/Iris.
2. Copia `NexShader.zip` en la carpeta `shaderpacks` de tu instalación de Minecraft.
3. En el juego, abre **Opciones > Vídeo > Shader Packs** y selecciona **NexShader**.

## Compatibilidad

- Objetivo principal: Iris Shaders para Minecraft Java Edition moderno.
- El pack usa programas estándar de shader packs: `shadow`, `gbuffers_*`, `composite` y `final`.
- Las opciones y perfiles se definen en `shaders/shaders.properties` para aparecer en el menú de Iris cuando la versión instalada soporte esas opciones.
- `pack.mcmeta` usa `pack_format` moderno y puede ajustarse si se instala en una versión de Minecraft que requiera otro valor.

## Perfiles de calidad

NexShader incluye exactamente siete perfiles reales:

- **PATATA**: sombras 512, sin SSAO, sin SSR, sin volumétricos, sin bloom, agua simple, fog y cielo básicos mejorados.
- **MUY BAJO**: sombras 768, SSAO mínimo, agua simplificada, cielo/fog mejorados.
- **BAJO**: sombras 1024, SSAO ligero, bloom ligero, reflejos simplificados, volumétrico mínimo.
- **MEDIO**: sombras 1536, SSAO medio, bloom, agua con reflejos, volumétricos ligeros.
- **NORMAL**: perfil recomendado, sombras 2048, SSAO bueno, SSR moderado, bloom y post-procesado completo razonable.
- **ALTO**: sombras 3072, filtrado avanzado, SSAO alto, SSR mejorado, volumétricos moderados, bloom avanzado.
- **MUY ALTO**: sombras 4096, más muestras, SSAO/SSR/volumétricos de mayor calidad, cielo y agua avanzados.

## Características

- Shadow pass real y uso del shadow map en iluminación.
- Iluminación solar y ambiental basada en normales, hora del día, lluvia y lightmap por píxel (luz de bloques tipo antorcha y luz de cielo por superficie).
- SSAO escalable por perfil.
- Agua con transparencia, normal animada, color por profundidad aproximada, fresnel y reflejos.
- Cielo con gradiente atmosférico, transición día/noche, amanecer/atardecer y estrellas.
- Fog por distancia, ambiente, lluvia y agua.
- Reflejos en espacio de pantalla aproximados para perfiles medios/altos.
- God rays/volumétricos limitados por pasos para evitar costes excesivos.
- Bloom eficiente de pocas muestras.
- Tonemapping, exposure, contraste, saturación, vibrance y color grading natural.
- Opciones extra para intensidad de sombras, bias, fuerza/radio de SSAO, fuerza de reflejos, niebla, bloom, nubes y agua.

## Optimización para Intel UHD

El perfil recomendado para Intel UHD Graphics en un Intel Core i3-N305 es **PATATA**, **MUY BAJO**, **BAJO** o **MEDIO** según resolución y distancia de renderizado. El pack evita bucles largos y usa recuentos de muestras moderados en perfiles bajos.

Recomendaciones:

- Empieza en **BAJO** a 1080p.
- Reduce distancia de renderizado antes de subir SSR o volumétricos.
- Usa **NORMAL** solo si la escena mantiene FPS estables.
- Mantén `SSR_SAMPLES`, `SSAO_SAMPLES` y `VOLUMETRIC_STEPS` bajos en GPUs integradas.

## Configuración

Las opciones principales expuestas son: `QUALITY_PROFILE`, `SHADOW_RESOLUTION`, `SHADOW_SAMPLES`, `SHADOW_FILTER`, `SHADOW_STRENGTH`, `SHADOW_BIAS`, `SSAO_ENABLED`, `SSAO_SAMPLES`, `SSAO_STRENGTH`, `SSAO_RADIUS`, `SSR_ENABLED`, `SSR_SAMPLES`, `REFLECTION_STRENGTH`, `VOLUMETRIC_ENABLED`, `VOLUMETRIC_STEPS`, `VOLUMETRIC_STRENGTH`, `BLOOM_ENABLED`, `BLOOM_QUALITY`, `BLOOM_STRENGTH`, `BLOOM_THRESHOLD`, `WATER_QUALITY`, `WATER_OPACITY`, `WATER_WAVE_STRENGTH`, `WATER_TINT_STRENGTH`, `REFLECTION_QUALITY`, `CLOUD_QUALITY`, `CLOUD_STRENGTH`, `FOG_QUALITY`, `FOG_DENSITY`, `SKY_QUALITY`, `LIGHTING_QUALITY`, `POST_PROCESSING_QUALITY`, `EXPOSURE`, `CONTRAST`, `SATURATION`, `VIBRANCE` y `GAMMA`.

## Depuración del oscurecimiento extremo (causa raíz)

Diagnóstico realizado ejecutando el GLSL real del pack de forma headless con `tools/lighting_harness.py` (moderngl + llvmpipe), midiendo la luminancia final por componente en escenarios controlados.

**CAUSA 1 — Iluminación dependiente de la cámara.** `sunPosition` es un vector en *view space* (rota con la cámara). `nexDayFactor`, `sunUp`, el cielo y los volumétricos leían `sunPosition.y` directamente, así que toda la iluminación global cambiaba con la orientación de la cámara.
**EVIDENCIA:** con el sol fijo a 65°, el mismo píxel de césped soleado pasaba de luminancia final 0.664 (mirando al horizonte) a 0.392 (mirando al suelo/cielo, pitch ±80°): −41% solo por girar la cámara. Al caminar por un bosque mirando al suelo, toda la escena se oscurecía.
**CORRECCIÓN:** el sol se transforma a espacio mundo (`mat3(gbufferModelViewInverse) * sunPosition`) en `nexSunElevation()`, y todos los factores día/noche, cielo, estrellas y volumétricos usan esa elevación. El cielo (`gbuffers_skybasic`) también pasa a direcciones en espacio mundo.
**EFECTO:** la luminancia final del mismo píxel varía menos de 0.3% en todo el rango de pitch/yaw (antes 41%).

**CAUSA 2 — Espacios de color mezclados (doble oscurecimiento).** La iluminación multiplicaba el albedo sRGB (no lineal), el resultado pasaba por una curva ACES pensada para entrada lineal, y el valor final se mostraba **sin** codificación sRGB de salida. Mostrar luz lineal sin `pow(1/2.2)` hunde todos los medios tonos: una sombra con luz lineal 0.1 se mostraba como 0.1 en pantalla en lugar de ~0.35. Además, `colortex0` era RGBA8, cuantizando las zonas oscuras.
**EVIDENCIA:** un tronco lateral en sombra mostraba luminancia 0.124 y una cueva 0.087 (casi negro absoluto) pese a que la luz ambiental calculada no era cero.
**CORRECCIÓN:** pipeline lineal completo: el albedo se linealiza (`nexSrgbToLinear`) antes de iluminar, la luz se acumula en HDR lineal (`colortex0` ahora RGBA16F), y `nexTonemap` aplica ACES y después codifica a sRGB (`nexLinearToSrgb`). Saturación/contraste operan en espacio de display.
**EFECTO:** sombra de bosque denso 0.27 → 0.42 de luminancia mostrada conservando textura, sin subir el brillo global ni debilitar las sombras (el sol directo mantiene ~1.8:1 sobre la sombra).

Complementos: adaptación nocturna fija y suave basada solo en la elevación solar (nunca en el contenido de pantalla — no existe autoexposición), y modos `NEX_DEBUG` 1–9 (shadow, direct, ambient, SSAO, normals, depth, lightmap, final, heatmap de luminancia) para diagnóstico in-game.

## Limitaciones

- SSR es una aproximación barata y no sustituye trazado físico completo.
- No hay opción de render scale: ni OptiFine ni Iris exponen una forma estándar de reducir la resolución completa de renderizado desde un shader pack, así que los perfiles bajos escalan reduciendo muestras, pasos y resolución de sombras.
- Las nubes se mantienen compatibles con el pipeline vanilla/Iris y se mejoran principalmente mediante cielo, fog y color.
- La validación final debe hacerse dentro de Minecraft/Iris porque la disponibilidad exacta de uniforms puede variar entre versiones.
- Este repositorio no incluye `NexShader.zip`; si quieres empaquetarlo manualmente, comprime directamente `pack.mcmeta`, `README.md` y `shaders/` sin una carpeta adicional por encima.
