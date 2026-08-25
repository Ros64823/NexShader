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

## Robustez numérica

Un shader no puede lanzar una excepción: una división por cero o un `normalize()` de un vector de longitud cero devuelve NaN/Inf, y ese valor se mezcla en los pases siguientes hasta que la pantalla se vuelve negra o blanca sin ningún mensaje de error.

`shaders/lib/safety.glsl` centraliza los guardas usados en todo el pack:

- `safeNormalize(v, fallback)` para vectores que pueden ser nulos (normales del gbuffer, `sunPosition.xy`, dirección de SSR).
- `nexGuardDenom` / `safeDiv` para denominadores que pueden anularse (`p.w` en `screenToView`, `linearDepth`, resolución de pantalla, tonemapping).
- `sanitize` antes de escribir en cada render target, de forma que un valor no finito no se propague a `composite`/`final`.
- `clampScreenUV` para las lecturas en espacio de pantalla, que si no dependen del modo de repetición del buffer.

Todos los guardas eligen un valor visible y documentado (por ejemplo, sin sombra o sin oclusión) en lugar de dejar pasar un resultado indefinido.

## Validación

```bash
sudo apt-get install -y glslang-tools
python3 tools/validate_shaders.py            # todos los perfiles
python3 tools/validate_shaders.py --profile NORMAL
```

El script resuelve los `#include` como hace Iris, aplica los valores de cada perfil de `shaders.properties` y compila los 16 programas con `glslangValidator`. Iris responde a un error de compilación volviendo al render vanilla, así que sin esta comprobación un programa roto pasa desapercibido. El workflow `.github/workflows/validate-shaders.yml` lo ejecuta en cada push y pull request.

## Limitaciones

- SSR es una aproximación barata y no sustituye trazado físico completo.
- Las nubes se mantienen compatibles con el pipeline vanilla/Iris y se mejoran principalmente mediante cielo, fog y color.
- La validación final debe hacerse dentro de Minecraft/Iris porque la disponibilidad exacta de uniforms puede variar entre versiones.
