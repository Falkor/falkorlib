(TeX-add-style-hook
 "main.tex"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("letter" "11pt" "a4paper")))
   (TeX-run-style-hooks
    "latex2e"
    "_content"
    "letter"
    "letter11"
    "_style"
    "microtype"
    "longtable"
    "booktabs"
    "fontawesome")
   (TeX-add-symbols
    "vhrulefill"
    "Location"
    "Who"
    "What"
    "Where"
    "Address"
    "CityZip"
    "Email"
    "TEL"
    "URL"
    "LinkedIN"
    "Twitter"
    "GoogleScholar"
    "Skype"
    "opening"
    "closing"))
 :latex)

