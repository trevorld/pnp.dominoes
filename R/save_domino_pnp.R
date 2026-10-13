#' Save print-and-play dominoes
#'
#' `save_domino_pnp_12()` saves a print-and-play pdf of a double-twelve set of dominoes (91 tiles) on three sheets of tiles.
#' `save_domino_pnp_18()` saves a print-and-play pdf of a double-eighteen set of dominoes (190 tiles) on six sheets of tiles.
#'
#' * Smaller sets are nested within the first sheets:
#'
#'   * In the double-twelve pdf the first sheet is a double-six set and the first two sheets contain a double-nine set.
#'   * In the double-eighteen pdf the first four sheets are a double-fifteen set and the first five sheets are a double-seventeen set.
#'
#' * Tiles are 1" by 2" with a 1/8" bleed around each group of tiles.
#'   Crop marks in the margins indicate the cut lines and
#'   crosshairs (in the pip color) mark the tile corners on the faces.
#' * The first page is a cover page with credits, license, and instructions followed by a deliberately blank page.
#'   The remaining odd pages are the tile faces and the even pages are the tile backs.
#' * Registration marks on both sides help check that double-sided prints line up.
#' * The print-and-play pdfs are licensed under a permissive [CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/) license.
#' @param filename Filename of the pdf to save.
#' @param ... Must be empty.
#' @param paper Paper size: either `"letter"` or `"a4"`.
#' @param background_color Tile background color.
#' @param pip_color Tile pip (and center line) color.
#' @return The filename invisibly.  As a side effect saves a pdf file.
#' @examples
#' f12 <- save_domino_pnp_12(
#'   tempfile(fileext = ".pdf"),
#'   paper = "a4",
#'   background_color = palette.colors()[[6L]], # Okabe-Ito blue
#'   pip_color = "white"
#' )
#' f18 <- save_domino_pnp_18(tempfile(fileext = ".pdf"))
#' if (requireNamespace("pnpmisc", quietly = TRUE)) {
#'   grid::grid.newpage()
#'   grid::grid.raster(pnpmisc::pdf_render_raster(f12, page = 3L, dpi = 150))
#' }
#' if (requireNamespace("pnpmisc", quietly = TRUE)) {
#'   grid::grid.newpage()
#'   grid::grid.raster(pnpmisc::pdf_render_raster(f18, page = 13L, dpi = 150))
#' }
#' unlink(c(f12, f18))
#' @export
save_domino_pnp_12 <- function(
	filename = "dominoes_double12.pdf",
	...,
	paper = c("letter", "a4"),
	background_color = "white",
	pip_color = "black"
) {
	check_dots_empty()
	paper <- match.arg(tolower(paper), c("letter", "a4"))
	save_domino_pnp(
		filename,
		domino_pages_12(),
		paper = paper,
		background_color = background_color,
		pip_color = pip_color,
		title = "Double-Twelve Dominoes",
		set_info = c(
			"* The 91 tiles of a double-twelve set are provided on three sheets of 1\" by 2\" tiles.",
			"* The first sheet is a double-six set (28 tiles).",
			"* The first two sheets contain a double-nine set (55 tiles) plus one tile from the double-twelve set."
		)
	)
}

#' @rdname save_domino_pnp_12
#' @export
save_domino_pnp_18 <- function(
	filename = "dominoes_double18.pdf",
	...,
	paper = c("letter", "a4"),
	background_color = "white",
	pip_color = "black"
) {
	check_dots_empty()
	paper <- match.arg(tolower(paper), c("letter", "a4"))
	save_domino_pnp(
		filename,
		domino_pages_18(),
		paper = paper,
		background_color = background_color,
		pip_color = pip_color,
		title = "Double-Eighteen Dominoes",
		set_info = c(
			"* The 190 tiles of a double-eighteen set are provided on six sheets of 1\" by 2\" tiles.",
			"* The first four sheets are a double-fifteen set (136 tiles).",
			"* The first five sheets are a double-seventeen set (171 tiles)."
		)
	)
}

