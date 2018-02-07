LATEX=pdflatex
LATEXOPT=--shell-escape
NONSTOP=--interaction=nonstopmode
BIBTEX=bibtex

LATEXMK=latexmk
LATEXMKOPT=-pdf
CONTINUOUS=-pvc

BIBLIO=references
MAIN=main
DRAFT=draft
CHANGES_POSTFIX=_changes
TEX_FILES := $(shell find tex/* -type f)
SOURCES=$(MAIN).tex $(TEX_FILES) Makefile
DRAFT_SOURCES=$(DRAFT).tex $(TEX_FILES) Makefile
FIGURES := $(shell find figures/* -type f)

all: $(MAIN).pdf

.refresh:
	touch .refresh

$(MAIN).pdf: $(MAIN).tex .refresh $(SOURCES) $(FIGURES)
	$(LATEXMK) $(LATEXMKOPT) $(CONTINUOUS) \
            -pdflatex="$(LATEX) $(LATEXOPT) $(NONSTOP) %O %S" $(MAIN)
$(BIBLIO):
	$(BIBTEX) $(MAIN).aux

force:
	touch .refresh
	rm $(MAIN).pdf
	$(LATEXMK) $(LATEXMKOPT) $(CONTINUOUS) -pdflatex="$(LATEX) $(LATEXOPT) %O %S" $(MAIN)

clean:
	$(LATEXMK) -f -C $(MAIN)
	$(LATEXMK) -f -C $(DRAFT)
	$(LATEXMK) -f -C $(MAIN)$(CHANGES_POSTFIX)
	rm -f $(MAIN).pdfsync $(DRAFT).pdfsync
	rm -rf *~ *.tmp
	rm -f *.bbl *.blg *.aux *.end *.fls *.log *.out *.fdb_latexmk
	rm -f $(MAIN)$(CHANGES_POSTFIX).tex

once:
	$(LATEXMK) $(LATEXMKOPT) -pdflatex="$(LATEX) $(LATEXOPT) %O %S" $(MAIN)

debug:
	$(LATEX) $(LATEXOPT) $(MAIN)

draft: $(DRAFT).tex $(DRAFT_SOURCES) $(FIGURES)
	$(LATEXMK) $(LATEXMKOPT) -pdflatex="$(LATEX) $(LATEXOPT) %O %S" $(DRAFT)

$(MAIN)$(CHANGES_POSTFIX).tex: $(MAIN).tex $(DRAFT).tex $(SOURCES) $(FIGURES)
	# rm $(MAIN)$(CHANGES_POSTFIX).tex
	latexdiff --flatten $(DRAFT).tex $(MAIN).tex > $(MAIN)$(CHANGES_POSTFIX).tex

diff: $(MAIN)$(CHANGES_POSTFIX).tex

compile_diff: $(MAIN)$(CHANGES_POSTFIX).tex $(FIGURES)
	$(LATEXMK) $(LATEXMKOPT) -pdflatex="$(LATEX) $(LATEXOPT) %O %S" $(MAIN)$(CHANGES_POSTFIX)


.PHONY: clean force once all
