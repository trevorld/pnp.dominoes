test_that("domino_pages_12() splits a double-12 set into nested sets", {
	pages <- domino_pages_12()
	expect_equal(unname(vapply(pages, nrow, integer(1L))), c(28L, 28L, 35L))
	max_pips <- function(df) max(pmax(df$suit, df$rank)) - 1L
	expect_equal(max_pips(pages[[1L]]), 6L)
	expect_equal(max_pips(do.call(rbind, pages[1:2])[1:55, ]), 9L)
	expect_equal(max_pips(pages[[3L]]), 12L)
	df <- do.call(rbind, pages)
	expect_equal(anyDuplicated(df[c("suit", "rank")]), 0L)
})

test_that("domino_pages_18() splits a double-18 set into nested sets", {
	pages <- domino_pages_18()
	expect_equal(unname(vapply(pages, nrow, integer(1L))), c(35L, 35L, 35L, 31L, 35L, 19L))
	max_pips <- function(df) max(pmax(df$suit, df$rank)) - 1L
	expect_equal(max_pips(do.call(rbind, pages[1:4])), 15L)
	expect_equal(max_pips(pages[[5L]]), 17L)
	expect_equal(min(pmax(pages[[5L]]$suit, pages[[5L]]$rank)) - 1L, 16L)
	expect_equal(max_pips(pages[[6L]]), 18L)
	df <- do.call(rbind, pages)
	expect_equal(anyDuplicated(df[c("suit", "rank")]), 0L)
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
