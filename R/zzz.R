#' @import grid
#' @importFrom grDevices dev.cur dev.off dev.set cairo_pdf
#' @importFrom grImport2 readPicture symbolsGrob
#' @importFrom marquee classic_style em marquee_grob modify_style relative rem trbl
#' @importFrom piecepackr game_systems pmap_piece pp_cfg
#' @importFrom ppdf domino_tiles
#' @importFrom rlang check_dots_empty
#' @importFrom utils packageDescription
#' @importFrom xmpdf as_docinfo set_docinfo set_xmp supports_set_docinfo supports_set_xmp xmp
NULL

# Inches
TILE_WIDTH <- 1
TILE_HEIGHT <- 2
BLEED <- 1 / 8
CROPMARK_LENGTH <- 1 / 4
REGISTRATION_SIZE <- 1 / 4
CROSSHAIR_SIZE <- 1 / 6
A4_WIDTH <- 210 / 25.4
A4_HEIGHT <- 297 / 25.4

N_COLUMNS <- 7L # tiles per row
