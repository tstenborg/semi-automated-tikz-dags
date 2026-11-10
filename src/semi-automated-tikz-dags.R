# Semi-automated TikZ directed acyclic graphs in R.
#
# This script generates TikZ code for rendering directed acyclic graphs (DAGs).
# That TikZ code is copied to the system's clipboard, with the intent that
# users paste it into a LaTeX document for typesetting.
#
# Accompanying article:
# Stenborg, T 2024, "Semi-automated TikZ Directed Acyclic Graphs in R",
# TUGboat, vol. 45, no. 1, pp. 115-116.


################################################################################
# Set up dependencies of causalDisco, the key DAG generation package.

# N.B. The order of package listings determines their installation order and
#      should not be changed. Otherwise, dependency errors may arise.

# Define CRAN package dependencies and their versions, set one.
packages_cran_one <- c("BH" = "1.90.0.1",
                       "DEoptimR" = "1.2.0",
                       "R6" = "2.6.1",
                       "RColorBrewer" = "1.1.3",
                       "Rcpp" = "1.1.2",
                       "abind" = "1.4.8",
                       "base64enc" = "0.1.6",
                       "bdsmatrix" = "1.3.7",
                       "clipr" = "0.8.1",
                       "clue" = "0.3.68",
                       "colorspace" = "2.1.3",
                       "corpcor" = "1.6.10",
                       "cpp11" = "0.5.5",
                       "curl" = "7.1.0",
                       "digest" = "0.6.39",
                       "evaluate" = "1.0.5",
                       "farver" = "2.1.2",
                       "fastICA" = "1.2.7",
                       "fastmap" = "1.2.0",
                       "fs" = "2.1.0",
                       "generics" = "0.1.4",
                       "gtools" = "3.9.5",
                       "jsonlite" = "2.0.0",
                       "labeling" = "0.4.3",
                       "mime" = "0.13",
                       "pkgconfig" = "2.0.3",
                       "rappdirs" = "0.3.4",
                       "sfsmisc" = "1.1.24",
                       "viridisLite" = "0.4.3",
                       "xfun" = "0.60",
                       "yaml" = "2.3.12",
                       "zoo" = "1.8.15",
                       "RcppArmadillo" = "15.4.0.1",
                       "cachem" = "1.1.0",
                       "htmltools" = "0.5.9",
                       "highr" = "0.12",
                       "igraph" = "2.3.3",
                       "lmtest" = "0.9.40",
                       "magick" = "2.9.1",
                       "robustbase" = "0.99.7",
                       "scales" = "1.4.0",
                       "tinytex" = "0.60",
                       "vcd" = "1.4.13",
                       "fontawesome" = "0.5.3",
                       "jquerylib" = "0.1.4",
                       "knitr" = "1.51",
                       "memoise" = "2.0.1",
                       "sass" = "0.4.10",
                       "bslib" = "0.11.0",
                       "rmarkdown" = "2.31",
                       "BiocManager" = "1.30.27")

# Define Bioconductor package dependencies and their versions.
# These package versions are associated with Bioconductor release 3.23.
bioconductor_release <- "3.23"
packages_bioconductor <- c("BiocGenerics" = "0.58.1",
                           "BiocVersion" = "3.23.1",
                           "graph" = "1.90.0",
                           "RBGL" = "1.88.0",
                           "Rgraphviz" = "2.56.0")

# Define CRAN package dependencies and their versions, set two.
# N.B. causalDisco 0.9.5 was the last version with a "tamat" function, used to
#      create a temporal adjacency matrix.
packages_cran_two <- c("ggm" = "2.5.2",
                       "pcalg" = "2.7.12",
                       "causalDisco" = "0.9.5")

################################################################################


################################################################################
# Begin function declarations.


is_install_needed <- function(package_name, package_version) {

  # This function checks if an R package needs installation.
  # The package is flagged for installation if:
  #    a) the package is missing, or
  #    b) the package is present, but not at the specified version.
  #
  # Inputs
  #
  #   Name: package_name
  #   Expected value: The name of an R package. String.
  #   Example value: "knitr"
  #
  #   Name: package_version
  #   Expected value: The version of an R package. String.
  #   Example value: "1.51"
  #
  # Outputs
  #   Unnamed Boolean.
  #   Expected values:
  #     TRUE if package installation is needed.
  #     FALSE if package installation is not needed

  if (!requireNamespace(package_name, quietly = TRUE)) {
    # If the package is missing, install the desired version.
    TRUE

  } else if (packageVersion(package_name) != package_version) {
    # If the package is present at the wrong version, install the desired one.
    TRUE

  } else {
    FALSE
  }

}


