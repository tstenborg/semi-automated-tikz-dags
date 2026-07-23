# Semi-Automated Ti*k*Z Directed Acyclic Graphs in R

![human-only code](https://img.shields.io/badge/human--only-code-white)

This repository holds digital assets associated with the article
"Semi-automated Ti*k*Z Directed Acyclic Graphs in R" [[1](#references)]. That
article walks through rendering directed acyclic graphs (DAGs) for LaTeX. An R
script generates DAG rendering code for Ti*k*Z, the LaTeX graphics package. The
code is then copied to the system's clipboard, with the intent that users paste
it into a LaTeX document for typesetting.

---

<figure>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/reef-ecology-directed-acyclic-graph-dm.svg">
    <img src="assets/reef-ecology-directed-acyclic-graph-lm.svg" loading="lazy" alt="Directed acyclic graph for coral reef ecology, showing how marine protected areas influence reef fish biomass." width="100%">
  </picture>
  <br>
  <figcaption>Figure 1. Directed acyclic graph (DAG) for coral reef ecology. The DAG visualises the causal structure of the influence of marine protected areas (MPAs) on reef fish biomass. <i>Human gravity</i> measures the human population near a reef, divided by the square of the time it takes to travel to that reef. Adapted from Stenborg [<a href="#references">1</a>].</figcaption>
</figure>

---

## Table of Contents

- [Key Files](#key-files)
- [Software Requirements](#software-requirements)
- [Quality Assurance](#quality-assurance)
- [Getting Started](#getting-started)
- [Acknowledgements](#acknowledgements)
- [References](#references)

## Key Files

| File                               | Notes       |
| :--------------------------------- | :---------- |
| `src/semi-automated-tikz-dags.R`   | R script.   |
| `src/semi-automated-tikz-dags.tex` | LaTeX file. |

## Software Requirements

| Software          | Notes                                                                                                                               |
| :---------------- | :---------------------------------------------------------------------------------------------------------------------------------- |
| LaTeX             | [Available here](https://www.latex-project.org). Free.                                                                              |
| R<br>&nbsp;       | [Available here](https://www.r-project.org/). Free.<br>&nbsp;&nbsp;&nbsp;Version 4.6.x required.                                    |
| RStudio<br>&nbsp; | [Details here](https://posit.co/products/open-source/rstudio). Optional.<br>&nbsp;&nbsp;&nbsp;Free and fee-based options available. |

### LaTeX Configuration

Please ensure the LaTeX environment has the following packages installed:

- standalone.
- tikz.

## Quality Assurance

The repository code was tested in the following environment.

<details>
<summary>Windows Test Environment</summary>

<br>

| Type          | Component        | Version                                |
| :------------ | :--------------- | :------------------------------------- |
| Platform      | Operating system | Windows 11, 25H2 (OS Build 26200.8875) |
| Software      | MiKTeX           | 26.5                                   |
| &quot;        | R                | 4.6.1                                  |
| &quot;        | RStudio          | 2026.07.0 (Build 139)                  |
| &quot;        | pdfLaTeX         | MiKTeX-pdfTeX 4.27                     |
| LaTeX package | standalone       | 1.5a                                   |
| &quot;        | tikz             | 3.1.11a                                |

</details>

## Getting Started

### Ti*k*Z DAGs

The file `semi-automated-tikz-dags.R` should be run from R, or an R-compatible
IDE like RStudio.

That R script generates Ti*k*Z code for rendering DAGs. The Ti*k*Z code is
automatically copied to the system's clipboard. The Ti*k*Z code should be
manually pasted from the system's clipboard into a LaTeX document (e.g., via
Ctrl + V in Windows).

If the LaTeX document doesn't already import the `tikz` package, it should be
edited to do so (e.g., via `\usepackage{tikz}`).

### Node Borders

The generated Ti*k*Z code renders *naked nodes*, that is, Ti*k*Z nodes without a
surrounding border. To render DAGs with vertex outlines, shapes must be added
manually to the Ti*k*Z code (hence, *semi-automated*, not automated DAGs.)
Annotating Ti*k*Z nodes with a `shape` option suffices. Example syntax is
given below.

Naked Ti*k*Z node.

```TeX
\node (1) at (0,1) {Depth};
```

Annotated Ti*k*Z node.

```TeX
\node (1) at (0,1) [shape=circle,draw] {Depth};
```

### LaTeX Typesetting

To render and typeset a DAG, compile the annotated LaTeX document.

The file `semi-automated-tikz-dags.tex`, supplied in this repository, holds
example markup obtained by implementing the process described here. That file
takes the additional step of applying the `standalone` package to crop output to
DAG content.

## Acknowledgements

This work was supported by the Australian Research Council Training Centre in
Data Analytics for Resources and Environments (project ICI9010031).

## References

1. Stenborg, T 2024, "Semi-automated Ti*k*Z directed acyclic graphs in R",
   TUGboat, vol. 45, no. 1, pp. 115&ndash;116.\
   [View PDF](https://tug.org/TUGboat/tb45-1/tb139stenborg-dags.pdf) &nbsp;
   [View at publisher](https://tug.org/TUGboat/tb45-1/tb139stenborg-dags.html)
   &nbsp; [SciX](https://scixplorer.org/abs/2024TUGbt..45..115S/abstract)
