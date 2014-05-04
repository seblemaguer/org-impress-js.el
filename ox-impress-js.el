;;; ox-impress-js.el --- impress.js Back-End for Org Export Engine

;; Copyright (C) 2014 Takumi Kinjo.

;; Author: Takumi KINJO <takumi dot kinjo at gmail dot org>
;; URL: https://github.com/kinjo/org-impress-js.el
;; Version: 0.1
;; Keywords: outlines, hypermedia, calendar, wp

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This library implements a impress.js back-end for Org
;; generic exporter based on ox-html.el.

;; See http://orgmode.org/ about Org-mode and see 
;; http://bartaz.github.io/impress.js/ about impress.js.
;; I appreciate for their great works.

;; Original author: Carsten Dominik <carsten at orgmode dot org>
;;      Jambunathan K <kjambunathan at gmail dot com>

;;; Code:

;;; Dependencies

(require 'ox)
(require 'ox-publish)
(require 'format-spec)
(eval-when-compile (require 'cl) (require 'table nil 'noerror))


;;; Function Declarations

(declare-function org-id-find-id-file "org-id" (id))
(declare-function htmlize-region "ext:htmlize" (beg end))
(declare-function org-pop-to-buffer-same-window
		  "org-compat" (&optional buffer-or-name norecord label))
(declare-function mm-url-decode-entities "mm-url" ())

;;; Define Back-End

(org-export-define-backend 'impress-js
  '((bold . org-html-bold)
    (center-block . org-html-center-block)
    (clock . org-html-clock)
    (code . org-html-code)
    (drawer . org-html-drawer)
    (dynamic-block . org-html-dynamic-block)
    (entity . org-html-entity)
    (example-block . org-html-example-block)
    (export-block . org-html-export-block)
    (export-snippet . org-html-export-snippet)
    (fixed-width . org-html-fixed-width)
    (footnote-definition . org-impress-js-footnote-definition)
    (footnote-reference . org-html-footnote-reference)
    (headline . org-impress-js-headline)
    (horizontal-rule . org-html-horizontal-rule)
    (inline-src-block . org-html-inline-src-block)
    (inlinetask . org-html-inlinetask)
    (inner-template . org-html-inner-template)
    (italic . org-html-italic)
    (item . org-html-item)
    (keyword . org-impress-js-keyword)
    (latex-environment . org-html-latex-environment)
    (latex-fragment . org-html-latex-fragment)
    (line-break . org-html-line-break)
    (link . org-html-link)
    (paragraph . org-html-paragraph)
    (plain-list . org-html-plain-list)
    (plain-text . org-html-plain-text)
    (planning . org-html-planning)
    (property-drawer . org-html-property-drawer)
    (quote-block . org-html-quote-block)
    (quote-section . org-html-quote-section)
    (radio-target . org-html-radio-target)
    (section . org-impress-js-section)
    (special-block . org-html-special-block)
    (src-block . org-html-src-block)
    (statistics-cookie . org-html-statistics-cookie)
    (strike-through . org-html-strike-through)
    (subscript . org-html-subscript)
    (superscript . org-html-superscript)
    (table . org-html-table)
    (table-cell . org-html-table-cell)
    (table-row . org-html-table-row)
    (target . org-html-target)
    (template . org-impress-js-template)
    (timestamp . org-html-timestamp)
    (underline . org-html-underline)
    (verbatim . org-html-verbatim)
    (verse-block . org-html-verse-block))
  :export-block "impress.js"
  :filters-alist '((:filter-options . org-impress-js-infojs-install-script)
		   (:filter-final-output . org-html-final-function))
  :menu-entry
  '(?j "Export to impress.js HTML"
       ((?J "As impress.js HTML buffer" org-impress-js-export-as-html)
	(?j "As impress.js HTML file" org-impress-js-export-to-html)
	(?o "As impress.js HTML file and open"
	    (lambda (a s v b)
	      (if a (org-impress-js-export-to-html t s v b)
		(org-open-file (org-impress-js-export-to-html nil s v b)))))))
  :options-alist
  '((:html-extension nil nil org-html-extension)
    (:html-link-org-as-html nil nil org-html-link-org-files-as-html)
    (:html-doctype "HTML_DOCTYPE" nil org-impress-js-doctype)
    (:html-container "HTML_CONTAINER" nil org-html-container-element)
    (:html-html5-fancy nil "html5-fancy" org-html-html5-fancy)
    (:html-link-use-abs-url nil "html-link-use-abs-url" org-html-link-use-abs-url)
    (:html-description nil nil org-impress-js-description)
    (:html-fallback-message nil nil org-impress-js-fallback-message)
    (:html-hint-message nil nil org-impress-js-hint-message)
    (:html-hint-js nil nil org-impress-js-hint-js)
    (:html-link-home "HTML_LINK_HOME" nil org-html-link-home)
    (:html-link-up "HTML_LINK_UP" nil org-html-link-up)
    (:html-mathjax "HTML_MATHJAX" nil "" space)
    (:html-postamble nil "html-postamble" org-html-postamble)
    (:html-preamble nil "html-preamble" org-html-preamble)
    (:html-head "HTML_HEAD" nil org-html-head newline)
    (:html-head-extra "HTML_HEAD_EXTRA" nil org-html-head-extra newline)
    (:html-impress-js-stylesheet "IMPRESSJS_STYLE" nil org-impress-js-stylesheet newline)
    (:html-impress-js-javascript "IMPRESSJS_SRC" nil org-impress-js-javascript newline)
    (:html-head-include-default-style nil "html-style" org-html-head-include-default-style)
    (:html-head-include-scripts nil "html-scripts" org-html-head-include-scripts)
    (:html-table-attributes nil nil org-html-table-default-attributes)
    (:html-table-row-tags nil nil org-html-table-row-tags)
    (:html-xml-declaration nil nil org-html-xml-declaration)
    (:html-inline-images nil nil org-html-inline-images)
    (:infojs-opt "INFOJS_OPT" nil nil)
    ;; Redefine regular options.
    (:creator "CREATOR" nil org-html-creator-string)
    (:with-latex nil "tex" org-html-with-latex)
    ;; Retrieve LaTeX header for fragments.
    (:latex-header "LATEX_HEADER" nil nil newline)))


;;; Internal Variables


;;; User Configuration Variables

;;;; Handle infojs

(defun org-impress-js-infojs-install-script (exp-plist backend)
  "Install script in export options when appropriate.
EXP-PLIST is a plist containing export options.  BACKEND is the
export back-end currently used."

  ;; Disable toc option because slide can be broken when exported with toc.
  (plist-put exp-plist :with-toc nil)

  (unless (or (memq 'body-only (plist-get exp-plist :export-options))
	      (not org-html-use-infojs)
	      (and (eq org-html-use-infojs 'when-configured)
		   (or (not (plist-get exp-plist :infojs-opt))
		       (string-match "\\<view:nil\\>"
				     (plist-get exp-plist :infojs-opt)))))
    (let* ((template org-html-infojs-template)
	   (ptoc (plist-get exp-plist :with-toc))
	   (hlevels (plist-get exp-plist :headline-levels))
	   (sdepth hlevels)
	   (tdepth (if (integerp ptoc) (min ptoc hlevels) hlevels))
	   (options (plist-get exp-plist :infojs-opt))
	   (table org-html-infojs-opts-table)
	   style)
      (dolist (entry table)
	(let* ((opt (car entry))
	       (var (nth 1 entry))
	       ;; Compute default values for script option OPT from
	       ;; `org-html-infojs-options' variable.
	       (default
		 (let ((default (cdr (assq opt org-html-infojs-options))))
		   (if (and (symbolp default) (not (memq default '(t nil))))
		       (plist-get exp-plist default)
		     default)))
	       ;; Value set through INFOJS_OPT keyword has precedence
	       ;; over the default one.
	       (val (if (and options
			     (string-match (format "\\<%s:\\(\\S-+\\)" opt)
					   options))
			(match-string 1 options)
		      default)))
	  (case opt
	    (path (setq template
			(replace-regexp-in-string
			 "%SCRIPT_PATH" val template t t)))
	    (sdepth (when (integerp (read val))
		      (setq sdepth (min (read val) sdepth))))
	    (tdepth (when (integerp (read val))
		      (setq tdepth (min (read val) tdepth))))
	    (otherwise (setq val
			     (cond
			      ((or (eq val t) (equal val "t")) "1")
			      ((or (eq val nil) (equal val "nil")) "0")
			      ((stringp val) val)
			      (t (format "%s" val))))
		       (push (cons var val) style)))))
      ;; Now we set the depth of the *generated* TOC to SDEPTH,
      ;; because the toc will actually determine the splitting.  How
      ;; much of the toc will actually be displayed is governed by the
      ;; TDEPTH option.
      (setq exp-plist (plist-put exp-plist :with-toc sdepth))
      ;; The table of contents should not show more sections than we
      ;; generate.
      (setq tdepth (min tdepth sdepth))
      (push (cons "TOC_DEPTH" tdepth) style)
      ;; Build style string.
      (setq style (mapconcat
		   (lambda (x) (format "org_html_manager.set(\"%s\", \"%s\");"
				  (car x)
				  (cdr x)))
		   style "\n"))
      (when (and style (> (length style) 0))
	(and (string-match "%MANAGER_OPTIONS" template)
	     (setq style (replace-match style t t template))
	     (setq exp-plist
		   (plist-put
		    exp-plist :html-head-extra
		    (concat (or (plist-get exp-plist :html-head-extra) "")
			    "\n"
			    style)))))
      ;; This script absolutely needs the table of contents, so we
      ;; change that setting.
      (unless (plist-get exp-plist :with-toc)
	(setq exp-plist (plist-put exp-plist :with-toc t)))
      ;; Return the modified property list.
      exp-plist)))

;;;; Bold, etc.

(defcustom org-impress-js-text-markup-alist
  '((bold . "<b>%s</b>")
    (code . "<code>%s</code>")
    (italic . "<i>%s</i>")
    (strike-through . "<del>%s</del>")
    (underline . "<span class=\"underline\">%s</span>")
    (verbatim . "<code>%s</code>"))
  "Alist of HTML expressions to convert text markup.

The key must be a symbol among `bold', `code', `italic',
`strike-through', `underline' and `verbatim'.  The value is
a formatting string to wrap fontified text with.

If no association can be found for a given markup, text will be
returned as-is."
  :group 'org-export-impress-js
  :version "24.4"
  :package-version '(Org . "8.0")
  :type '(alist :key-type (symbol :tag "Markup type")
		:value-type (string :tag "Format string"))
  :options '(bold code italic strike-through underline verbatim))

(defcustom org-impress-js-indent nil
  "Non-nil means to indent the generated HTML.
Warning: non-nil may break indentation of source code blocks."
  :group 'org-export-impress-js
  :version "24.4"
  :package-version '(Org . "8.0")
  :type 'boolean)

(defcustom org-impress-js-use-unicode-chars nil
  "Non-nil means to use unicode characters instead of HTML entities."
  :group 'org-export-impress-js
  :version "24.4"
  :package-version '(Org . "8.0")
  :type 'boolean)

;;;; Drawers

(defcustom org-impress-js-format-drawer-function
  (lambda (name contents) contents)
  "Function called to format a drawer in HTML code.

The function must accept two parameters:
  NAME      the drawer name, like \"LOGBOOK\"
  CONTENTS  the contents of the drawer.

The function should return the string to be exported.

For example, the variable could be set to the following function
in order to mimic default behaviour:

The default value simply returns the value of CONTENTS."
  :group 'org-export-impress-js
  :version "24.4"
  :package-version '(Org . "8.0")
  :type 'function)

;;;; Footnotes

(defcustom org-impress-js-footnotes-section "<div id=\"footnotes\">
<h2 class=\"footnotes\">%s: </h2>
<div id=\"text-footnotes\">
%s
</div>
</div>"
  "Format for the footnotes section.
Should contain a two instances of %s.  The first will be replaced with the
language-specific word for \"Footnotes\", the second one will be replaced
by the footnotes themselves."
  :group 'org-export-impress-js
  :type 'string)

(defcustom org-impress-js-footnote-format "<sup>%s</sup>"
  "The format for the footnote reference.
%s will be replaced by the footnote reference itself."
  :group 'org-export-impress-js
  :type 'string)

(defcustom org-impress-js-footnote-separator "<sup>, </sup>"
  "Text used to separate footnotes."
  :group 'org-export-impress-js
  :type 'string)

;;;; Headline

(defcustom org-impress-js-toplevel-hlevel 2
  "The <H> level for level 1 headings in HTML export.
This is also important for the classes that will be wrapped around headlines
and outline structure.  If this variable is 1, the top-level headlines will
be <h1>, and the corresponding classes will be outline-1, section-number-1,
and outline-text-1.  If this is 2, all of these will get a 2 instead.
The default for this variable is 2, because we use <h1> for formatting the
document title."
  :group 'org-export-impress-js
  :type 'integer)

(defcustom org-impress-js-format-headline-function 'ignore
  "Function to format headline text.

This function will be called with 5 arguments:
TODO      the todo keyword (string or nil).
TODO-TYPE the type of todo (symbol: `todo', `done', nil)
PRIORITY  the priority of the headline (integer or nil)
TEXT      the main headline text (string).
TAGS      the tags (string or nil).

The function result will be used in the section format string."
  :group 'org-export-impress-js
  :version "24.4"
  :package-version '(Org . "8.0")
  :type 'function)

;;;; HTML-specific

(defcustom org-impress-js-allow-name-attribute-in-anchors nil
  "When nil, do not set \"name\" attribute in anchors.
By default, when appropriate, anchors are formatted with \"id\"
but without \"name\" attribute."
  :group 'org-export-impress-js
  :version "24.4"
  :package-version '(Org . "8.0")
  :type 'boolean)

;;;; Inlinetasks

(defcustom org-impress-js-format-inlinetask-function 'ignore
  "Function called to format an inlinetask in HTML code.

The function must accept six parameters:
  TODO      the todo keyword, as a string
  TODO-TYPE the todo type, a symbol among `todo', `done' and nil.
  PRIORITY  the inlinetask priority, as a string
  NAME      the inlinetask name, as a string.
  TAGS      the inlinetask tags, as a list of strings.
  CONTENTS  the contents of the inlinetask, as a string.

The function should return the string to be exported."
  :group 'org-export-impress-js
  :version "24.4"
  :package-version '(Org . "8.0")
  :type 'function)

;;;; FIXME: comment

(defcustom org-impress-js-description
  "impress.js is a presentation tool based on the power of CSS3 transforms and transitions in modern browsers and inspired by the idea behind prezi.com."
  "For metadata description."
  :group 'org-export-impress-js
  :type 'string)

(defcustom org-impress-js-fallback-message
  "    <p>Your browser <b>doesn't support the features required</b> by impress.js, so you are presented with a simplified version of this presentation.</p>
<p>For the best experience please use the latest <b>Chrome</b>, <b>Safari</b> or <b>Firefox</b> browser.</p>
"
  "impress.js fallback-message."
  :group 'org-export-impress-js
  :type 'string)

(defcustom org-impress-js-hint-message
  "    <p>Use a spacebar or arrow keys to navigate</p>\n"
  "impress.js hint message."
  :group 'org-export-impress-js
  :type 'string)

(defcustom org-impress-js-hint-js
  "if (\"ontouchstart\" in document.documentElement) {
document.querySelector(\".hint\").innerHTML = \"<p>Tap on the left or right to navigate</p>\";
}
"
  "impress.js hint JavaScript."
  :group 'org-export-impress-js
  :type 'string)

(defcustom org-impress-js-divs
  '((preamble  "div" "preamble")
    (content   "div" "impress")
    (postamble "div" "postamble"))
  "Alist of the three section elements for HTML export.
The car of each entry is one of 'preamble, 'content or 'postamble.
The cdrs of each entry are the ELEMENT_TYPE and ID for each
section of the exported document.

Note that changing the default will prevent you from using
org-info.js for your website."
  :group 'org-export-impress-js
  :version "24.4"
  :package-version '(Org . "8.0")
  :type '(list :greedy t
	       (list :tag "Preamble"
		     (const :format "" preamble)
		     (string :tag "element") (string :tag "     id"))
	       (list :tag "Content"
		     (const :format "" content)
		     (string :tag "element") (string :tag "     id"))
	       (list :tag "Postamble" (const :format "" postamble)
		     (string :tag "     id") (string :tag "element"))))

;;;; Template :: Generic

(defconst org-impress-js-doctype "html5"
  "Document type definition to use for exported impress.js HTML files.")

;;;; Template :: Styles

(defcustom org-impress-js-stylesheet "resources/css/impress-demo.css"
  "Path to a default CSS file for impress.js. 

Use IMPRESSJS_STYLE option in your org-mode file is available too."
  :group 'org-export-impress-js
  :version "24.4"
  :package-version '(Org . "8.0")
  :type 'string)

(defcustom org-impress-js-javascript "resources/js/impress.js"
  "Path to a JavaScript file for impress.js.

Use IMPRESSJS_SRC option in your org-mode file is available too."
  :group 'org-export-impress-js
  :version "24.4"
  :package-version '(Org . "8.0")
  :type 'string)

;;;; impress.js

(defcustom org-impress-js-default-slide-class "step slide"
  "Default of the class attribute for the slides. \"step\" and \"step slide\"
are available.")

(defcustom org-impress-js-default-translation '(1000 0 0)
  "Default translation vector for the slides. List are corresponding to
X, Y and Z axis.")

(defcustom org-impress-js-default-rotation '(0 0 0)
  "Default rotational vector for the slides. List are angles by degrees
around X, Y and Z axis.")


;;; Matrix calculation functions

(defmacro mnth (i j m)
  "Return a i-j-th value in 4x4 matrix correspond as below.

  | m00 m01 m02 m03 |
  | m10 m11 m12 m13 |
  | m20 m21 m22 m23 |
  | m30 m31 m32 m33 |"
  (list 'nth j (list 'nth i m)))

(defmacro vnth (i v)
  "Return a i-th value in 1x4 row vecotr."
  (list 'nth i v))

(defun make-vec (v)
  "Make a new vector form `v'. `v' is a 4-vector."
  (copy-tree v))

(defun make-matx (m)
  "Make a new matrix from `m'. `m' is a 4x4 matrix."
  (copy-tree m))

(defun unit-matx ()
  "Return a 4x4 unit matrix."
  (make-matx '((1 0 0 0)
	       (0 1 0 0)
	       (0 0 1 0)
	       (0 0 0 1))))

(defun add-vec (v0 v1)
  "Add vector `v0' and `v1'. `v0' and `v1' are 4-vectors."
  (list (+ (vnth 0 v0) (vnth 0 v1))
	(+ (vnth 1 v0) (vnth 1 v1))
	(+ (vnth 2 v0) (vnth 2 v1))
	(+ (vnth 3 v0) (vnth 3 v1))))

(defun matx-vec-prod (m v)
  "Return a product of `m' and `v'. `m' is a 4x4 matrix and `v' is
a 4-vector."
  (list
   (+ (* (vnth 0 v) (mnth 0 0 m)) (* (vnth 1 v) (mnth 0 1 m))
      (* (vnth 2 v) (mnth 0 2 m)) (* (vnth 3 v) (mnth 0 3 m)))
   (+ (* (vnth 0 v) (mnth 1 0 m)) (* (vnth 1 v) (mnth 1 1 m))
      (* (vnth 2 v) (mnth 1 2 m)) (* (vnth 3 v) (mnth 1 3 m)))
   (+ (* (vnth 0 v) (mnth 2 0 m)) (* (vnth 1 v) (mnth 2 1 m))
      (* (vnth 2 v) (mnth 2 2 m)) (* (vnth 3 v) (mnth 2 3 m)))
   (+ (* (vnth 0 v) (mnth 3 0 m)) (* (vnth 1 v) (mnth 3 1 m))
      (* (vnth 2 v) (mnth 3 2 m)) (* (vnth 3 v) (mnth 3 3 m)))))

(defun vec-matx-prod (v m)
  "Return a product of `v' and `m'. `v' is a 4-vector and `m'
is a 4x4 matrix."
  (list
   (+ (* (vnth 0 v) (mnth 0 0 m)) (* (vnth 1 v) (mnth 1 0 m))
      (* (vnth 2 v) (mnth 2 0 m)) (* (vnth 3 v) (mnth 3 0 m)))
   (+ (* (vnth 0 v) (mnth 0 1 m)) (* (vnth 1 v) (mnth 1 1 m))
      (* (vnth 2 v) (mnth 2 1 m)) (* (vnth 3 v) (mnth 3 1 m)))
   (+ (* (vnth 0 v) (mnth 0 2 m)) (* (vnth 1 v) (mnth 1 2 m))
      (* (vnth 2 v) (mnth 2 2 m)) (* (vnth 3 v) (mnth 3 2 m)))
   (+ (* (vnth 0 v) (mnth 0 3 m)) (* (vnth 1 v) (mnth 1 3 m))
      (* (vnth 2 v) (mnth 2 3 m)) (* (vnth 3 v) (mnth 3 3 m)))))

(defun matx-matx-prod (m0 m1)
  "Return a product of `m0' and `m1'. `m0' and `m1' are 4x4 matrices."
  (list
   (vec-matx-prod (nth 0 m0) m1)
   (vec-matx-prod (nth 1 m0) m1)
   (vec-matx-prod (nth 2 m0) m1)
   (vec-matx-prod (nth 3 m0) m1)))

(defun rot-matx-z (m r)
  "Return a matrix rotated around Z axis. `m' is a 4x4 matrix and
`r' is a radian aroundx Z axis."
  (let ((u (unit-matx)))
    (setf (mnth 0 0 u) (cos r))
    (setf (mnth 0 1 u) (- (sin r)))
    (setf (mnth 1 0 u) (sin r))
    (setf (mnth 1 1 u) (cos r))
    (matx-matx-prod u m)))

(defun rot-matx-x (m r)
  "Return a matrix rotated around X axis. `m' is a 4x4 matrix and
`r' is a radian aroundx X axis."
  (let ((u (unit-matx)))
    (setf (mnth 1 1 u) (cos r))
    (setf (mnth 1 2 u) (- (sin r)))
    (setf (mnth 2 1 u) (sin r))
    (setf (mnth 2 2 u) (cos r))
    (matx-matx-prod u m)))

(defun rot-matx-y (m r)
  "Return a matrix rotated around Y axis. `m' is a 4x4 matrix and
`r' is a radian aroundx Y axis."
  (let ((u (unit-matx)))
    (setf (mnth 0 0 u) (cos r))
    (setf (mnth 2 0 u) (sin r))
    (setf (mnth 0 2 u) (- (sin r)))
    (setf (mnth 2 2 u) (cos r))
    (matx-matx-prod u m)))

(defun rot-matx (m rx ry rz)
  "Return a matrix rotated around Z-Y-X. `m' is a 4x4 matrix.
`rx', `ry' and `rz' are angles around each axies."
  (rot-matx-x (rot-matx-y (rot-matx-z m rz) ry) rx))

(defun matx-euler (m)
  "Return euler angles (rx ry rz) extracted from `M'. `M' is a 4x4
rotation matrix calculated in Z-Y-X euler angles."
  (list (- (atan (mnth 1 2 m) (mnth 2 2 m)))
	(atan (- (mnth 0 2 m)) (sqrt (+ (* (mnth 1 2 m) (mnth 1 2 m)) (* (mnth 2 2 m) (mnth 2 2 m)))))
	(- (atan (mnth 0 1 m) (mnth 0 0 m)))))


;;; Internal Functions

(defun org-impress-js-xhtml-p (info) nil)

(defun org-impress-js-html5-p (info) t)

(defun org-impress-js-close-tag (tag attr info)
  (concat "<" tag " " attr " />"))

(defun org-impress-js-doctype (info) "Return correct html doctype tag." "<!DOCTYPE html>")

(defvar org-impress-js-slide-angles '(0 0 0 0)
  "Accumulated euler angles.")

(defvar org-impress-js-slide-trans '(0 0 0 0)
  "Accumulated translation.")

(defun org-impress-js-export-begin () 
  "Called when export begin."
  (setq org-impress-js-slide-angles '(0 0 0 0))
  (setq org-impress-js-slide-trans '(0 0 0 0)))

(defun org-impress-js-to-number (v)
  "Convert to a number."
  (and v (string-to-number (format "%s" v))))
       

;;; Template

(defun org-impress-js--build-meta-info (info)
  "Return meta tags for exported document.
INFO is a plist used as a communication channel."
  (let ((protect-string
	 (lambda (str)
	   (replace-regexp-in-string
	    "\"" "&quot;" (org-html-encode-plain-text str))))
	(title (org-export-data (plist-get info :title) info))
	(author (and (plist-get info :with-author)
		     (let ((auth (plist-get info :author)))
		       (and auth
			    ;; Return raw Org syntax, skipping non
			    ;; exportable objects.
			    (org-element-interpret-data
			     (org-element-map auth
				 (cons 'plain-text org-element-all-objects)
			       'identity info))))))
	(description (plist-get info :html-description))
	(keywords (plist-get info :keywords))
	(charset (or (and org-html-coding-system
			  (fboundp 'coding-system-get)
			  (coding-system-get org-html-coding-system
					     'mime-charset))
		     "iso-8859-1")))
    (concat
     (format "<title>%s</title>\n" title)
     (when (plist-get info :time-stamp-file)
       (format-time-string
	 (concat "<!-- " org-html-metadata-timestamp-format " -->\n")))
     (format
      (if (org-impress-js-html5-p info)
	  (org-impress-js-close-tag "meta" " charset=\"%s\"" info)
	(org-impress-js-close-tag
	 "meta" " http-equiv=\"Content-Type\" content=\"text/html;charset=%s\""
	 info))
      charset) "\n"
     (org-impress-js-close-tag "meta" " name=\"generator\" content=\"Org-mode\"" info)
     "\n"
     (org-impress-js-close-tag "meta" " name=\"viewport\" content=\"width=1024\"" info)
     "\n"
     (org-impress-js-close-tag "meta" " name=\"apple-mobile-web-app-capable\" content=\"yes\"" info) "\n"
     (and (org-string-nw-p author)
	  (concat
	   (org-impress-js-close-tag "meta"
			       (format " name=\"author\" content=\"%s\""
				       (funcall protect-string author))
			       info)
	   "\n"))
     (and (org-string-nw-p description)
	  (concat
	   (org-impress-js-close-tag "meta"
			       (format " name=\"description\" content=\"%s\"\n"
				       (funcall protect-string description))
			       info)
	   "\n"))
     (and (org-string-nw-p keywords)
	  (concat
	   (org-impress-js-close-tag "meta"
			       (format " name=\"keywords\" content=\"%s\""
				       (funcall protect-string keywords))
			       info)
	   "\n"))
      (org-impress-js-close-tag "link" " href=\"http://fonts.googleapis.com/css?family=Open+Sans:regular,semibold,italic,italicsemibold|PT+Sans:400,700,400italic,700italic|PT+Serif:400,700,400italic,700italic\" rel=\"stylesheet\"" info) "\n"
      (org-impress-js-close-tag "link" " rel=\"shortcut icon\" href=\"favicon.png\"" info) "\n"
      (org-impress-js-close-tag "link" " rel=\"apple-touch-icon\" href=\"apple-touch-icon.png\"" info) "\n")))

(defun org-impress-js--build-impress-js-stylesheet (info)
  "Return a link tag to load impress.js CSS file.
INFO is a plist used as a communication channel."
  (org-element-normalize-string
   (concat
    (when (plist-get info :html-impress-js-stylesheet)
      (org-impress-js-close-tag "link"
			  (format " rel=\"stylesheet\" href=\"%s\" type=\"text/css\""
				  (plist-get info :html-impress-js-stylesheet))
			  info)))))

(defun org-impress-js--build-head (info)
  "Return information for the <head>..</head> of the HTML output.
INFO is a plist used as a communication channel."
  (org-element-normalize-string
   (concat
    (when (plist-get info :html-head-include-default-style)
      (org-element-normalize-string org-html-style-default))
    (org-element-normalize-string (plist-get info :html-head))
    (org-element-normalize-string (plist-get info :html-head-extra))
    (when (and (plist-get info :html-htmlized-css-url)
	       (eq org-html-htmlize-output-type 'css))
      (org-impress-js-close-tag "link"
			  (format " rel=\"stylesheet\" href=\"%s\" type=\"text/css\""
				  (plist-get info :html-htmlized-css-url))
			  info))
    (when (plist-get info :html-head-include-scripts) org-html-scripts))))

(defun org-impress-js--build-fallback-message (info)
  "Return impress.js fallback-message as a string.
INFO is a plist used as a communication channel."
  (concat "<div class=\"fallback-message\">\n"
	  (plist-get info :html-fallback-message)
	  "</div>\n"))

(defun org-impress-js--build-title (info)
  "Return a title step.

Postamble will be embeded if available. See `org-html-postamble'."
  (org-element-normalize-string
   (concat
    "<div id=\"title\" class=\"step\" data-x=\"0\" data-y=\"0\" data-scale=\"1\">\n"
    ;; Document title.
    (let ((title (plist-get info :title)))
      (format "<h1>%s</h1>\n" (org-export-data (or title "") info)))
    (org-html--build-pre/postamble 'postamble info)
    "</div>\n")))

(defun org-impress-js--build-hint-message (info)
  "Return impress.js hint message as a string.
INFO is a plist used as a communication channel."
  (concat "<div class=\"hint\">\n"
	  (plist-get info :html-hint-message)
	  "</div>\n"))

(defun org-impress-js--build-init-impress-js (info)
  "Return a init script for impress.js as a string.
INFO is a plist used as a communication channel."
  (concat "<script>\n"
	  (plist-get info :html-hint-js)
	  "</script>\n"
	  (format "<script src=\"%s\"></script>\n"
		  (plist-get info :html-impress-js-javascript))
	  "<script>impress().init();</script>\n"))

(defun org-impress-js-template (contents info)
  "Return complete document string after HTML conversion.
CONTENTS is the transcoded contents string.  INFO is a plist
holding export options."
  (concat
   (when (and (not (org-impress-js-html5-p info)) (org-impress-js-xhtml-p info))
     (let ((decl (or (and (stringp org-html-xml-declaration)
			      org-html-xml-declaration)
			 (cdr (assoc (plist-get info :html-extension)
				     org-html-xml-declaration))
			 (cdr (assoc "html" org-html-xml-declaration))

			 "")))
       (when (not (or (eq nil decl) (string= "" decl)))
	 (format "%s\n"
		 (format decl
		  (or (and org-html-coding-system
			   (fboundp 'coding-system-get)
			   (coding-system-get org-html-coding-system 'mime-charset))
		      "iso-8859-1"))))))
   (org-impress-js-doctype info)
   "\n"
   (format "<html lang=\"%s\">\n" (plist-get info :language))
   "<head>\n"
   (org-impress-js--build-meta-info info)
   (org-impress-js--build-impress-js-stylesheet info)
   (org-impress-js--build-head info)
   (org-html--build-mathjax-config info)
   "</head>\n"
   "<body class=\"impress-not-supported\">\n"
   (let ((link-up (org-trim (plist-get info :html-link-up)))
	 (link-home (org-trim (plist-get info :html-link-home))))
     (unless (and (string= link-up "") (string= link-home ""))
       (format org-html-home/up-format
	       (or link-up link-home)
	       (or link-home link-up))))
   ;; Preamble.
   ;; (org-html--build-pre/postamble 'preamble info)
   ;; Fallback message.
   (org-impress-js--build-fallback-message info)
   ;; Document contents.
   (format "<%s id=\"%s\">\n"
	   (nth 1 (assq 'content org-impress-js-divs))
	   (nth 2 (assq 'content org-impress-js-divs)))
   ;; Title.
   (org-impress-js--build-title info)
   contents
   (format "</%s>\n"
	   (nth 1 (assq 'content org-impress-js-divs)))
   ;; Postamble.
   ;; (org-html--build-pre/postamble 'postamble info)
   ;; Hint message.
   (org-impress-js--build-hint-message info)
   ;; impress.js init.
   (org-impress-js--build-init-impress-js info)
   ;; Closing document.
   "</body>\n</html>"))

(defun org-impress-js--translate (s info)
  "Translate string S according to specified language.
INFO is a plist used as a communication channel."
  (org-export-translate s :html info))

;;;; Anchor

(defun org-impress-js--anchor (&optional id desc attributes)
  "Format a HTML anchor."
  (let* ((name (and org-impress-js-allow-name-attribute-in-anchors id))
	 (attributes (concat (and id (format " id=\"%s\"" id))
			     (and name (format " name=\"%s\"" name))
			     attributes)))
    (format "<a%s>%s</a>" attributes (or desc ""))))

;;;; Todo

(defun org-impress-js--todo (todo)
  "Format TODO keywords into HTML."
  (when todo
    (format "<span class=\"%s %s%s\">%s</span>"
	    (if (member todo org-done-keywords) "done" "todo")
	    org-html-todo-kwd-class-prefix (org-html-fix-class-name todo)
	    todo)))

;;;; Tags

(defun org-impress-js--tags (tags)
  "Format TAGS into HTML."
  (when tags
    (format "<span class=\"tag\">%s</span>"
	    (mapconcat
	     (lambda (tag)
	       (format "<span class=\"%s\">%s</span>"
		       (concat org-html-tag-class-prefix
			       (org-html-fix-class-name tag))
		       tag))
	     tags "&#xa0;"))))

;;;; Headline

(defun* org-impress-js-format-headline
  (todo todo-type priority text tags
	&key level section-number headline-label &allow-other-keys)
  "Format a headline in HTML."
  (let ((section-number
	 (when section-number
	   (format "<span class=\"section-number-%d\">%s</span> "
		   level section-number)))
	(todo (org-impress-js--todo todo))
	(tags (org-impress-js--tags tags)))
    (concat section-number todo (and todo " ") text
	    (and tags "&#xa0;&#xa0;&#xa0;") tags)))

;;;; Src Code

(defun org-impress-js-fontify-code (code lang)
  "Color CODE with htmlize library.
CODE is a string representing the source code to colorize.  LANG
is the language used for CODE, as a string, or nil."
  (when code
    (cond
     ;; Case 1: No lang.  Possibly an example block.
     ((not lang)
      ;; Simple transcoding.
      (org-html-encode-plain-text code))
     ;; Case 2: No htmlize or an inferior version of htmlize
     ((not (and (require 'htmlize nil t) (fboundp 'htmlize-region-for-paste)))
      ;; Emit a warning.
      (message "Cannot fontify src block (htmlize.el >= 1.34 required)")
      ;; Simple transcoding.
      (org-html-encode-plain-text code))
     (t
      ;; Map language
      (setq lang (or (assoc-default lang org-src-lang-modes) lang))
      (let* ((lang-mode (and lang (intern (format "%s-mode" lang)))))
	(cond
	 ;; Case 1: Language is not associated with any Emacs mode
	 ((not (functionp lang-mode))
	  ;; Simple transcoding.
	  (org-html-encode-plain-text code))
	 ;; Case 2: Default.  Fontify code.
	 (t
	  ;; htmlize
	  (setq code (with-temp-buffer
		       ;; Switch to language-specific mode.
		       (funcall lang-mode)
		       (insert code)
		       ;; Fontify buffer.
		       (font-lock-fontify-buffer)
		       ;; Remove formatting on newline characters.
		       (save-excursion
			 (let ((beg (point-min))
			       (end (point-max)))
			   (goto-char beg)
			   (while (progn (end-of-line) (< (point) end))
			     (put-text-property (point) (1+ (point)) 'face nil)
			     (forward-char 1))))
		       (org-src-mode)
		       (set-buffer-modified-p nil)
		       ;; Htmlize region.
		       (org-html-htmlize-region-for-paste
			(point-min) (point-max))))
	  ;; Strip any enclosing <pre></pre> tags.
	  (let* ((beg (and (string-match "\\`<pre[^>]*>\n*" code) (match-end 0)))
		 (end (and beg (string-match "</pre>\\'" code))))
	    (if (and beg end) (substring code beg end) code)))))))))

(defun org-impress-js-do-format-code
  (code &optional lang refs retain-labels num-start)
  "Format CODE string as source code.
Optional arguments LANG, REFS, RETAIN-LABELS and NUM-START are,
respectively, the language of the source code, as a string, an
alist between line numbers and references (as returned by
`org-export-unravel-code'), a boolean specifying if labels should
appear in the source code, and the number associated to the first
line of code."
  (let* ((code-lines (org-split-string code "\n"))
	 (code-length (length code-lines))
	 (num-fmt
	  (and num-start
	       (format "%%%ds: "
		       (length (number-to-string (+ code-length num-start))))))
	 (code (org-impress-js-fontify-code code lang)))
    (org-export-format-code
     code
     (lambda (loc line-num ref)
       (setq loc
	     (concat
	      ;; Add line number, if needed.
	      (when num-start
		(format "<span class=\"linenr\">%s</span>"
			(format num-fmt line-num)))
	      ;; Transcoded src line.
	      loc
	      ;; Add label, if needed.
	      (when (and ref retain-labels) (format " (%s)" ref))))
       ;; Mark transcoded line as an anchor, if needed.
       (if (not ref) loc
	 (format "<span id=\"coderef-%s\" class=\"coderef-off\">%s</span>"
		 ref loc)))
     num-start refs)))

(defun org-impress-js-format-code (element info)
  "Format contents of ELEMENT as source code.
ELEMENT is either an example block or a src block.  INFO is
a plist used as a communication channel."
  (let* ((lang (org-element-property :language element))
	 ;; Extract code and references.
	 (code-info (org-export-unravel-code element))
	 (code (car code-info))
	 (refs (cdr code-info))
	 ;; Does the src block contain labels?
	 (retain-labels (org-element-property :retain-labels element))
	 ;; Does it have line numbers?
	 (num-start (case (org-element-property :number-lines element)
		      (continued (org-export-get-loc element info))
		      (new 0))))
    (org-impress-js-do-format-code code lang refs retain-labels num-start)))


;;; Tables of Contents

(defun org-impress-js-toc (depth info)
  "Build a table of contents.
DEPTH is an integer specifying the depth of the table.  INFO is a
plist used as a communication channel.  Return the table of
contents as a string, or nil if it is empty."
  (let ((toc-entries
	 (mapcar (lambda (headline)
		   (cons (org-impress-js--format-toc-headline headline info)
			 (org-export-get-relative-level headline info)))
		 (org-export-collect-headlines info depth)))
	(outer-tag (if (and (org-impress-js-html5-p info)
			    (plist-get info :html-html5-fancy))
		       "nav"
		     "div")))
    (when toc-entries
      (concat (format "<%s id=\"table-of-contents\">\n" outer-tag)
	      (format "<h%d>%s</h%d>\n"
		      org-impress-js-toplevel-hlevel
		      (org-impress-js--translate "Table of Contents" info)
		      org-impress-js-toplevel-hlevel)
	      "<div id=\"text-table-of-contents\">"
	      (org-impress-js--toc-text toc-entries)
	      "</div>\n"
	      (format "</%s>\n" outer-tag)))))

(defun org-impress-js--toc-text (toc-entries)
  "Return innards of a table of contents, as a string.
TOC-ENTRIES is an alist where key is an entry title, as a string,
and value is its relative level, as an integer."
  (let* ((prev-level (1- (cdar toc-entries)))
	 (start-level prev-level))
    (concat
     (mapconcat
      (lambda (entry)
	(let ((headline (car entry))
	      (level (cdr entry)))
	  (concat
	   (let* ((cnt (- level prev-level))
		  (times (if (> cnt 0) (1- cnt) (- cnt)))
		  rtn)
	     (setq prev-level level)
	     (concat
	      (org-html--make-string
	       times (cond ((> cnt 0) "\n<ul>\n<li>")
			   ((< cnt 0) "</li>\n</ul>\n")))
	      (if (> cnt 0) "\n<ul>\n<li>" "</li>\n<li>")))
	   headline)))
      toc-entries "")
     (org-html--make-string (- prev-level start-level) "</li>\n</ul>\n"))))

(defun org-impress-js--format-toc-headline (headline info)
  "Return an appropriate table of contents entry for HEADLINE.
INFO is a plist used as a communication channel."
  (let* ((headline-number (org-export-get-headline-number headline info))
	 (todo (and (plist-get info :with-todo-keywords)
		    (let ((todo (org-element-property :todo-keyword headline)))
		      (and todo (org-export-data todo info)))))
	 (todo-type (and todo (org-element-property :todo-type headline)))
	 (priority (and (plist-get info :with-priority)
			(org-element-property :priority headline)))
	 (text (org-export-data-with-backend
		(org-export-get-alt-title headline info)
		;; Create an anonymous back-end that will ignore any
		;; footnote-reference, link, radio-target and target
		;; in table of contents.
		(org-export-create-backend
		 :parent 'impress-js
		 :transcoders '((footnote-reference . ignore)
				(link . (lambda (object c i) c))
				(radio-target . (lambda (object c i) c))
				(target . ignore)))
		info))
	 (tags (and (eq (plist-get info :with-tags) t)
		    (org-export-get-tags headline info))))
    (format "<a href=\"#%s\">%s</a>"
	    ;; Label.
	    (org-export-solidify-link-text
	     (or (org-element-property :CUSTOM_ID headline)
		 (concat "sec-"
			 (mapconcat #'number-to-string headline-number "-"))))
	    ;; Body.
	    (concat
	     (and (not (org-export-low-level-p headline info))
		  (org-export-numbered-headline-p headline info)
		  (concat (mapconcat #'number-to-string headline-number ".")
			  ". "))
	     (apply (if (not (eq org-impress-js-format-headline-function 'ignore))
			(lambda (todo todo-type priority text tags &rest ignore)
			  (funcall org-impress-js-format-headline-function
				   todo todo-type priority text tags))
		      #'org-impress-js-format-headline)
		    todo todo-type priority text tags :section-number nil)))))

(defun org-impress-js-list-of-listings (info)
  "Build a list of listings.
INFO is a plist used as a communication channel.  Return the list
of listings as a string, or nil if it is empty."
  (let ((lol-entries (org-export-collect-listings info)))
    (when lol-entries
      (concat "<div id=\"list-of-listings\">\n"
	      (format "<h%d>%s</h%d>\n"
		      org-impress-js-toplevel-hlevel
		      (org-impress-js--translate "List of Listings" info)
		      org-impress-js-toplevel-hlevel)
	      "<div id=\"text-list-of-listings\">\n<ul>\n"
	      (let ((count 0)
		    (initial-fmt (format "<span class=\"listing-number\">%s</span>"
					 (org-impress-js--translate "Listing %d:" info))))
		(mapconcat
		 (lambda (entry)
		   (let ((label (org-element-property :name entry))
			 (title (org-trim
				 (org-export-data
				  (or (org-export-get-caption entry t)
				      (org-export-get-caption entry))
				  info))))
		     (concat
		      "<li>"
		      (if (not label)
			  (concat (format initial-fmt (incf count)) " " title)
			(format "<a href=\"#%s\">%s %s</a>"
				(org-export-solidify-link-text label)
				(format initial-fmt (incf count))
				title))
		      "</li>")))
		 lol-entries "\n"))
	      "\n</ul>\n</div>\n</div>"))))

(defun org-impress-js-list-of-tables (info)
  "Build a list of tables.
INFO is a plist used as a communication channel.  Return the list
of tables as a string, or nil if it is empty."
  (let ((lol-entries (org-export-collect-tables info)))
    (when lol-entries
      (concat "<div id=\"list-of-tables\">\n"
	      (format "<h%d>%s</h%d>\n"
		      org-impress-js-toplevel-hlevel
		      (org-impress-js--translate "List of Tables" info)
		      org-impress-js-toplevel-hlevel)
	      "<div id=\"text-list-of-tables\">\n<ul>\n"
	      (let ((count 0)
		    (initial-fmt (format "<span class=\"table-number\">%s</span>"
					 (org-impress-js--translate "Table %d:" info))))
		(mapconcat
		 (lambda (entry)
		   (let ((label (org-element-property :name entry))
			 (title (org-trim
				 (org-export-data
				  (or (org-export-get-caption entry t)
				      (org-export-get-caption entry))
				  info))))
		     (concat
		      "<li>"
		      (if (not label)
			  (concat (format initial-fmt (incf count)) " " title)
			(format "<a href=\"#%s\">%s %s</a>"
				(org-export-solidify-link-text label)
				(format initial-fmt (incf count))
				title))
		      "</li>")))
		 lol-entries "\n"))
	      "\n</ul>\n</div>\n</div>"))))


;;; Transcode Functions

;;;; Headline

(defun org-impress-js-headline (headline contents info)
  "Transcode a HEADLINE element from Org to HTML.
CONTENTS holds the contents of the headline.  INFO is a plist
holding contextual information."
  ;; Empty contents?
  (setq contents (or contents ""))
  (let* ((numberedp (org-export-numbered-headline-p headline info))
	 (level (org-export-get-relative-level headline info))
	 (text (org-export-data (org-element-property :title headline) info))
	 (todo (and (plist-get info :with-todo-keywords)
		    (let ((todo (org-element-property :todo-keyword headline)))
		      (and todo (org-export-data todo info)))))
	 (todo-type (and todo (org-element-property :todo-type headline)))
	 (tags (and (plist-get info :with-tags)
		    (org-export-get-tags headline info)))
	 (priority (and (plist-get info :with-priority)
			(org-element-property :priority headline)))
	 (section-number (and (org-export-numbered-headline-p headline info)
			      (mapconcat 'number-to-string
					 (org-export-get-headline-number
					  headline info) ".")))
	 ;; Create the headline text.
	 (full-text (org-html-format-headline--wrap headline info))
	 ;; Attributes used to position presentation steps
	 (class (org-export-get-node-property :CLASS headline))
	 (data-x (org-impress-js-to-number (org-export-get-node-property :DATA-X headline)))
	 (data-y (org-impress-js-to-number (org-export-get-node-property :DATA-Y headline)))
	 (data-z (org-impress-js-to-number (org-export-get-node-property :DATA-Z headline)))
	 (data-scale (org-impress-js-to-number (org-export-get-node-property :DATA-SCALE headline)))
	 (data-rotate (org-impress-js-to-number (org-export-get-node-property :DATA-ROTATE headline)))
	 (data-rotate-x (org-impress-js-to-number (org-export-get-node-property :DATA-ROTATE-X headline)))
	 (data-rotate-y (org-impress-js-to-number (org-export-get-node-property :DATA-ROTATE-Y headline)))
	 (data-rotate-z (org-impress-js-to-number (org-export-get-node-property :DATA-ROTATE-Z headline)))
	 (trans-x (org-impress-js-to-number (org-export-get-node-property :TRANS-X headline)))
	 (trans-y (org-impress-js-to-number (org-export-get-node-property :TRANS-Y headline)))
	 (trans-z (org-impress-js-to-number (org-export-get-node-property :TRANS-Z headline)))
	 (rotate (org-impress-js-to-number (org-export-get-node-property :ROTATE headline)))
	 (rotate-x (org-impress-js-to-number (org-export-get-node-property :ROTATE-X headline)))
	 (rotate-y (org-impress-js-to-number (org-export-get-node-property :ROTATE-Y headline)))
	 (rotate-z (org-impress-js-to-number (org-export-get-node-property :ROTATE-Z headline))))
    (cond
     ;; Case 1: This is a footnote section: ignore it.
     ((org-element-property :footnote-section-p headline) nil)
     ;; Case 2. This is a deep sub-tree: export it as a list item.
     ;;         Also export as items headlines for which no section
     ;;         format has been found.
     ((org-export-low-level-p headline info)
      ;; Build the real contents of the sub-tree.
      (let* ((type (if numberedp 'ordered 'unordered))
	     (itemized-body (org-html-format-list-item
			     contents type nil info nil full-text)))
	(concat
	 (and (org-export-first-sibling-p headline info)
	      (org-html-begin-plain-list type))
	 itemized-body
	 (and (org-export-last-sibling-p headline info)
	      (org-html-end-plain-list type)))))
     ;; Case 3. Standard headline.  Export it as a section.
     (t
      ;; Set default values to translation variables if needed.
      (and (not (or data-x data-y data-z trans-x trans-y trans-z
		    data-rotate-x data-rotate-y data-rotate-z data-rotate
		    rotate-x rotate-y rotate-z rotate))
	   (setq trans-x (vnth 0 org-impress-js-default-translation)
		 trans-y (vnth 1 org-impress-js-default-translation)
		 trans-z (vnth 2 org-impress-js-default-translation)
		 rotate-x (vnth 0 org-impress-js-default-rotation)
		 rotate-y (vnth 1 org-impress-js-default-rotation)
		 rotate-z (vnth 2 org-impress-js-default-rotation)))
      (let* ((section-number (mapconcat 'number-to-string
					(org-export-get-headline-number
					 headline info) "-"))
	     (ids (remove 'nil
			  (list (org-element-property :CUSTOM_ID headline)
				(concat "sec-" section-number)
				(org-element-property :ID headline))))
	     (preferred-id (car ids))
	     (extra-ids (cdr ids))
	     (extra-class (org-element-property :HTML_CONTAINER_CLASS headline))
	     ;; Ignore the section indentations.
	     (level1 1)
	     (first-content (car (org-element-contents headline)))
	     (rot (let ((angles org-impress-js-slide-angles))
		    (matx-matx-prod
		     (rot-matx (unit-matx)
			       (if data-rotate-x (degrees-to-radians data-rotate-x) (vnth 0 angles))
			       (if data-rotate-y (degrees-to-radians data-rotate-y) (vnth 1 angles))
			       ;; `data-rotate-z' is prioritized than `data-rotate'.
			       (if data-rotate-z (degrees-to-radians data-rotate-z)
				 (if data-rotate (degrees-to-radians data-rotate)
				   (vnth 2 angles))))
		     (rot-matx (unit-matx)
			       (degrees-to-radians (or rotate-x 0))
			       (- (degrees-to-radians (or rotate-y 0)))
			       ;; `rotate-z' is prioritized than `rotate'.
			       (degrees-to-radians (or rotate-z rotate 0))))))
	     (angles (setq org-impress-js-slide-angles (matx-euler rot)))
	     (degrees (list
		       (radians-to-degrees (vnth 0 angles))
		       (- (radians-to-degrees (vnth 1 angles)))
		       (radians-to-degrees (vnth 2 angles))))
	     (tran (setq org-impress-js-slide-trans
			 (let ((tran (add-vec
				      org-impress-js-slide-trans
				      (matx-vec-prod (rot-matx (unit-matx)
							       (vnth 0 angles)
							       (vnth 1 angles)
							       (- (vnth 2 angles) pi))
						     (list (- (or trans-x 0))
							   (or trans-y 0)
							   (or trans-z 0)
							   1)))))
			   ;; Reset coordinates if corresponding data are given.
			   (and data-x (setf (vnth 0 tran) data-x))
			   (and data-y (setf (vnth 1 tran) data-y))
			   (and data-z (setf (vnth 2 tran) data-z))
			   tran))))
	(format "<%s id=\"%s\" class=\"%s\"%s>%s%s\n"
		(org-html--container headline info)
		(format "outline-container-%s"
			(or (org-element-property :CUSTOM_ID headline)
			    (concat "sec-" section-number)))
		(concat (format "outline-%d" level1) (and extra-class " ")
			extra-class
			(concat " " (if class class org-impress-js-default-slide-class)))
		(concat (format " data-x=\"%0.8f\"" (vnth 0 tran))
			(format " data-y=\"%0.8f\"" (vnth 1 tran))
			(format " data-z=\"%0.8f\"" (vnth 2 tran))
			(and data-scale (format " data-scale=\"%s\"" data-scale))
			(and data-rotate (format " data-rotate=\"%s\"" data-rotate))
			(format " data-rotate-x=\"%0.8f\"" (vnth 0 degrees))
			(format " data-rotate-y=\"%0.8f\"" (vnth 1 degrees))
			(format " data-rotate-z=\"%0.8f\"" (vnth 2 degrees)))
		(format "\n<h%d id=\"%s\">%s%s</h%d>\n"
			level1
			preferred-id
			(mapconcat
			 (lambda (x)
			   (let ((id (org-export-solidify-link-text
				      (if (org-uuidgen-p x) (concat "ID-" x)
					x))))
			     (org-impress-js--anchor id)))
			 extra-ids "")
			full-text
			level1)
		;; When there is no section, pretend there is an empty
		;; one to get the correct <div class="outline- ...>
		;; which is needed by `org-info.js'.
		(if (not (eq (org-element-type first-content) 'section))
		    (concat (org-impress-js-section first-content "" info)
			    contents)
		  contents)))))))

;;;; Keyword

(defun org-impress-js-keyword (keyword contents info)
  "Transcode a KEYWORD element from Org to HTML.
CONTENTS is nil.  INFO is a plist holding contextual information."
  (let ((key (org-element-property :key keyword))
	(value (org-element-property :value keyword)))
    (cond
     ((string= key "HTML") value))))

;;;; Section

(defun org-impress-js-section (section contents info)
  "Transcode a SECTION element from Org to HTML.
CONTENTS holds the contents of the section.  INFO is a plist
holding contextual information."
  (let ((parent (org-export-get-parent-headline section)))
    ;; Before first headline: no container, just return CONTENTS.
    (if (not parent) contents
      ;; Get div's class and id references.
      (let* ((class-num (+ (org-export-get-relative-level parent info)
			   (1- org-impress-js-toplevel-hlevel)))
	     (section-number
	      (mapconcat
	       'number-to-string
	       (org-export-get-headline-number parent info) "-")))
        ;; Build return value.
	(format "<div class=\"outline-text-%d\" id=\"text-%s\">\n%s</div>\n</div>"
		class-num
		(or (org-element-property :CUSTOM_ID parent) section-number)
		contents)))))


;;; End-user functions

;;;###autoload
(defun org-impress-js-export-as-html
  (&optional async subtreep visible-only body-only ext-plist)
  "Export current buffer to an HTML buffer.

If narrowing is active in the current buffer, only export its
narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting buffer should be accessible
through the `org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

When optional argument BODY-ONLY is non-nil, only write code
between \"<body>\" and \"</body>\" tags.

EXT-PLIST, when provided, is a property list with external
parameters overriding Org default settings, but still inferior to
file-local settings.

Export is done in a buffer named \"*Org HTML Export*\", which
will be displayed when `org-export-show-temporary-export-buffer'
is non-nil."
  (interactive)
  (org-impress-js-export-begin)
  (org-export-to-buffer 'impress-js "*Org HTML Export*"
    async subtreep visible-only body-only ext-plist
    (lambda () (set-auto-mode t))))

;;;###autoload
(defun org-impress-js-convert-region-to-html ()
  "Assume the current region has org-mode syntax, and convert it to HTML.
This can be used in any buffer.  For example, you can write an
itemized list in org-mode syntax in an HTML buffer and use this
command to convert it."
  (interactive)
  (org-export-replace-region-by 'impress-js))

;;;###autoload
(defun org-impress-js-export-to-html
  (&optional async subtreep visible-only body-only ext-plist)
  "Export current buffer to a HTML file.

If narrowing is active in the current buffer, only export its
narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting file should be accessible through
the `org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

When optional argument BODY-ONLY is non-nil, only write code
between \"<body>\" and \"</body>\" tags.

EXT-PLIST, when provided, is a property list with external
parameters overriding Org default settings, but still inferior to
file-local settings.

Return output file's name."
  (interactive)
  (org-impress-js-export-begin)
  (let* ((extension (concat "." org-html-extension))
	 (file (org-export-output-file-name extension subtreep))
	 (org-export-coding-system org-html-coding-system))
    (org-export-to-file 'impress-js file
      async subtreep visible-only body-only ext-plist)))

;;;###autoload
(defun org-impress-js-publish-to-html (plist filename pub-dir)
  "Publish an org file to HTML.

FILENAME is the filename of the Org file to be published.  PLIST
is the property list for the given project.  PUB-DIR is the
publishing directory.

Return output file name."
  (org-publish-org-to 'impress-js filename
		      (concat "." (or (plist-get plist :html-extension)
				      org-html-extension "html"))
		      plist pub-dir))


(provide 'ox-impress-js)
;;; ox-impress-js.el ends here
