---
name: Juntos
description: Álbum privado de dos personas, servido en una mesa de fresa y guinda.
colors:
  paper-cream: "#FBF4EA"
  page-white: "#FFFCF7"
  warm-linen: "#F7EADF"
  strawberry: "#C82F45"
  strawberry-pressed: "#9E1C32"
  cherry: "#8A1230"
  cherry-deep: "#5E0B20"
  leaf: "#5C8A44"
  leaf-deep: "#3F6A2E"
  leaf-soft: "#DDE8D3"
  blush: "#F9DFE2"
  plum-ink: "#33161D"
  plum-muted: "#7C5F63"
  hairline: "#E5D2C3"
  hairline-soft: "#F0E1D5"
  error-brick: "#A32A2D"
  overlay-plum: "#1B0C11"
typography:
  display:
    fontFamily: "DM Serif Display, Georgia, serif"
    fontSize: "36px"
    fontWeight: 400
    lineHeight: 1.04
    letterSpacing: "-0.028em"
  headline:
    fontFamily: "DM Serif Display, Georgia, serif"
    fontSize: "27px"
    fontWeight: 400
    lineHeight: 1.05
    letterSpacing: "-0.026em"
  headline-small:
    fontFamily: "DM Serif Display, Georgia, serif"
    fontSize: "24px"
    fontWeight: 400
    lineHeight: 1.12
    letterSpacing: "-0.017em"
  title:
    fontFamily: "DM Serif Display, Georgia, serif"
    fontSize: "20px"
    fontWeight: 400
    lineHeight: 1.2
    letterSpacing: "-0.01em"
  body:
    fontFamily: "Manrope, system-ui, sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.55
  label:
    fontFamily: "Manrope, system-ui, sans-serif"
    fontSize: "12.5px"
    fontWeight: 600
    lineHeight: 1.4
    letterSpacing: "0.005em"
  label-strong:
    fontFamily: "Manrope, system-ui, sans-serif"
    fontSize: "15px"
    fontWeight: 700
    lineHeight: 1.3
    letterSpacing: "0.006em"
  micro-label:
    fontFamily: "Manrope, system-ui, sans-serif"
    fontSize: "10px"
    fontWeight: 700
    lineHeight: 1.3
    letterSpacing: "0.03em"
rounded:
  sm: "12px"
  md: "16px"
  button: "18px"
  lg: "22px"
  xl: "26px"
  sheet: "30px"
  pill: "999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "20px"
  xxl: "24px"
  section: "40px"
components:
  button-primary:
    backgroundColor: "{colors.strawberry}"
    textColor: "{colors.page-white}"
    typography: "{typography.label-strong}"
    rounded: "{rounded.button}"
    padding: "18px 24px"
    height: "56px"
  button-primary-pressed:
    backgroundColor: "{colors.strawberry-pressed}"
    textColor: "{colors.page-white}"
    typography: "{typography.label-strong}"
    rounded: "{rounded.button}"
    height: "56px"
  fab-nuevo-recuerdo:
    backgroundColor: "{colors.strawberry}"
    textColor: "{colors.page-white}"
    typography: "{typography.label-strong}"
    rounded: "{rounded.button}"
    padding: "18px 22px"
    height: "56px"
  input-field:
    backgroundColor: "{colors.warm-linen}"
    textColor: "{colors.plum-ink}"
    typography: "{typography.body}"
    rounded: "{rounded.md}"
    padding: "18px 18px"
    height: "56px"
  memory-card:
    backgroundColor: "{colors.page-white}"
    textColor: "{colors.page-white}"
    typography: "{typography.title}"
    rounded: "{rounded.lg}"
    padding: "16px"
  badge-sin-foto:
    backgroundColor: "{colors.leaf-soft}"
    textColor: "{colors.leaf-deep}"
    typography: "{typography.micro-label}"
    rounded: "{rounded.pill}"
    padding: "4px 9px"
  meta-pill:
    backgroundColor: "rgba(27, 12, 17, 0.62)"
    textColor: "{colors.page-white}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    padding: "8px 12px"
---

# Design System: Juntos

## Overview

**Creative North Star: "La mesa del domingo"**

Juntos se parece más al cuaderno de recetas que hay sobre la mesa de una casa que a una rejilla de fotos. La mesa está cubierta con un mantel de papel crema; en el centro, un cuenco de fresas y guindas. Esa es la imagen que gobierna el sistema: cálida, comestible, íntima y sin ninguna prisa.

La interfaz se queda quieta para que la foto sea el plato principal. El logotipo aporta el carácter dibujado a mano —la fresa sonriente y la guinda que se dan la mano—, mientras que la tipografía y las superficies aportan el tono editorial. No hay brillos, cristal, degradados de texto ni mecánicas de red social: solo papel, fruta y recuerdos con nombre.