# All tiles of a double-`n` set ordered so that every smaller double-`m` set
# is a prefix i.e. the first 28 tiles are a double-six set,
# the first 55 tiles are a double-nine set, etc.
double_n_tiles <- function(n) {
	df <- domino_tiles(n + 1L)
	df[order(pmax(df$suit, df$rank), pmin(df$suit, df$rank)), ]
}

# 28 (double-six) + 28 (rest of double-nine + one double-twelve tile) + 35
domino_pages_12 <- function() {
	df <- double_n_tiles(12L)
	split(df, rep.int(1:3, c(28L, 28L, 35L)))
}

# 136 (double-fifteen) + 35 (completes double-seventeen) + 19
domino_pages_18 <- function() {
	df <- double_n_tiles(18L)
	split(df, rep.int(1:6, c(35L, 35L, 35L, 31L, 35L, 19L)))
}

domino_cfg <- function(background_color = "white", pip_color = "black") {
	l <- as.list(game_systems(border = FALSE)$dominoes)
	l$background_color <- background_color
	l$suit_color <- pip_color
	l$mat_color <- pip_color
	l$gridline_color.tile_face <- pip_color
	pp_cfg(l)
}

save_domino_pnp <- function(
	filename,
	pages,
	paper,
	background_color,
	pip_color,
	title,
	set_info
) {
	x <- xmp(
		creator = "Trevor L. Davis",
		creator_tool = paste0("pnp.dominoes v", packageDescription("pnp.dominoes")$Version),
		date_created = "2026",
		spdx_id = "CC-BY-4.0",
		title = title
	)
	cfg <- domino_cfg(background_color, pip_color)
	width <- switch(paper, letter = 8.5, a4 = A4_WIDTH)
	height <- switch(paper, letter = 11, a4 = A4_HEIGHT)

	current_dev <- dev.cur()
	if (current_dev > 1) {
		on.exit(dev.set(current_dev), add = TRUE)
	}
	# `cairo_pdf()` (unlike `pdf()`) embeds the fonts used by `marquee`
	cairo_pdf(filename, width = width, height = height, onefile = TRUE)
	grid.newpage()
	grid.draw(credits_grob(x, set_info, width))

	# Deliberately blank:
	# keeps the cover page from ending up printed on the back of the first sheet of tiles
	# so that each sheet's faces and backs share a physical sheet under duplex printing.
	grid.newpage()
	grid.text("This page deliberately left blank.", gp = gpar(fontsize = 12))

	for (i in seq_along(pages)) {
		df <- pages[[i]]
		layout <- domino_layout(nrow(df), width, height)
		# The last sheet has a different number of rows than the earlier sheets
		layout$squared <- i == length(pages)
		grid.newpage()
		grid_domino_front(df, cfg, background_color, pip_color, layout)
		grid.newpage()
		grid_domino_back(background_color, layout)
	}
	dev.off()

	# Set docinfo before xmp since (in some cases) setting docinfo with ghostscript clobbers xmp
	if (supports_set_docinfo()) {
		set_docinfo(as_docinfo(x), filename)
	}
	if (supports_set_xmp()) {
		set_xmp(x, filename)
	}
	invisible(filename)
}

