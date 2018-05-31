;;; init.el --- Startup file for Emacs.  -*- lexical-binding: t; -*-

;; Copyright (C) 2018 Ryan Scott

;; Author: Ryan Scott <ryankennethscott@gmail.com>

;;; Commentary:

;; TODO:
;; - Fix the title bar that has the resolution in it
;; - Get prettier
;; - Magit (?)
;; - get tabs to indent
;; - goto def is broken

;;; Code:
(when (version< emacs-version "26")
  (error "This version of Emacs is not supported"))

;; Bootstrap straight

(setq package-enable-at-startup nil)

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

;; Remove splash screen
(setq initial-scratch-message nil)
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)

;; Smooth scrolling
(setq scroll-step           1
      scroll-margin         0
      scroll-conservatively 10000)

;; Hide toolbars
(tool-bar-mode -1)
(menu-bar-mode -1)
(toggle-scroll-bar -1)
(horizontal-scroll-bar-mode -1)

;; Enable hideshow in all programming buffers.

(autoload 'hs-minor-mode "hideshow")
(add-hook 'prog-mode-hook 'hs-minor-mode)


;; Use path from shell for Golang
(use-package exec-path-from-shell
  :straight t
  :config
  (exec-path-from-shell-initialize)
  (exec-path-from-shell-copy-env "GOPATH"))


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
(use-package rainbow-mode
  :straight t)

(use-package nlinum
  :straight t
  :config
  (global-nlinum-mode))

(use-package company
  :straight t
	:commands (global-company-mode)
	:init
  (add-hook 'after-init-hook #'global-company-mode)
	)

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


(use-package swiper
  :straight t
	)

(use-package counsel
  :straight t
  :after swiper
)

(use-package projectile
  :straight t
  )

(use-package flycheck
  :straight t
:init (global-flycheck-mode))

(use-package smartparens
  :straight t
  :config
  (progn
    (require 'smartparens-config)
		(smartparens-global-mode)))

(use-package iedit
  :straight t
  :config
  (progn
		(setq iedit-toggle-key-default nil)))


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
    (evil-escape-mode)))

(use-package evil-surround
  :straight t
  :after evil
  :preface
  (progn
    (defun rs--elisp/init-evil-surround-pairs ()
      (make-local-variable 'evil-surround-pairs-alist)
      (push '(?\` . ("`" . "'")) evil-surround-pairs-alist)))

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
    (evil-define-key 'visual evil-surround-mode-map "S" #'evil-substitute)))

(use-package doom-modeline
  :config
	(+doom-modeline|init))

(use-package yasnippet
	:straight t)

(use-package yasnippet-snippets
	:straight t)

(use-package aggressive-indent
  :straight t
  :config
	(add-hook 'emacs-lisp-mode-hook #'aggressive-indent-mode))

(use-package all-the-icons
	:straight t)


(use-package json-mode
	:straight t)

(use-package general
  :straight t
  :config
  (general-override-mode))


(use-package align)

(use-package which-key
  :straight t
  :config
  (progn
    (which-key-mode)
    (setq which-key-idle-delay 0.0)))


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
    ))


(use-package neotree
  :straight t
  )

(use-package go-rename
  :straight t
  :after go-mode
	)


;; Key mappings
(general-create-definer rs-leader-def
  :states '(normal visual insert emacs)
  :prefix "SPC"
  :keymaps 'override
  :non-normal-prefix "M-SPC")

(rs-leader-def
  "bb"  '(ivy-switch-buffer :which-key "prev buffer")
  "bd"  '(bury-buffer :which-key "delete buffer")
  
  "SPC" '(counsel-M-x :which-key "M-x")
  "ff"  '(counsel-find-file :which-key "find file")
  ";" '(rs-comment-or-uncomment-region-or-line :which-key "comment")
  
  "aa" '(align-regexp :which-key "align-regexp")
  
  "v" '(er/expand-region :which-key "expand-region")
  
  "uc" '(upcase-char :which-key "upcase char")
  "uw" '(upcase-word :which-key "upcase word")
  "ur" '(upcase-region :which-key "upcase region")
  
  "dc" '(downcase-char :which-key "downcase char")
  "dw" '(downcase-word :which-key "downcase word")
  "dr" '(downcase-region :which-key "downcase region")
  
  "cw" '(capitalize-word :which-key "capitalise word")
  "cr" '(capitalize-region :which-key "capitalise region")

  "se" '(evil-multiedit-match-all :which-key "multi-match-all")

  "nt" '(neotree-toggle :which-key "neotree")
  
  "w/"  '(evil-window-vsplit :which-key "vertical split window")
  "w-"  '(evil-window-split :which-key "horizontal split window")
  "w="  '(balance-windows :which-key "balance windows")
  "wd"  '(evil-window-delete :which-key "delete window")
  "wh" '(windmove-left :which-key "move window left")
  "wl" '(windmove-right :which-key "move window right")
  "wj" '(windmove-up :which-key "move window up")
  "wk" '(windmove-down :which-key "move window down")
  
  "tm"  '(toggle-frame-maximized :which-key "maximise window")
  )

(general-def 'motion
  "/" 'counsel-grep-or-swiper)

;; modes
(use-package go-mode
  :straight t
  :mode ("\\.go\\'" . go-mode)
  :config
  (progn
    (setq gofmt-command "goimports")
    (setq-local tab-width 4)
    (setq-local indent-tabs-mode t)

    (add-hook 'before-save-hook 'gofmt-before-save))
	)

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


;; weird config stuff

;; ambient title bar
(when (eq system-type 'darwin)
  (progn
    (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
    (add-to-list 'default-frame-alist '(ns-appearance . 'nil))
    (setq frame-title-format nil)))


(put 'downcase-region 'disabled nil)

(provide 'init)
;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
	("1c6546c19d5c420a03ea2cb12ec56388a8931e786e47f5c96b23262001d001c7" "329e97dffff82b5b177b767f1dd299197b285e24ba7a85180bda9da2c5143cc4" "dce530e4dff6ca98607aae0e367847ba39e8e26ba4e36ba77924ecfa5420de45" default))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
