;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; test
;;

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Giuseppe Coviello"
      user-mail-address "gcov@pm.me")

(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

(setq doom-font (font-spec :family "FiraCode" :size 18)
      doom-variable-pitch-font (font-spec :family "Alegreya Sans" :size 18))

(setq initial-frame-alist '((top . 1) (left . 1) (width . 130) (height . 40)))

(cua-mode)

(map! "<XF86Paste>" #'yank)
(map! "<XF86Copy>" #'kill-ring-save)
(map! "M-d" #'centaur-tabs-forward)
(map! "M-a" #'centaur-tabs-backward)
(map! "C-c C-g" #'goto-line)
(map! "M-e" #'next-multiframe-window)
(map! "M-q" #'previous-multiframe-window)

(use-package! visual-regexp-steroids
  :defer 3
  :config
  (require 'pcre2el)
  (setq vr/engine 'pcre2el)
  (map! "C-f" #'vr/isearch-forward)
  (map! "C-r" #'vr/query-replace))

(after! undo-fu
  (map! :map undo-fu-mode-map "C-z" #'undo-fu-only-undo)
  (map! :map undo-fu-mode-map "C-S-z" #'undo-fu-only-redo))

(add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode))
(put 'dockerfile-image-name 'safe-local-variable #'stringp)

(use-package vterm
  :ensure t)

(use-package julia-snail
  :ensure t
  :requires vterm
  :config
  (setq julia-snail-multimedia-enable t)
  (setq julia-snail-multimedia-buffer-style :single-new)
  :hook (julia-mode . julia-snail-mode))

(after! julia-snail
  (add-to-list 'display-buffer-alist
               '("\\*julia" (display-buffer-reuse-window display-buffer-same-window))))

(defun julia-ide()
  (interactive)
  (delete-other-windows)
  (split-window-horizontally)
  (next-multiframe-window)
  (switch-to-buffer (get-buffer-create "*julia* mm"))
  (shrink-window-horizontally 35)
  (previous-multiframe-window)
  (julia-snail)
  (enlarge-window 5)
  (next-multiframe-window)
  )

 (use-package centaur-tabs
   ;:load-path "~/.emacs.d/other/centaur-tabs"
   :config
   (setq centaur-tabs-style "bar"
	  centaur-tabs-height 32
	  centaur-tabs-set-icons t
	  centaur-tabs-set-modified-marker t
	  centaur-tabs-show-navigation-buttons t
	  centaur-tabs-set-bar 'under
	  x-underline-at-descent-line t)
   (centaur-tabs-headline-match)
   ;; (setq centaur-tabs-gray-out-icons 'buffer)
   ;; (centaur-tabs-enable-buffer-reordering)
   ;; (setq centaur-tabs-adjust-buffer-order t)
   ;(centaur-tabs-mode t)
   (setq uniquify-separator "/")
   (setq uniquify-buffer-name-style 'forward)
   (defun centaur-tabs-buffer-groups ()
     "`centaur-tabs-buffer-groups' control buffers' group rules.

 Group centaur-tabs with mode if buffer is derived from `eshell-mode' `emacs-lisp-mode' `dired-mode' `org-mode' `magit-mode'.
 All buffer name start with * will group to \"Emacs\".
 Other buffer group by `centaur-tabs-get-group-name' with project name."
     (list
      (cond
       ((derived-mode-p 'prog-mode)
	"Editing")
       ((or
         (derived-mode-p 'image-mode)
         (string-equal (buffer-name) "*julia* mm"))
        "JuliaPlots")
	;; ((not (eq (file-remote-p (buffer-file-name)) nil))
	;; "Remote")
       ((string-equal "*vterm*" (buffer-name))
        "Repl")
       ((or (string-equal "*" (substring (buffer-name) 0 1))
	     (memq major-mode '(magit-process-mode
				magit-status-mode
				magit-diff-mode
				magit-log-mode
				magit-file-mode
				magit-blob-mode
				magit-blame-mode
				)))
	 "Emacs")
	((derived-mode-p 'dired-mode)
	 "Dired")
	((memq major-mode '(helpful-mode
			    help-mode))
	 "Help")
	((memq major-mode '(org-mode
			    org-agenda-clockreport-mode
			    org-src-mode
			    org-agenda-mode
			    org-beamer-mode
			    org-indent-mode
			    org-bullets-mode
			    org-cdlatex-mode
			    org-agenda-log-mode
			    diary-mode))
	 "OrgMode")
	(t
	 (centaur-tabs-get-group-name (current-buffer))))))
   :hook
   (julia-snail-repl-mode . centaur-tabs-local-mode)
   (dashboard-mode . centaur-tabs-local-mode)
   (term-mode . centaur-tabs-local-mode)
   (calendar-mode . centaur-tabs-local-mode)
   ;(org-agenda-mode . centaur-tabs-local-mode)
   (helpful-mode . centaur-tabs-local-mode)
   ;:bind
   ;("C-<prior>" . centaur-tabs-backward)
   ;("C-<next>" . centaur-tabs-forward)
   ;("C-c t s" . centaur-tabs-counsel-switch-group)
   ;("C-c t p" . centaur-tabs-group-by-projectile-project)
   ;("C-c t g" . centaur-tabs-group-buffer-groups)
   ;(:map evil-normal-state-map
;	  ("g t" . centaur-tabs-forward)
;	  ("g T" . centaur-tabs-backward))
)

(use-package lsp-mode
  :ensure t
  :commands lsp-register-client
  :init (setq lsp-gopls-server-args '("--debug=localhost:6060"))
  :config
  (setq lsp-prefer-flymake :none)
  (lsp-register-custom-settings
   '(("gopls.completeUnimported" t t))))

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