La densidad es baja. El archivo se lee como una cronología por meses, con una tarjeta protagonista por mes y pares de fotos debajo. Los controles son pocos y familiares; el acento de fresa aparece únicamente donde hay una acción que tomar.

**Key Characteristics:**
- Fondo de papel crema, nunca blanco puro.
- Fresa para la acción, guinda para la profundidad, hoja para el apoyo.
- Serif editorial para recuerdos y marca; sans para controles y metadatos.
- Fotos a sangre con esquinas de papel recortado (22 px) y sombra cálida hacia abajo.
- Cronología por meses como columna vertebral; un solo botón de añadir por pantalla.
- Estados honestos para lo que aún no existe: «Sin foto», «Foto pendiente».

## Colors

Una paleta de frutería sobre crema: rojos comestibles, verdes de hoja y tinta de ciruela.

### Primary
- **Strawberry** (#C82F45): el único acento de acción. Botones primarios, FAB, foco de campos, punto del mes más reciente y la palabra en cursiva del titular. No decora: señala lo que se puede tocar.
- **Strawberry pressed** (#9E1C32): estado pulsado del botón primario.

### Secondary
- **Cherry** (#8A1230): profundidad editorial. Iconos de metadatos en fondos claros, acciones destructivas, el título de un recuerdo sin foto.
- **Cherry deep** (#5E0B20): la superficie oscura del detalle a pantalla completa y el degradado de la tarjeta sin foto.
- **Leaf** (#5C8A44): apoyo y crecimiento. Puntos de meses anteriores, avatares de pareja, confirmaciones. Nunca es el color de una acción primaria.
- **Leaf deep** (#3F6A2E): texto sobre el verde suave o sobre papel crema.
- **Leaf soft** (#DDE8D3): insignia «Sin foto», lavados de fondo y contenedores de confirmación.
- **Blush** (#F9DFE2): lavado de acuarela detrás del acceso y del encabezado; tiñe la selección de texto.

### Neutral
- **Paper cream** (#FBF4EA): el suelo de toda la app. Ni blanco ni gris.
- **Page white** (#FFFCF7): la superficie elevada más clara (tarjetas, hojas, medallones).
- **Warm linen** (#F7EADF): relleno de campos, panel de metadatos y superficies hundidas.
- **Plum ink** (#33161D): texto principal y tinta de iconos.
- **Plum muted** (#7C5F63): texto secundario y metadatos; mantiene contraste AA sobre crema.
- **Hairline** (#E5D2C3): bordes de campos y separadores. **Hairline soft** (#F0E1D5): divisores casi invisibles.
- **Error brick** (#A32A2D): errores y la acción destructiva del diálogo. Se distingue de la fresa por ser más apagado y terroso.
- **Overlay plum** (#1B0C11): scrim del detalle y fondo de la barra de estado en modo foto.

### Named Rules
**The Cream Tablecloth Rule.** El fondo de página es papel crema; el blanco puro solo existe como superficie elevada. Un fondo blanco frío rompe el mundo de la mesa.

**The Two Fruits, Two Jobs Rule.** La fresa es acción; la guinda es profundidad. Nunca se intercambian, y la hoja jamás asume el papel de botón primario.

**The Ten Percent Rule.** El color fruta saturado ocupa como máximo el 10 % de una pantalla. Su rareza es lo que hace que el botón se encuentre sin buscarlo.

## Typography

**Display Font:** DM Serif Display (Google Fonts; fallback Georgia, serif)
**Body Font:** Manrope (Google Fonts; fallback system-ui, sans-serif)

**Character:** Una pareja editorial y doméstica: la serif recuerda y la sans opera. La serif tiene curvas de mantel y una cursiva que parece escrita a mano; la sans es redonda, bajada de contraste y perfectamente legible en un móvil en la calle.

### Hierarchy
- **Display** (400, 36 px, 1.04, −0.028em): el titular «Nuestra vida, en fotos.» y la frase de marca. Solo un display por pantalla.
- **Headline** (400, 27 px, 1.05, −0.026em): el nombre «Juntos» y los encabezados de pantalla. **Headline small** (400, 24 px, 1.12): inicio de sesión, registro y estados vacíos.
- **Title** (400, 20 px, 1.2, −0.01em): nombres de mes y títulos de tarjeta. Siempre en serif, incluso sobre foto.
- **Body** (400, 14 px, 1.55): prosa y subtítulos. Línea máxima de 65–75 caracteres; 15 px para el cuerpo de formularios.
- **Label** (600, 12.5 px): etiquetas de campo y metadatos. **Label strong** (700, 15 px): botones y FAB. **Micro-label** (700, 10 px, +0.03em): insignias como «Sin foto»; no se usa como «eyebrow» decorativo encima de un titular.

### Named Rules
**The Serif Remembers Rule.** Si es un recuerdo, un mes o un momento de marca, se compone en DM Serif. Si es una acción, un control, una fecha o un metadato, se compone en Manrope.

**The Sans Operates Rule.** Ningún botón, pestaña, campo o etiqueta usa la serif. La serif no se toca.

## Layout

La app es de una sola columna y prioriza el teléfono. El contenido vive en un máximo de 560 dp; en tabletas aparece un margen de papel crema a los lados, como el borde de un cuaderno. Las pantallas de acceso se limitan a 440 dp y se centran.

- **Márgenes:** 20 dp laterales en la cronología y el detalle; 24 dp en el acceso.
- **Ritmo:** sistema de 4 puntos. 12 dp entre tarjetas emparejadas, 24 dp entre el encabezado de sección y el primer mes, 40 dp entre meses.
- **Columna vertebral:** cada mes abre con un punto de fruta, el nombre del mes en serif, una línea de mantel y el contador de recuerdos. La primera foto del mes ocupa todo el ancho (3:2); las siguientes se emparejan en una rejilla 2-up.
- **Una sola acción de añadir:** el FAB extendido «Nuevo recuerdo» flota centrado abajo. No hay botones de cámara duplicados en el encabezado ni barras inferiores.
- **Aire bajo el archivo:** 132 dp de relleno inferior para que el FAB nunca tape el último recuerdo.
- **Teclado:** las hojas de creación y los formularios se desplazan por encima del teclado; el pie de guardado permanece visible.
- **Toque:** 48 dp mínimos en todos los controles; 56 dp de alto en botones y campos.

## Elevation & Depth

Sistema híbrido: capas tonales de papel crema más una sombra cálida con desplazamiento. La luz viene de arriba; ninguna sombra envuelve un elemento por los cuatro lados. Las fotos no flotan: se apoyan.

### Shadow Vocabulary
- **Card** (`0 10px 26px rgba(165,58,75,0.07), 0 2px 4px rgba(51,22,29,0.05)`): tarjetas de recuerdo sobre el papel.
- **Medallion** (`0 8px 22px rgba(138,18,48,0.12)`): el logotipo circular y la cámara de la hoja de creación.
- **Action** (`0 10px 22px rgba(200,47,69,0.22)` a `0 12px 24px rgba(200,47,69,0.20)`): botón de guardado y FAB. Es la única sombra coloreada.
- **Dialog** (`elevation 8`, sombra de tinta al 16 %): solo para decisiones que interrumpen, como eliminar un recuerdo.

### Named Rules
**The Paper Lift Rule.** La elevación se lee como una tarjeta levantada de la mesa: borde suave, sombra hacia abajo y un halo mínimo. Un resplandor de desplazamiento cero es decoración, no profundidad.

**The One Dark Room Rule.** La única superficie oscura de la app es el detalle de un recuerdo a pantalla completa. Allí el scrim es tinta de ciruela, las píldoras son sólidas y no hay cristal.

## Shapes

Lenguaje de papel recortado: esquinas generosas, nunca afiladas. 22 px en tarjetas y fotos; 18 px en botones y FAB; 16 px en campos y paneles; 30 px en la parte superior de las hojas; 999 px en píldoras e insignias. El logotipo siempre va en un medallón circular con un aro de papel y un filo interior de blush.

Los indicadores de mes son puntos de fruta, no barras ni reglas. La línea del mes es fina y horizontal, como el borde de un mantel. Las fotos se recortan siempre con el radio de la tarjeta.

## Components

### Buttons
- **Shape:** rectángulo de papel con 18 px de radio y 56 px de alto.
- **Primary:** fondo Strawberry, texto Page white en 15 px/700, relleno de 18 × 24. Al pulsar, Strawberry pressed. Deshabilitado: Warm linen con texto Plum muted.
- **Loading:** el botón conserva su tamaño y muestra un spinner blanco de 22 px; nunca cambia de ancho.
- **Text / tertiary:** solo texto en Strawberry, con área de toque de 48 dp. No se usa para acciones destructivas (esas van en Error brick).
- **FAB:** extendido, fondo Strawberry, icono `add_a_photo_outlined`, etiqueta «Nuevo recuerdo», centrado abajo. Es la única acción de añadir de la pantalla.

### Inputs / Fields
- **Style:** relleno Warm linen, radio 16 px, borde de 1 px Hairline soft. Texto Plum ink; etiqueta flotante Plum muted en 12.5 px/600.
- **Focus:** borde de 1.6 px Strawberry y etiqueta flotante en tinta de ciruela; al enfocar, la etiqueta toma temporalmente la fresa. El borde es la señal principal.
- **Error:** borde y texto Error brick, con icono de error en el aviso; el mensaje nombra el problema y la recuperación.
- **Icons:** prefijo de 20 px en Plum muted; ojo de visibilidad con tooltip y 48 dp.

### Cards / Containers
- **Photo card:** radio 22 px, sombra Card, imagen a sangre y scrim inferior `0xC0000000`. Título en DM Serif 20 px blanco, fecha y hora en Manrope 10.5 px blanco al 84 %. La ubicación solo aparece en la tarjeta protagonista.
- **Featured:** proporción 1.5 (3:2) para la primera foto de cada mes. Las parejas usan 0.78 de proporción.
- **Sin foto:** degradado de lino, más ancho (2.05) y bajo, insignia Leaf soft «Sin foto», título en Plum ink y fecha en Plum muted. No simula una imagen que no existe.
- **Elevación:** la tarjeta se apoya en la mesa; no se anida dentro de otra tarjeta.

### Navigation
No hay barra de navegación permanente: el álbum es una sola superficie. La cabecera es editorial: «Juntos» en serif, «Nuestro álbum» en sans, dos avatares superpuestos (inicial + corazón) y un menú de desbordamiento para cerrar sesión. El detalle a pantalla completa se cierra con un círculo de 46 px; el borrado, solo en recuerdos personales, pide confirmación en un diálogo Material.

### Month Header (signature)
- **Anatomy:** halo de 18 px + punto de 8 px (Strawberry en el mes más reciente, Leaf en los anteriores), nombre del mes en DM Serif 20 px, línea de mantel flexible y contador «1 recuerdo» / «4 recuerdos» en Manrope 12.5 px Plum muted.
- **Rhythm:** 40 px entre secciones; 16 px entre la cabecera y su primera tarjeta. Es la columna vertebral de la cronología.

### Memory Detail
- **Surface:** foto a sangre sobre Overlay plum; scrim superior e inferior. Título de 38 px en serif blanco, píldoras de fecha/hora y ubicación con fondo `rgba(27,12,17,0.62)` y borde blanco al 12 %.
- **Motion:** fade-through de 260 ms con escala de 1.015 a 1 y `easeOutCubic`; la vuelta dura 210 ms. Es el único momento coreografiado de la app.
- **Destructive:** el icono de papelera abre un diálogo; «Eliminar» va en Error brick y en negrita. El borrado ofrece «Deshacer» durante unos segundos en una snackbar; nunca se borra con un gesto.

### Add Memory Sheet
- **Surface:** hoja de 30 px de radio superior, grabber de 40 × 5, título serif de 26 px y subtítulo sans.
- **Preview:** lavado vertical blush → lino → hoja en 16:10 con un medallón de cámara. El texto dice la verdad: «La cámara llegará en la próxima versión».
- **Field:** título en DM Serif 21 px sobre Warm linen; la fecha y la hora se completan solas, y la ubicación llegará junto con la cámara.
- **Footer:** el botón «Guardar recuerdo» y la nota de automatismo viven en un pie fijo que queda por encima del teclado.

### Auth
- **Composition:** medallón de 94 px, «Juntos» en serif, titular de tarea en serif small, campos rellenos y botón Strawberry. El fondo lleva dos lavados radiales, blush arriba y hoja abajo.
- **Error:** banda Error brick sobre Error surface, con icono y texto de 12.5 px/600. El error de autenticación no se muestra como texto suelto.
- **Privacy:** una línea con candado y «Un álbum privado para dos.» cierra la pantalla.

## Do's and Don'ts

### Do:
- **Do** mantener el fondo en Paper cream y dejar que las fotos aporten la saturación.
- **Do** reservar Strawberry para la acción primaria, el foco y el punto del mes más reciente.
- **Do** componer recuerdos y meses en DM Serif; controles, fechas y etiquetas en Manrope.
- **Do** recortar las fotos a 22 px y apoyarlas con la sombra Card hacia abajo.
- **Do** mostrar estados honestos: «Sin foto», «Foto pendiente», «La cámara llegará en la próxima versión».
- **Do** mantener un solo botón de añadir por pantalla y 48 dp de área de toque.
- **Do** dejar el pie de guardado visible por encima del teclado.

### Don't:
- **Don't** usar blanco puro como fondo de página, grises fríos ni sombras azuladas.
- **Don't** convertir la hoja verde en botón primario ni usarla para errores.
- **Don't** añadir una cámara en la cabecera, otra barra inferior o un segundo FAB.
- **Don't** poner la serif en botones, pestañas, etiquetas de campo o fechas.
- **Don't** usar glassmorphism, desenfoques decorativos, degradados de texto ni halos de desplazamiento cero.
- **Don't** inventar fotos, personas o testimonios: las fotos semilla de Unsplash son material de demostración.