robust_install <- function(func_install, args_install) {

  # This function attempts R package installation.
  # Error handling has been added to allow for, e.g., network outages.
  #
  # Inputs
  #
  #   Name: func_install
  #   Expected value: An R package installation function.
  #
  #   Name: args_install
  #   Expected value:
  #     Arguments to pass to func_install.
  #     It's assumed args_install is either:
  #     a) a list whose first element is a package name (and later elements are
  #          other arguments to the installation function), or
  #     b) a vector of package names.
  #
  # Outputs
  #   Name: result_install
  #   Expected values:
  #     TRUE if package installation is error-free.
  #     Execution is stopped otherwise.


  # Determine how installation function arguments were passed in.
  is_list_args <- is.list(args_install)
  is_vector_args <- is.vector(args_install)

  # Attempt package(s) installation.
  # Some package installation functions fail with an error.
  # Some package installation functions fail with a warning, not an error.
  # Omit complex handling, custom installation occur later.
  tryCatch(
    if (isTRUE(is_list_args)) {
      # Install packages using arguments from an input list.
      do.call(func_install, args_install)
    } else {
      # Install packages using arguments from an input vector.
      func_install(args_install)
    },
    error = function(e) {
      print(e)
    }
  )


  # Test if package(s) installation was successful.
  result_install <- TRUE
  if (isTRUE(is_list_args)) {
    if (!requireNamespace(args_install[[1]], quietly = TRUE)) {
      result_install <- args_install[[1]]
    }
  } else if (isTRUE(is_vector_args)) {
    for (pkg in args_install) {
      if (!requireNamespace(pkg, quietly = TRUE)) {
        result_install <- pkg
        break
      }
    }
  } else {
    result_install <- "Invalid package installation arguments."
  }


  if (isTRUE(result_install)) {
    result_install
  } else {
    error_msg <- paste0("Package installation error [", result_install, "].")
    stop(error_msg, call. = FALSE)
  }
}


install_dependencies <- function(vec_packages, bioconductor_packages = FALSE) {

  # This function triggers installation of any missing dependencies.
  # Specific package versions are checked.
  #
  # Inputs
  #
  #   Name: vec_packages
  #   Expected value: A vector of package name/version pairs. String.
  #   Example value: c("knitr" = "1.51", "rmarkdown" = "2.31")
  #
  #   Name: bioconductor_packages
  #   Expected value: A flag indicating Bioconductor packages. Boolean.
  #   Example value: FALSE.
  #
  # Outputs
  #   None.

  # Install missing packages, and set existing ones to the desired versions.
  for (i in seq_along(vec_packages)) {

    install_package <- is_install_needed(names(vec_packages)[i],
                                         vec_packages[i])

    if (isTRUE(install_package)) {

      if (isTRUE(bioconductor_packages)) {
        # Install Bioconductor packages.
        # Use Bioconductor releases, not individual package versions.
        robust_install(BiocManager::install,
                       list(pkgs = c(names(vec_packages)[i]),
                            lib = .libPaths()[1],
                            update = FALSE,
                            version = bioconductor_release))

      } else {
        # Install CRAN packages.
        robust_install(remotes::install_version,
                       list(package = names(vec_packages)[i],
                            version = vec_packages[i],
                            lib = .libPaths()[1]))
      }
    }
  }

}

# End function declarations.
################################################################################


################################################################################
# Prepare for version-specific package installations.
for (pkg in c("remotes")) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    robust_install(install.packages, list(pkgs = pkg, lib = .libPaths()[1]))
  }
}

# Ensure causalDisco CRAN dependencies are installed.
install_dependencies(vec_packages = packages_cran_one,
                     bioconductor_packages = FALSE)

# Ensure causalDisco Bioconductor dependencies are installed.
install_dependencies(vec_packages = packages_bioconductor,
                     bioconductor_packages = TRUE)

# Ensure final causalDisco CRAN dependencies are installed.
vec_packages <- packages_cran_two
install_dependencies(vec_packages = packages_cran_two,
                     bioconductor_packages = FALSE)

################################################################################


# Initialise a DAG matrix.
dag_matrix <- matrix(
  c(0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0,
    1, 1, 0, 0, 0, 0, 0,
    1, 0, 1, 1, 0, 0, 0,
    0, 1, 1, 0, 1, 0, 0,
    0, 0, 0, 1, 0, 1, 0),
  nrow = 7,
  ncol = 7,
  byrow = TRUE
)

# Specify matching matrix row and column names.
rownames(dag_matrix) <- c("a_nd1", "a_nd2", "a_nd3",
                          "b_nd4", "b_nd5", "b_nd6", "c_nd7")
colnames(dag_matrix) <- rownames(dag_matrix)

# Create a temporal adjacency matrix.
model <- causalDisco::tamat(dag_matrix, c("a", "b", "c"))

# Render TikZ and copy to clipboard.
causalDisco::maketikz(model, xjit = 0,
  markperiods = FALSE, addAxis = FALSE,
  varLabels = list(a_nd1 = "Depth",
                   a_nd2 = "\\footnotesize Structural\\\\
                            \\footnotesize Complexity",
                   a_nd3 = "\\footnotesize Human\\\\
                            \\footnotesize Gravity",
                   b_nd4 = "MPA",
                   b_nd5 = "\\footnotesize Fishing\\\\
                            \\footnotesize Pressure",
                   b_nd6 = "\\footnotesize Reef Fish\\\\
                            \\footnotesize Biomass",
                   c_nd7 = "\\footnotesize Coral\\\\
                            \\footnotesize Cover")
)
