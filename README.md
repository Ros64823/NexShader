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

- **PATATA**: sombras 512, sin SSAO pesado, sin SSR, sin volumétricos, agua simple, render scale 0.70.
- **MUY BAJO**: sombras 768, SSAO mínimo, agua simplificada, cielo/fog mejorados, render scale 0.75.
- **BAJO**: sombras 1024, SSAO ligero, bloom ligero, reflejos simplificados, volumétrico mínimo, render scale 0.85.
- **MEDIO**: sombras 1536, SSAO medio, bloom, agua con reflejos, volumétricos ligeros, render scale 0.90.
- **NORMAL**: perfil recomendado, sombras 2048, SSAO bueno, SSR moderado, bloom y post-procesado completo razonable.
- **ALTO**: sombras 3072, filtrado avanzado, SSAO alto, SSR mejorado, volumétricos moderados, bloom avanzado.
- **MUY ALTO**: sombras 4096, más muestras, SSAO/SSR/volumétricos de mayor calidad, cielo y agua avanzados.

## Características

- Shadow pass real y uso del shadow map en iluminación.
- Iluminación solar y ambiental basada en normales, hora del día, lluvia y lightmap del ojo.
- SSAO escalable por perfil.
- Agua con transparencia, normal animada, color por profundidad aproximada, fresnel y reflejos.
- Cielo con gradiente atmosférico, transición día/noche, amanecer/atardecer y estrellas.
- Fog por distancia, ambiente, lluvia y agua.
- Reflejos en espacio de pantalla aproximados para perfiles medios/altos.
- God rays/volumétricos limitados por pasos para evitar costes excesivos.
- Bloom eficiente de pocas muestras.
- Tonemapping, exposure, contraste, saturación y color grading natural.

## Optimización para Intel UHD

El perfil recomendado para Intel UHD Graphics en un Intel Core i3-N305 es **PATATA**, **MUY BAJO**, **BAJO** o **MEDIO** según resolución y distancia de renderizado. El pack evita bucles largos, usa recuentos de muestras moderados y reduce render scale en perfiles bajos.

Recomendaciones:

- Empieza en **BAJO** a 1080p.
- Reduce distancia de renderizado antes de subir SSR o volumétricos.
- Usa **NORMAL** solo si la escena mantiene FPS estables.
- Mantén `SSR_SAMPLES`, `SSAO_SAMPLES` y `VOLUMETRIC_STEPS` bajos en GPUs integradas.

## Configuración

Las opciones principales expuestas son: `QUALITY_PROFILE`, `SHADOW_RESOLUTION`, `SHADOW_SAMPLES`, `SHADOW_FILTER`, `SSAO_ENABLED`, `SSAO_SAMPLES`, `SSR_ENABLED`, `SSR_SAMPLES`, `VOLUMETRIC_ENABLED`, `VOLUMETRIC_STEPS`, `BLOOM_ENABLED`, `BLOOM_QUALITY`, `WATER_QUALITY`, `REFLECTION_QUALITY`, `CLOUD_QUALITY`, `FOG_QUALITY`, `SKY_QUALITY`, `LIGHTING_QUALITY`, `POST_PROCESSING_QUALITY`, `RENDER_SCALE`, `EXPOSURE`, `CONTRAST` y `SATURATION`.

## Limitaciones

- SSR es una aproximación barata y no sustituye trazado físico completo.
- Las nubes se mantienen compatibles con el pipeline vanilla/Iris y se mejoran principalmente mediante cielo, fog y color.
- La validación final debe hacerse dentro de Minecraft/Iris porque la disponibilidad exacta de uniforms puede variar entre versiones.

## Tests

Para validar todos los programas GLSL y ejecutar las pruebas numéricas de las librerías:

```bash
python -m pip install -r requirements-dev.txt
python tools/validate_shaders.py
pytest -q
```
