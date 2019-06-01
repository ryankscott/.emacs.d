;;; init.el --- Startup file for Emacs.  -*- lexical-binding: t; -*-

;; Copyright (C) 2018 Ryan Scott

;; Author: Ryan Scott <ryankennethscott@gmail.com>

;;; Commentary:

;; TODO:
;; - Fix the title bar that has the resolution in it
;; - Get prettier
;; - goto def is broken

;;; Code:
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(eval-and-compile
  (defvar bootstrap-version 3)
  (defvar bootstrap-file (concat user-emacs-directory "straight/repos/straight.el/bootstrap.el")))

(unless (file-exists-p bootstrap-file)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
       'silent 'inhibit-cookies)
    (goto-char (point-max))
    (eval-print-last-sexp)))

(defconst straight-cache-autoloads t)
(defconst straight-check-for-modifications 'live)

(require 'straight bootstrap-file t)


;; Add the lisp directory
(add-to-list 'load-path (concat user-emacs-directory "lisp"))


;; Install some basic packages

(straight-use-package 'dash)
(straight-use-package 'dash-functional)
(straight-use-package 'f)
(straight-use-package 's)
(straight-use-package 'noflet)
(straight-use-package 'memoize)


;; Set up personal settings

(setq user-full-name "Ryan Scott")
(setq user-mail-address "ryankennethscott@gmail.com")

(defconst use-package-verbose t)

(straight-use-package 'use-package)
(straight-use-package 'bind-map)

(eval-when-compile
  (require 'recentf)
  (require 'use-package))


;; Basic settings
(defalias #'yes-or-no-p #'y-or-n-p)
(setq tab-width 2)

;; Don't autosave
(setq make-backup-files nil)

;; Auto-indent on RET
(define-key global-map (kbd "RET") #'comment-indent-new-line)


;; Remove splash screen
(setq initial-scratch-message nil)
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)

;; Smooth scrolling
(setq scroll-step           1
      scroll-margin         0
      scroll-conservatively 10000)

;; Instantly display current keystrokes in mini buffer
(setq echo-keystrokes 0.00)

;; Hide toolbars
(tool-bar-mode -1)
(menu-bar-mode -1)
(toggle-scroll-bar -1)
(horizontal-scroll-bar-mode -1)

;; Enable hideshow in all programming buffers.
(autoload 'hs-minor-mode "hideshow")
(add-hook 'prog-mode-hook 'hs-minor-mode)

;; Add prettier to web-mode
(setq prettier-js-args '(
                         "--trailing-comma" "all"
                         "--single-quote" "true"
                         ))
(add-hook 'js2-jsx-mode-hook 'prettier-js-mode)
(add-hook 'web-mode-hook 'prettier-js-mode)

;; Highlight matching parens by default
(show-paren-mode 1)

;; Evil breaks cursor settings in Hydra buffers
(setq-default cursor-in-non-selected-windows nil)

;; Start fullscreen
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Use path from shell for Golang
(use-package exec-path-from-shell
  :straight t
  :config
  (exec-path-from-shell-initialize)
  (exec-path-from-shell-copy-env "GOPATH"))

;; Enable commands.
(put 'narrow-to-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'downcase-char 'disabled nil)
(put 'erase-buffer 'disabled nil)

;; Functions
(defun rs-comment-or-uncomment-region-or-line ()
  "Comments or uncomments the region or the current line if there's no active region."
  (interactive)
  (let (beg end)
    (if (region-active-p)
        (setq beg (region-beginning) end (region-end))
      (setq beg (line-beginning-position) end (line-end-position)))
    (comment-or-uncomment-region beg end)))

;; Themes

(set-default-font "Fira Code 14" nil t)


;; Smart tabs
(require 'smart-tab)
(global-smart-tab-mode 1)


(use-package doom-themes
  :preface (defvar region-fg nil)
  :straight t
  :config
  (progn
    (require 'doom-themes)
    (setq doom-themes-enable-bold nil)
    (setq doom-themes-enable-italic nil)
    (setq nlinum-highlight-current-line t)
    (doom-themes-visual-bell-config)
    (doom-themes-neotree-config)
    (load-theme 'doom-solarized-light t)
    ))


;; New packages
(use-package hydra
  :straight t
  :config
  (setq lv-use-separator t))


;; LSP
(use-package lsp-mode
  :straight t
  :init
  (setq lsp-prefer-flymake nil)
  (setq flymake-fringe-indicator-position 'right-fringe)
  :config
  (require 'lsp-clients)
  (add-hook 'js2-mode-hook 'lsp)
  (add-hook 'css-mode 'lsp)
  (add-hook 'web-mode 'lsp)
  (which-key-add-major-mode-key-based-replacements 'lsp-mode
    "SPC ml" "lsp")
  )

(use-package lsp-ui
  :straight t
  :custom-face
  (lsp-ui-doc-background ((t (:background nil))))
  (lsp-ui-doc-header ((t (:inherit (font-lock-string-face italic)))))
  :bind (:map lsp-ui-mode-map
              ([remap xref-find-definitions] . lsp-ui-peek-find-definitions)
              ([remap xref-find-references] . lsp-ui-peek-find-references)
              ("C-c u" . lsp-ui-imenu))
  :init (setq lsp-ui-doc-enable nil
              lsp-ui-doc-header t
              lsp-ui-doc-include-signature t
              lsp-ui-doc-position 'top
              lsp-ui-doc-use-webkit t
              lsp-ui-doc-border (face-foreground 'default)

              lsp-ui-sideline-enable nil
              lsp-ui-sideline-ignore-duplicate t)
  :config
  ;; WORKAROUND Hide mode-line of the lsp-ui-imenu buffer
  ;; https://github.com/emacs-lsp/lsp-ui/issues/243
  (defadvice lsp-ui-imenu (after hide-lsp-ui-imenu-mode-line activate)
    (setq mode-line-format nil)))

(use-package magit
  :straight t
  :defer t
  :commands (magit-status magit-blame magit-branch-and-checkout)
  :functions (magit-display-buffer-fullframe-status-v1)
  )

(use-package evil-magit
  :straight t
  :after magit)

(use-package rainbow-mode
  :straight t)

(use-package nlinum
  :straight t
  :config
  (global-nlinum-mode))


(use-package company
  :hook (after-init . global-company-mode)
  :defines (company-dabbrev-ignore-case company-dabbrev-downcase)
  :config
  (setq company-tooltip-align-annotations t ; aligns annotation to the right
        company-tooltip-limit 12            ; bigger popup window
        company-idle-delay .2               ; decrease delay before autocompletion popup shows
        company-echo-delay 0                ; remove annoying blinking
        company-minimum-prefix-length 2
        company-require-match nil
        company-dabbrev-ignore-case nil
        company-dabbrev-downcase nil)
  :general
  (:keymaps 'company-active-map
            "TAB" #'company-complete-selection
            "<tab>" #'company-complete-selection
            "S-<return>" #'company-complete-selection))

(use-package company-lsp
  :ensure t
  :after (company lsp-mode)
  :defines company-lsp
  :preface
  (progn
    (defun rs-company--lsp-mode-p ()
      (and (bound-and-true-p lsp-mode)
           (bound-and-true-p company-mode)))
    (defun rs-company--setup-lsp-backend ()
      (when (rs-company--lsp-mode-p)
        (set (make-local-variable 'company-backends) '(company-lsp)))))
  :config
  (add-hook 'company-mode-hook #'rs-company--setup-lsp-backend))

(use-package company-box
  :ensure t
  :hook (company-mode . company-box-mode)
  :init (setq company-box-icons-alist 'company-box-icons-all-the-icons)
  :config
  (setq company-box-backends-colors nil)
  (setq company-box-show-single-candidate t)
  (setq company-box-max-candidates 50)
  ;; Support `company-common'
  (defun my-company-box--make-line (candidate)
    (-let* (((candidate annotation len-c len-a backend) candidate)
            (color (company-box--get-color backend))
            ((c-color a-color i-color s-color) (company-box--resolve-colors color))
            (icon-string (and company-box--with-icons-p (company-box--add-icon candidate)))
            (candidate-string (concat (propertize company-common 'face 'company-tooltip-common)
                                      (substring (propertize candidate 'face 'company-box-candidate) (length company-common) nil)))
            (align-string (when annotation
                            (concat " " (and company-tooltip-align-annotations
                                             (propertize " " 'display `(space :align-to (- right-fringe ,(or len-a 0) 1)))))))
            (space company-box--space)
            (icon-p company-box-enable-icon)
            (annotation-string (and annotation (propertize annotation 'face 'company-box-annotation)))
            (line (concat (unless (or (and (= space 2) icon-p) (= space 0))
                            (propertize " " 'display `(space :width ,(if (or (= space 1) (not icon-p)) 1 0.75))))
                          (company-box--apply-color icon-string i-color)
                          (company-box--apply-color candidate-string c-color)
                          align-string
                          (company-box--apply-color annotation-string a-color)))
            (len (length line)))
      (add-text-properties 0 len (list 'company-box--len (+ len-c len-a)
                                       'company-box--color s-color)
                           line)
      line))
  (advice-add #'company-box--make-line :override #'my-company-box--make-line)

  ;; Prettify icons
  (defun my-company-box-icons--elisp (candidate)
    (when (derived-mode-p 'emacs-lisp-mode)
      (let ((sym (intern candidate)))
        (cond ((fboundp sym) 'Function)
              ((featurep sym) 'Module)
              ((facep sym) 'Color)
              ((boundp sym) 'Variable)
              ((symbolp sym) 'Text)
              (t . nil)))))
  (advice-add #'company-box-icons--elisp :override #'my-company-box-icons--elisp)

  (with-eval-after-load 'all-the-icons
    (declare-function all-the-icons-faicon 'all-the-icons)
    (declare-function all-the-icons-material 'all-the-icons)
    (setq company-box-icons-all-the-icons
          `((Unknown . ,(all-the-icons-material "find_in_page" :height 0.9 :v-adjust -0.2))
            (Text . ,(all-the-icons-faicon "text-width" :height 0.85 :v-adjust -0.05))
            (Method . ,(all-the-icons-faicon "cube" :height 0.85 :v-adjust -0.05 :face 'all-the-icons-purple))
            (Function . ,(all-the-icons-faicon "cube" :height 0.85 :v-adjust -0.05 :face 'all-the-icons-purple))
            (Constructor . ,(all-the-icons-faicon "cube" :height 0.85 :v-adjust -0.05 :face 'all-the-icons-purple))
            (Field . ,(all-the-icons-faicon "tag" :height 0.85 :v-adjust -0.05 :face 'all-the-icons-lblue))
            (Variable . ,(all-the-icons-faicon "tag" :height 0.85 :v-adjust -0.05 :face 'all-the-icons-lblue))
            (Class . ,(all-the-icons-material "settings_input_component" :height 0.9 :v-adjust -0.2 :face 'all-the-icons-orange))
            (Interface . ,(all-the-icons-material "share" :height 0.9 :v-adjust -0.2 :face 'all-the-icons-lblue))
            (Module . ,(all-the-icons-material "view_module" :height 0.9 :v-adjust -0.2 :face 'all-the-icons-lblue))
            (Property . ,(all-the-icons-faicon "wrench" :height 0.85 :v-adjust -0.05))
            (Unit . ,(all-the-icons-material "settings_system_daydream" :height 0.9 :v-adjust -0.2))
            (Value . ,(all-the-icons-material "format_align_right" :height 0.9 :v-adjust -0.2 :face 'all-the-icons-lblue))
            (Enum . ,(all-the-icons-material "storage" :height 0.9 :v-adjust -0.2 :face 'all-the-icons-orange))
            (Keyword . ,(all-the-icons-material "filter_center_focus" :height 0.9 :v-adjust -0.2))
            (Snippet . ,(all-the-icons-material "format_align_center" :height 0.9 :v-adjust -0.2))
            (Color . ,(all-the-icons-material "palette" :height 0.9 :v-adjust -0.2))
            (File . ,(all-the-icons-faicon "file-o" :height 0.9 :v-adjust -0.05))
            (Reference . ,(all-the-icons-material "collections_bookmark" :height 0.9 :v-adjust -0.2))
            (Folder . ,(all-the-icons-faicon "folder-open" :height 0.9 :v-adjust -0.05))
            (EnumMember . ,(all-the-icons-material "format_align_right" :height 0.9 :v-adjust -0.2 :face 'all-the-icons-lblue))
            (Constant . ,(all-the-icons-faicon "square-o" :height 0.9 :v-adjust -0.05))
            (Struct . ,(all-the-icons-material "settings_input_component" :height 0.9 :v-adjust -0.2 :face 'all-the-icons-orange))
            (Event . ,(all-the-icons-faicon "bolt" :height 0.85 :v-adjust -0.05 :face 'all-the-icons-orange))
            (Operator . ,(all-the-icons-material "control_point" :height 0.9 :v-adjust -0.2))
            (TypeParameter . ,(all-the-icons-faicon "arrows" :height 0.85 :v-adjust -0.05))
            (Template . ,(all-the-icons-material "format_align_center" :height 0.9 :v-adjust -0.2))))))

(use-package company-go
  :straight t
  :after go-mode
  :config
  (progn
    (setq company-go-show-annotation t)
    (setq company-idle-delay .2)
    (setq company-echo-delay 0)
    (add-hook 'go-mode-hook
	      (lambda ()
		(set (make-local-variable 'company-backends) '(company-go))
		(company-mode)))))

(use-package ivy
  :straight t
  :config
  (define-key ivy-minibuffer-map (kbd "<escape>") 'minibuffer-keyboard-quit)
  )

(use-package ivy-hydra
  :straight t
  :after ivy)

(use-package swiper
  :straight t
  )

(use-package counsel
  :straight t
  :after swiper
  )

(use-package projectile
  :straight t
  :config
  (progn
    (setq projectile-completion-system 'ivy)
    (setq projectile-switch-project-action 'magit-status)
    (setq projectile-enable-caching t)

    (setq projectile-globally-ignored-files '("TAGS" ".DS_Store"))
    (setq projectile-globally-ignored-file-suffixes '("gz" "zip" "tar" "elc"))
    (setq projectile-globally-ignored-directories
          '(".bzr"
            ".ensime_cache"
            ".eunit"
            ".fslckout"
            ".g8"
            ".git"
            ".hg"
            ".idea"
            ".stack-work"
            ".svn"
            "build"
            "dist"
            "node_modules"
            "target"))
    (projectile-mode)))

(use-package counsel-projectile
  :straight t
  :defer t
  :commands (counsel-projectile-mode
	     counsel-projectile-find-file
             counsel-projectile-find-dir
             counsel-projectile-switch-project
             counsel-projectile-switch-to-buffer
             counsel-projectile-rg)
  )


(use-package flycheck
  :straight t
  :init (global-flycheck-mode)
  )

(use-package smartparens
  :straight t
  :config
  (progn
    (require 'smartparens-config)
    (smartparens-global-mode))
  )

;; Add an additional new line and indent when using smartparens
(sp-local-pair 'prog-mode "{" nil :post-handlers '((rs-create-newline-and-enter-sexp "RET")))
(defun rs-create-newline-and-enter-sexp (&rest _ignored)
  "Open a new brace or bracket expression, with relevant newlines and indent."
  (newline)
  (indent-according-to-mode)
  (forward-line -1)
  (indent-according-to-mode)
  )




(use-package iedit
  :straight t
  :config
  (progn
    (setq iedit-toggle-key-default nil))
  )


(use-package evil
  :straight t
  :config
  (evil-mode +1)
  (define-key evil-normal-state-map "r" 'undo-tree-redo)
  (evil-define-key 'normal neotree-mode-map (kbd "TAB") 'neotree-enter)
  (evil-define-key 'normal neotree-mode-map (kbd "SPC") 'neotree-quick-look)
  (evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
  (evil-define-key 'normal neotree-mode-map (kbd "RET") 'neotree-enter)
  )

(use-package evil-multiedit
  :straight t
  :commands (evil-multiedit-match-all)
  :config
  (progn
    (define-key evil-multiedit-state-map (kbd "RET") 'evil-multiedit-toggle-or-restrict-region)
    (define-key evil-motion-state-map (kbd "RET") 'evil-multiedit-toggle-or-restrict-region)
    (define-key evil-multiedit-state-map (kbd "C") nil)
    (define-key evil-multiedit-state-map (kbd "S") #'evil-multiedit--substitute)
    (define-key evil-multiedit-state-map (kbd "C-n") #'evil-multiedit-next)
    (define-key evil-multiedit-state-map (kbd "C-p") #'evil-multiedit-prev)
    (define-key evil-multiedit-insert-state-map (kbd "C-n") #'evil-multiedit-next)
    (define-key evil-multiedit-insert-state-map (kbd "C-p") #'evil-multiedit-prev)))

(use-package evil-escape
  :straight t
  :after evil
  :config
  (progn
    (setq-default evil-escape-key-sequence "jk")
    (evil-escape-mode))
  )

(use-package evil-surround
  :straight t
  :after evil
  :preface
  (progn
    (defun rs--elisp/init-evil-surround-pairs ()
      (make-local-variable 'evil-surround-pairs-alist)
      (push '(?\` . ("`" . "'")) evil-surround-pairs-alist))
    )
  :config
  (progn
    (setq-default evil-surround-pairs-alist
                  '((?\( . ("(" . ")"))
                    (?\[ . ("[" . "]"))
                    (?\{ . ("{" . "}"))

                    (?\) . ("(" . ")"))
                    (?\] . ("[" . "]"))
                    (?\} . ("{" . "}"))

                    (?# . ("#{" . "}"))
                    (?b . ("(" . ")"))
                    (?B . ("{" . "}"))
                    (?> . ("<" . ">"))
                    (?$ . ("${" . "}"))
                    (?t . evil-surround-read-tag)
                    (?< . evil-surround-read-tag)
                    (?f . evil-surround-function)))
    (add-hook 'emacs-lisp-mode-hook #'rs--elisp/init-evil-surround-pairs)
    (global-evil-surround-mode +1)
    (evil-define-key 'visual evil-surround-mode-map "s" #'evil-surround-region)
    (evil-define-key 'visual evil-surround-mode-map "S" #'evil-substitute))
  )

(use-package doom-modeline
  :config
  (+doom-modeline|init)
  )

(use-package yasnippet
  :straight t
  )

(use-package yasnippet-snippets
  :straight t
  )

(use-package aggressive-indent
  :straight t
  :config
  (add-hook 'emacs-lisp-mode-hook #'aggressive-indent-mode)
  )

(use-package all-the-icons
  :straight t
  )

(use-package json-mode
  :straight t
  )

(use-package general
  :straight t
  :config
  (general-override-mode)
  )


(use-package align)

(use-package which-key
  :straight t
  :config
  (progn
    (which-key-mode)
    (setq which-key-idle-delay 0.0))
  )


(use-package expand-region
  :straight t
  :commands
  (er/expand-region)
  )

(use-package ws-butler
  :straight t
  :commands (ws-butler-global-mode)
  :config
  (ws-butler-global-mode)
  )

(use-package highlight-thing
  :straight t
  :commands (highlight-thing-mode)
  :init
  (add-hook 'prog-mode-hook #'highlight-thing-mode)
  :config
  (progn
    (setq highlight-thing-what-thing 'symbol)
    (setq highlight-thing-delay-seconds 0.5)
    (setq highlight-thing-limit-to-defun nil)
    (setq highlight-thing-case-sensitive-p t)
    )
  )


(use-package neotree
  :straight t
  )

(use-package sql-indent
  :straight (:host github :repo "alex-hhh/emacs-sql-indent"
                   :branch "master")
  :after sql
  :config
  (add-hook 'sql-mode-hook #'sqlind-minor-mode)
  )

(use-package restclient
  :straight t
  :commands (restclient-mode
             restclient-http-send-current
             restclient-jump-next
             restclient-jump-prev
	     restclient-http-send-current-stay-in-window)
  :config
  (progn
    (setq restclient-same-buffer-response-name "*restclient*")
    (with-eval-after-load 'which-key
      (with-no-warnings
        (push `((nil . ,(rx bos "restclient-http-" (group (+ nonl)))) . (nil . "\\1"))
              which-key-replacement-alist)))

    (add-to-list 'display-buffer-alist
                 `(,(rx bos "*restclient*" eos)
                   (display-buffer-reuse-window
                    display-buffer-pop-up-window)
                   (reusable-frames . visible)
                   (side            . bottom)
		   (window-height . 0.66))))
  )
(use-package yaml-mode
  :straight t
  :mode ("\\.\\(e?ya?\\|ra\\)ml\\'" . yaml-mode))

(general-def
  :keymaps 'restclient-mode-map
  :states 'motion
  :prefix "SPC r"
  "c" '(restclient-http-send-current :which-key "send-current")
  "o" '(restclient-http-send-current-stay-in-window :which-key "send-current-in-window")
  )

(general-def
  :keymaps 'restclient-mode-map
  "C-n" '(restclient-jump-next :which-key "jump-next")
  "C-p" '(restclient-jump-prev :which-key "jump-prev")
  )
;; Key mappings
(general-create-definer rs-leader-def
  :states '(normal visual insert emacs)
  :prefix "SPC"
  :keymaps 'override
  :non-normal-prefix "M-SPC")

(general-create-definer rs-local-leader-def
  :states 'motion
  :keymaps 'override
:prefix "SPC m")


(rs-leader-def
  "bb"  '(ivy-switch-buffer :which-key "prev buffer")
  "bd"  '(bury-buffer :which-key "delete buffer")

  "SPC" '(counsel-M-x :which-key "M-x")
  "ff"  '(counsel-find-file :which-key "find file")
  ";" '(rs-comment-or-uncomment-region-or-line :which-key "comment")

  "aa" '(align-regexp :which-key "align-regexp")

  "v" '(er/expand-region :which-key "expand-region")

  "uw" '(upcase-word :which-key "upcase word")
  "ur" '(upcase-region :which-key "upcase region")

  "dw" '(downcase-word :which-key "downcase word")
  "dr" '(downcase-region :which-key "downcase region")

  "cw" '(capitalize-word :which-key "capitalise word")
  "cr" '(capitalize-region :which-key "capitalise region")

  "gs" '(magit-status :which-key "magit status")

  "se" '(evil-multiedit-match-all :which-key "multi-match-all")

  "lg" '(lsp-find-definition)
  "lr" '(lsp-find-references)
  "lm" '(lsp-ui-imenu)

  "nt" '(neotree-toggle :which-key "neotree")

  "pn" '(neotree-projectile-action :which-key "project tree")
  "pf" '(counsel-projectile-find-file :which-key "project find file")

  "pb" '(counsel-projectile-switch-to-buffer :which-key "project switch to buffer")
  "ps" '(counsel-projectile-switch-project :which-key "project switch")
  "/" '(counsel-projectile-rg :which-key "project search")

  "w/"  '(evil-window-vsplit :which-key "vertical split window")
  "w-"  '(evil-window-split :which-key "horizontal split window")
  "w="  '(balance-windows :which-key "balance windows")
  "wd"  '(evil-window-delete :which-key "delete window")
  "wh" '(windmove-left :which-key "move window left")
  "wl" '(windmove-right :which-key "move window right")
  "wk" '(windmove-up :which-key "move window up")
  "wj" '(windmove-down :which-key "move window down")
  "wr"  '(evil-window-rotate-downwards :which-key "rotate window down")
  "wR"  '(evil-window-rotate-upwards :which-key "rotate window up")

  "tm"  '(toggle-frame-maximized :which-key "maximise window")
  )

;; Custom stuff
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)


;; Swiper definition
(general-def 'motion
  "/" 'counsel-grep-or-swiper)

;; Modes
(use-package go-mode
  :ensure t
  :mode ("\\.go\\'" . go-mode)
  :preface
  (defun rs-modules-p ()
    "Return non-nil if this buffer is part of a Go Modules project."
    (locate-dominating-file default-directory "go.mod"))

  (defun rs-setup-go ()
    "Run setup for Go buffers."
    (progn
      (if (rs-modules-p)
          (setenv "GO111MODULE" "on")
        (setenv "GO111MODULE" "auto"))
      (lsp)))
  :hook
  (go-mode . rs-setup-go)
  :config
  (progn
    (setq gofmt-command "goimports")
    ;; (setq godoc-at-point-function 'godoc-gogetdoc)
    (setq-local tab-width 4)
    (setq-local indent-tabs-mode t)

    (add-hook 'before-save-hook 'gofmt-before-save)
    (push '("*go test*" :dedicated t :position bottom :stick t :noselect t :height 0.25) popwin:special-display-config)

    ;; TODO: integrate with general definer
    (which-key-add-major-mode-key-based-replacements 'go-mode
      "SPC mr" "refactor"
      "SPC mg" "goto"
      "SPC mh" "help"
      "SPC mt" "test")

    (rs-local-leader-def
     :keymaps 'go-mode-map
     "tp" 'rs-go-run-package-tests
     "tf" 'rs-go-run-test-current-function)))

(use-package go-rename
  :ensure t
  :after go-mode
  :config
  (rs-local-leader-def
   :keymaps 'go-mode-map
   "rn" 'go-rename))

(use-package flycheck-golangci-lint
  :ensure t
  :config
  (setq flycheck-disabled-checkers '(go-gofmt
                                     go-golint
                                     go-vet
                                     go-build
                                     go-test
                                     go-errcheck))
  :hook (go-mode . flycheck-golangci-lint-setup))

(use-package go-eldoc
  :ensure t
  :after go-mode
  :config
  (add-hook 'go-mode-hook 'go-eldoc-setup))

(setq counsel-rg-base-command "rg -i -g '!.git/*' --no-heading --line-number --hidden --color never %s .")

(use-package go-tag
  :ensure t
  :after go-mode
  :init
  (rs-local-leader-def
   :keymaps 'go-mode-map
   "rf" 'go-tag-add
   "rF" 'go-tag-remove))

(use-package godoctor
  :ensure t
  :init
  (progn
    (rs-local-leader-def
     :keymaps 'go-mode-map
     "re" 'godoctor-extract
     "rt" 'godoctor-toggle
     "rd" 'godoctor-godoc)))

(use-package go-guru
  :ensure t
  :after go-mode
  :init
  (which-key-add-major-mode-key-based-replacements 'go-mode "SPC mf" "guru")
  (rs-local-leader-def
   :keymaps 'go-mode-map
   "fd" 'go-guru-describe
   "ff" 'go-guru-freevars
   "fi" 'go-guru-implements
   "fc" 'go-guru-peers
   "fr" 'go-guru-referrers
   "fj" 'go-guru-definition
   "fp" 'go-guru-pointsto
   "fs" 'go-guru-callstack
   "fe" 'go-guru-whicherrs
   "f<" 'go-guru-callers
   "f>" 'go-guru-callees
   "fo" 'go-guru-set-scope))

(use-package go-fill-struct
  :ensure t
  :init
  (rs-local-leader-def
   :keymaps 'go-mode-map
   "rs" 'go-fill-struct))

(use-package go-impl
  :ensure t
  :init
  (rs-local-leader-def
   :keymaps 'go-mode-map
   "ri" 'go-impl))



(use-package go-mode
  :straight t
  :mode ("\\.go\\'" . go-mode)
  :config
  (progn
    (setq-local tab-width 4)
    (setq-local indent-tabs-mode t)
    (setq gofmt-command "goreturns")
    (setq godoc-at-point-function 'godoc-gogetdoc)
    (setq gofmt-show-errors nil)
    (add-hook 'before-save-hook #'gofmt-before-save))

  :functions (gofmt-before-save godoc-at-point))

(use-package go-rename
  :straight t
  :after go-mode
  )

(use-package godoctor
  :straight t
  :init
  )

(use-package go-rename
  :straight t
  :after go-mode
  )

(use-package go-tag
  :straight t
  :after go-mode
  :config
  (setq go-tag-args (list "-transform" "camelcase"))
  )

(use-package go-eldoc
  :straight t
  :after go-mode
  :config
  (add-hook 'go-mode-hook 'go-eldoc-setup))

(general-def
  :keymaps 'go-mode-map
  :states 'motion
  :prefix "SPC g"
  "hh" '(godoc-at-point :which-key "godoc-at-point")
  "ig" '(go-goto-imports :which-key "go-goto-imports")
  "ia" '(go-import-add :which-key "go-import-add")
  "ir" '(go-remove-unused-imports :which-key "go-remove-unused-imports")

  "er" '(go-play-region :which-key "go-play-region")
  "ed" '(go-download-play :which-key "go-download-play")

  "gj" '(godef-jump :which-key "godef-jump")
  "gd" '(godef-describe :which-key "godef-describe")
  "gw" '(godef-jump-other-window :which-key "godef-jump-other-window")

  "dr" '(godoctor-rename :which-key "godoctor-rename")
  "de" '(godoctor-extract :which-key "godoctor-extract")
  "dt" '(godoctor-toggle :which-key "godoctor-toggle")
  "dg" '(godoctor-godoc :which-key "godoctor-godoc")

  "ta" '(go-tag-add :which-key "go-tag-add")
  "tr" '(go-tag-remove :which-key "go-tag-remove")
  )

;; Improved JavaScript editing mode
(use-package js2-mode
  :ensure t
  :defines flycheck-javascript-eslint-executable
  :mode (("\\.js\\'" . js2-mode)
         ("\\.jsx\\'" . js2-jsx-mode))
  :interpreter (("node" . js2-mode)
                ("node" . js2-jsx-mode))
  :hook ((js2-mode . js2-imenu-extras-mode)
         (js2-mode . js2-highlight-unused-variables-mode))
  :config
  ;; Use default keybindings for lsp
  (unbind-key "M-." js2-mode-map)
  (with-eval-after-load "lsp-javascript-typescript"
    (add-hook 'js2-mode-hook #'lsp))
  (when (featurep! +lsp)
    (add-hook! (js2-mode typescript-mode) #'lsp!))

  (with-eval-after-load 'flycheck
    (if (or (executable-find "eslint_d")
            (executable-find "eslint")
            (executable-find "jshint"))
	(setq js2-mode-show-strict-warnings nil))
    (if (executable-find "eslint_d")
	;; https://github.com/mantoni/eslint_d.js
	;; npm -i -g eslint_d
	(setq flycheck-javascript-eslint-executable "eslint_d"))))

(use-package js2-refactor
  :ensure t
  :diminish js2-refactor-mode
  :hook (js2-mode . js2-refactor-mode)
  :config (js2r-add-keybindings-with-prefix "C-c C-m"))

(use-package web-mode
  :straight t
  :config
  (require 'web-mode)
  (add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.json\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.css\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.xml\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.js[x]?\\'" . web-mode))
  )

(use-package prettier-js
  :straight t
  :after web-mode
  )

;; Ambient title bar
(when (eq system-type 'darwin)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist '(ns-appearance . 'nil))
  (setq frame-title-format nil))


(put 'downcase-region 'disabled nil)

(provide 'init)
;;; init.el ends here