credits_grob <- function(x, set_info, width) {
	credits <- c(
		paste0("*", x$title[["x-default"]], "* by ", x$attribution_name),
		"",
		x$rights,
		"",
		"# License",
		"",
		x$usage_terms,
		"",
		"# Instructions",
		"",
		set_info,
		"* Odd pages are the tile faces and even pages are the tile backs.",
		"  Always print at actual size.",
		"* For sturdier dominoes print the odd pages (skipping this cover page) on label (sticker) paper",
		"  and mount them onto something thicker (e.g. chipboard or mat board).",
		"  (Optional) also mount the even pages on the other side for two-sided dominoes.",
		"* For domino cards instead print double-sided (flip on the long edge) on cardstock.",
		"* Each sheet's four registration marks should line up on both sides:",
		"  they are squared on the last sheet and circled on the earlier sheets.",
		"* (Optional) laminate the printed sheets of paper.",
		"* Use the crop marks in the margins and the crosshairs at the tile corners to cut out the tiles.",
		"* (Optional) use a corner rounding tool to round the corners.",
		"",
		"# Further information",
		"",
		paste0("* Generated by `pnp.dominoes` v", packageDescription("pnp.dominoes")$Version),
		"* See https://github.com/trevorld/pnp.dominoes for more information.",
		"",
		"# Credits",
		"",
		"* Tiles drawn with `piecepackr` https://github.com/piecepackr/piecepackr"
	)
	mg <- marquee_grob(
		paste(credits, collapse = "\n"),
		width = unit(width - 1.5, "in"),
		x = unit(0.75, "in"),
		y = unit(1, "npc") - unit(0.75, "in"),
		style = credits_style()
	)
	gList(license_badge_grob(x$spdx_id), mg)
}

license_badge_grob <- function(spdx_id) {
	badge <- piecepackr::spdx_license_list[spdx_id, "badge"]
	if (is.na(badge)) {
		return(nullGrob())
	}
	badge_file <- system.file("extdata", "badges", badge, package = "piecepackr")
	symbolsGrob(
		readPicture(badge_file),
		x = unit(0.5, "npc"),
		y = unit(1, "in"),
		size = unit(1.5, "in")
	)
}

credits_style <- function() {
	# Don't manually set `bullets` to avoid marquee#99
	classic_style(base_size = 11, lineheight = 1.6, margin = trbl(0, bottom = rem(0.7))) |>
		modify_style(
			"h1",
			border = NA,
			size = relative(1.4),
			border_size = trbl(NULL),
			margin = trbl(NULL),
			padding = trbl(NULL)
		) |>
		modify_style("ul", padding = trbl(right = em(1)))
}

# Tiles fill rows of `N_COLUMNS` tiles from the top-left with the block of tiles centered on the page.
domino_layout <- function(n, width, height) {
	n_rows <- as.integer(ceiling(n / N_COLUMNS))
	left <- (width - N_COLUMNS * TILE_WIDTH) / 2
	top <- (height + n_rows * TILE_HEIGHT) / 2
	list(
		n = n,
		n_rows = n_rows,
		n_full_rows = n %/% N_COLUMNS,
		n_last_row = n %% N_COLUMNS,
		width = width,
		height = height,
		left = left,
		right = left + N_COLUMNS * TILE_WIDTH,
		top = top,
		bottom = top - n_rows * TILE_HEIGHT
	)
}

grid_domino_front <- function(df, cfg, background_color, pip_color, layout) {
	i <- seq_len(layout$n) - 1L
	df$x <- layout$left + (i %% N_COLUMNS + 0.5) * TILE_WIDTH
	df$y <- layout$top - (i %/% N_COLUMNS + 0.5) * TILE_HEIGHT
	df$cfg <- NULL

	# Bleed around the group of tiles
	if (layout$n_full_rows > 0L) {
		grid_bleed_rect(
			layout$left,
			layout$top - layout$n_full_rows * TILE_HEIGHT,
			layout$right,
			layout$top,
			background_color
		)
	}
	if (layout$n_last_row > 0L) {
		grid_bleed_rect(
			layout$left,
			layout$bottom,
			layout$left + layout$n_last_row * TILE_WIDTH,
			layout$bottom + TILE_HEIGHT,
			background_color
		)
	}
	pmap_piece(df, cfg = cfg, default.units = "in")
	grid_domino_crosshairs(pip_color, layout)
	grid_domino_marks(layout)
	invisible(NULL)
}

# One big rectangle covers the (mirrored) faces of every tile on the front
# even when the last row is only partially filled.
grid_domino_back <- function(background_color, layout) {
	grid_bleed_rect(layout$left, layout$bottom, layout$right, layout$top, background_color)
	grid_domino_marks(layout)
	invisible(NULL)
}

