---
geometry: margin=4cm
title: Installing `FIJI` and custom macros
date: \today
author: Jun Ishigohoka
colorlinks: true
linkcolor: blue
urlcolor: blue
numbersections: true
fontsize: 11pt
linestretch: 1
linkReferences: true
nameInLink: true
header-includes:
  - |
    \usepackage{xcolor}
    \usepackage{framed}
    \definecolor{shadecolor}{gray}{0.95}
    \AtBeginDocument{%
      \ifcsname Shaded\endcsname
        \renewenvironment{Shaded}{\begin{snugshade}}{\end{snugshade}}
      \fi
    }

figPrefix:
  - "Fig. "
  - "Figs. "

tblPrefix:
  - "Table "
  - "Tables "

---

\pagenumbering{arabic}
\setcounter{page}{1}


# Introduction

We use [`FIJI`](https://imagej.net/software/fiji/) to detect pupae, and a custom `FIJI` macro to measure pixel intensity inside the pupae over time, which will be later analysed to detect eclosion events.
Here, I describe how to install `FIJI` and custom macros.


# `FIJI`

Just download the package from <https://imagej.net/software/fiji/>, which comes with a binary executable.



# Custom macros

I wrote macros to run eclosion analysis.
They are maintained in <https://github.com/junishigohoka/EclosionMonitorJ>.

To install the macros...

- If you know how to use `git`, clone this repository in the `Fiji.app/scripts/Plugins/`.
- If you do not know how to use `git`, well, learn it...... or download the repository by clicking "Code" (A green button) -> Download ZIP.
Each `ijm` file is a macro.
Create a new folder "`EclosionMonitorJ` "in `Fiji.app/scripts/Plugins/`, and place the `ijm` files inside `EclosionMonitorJ`.
This will make `FIJI` recognise the macros as functions of `EclosionMonitorJ` plugin.






