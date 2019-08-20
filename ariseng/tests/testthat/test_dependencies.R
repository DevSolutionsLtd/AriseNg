test_that("Dependency check works", {
  dEnt <- "DataEntry"
  if (dEnt %in% .packages(all.available = TRUE) && curl::has_internet()) {
    remove.packages(dEnt)
    on.exit(install.packages(dEnt))
  }
  
  expect_condition(check_dependencies())
  expect_message(check_dependencies())
  expect_false(check_dependencies(silent = TRUE))
  skip_if_offline()
  expect_message(check_dependencies(),
                 "Required package(s) missing. Run 'fetch_dependencies()'",
                 fixed = TRUE)

})
