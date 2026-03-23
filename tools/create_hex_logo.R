# Script para generar el logo hexagonal de ciecl
# Ejecutar desde la raiz del paquete: source("tools/create_hex_logo.R")
# Requiere: hexSticker, ggplot2

library(hexSticker)
library(ggplot2)

# Colores del paquete
color_borde  <- "#1B4F72"  # Azul oscuro profesional
color_fondo  <- "#FFFFFF"  # Blanco
color_nombre <- "#1B4F72"  # Azul oscuro para el nombre
color_sub    <- "#5D6D7E"  # Gris azulado para el subtitulo

# Subplot: subtitulo "CIE-10 Chile" centrado
p_sub <- ggplot() +
  annotate(
    "text",
    x = 0.5, y = 0.5,
    label = "CIE-10 Chile",
    size  = 5.5,
    color = color_sub,
    fontface = "italic",
    family   = "sans"
  ) +
  xlim(0, 1) + ylim(0, 1) +
  theme_void() +
  theme(
    plot.background  = element_rect(fill = color_fondo, color = NA),
    panel.background = element_rect(fill = color_fondo, color = NA)
  )

# Generar hex sticker
sticker(
  subplot    = p_sub,
  package    = "ciecl",
  p_size     = 26,
  p_color    = color_nombre,
  p_y        = 1.45,
  p_family   = "sans",
  p_fontface = "bold",
  s_x        = 1.00,
  s_y        = 0.78,
  s_width    = 1.20,
  s_height   = 0.50,
  h_fill     = color_fondo,
  h_color    = color_borde,
  h_size     = 1.8,
  filename   = "man/figures/logo.png",
  dpi        = 300,
  white_around_sticker = TRUE
)

message("Logo generado en man/figures/logo.png")
