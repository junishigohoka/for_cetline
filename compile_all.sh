#!/bin/bash



# plan
pandoc src/plan.md -o plan.pdf --filter pandoc-crossref
#pandoc src/plan.md -o protocols_docx/plan.docx --filter pandoc-crossref


# prep_pupae
pandoc src/prep_pupae.md -o protocols_pdf/prep_papae.pdf --filter pandoc-crossref
#pandoc src/prep_pupae.md -o protocols_docx/prep_papae.docx

# Eclosion monitor
pandoc src/eclosion_monitor.md -o protocols_pdf/eclosion_monitor.pdf --filter pandoc-crossref
#pandoc src/eclosion_monitor.md -o protocols_docx/eclosion_monitor.docx


# FIJI
pandoc src/fiji.md -o protocols_pdf/fiji.pdf --filter pandoc-crossref
#pandoc src/fiji.md -o protocols_docx/fiji.docx --filter pandoc-crossref


# Image analysis
pandoc src/image_analysis.md -o protocols_pdf/image_analysis.pdf --filter pandoc-crossref
#pandoc src/image_analysis.md -o protocols_docx/image_analysis.docx --filter pandoc-crossref


# Eclosion detection
Rscript -e "rmarkdown::render('src/eclosion_detection.Rmd', output_dir = 'protocols_pdf')"


# DNA extraction
libreoffice --headless --convert-to pdf src/DNA_extraction.docx --outdir protocols_pdf

# Amplicon PCR
libreoffice --headless --convert-to pdf src/amplicon_PCR.docx --outdir protocols_pdf