# Crosshairs at every tile corner (adjacent tiles share corners so each is only drawn once)
grid_domino_crosshairs <- function(col, layout) {
	xs <- layout$left + seq.int(0L, N_COLUMNS) * TILE_WIDTH
	ys <- layout$top - seq.int(0L, layout$n_full_rows) * TILE_HEIGHT
	x <- rep(xs, length(ys))
	y <- rep(ys, each = length(xs))
	if (layout$n_last_row > 0L) {
		xs_last <- layout$left + seq.int(0L, layout$n_last_row) * TILE_WIDTH
		x <- c(x, xs_last, xs_last)
		y <- c(y, rep(c(layout$bottom + TILE_HEIGHT, layout$bottom), each = length(xs_last)))
		# The top corners of the last row are often already corners of the full rows above
		dupes <- duplicated(cbind(x, y))
		x <- x[!dupes]
		y <- y[!dupes]
	}
	size <- unit(CROSSHAIR_SIZE, "in")
	grid.draw(piecepackr::squaresCrosshairGrob(
		x = unit(x, "in"),
		y = unit(y, "in"),
		width = size,
		height = size,
		gp = gpar(col = col, fill = col)
	))
	invisible(NULL)
}

grid_bleed_rect <- function(left, bottom, right, top, fill) {
	grid.rect(
		x = left - BLEED,
		y = bottom - BLEED,
		width = right - left + 2 * BLEED,
		height = top - bottom + 2 * BLEED,
		just = c("left", "bottom"),
		default.units = "in",
		gp = gpar(col = NA, fill = fill)
	)
}

# The block of tiles is centered on the page so the crop and registration marks
# are symmetric (even under a 180 degree rotation) i.e. the backs have the same marks as the faces.
grid_domino_marks <- function(layout) {
	left <- layout$left
	right <- layout$right
	top <- layout$top
	bottom <- layout$bottom
	xs <- left + seq.int(0L, N_COLUMNS) * TILE_WIDTH
	ys <- top - seq.int(0L, layout$n_rows) * TILE_HEIGHT
	gp_cm <- gpar(col = "black", lwd = 1)

	# Crop marks
	grid.segments(
		x0 = c(xs, xs),
		x1 = c(xs, xs),
		y0 = rep(c(top + BLEED, bottom - BLEED), each = length(xs)),
		y1 = rep(
			c(top + BLEED + CROPMARK_LENGTH, bottom - BLEED - CROPMARK_LENGTH),
			each = length(xs)
		),
		default.units = "in",
		gp = gp_cm
	)
	grid.segments(
		x0 = rep(c(left - BLEED, right + BLEED), each = length(ys)),
		x1 = rep(
			c(left - BLEED - CROPMARK_LENGTH, right + BLEED + CROPMARK_LENGTH),
			each = length(ys)
		),
		y0 = c(ys, ys),
		y1 = c(ys, ys),
		default.units = "in",
		gp = gp_cm
	)

	# Registration marks centered on the outermost top and bottom vertical crop marks
	# (as in the `piecepackr` print-and-play layouts).
	# Squared on the last sheet and circled on the earlier sheets
	# so that one doesn't pair a face with the back of a differently sized sheet.
	if (layout$squared) {
		crosshair_grob <- piecepackr::squaredSegmentsCrosshairGrob
	} else {
		crosshair_grob <- piecepackr::circledSegmentsCrosshairGrob
	}
	offset <- BLEED + CROPMARK_LENGTH / 2
	size <- unit(REGISTRATION_SIZE, "in")
	grid.draw(crosshair_grob(
		x = unit(rep(c(left, right), 2L), "in"),
		y = unit(rep(c(top + offset, bottom - offset), each = 2L), "in"),
		width = size,
		height = size,
		gp = gp_cm
	))
	invisible(NULL)
}
