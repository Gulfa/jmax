;;; jmax-mode.el --- Summary
;; Copyright(C) 2014 John Kitchin

;; Author: John Kitchin <jkitchin@andrew.cmu.edu>
;; This file is not currently part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program ; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:
;; some utilities for the jmax

(require 'easymenu)

;;; Code:

(defvar jmax-mode-map
  (let ((map (make-sparse-keymap)))
    ;; Note \e\e is Esc Esc
    (define-key map (kbd "\e\er") 'email-region)
    (define-key map (kbd "\e\eh") 'email-heading)
    (define-key map (kbd "\e\ep") 'ox-manuscript-export-and-build-and-email)
    (define-key map (kbd "\e\ea") 'ox-archive-create-and-mail)
    ;; insert keys
    (define-key map (kbd "\e\eR") 'org-ref-insert-ref-link)
    (define-key map (kbd "\e\eC") 'org-ref-insert-cite-link)
    (define-key map (kbd "\e\ef") 'org-footnote-action)
    map)
  "Keymap for jmax mode.")

;;email aliases
(defalias 'jer 'email-region)
(defalias 'jeh 'email-heading)
(defalias 'jep 'ox-manuscript-export-and-build-and-email)
(defalias 'jea 'ox-archive-create-and-mail)

;; insert aliases
(defalias 'jif 'org-footnote-action)
(defalias 'jir 'org-ref-insert-ref-link)
(defalias 'jic 'org-ref-insert-cite-link)

(global-set-key (kbd "\e\eg") 'goto-line)


(defun kg-get-num-incoming-changes ()
  "Return number of changes the remote is different than local."
  (unless (shell-command "git rev-parse --is-inside-work-tree")
    (error "You are not in a git repo.  We think you are in %s" default-directory))
  (shell-command "git fetch origin")
  (string-to-number (shell-command-to-string "git rev-list HEAD...origin/master --count")))


(defun kg-update ()
  "Run git pull.  Refresh file currently visited."
  (interactive)
  (shell-command "git pull")
  (revert-buffer t t))


(defun jmax-customize-user ()
  "Open jmax/user/user.el. If it does not exist, copy the example
one and open it."
  (interactive)
  (let ((user-file (expand-file-name
		    "user/user.el"
		    starter-kit-dir)))
    (unless (file-exists-p user-file)
      (copy-file (expand-file-name
		  "user/user.example"
		  starter-kit-dir)
		 user-file))
    (find-file user-file)))


(easy-menu-define my-menu jmax-mode-map "My own menu"
  '("Jmax"
    [(format "Update (-%s)" (kg-get-num-incoming-changes)) kg-update t]
    ("email"
     ["email region" email-region t]
     ["email org-mode heading" email-heading t]
     ["email org-mode as PDF" ox-manuscript-export-and-build-and-email t]
     ["email org-archive" ox-archive-create-and-mail t])
    ("org-mode"
     ["Toggle symbols" org-toggle-pretty-entities t]
     ["Toggle inline images" org-toggle-inline-images t]
     ["Toggle LaTeX images" org-toggle-latex-overlays t]
     ("Markup"
      ["Bold" bold-region-or-point t]
      ["Italics" italics-region-or-point]
      ["Underline" underline-region-or-point t]
      ["Strikethrough" strikethrough-region-or-point t]
      ["Verbatim" verbatim-region-or-point t]
      ["Code" code-region-or-point t]
      ["Superscript" superscript-region-or-point t]
      ["Subscript" subscript-region-or-point t]
      ["Latex snippet" latex-math-region-or-point t])
     ("Track changes"
      ["Toggle track changes" (lambda ()
				(interactive)
				(unless cm-mode
				  (cm-mode))
				(cm-follow-changes 'toggle))
       t]
      ["Accept/reject changes" cm-accept/reject-all-changes t]
      ["Track change hydra" cm/body t])
     ("export"
      ["manuscript PDF" ox-manuscript-export-and-build-and-open t]
      ["submission PDF" ox-manuscript-build-submission-manuscript-and-open t]))
    ("bibtex"
     ["find non-ascii characters" org-ref-find-non-ascii-characters t]
     ["extract bibtex entries from org" org-ref-extract-bibtex-entries t]
     ["find bad citations" org-ref-find-bad-citations t]
     ["  reformat entry" bibtex-reformat (eq major-mode 'bibtex-mode)]
     ["  clean entry" org-ref-clean-bibtex-entry (eq major-mode 'bibtex-mode)]
     ["  Open entry pdf" org-ref-open-bibtex-pdf (eq major-mode 'bibtex-mode)]
     ["  Open entry url" org-ref-open-in-browser (eq major-mode 'bibtex-mode)]
     ["  Open entry in WOS" jmax-bibtex-wos (eq major-mode 'bibtex-mode)]
     ["  Find related entries" jmax-bibtex-wos-related (eq major-mode 'bibtex-mode)]
     ["  Find citing articles" jmax-bibtex-wos-citing (eq major-mode 'bibtex-mode)]
     ["  Open entry in Google Scholar" jmax-bibtex-google-scholar (eq major-mode 'bibtex-mode)]
     ["  Open entry in Crossref" jmax-bibtex-crossref (eq major-mode 'bibtex-mode)]
     ["  Open entry in Pubmed" jmax-bibtex-pubmed (eq major-mode 'bibtex-mode)]
     ["  validate bibtex file" bibtex-validate (eq major-mode 'bibtex-mode)]
     ["  sort bibtex file" bibtex-sort-buffer (eq major-mode 'bibtex-mode)]
     ["  build bibliography pdf from bib file" org-ref-build-full-bibliography (eq major-mode 'bibtex-mode)])
    ("doi-utils"
     ["Insert bibtex entry from doi" doi-utils-add-bibtex-entry-from-doi t]
     ["Insert bibtex entry from crossref" doi-utils-add-entry-from-crossref-query t])
    ("words"
     ["Menu" words t]
     ["Web of Knowledge" wos t]
     ["Scopus" scopus t]
     ["Pubmed" pubmed t]
     ["Crossref" crossref t]
     ["Lookup in Google" words-google t]
     ["Lookup in Twitter" words-twitter t]
     ["Lookup in WOS" words-wos t]
     ["Lookup in Scopus" words-scopus t]
     ["Lookup in Pubmed" words-pubmed t]
     ["Lookup in Crossref" words-crossref t]
     ["Lookup in Arxiv" words-arxiv]
     ["Lookup in Dictionary" words-dictionary t]
     ["Lookup in Thesaurus" words-thesaurus t])
    ["Help with jmax" jmax-help t]
    ["Customize user.el" jmax-customize-user t]))


(define-minor-mode jmax-mode
  "Minor mode for jmax

\\{jmax-mode-map}"
;  :lighter " JM"
  :global t
  :keymap jmax-mode-map)

(provide 'jmax-mode)

;;; jmax-mode.el ends here
