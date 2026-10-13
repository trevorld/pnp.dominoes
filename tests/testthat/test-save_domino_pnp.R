pips <- function(df) pmax(df$suit, df$rank) - 1L
sheet_sizes <- function(pages) unname(vapply(pages, nrow, integer(1L)))

# Which prefixes of sheets are complete double-`m` sets i.e. hold (m + 1)(m + 2) / 2 tiles
nested_sets <- function(pages) {
	m <- (sqrt(1 + 8 * cumsum(sheet_sizes(pages))) - 3) / 2
	ifelse(m == floor(m), m, NA_real_)
}

test_that("double_n_tiles() orders tiles so that every smaller set is a prefix", {
	df <- double_n_tiles(18L)
	expect_equal(pips(df), rep(0:18, times = 1:19))
	expect_equal(anyDuplicated(df[c("suit", "rank")]), 0L)
})

test_that("domino_pages_12() splits a double-12 set into nested sets", {
	pages <- domino_pages_12()
	expect_equal(sheet_sizes(pages), c(28L, 28L, 35L))
	expect_equal(nested_sets(pages), c(6, NA, 12))
	expect_equal(pips(do.call(rbind, pages)), rep(0:12, times = 1:13))
})

test_that("domino_pages_18() splits a double-18 set into nested sets", {
	pages <- domino_pages_18()
	expect_equal(sheet_sizes(pages), c(35L, 35L, 35L, 31L, 35L, 19L))
	expect_equal(nested_sets(pages), c(NA, NA, 13, 15, 17, 18))
	expect_equal(pips(do.call(rbind, pages)), rep(0:18, times = 1:19))
})

test_that("save_domino_pnp_12() and save_domino_pnp_18() work", {
	f12 <- save_domino_pnp_12(tempfile(fileext = ".pdf"))
	on.exit(unlink(f12), add = TRUE)
	expect_equal(as.integer(xmpdf::n_pages(f12)), 8L)

	f18 <- save_domino_pnp_18(
		tempfile(fileext = ".pdf"),
		paper = "a4",
		background_color = "black",
		pip_color = "white"
	)
	on.exit(unlink(f18), add = TRUE)
	expect_equal(as.integer(xmpdf::n_pages(f18)), 14L)
})
