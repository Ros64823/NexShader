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

## Limitaciones

- SSR es una aproximación barata y no sustituye trazado físico completo.
- No hay opción de render scale: ni OptiFine ni Iris exponen una forma estándar de reducir la resolución completa de renderizado desde un shader pack, así que los perfiles bajos escalan reduciendo muestras, pasos y resolución de sombras.
- Las nubes se mantienen compatibles con el pipeline vanilla/Iris y se mejoran principalmente mediante cielo, fog y color.
- La validación final debe hacerse dentro de Minecraft/Iris porque la disponibilidad exacta de uniforms puede variar entre versiones.
- Este repositorio no incluye `NexShader.zip`; si quieres empaquetarlo manualmente, comprime directamente `pack.mcmeta`, `README.md` y `shaders/` sin una carpeta adicional por encima.
