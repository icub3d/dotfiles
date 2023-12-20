;; -*- lexical-binding: t; -*-

;; straight and use-package setup  
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)2
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
(straight-use-package 'use-package)

;; some helper functions
(defun trim-string (str)
  "Trim whitespace from beginning and end of STR."
  (replace-regexp-in-string "\\`[[:blank:]\n]*" ""
                            (replace-regexp-in-string "[[:blank:]\n]*\\'" "" str)))


;; general settings
(setq column-number-mode t)                    ; show column number
(setq shell-file-name "/bin/bash")             ; use bash
(tool-bar-mode -1)                             ; hide tool bar
(menu-bar-mode -1)                             ; hide menu bar
(scroll-bar-mode -1)                           ; hide scroll bar
(xterm-mouse-mode 1)                           ; mouse in terminal
(setq inhibit-startup-screen t)                ; startup screen
(setq-default tab-width 4)                     ; tab size
(global-display-line-numbers-mode 1)           ; line numbers
(electric-pair-mode 1)                         ; autopairs
(setq ring-bell-function 'ignore)              ; no bell
(setq vc-follow-symlinks t)                    ; follow symlinks
(setq markdown-fontify-code-blocks-natively t) ; markdown code blocks
;; (setq-default indent-tabs-mode nil)			   ; no tabs

;; f
(use-package f
  :ensure t
  :straight t)

;; libvterm
(use-package vterm
  :ensure t
  :straight t
  :config
  (setq vterm-shell "/usr/bin/env fish")
  (setq vterm-max-scrollback 100000))

;; backup stuff
(setq
 backup-by-copying t          ; don't clobber symlinks
 backup-directory-alist
 '(("." . "~/.saves/"))      ; don't litter my fs tree
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 auto-save-file-name-transforms
 '((".*" "~/.saves/" t))
 version-control t)           ; use versioned backups

;; copy/paste with clipboard (wayland specific)
(setq wl-copy-process nil)
(defun wl-copy (text)
  (setq wl-copy-process (make-process :name "wl-copy"
                                      :buffer nil
                                      :command '("wl-copy" "-f" "-n")
                                      :connection-type 'pipe))
  (process-send-string wl-copy-process text)
  (process-send-eof wl-copy-process))
(defun wl-paste ()
  (if (and wl-copy-process (process-live-p wl-copy-process))
      nil ; should return nil if we're the current paste owner
    (shell-command-to-string "wl-paste -n | tr -d \r")))
(setq interprogram-cut-function 'wl-copy)
(setq interprogram-paste-function 'wl-paste)

;; update tmux on save
(add-hook 'after-save-hook
		  (lambda ()
			(call-process "/usr/bin/env" nil nil nil "fish" "-c" "tmux_status_tracker_save")))

;; general bindings
(global-set-key (kbd "C-c e r") 'eval-region)
(global-set-key (kbd "C-c e b") 'eval-buffer)

;; theming
(use-package monokai-pro-theme
  :ensure t
  :straight t
  :config
  (load-theme 'monokai-pro t))
(set-face-attribute 'default nil :font "JetBrains Mono" :height 120)
(use-package telephone-line
  :ensure t
  :straight t
  :config
  (telephone-line-defsegment my-telephone-line-flycheck-segment ()
	"Displays current checker state."
	(when (bound-and-true-p flycheck-mode)
      (let* ((text (pcase flycheck-last-status-change
					 ('finished (if flycheck-current-errors
									(let-alist (flycheck-count-errors flycheck-current-errors)
                                      (if (or .error .warning)
                                          (propertize (format "😱 %s / 😟 %s"
                                                              (or .error 0) (or .warning 0))
                                                      'face 'telephone-line-warning)
										""))
                                  (propertize "😌" 'face 'telephone-line-unimportant)))
					 ('running     "😔")
					 ('no-checker  (propertize "😐" 'face 'telephone-line-unimportant))
					 ('not-checked "😐")
					 ('errored     (propertize "😱" 'face 'telephone-line-error))
					 ('interrupted (propertize "😲" 'face 'telephone-line-error))
					 ('suspicious  "😒"))))
		(propertize text
					'help-echo (pcase flycheck-last-status-change
								 ('finished "Display errors found by Flycheck")
								 ('running "Running...")
								 ('no-checker "No Checker")
								 ('not-checked "Not Checked")
								 ('errored "Error!")
								 ('interrupted "Interrupted")
								 ('suspicious "Suspicious?"))
					'display '(raise 0.0)
					'mouse-face '(:box 1)
					'local-map (make-mode-line-mouse-map
								'mouse-1 #'flycheck-list-errors)))))
  (setq telephone-line-lhs '((accent . (telephone-line-projectile-segment))
							 (nil . (telephone-line-buffer-segment))))
  (setq telephone-line-rhs '((nil . (my-telephone-line-flycheck-segment))
							 (nil . (telephone-line-misc-info-segment))
							 (nil . (telephone-line-major-mode-segment))
							 (accent . (telephone-line-airline-position-segment))))
  (telephone-line-mode 1))

;; rainbow colors
(use-package rainbow-mode
  :ensure t
  :straight t
  :hook (prog-mode . rainbow-mode))

;; rainbow delimiters
(use-package rainbow-delimiters
  :ensure t
  :straight t
  :hook (prog-mode . rainbow-delimiters-mode))

;; diminish
(use-package diminish
  :ensure t
  :straight t
  :config
  (diminish 'elisp-mode "el"))

;; Ivy, Counsel, Swiper
(use-package counsel
  :ensure t
  :diminish
  :straight t
  :after ivy
  :bind
  (("C-x C-f" . counsel-find-file))
  :config (counsel-mode))

(use-package ivy
  :ensure t
  :straight t
  :defer 0.0
  :diminish
  :bind (("C-c C-r" . ivy-resume))
  :custom
  (ivy-count-format "(%d/%d) ")
  (ivy-use-virtual-buffers t)
  :config (ivy-mode))

(use-package ivy-rich
  :ensure t
  :straight t
  :after ivy
  :bind (("C-x B" . ivy-switch-buffer-other-window))
  :custom
  (ivy-virtual-abbreviate 'full
                          ivy-rich-switch-buffer-align-virtual-buffer t
                          ivy-rich-path-style 'abbrev)
  :config
  (ivy-set-display-transformer 'ivy-switch-buffer
                               'ivy-rich-switch-buffer-transformer))

(use-package swiper
  :ensure t
  :straight t
  :after ivy
  :bind (("C-s" . swiper)
         ("C-r" . swiper)))

;; command-log-mode
(use-package command-log-mode
  :ensure t
  :straight t
  :diminish
  :bind (("C-c l" . clm/toggle-command-log-buffer))
  :config
  (global-command-log-mode))

;; flycheck
(use-package flycheck
  :diminish
  :ensure t
  :straight t)
(use-package flycheck-status-emoji
  :diminish
  :ensure t
  :straight t
  :after flycheck
  :config
  (flycheck-status-emoji-mode))

;; company
(use-package company
  :ensure t
  :straight t
  :diminish
  :bind (:map company-active-map
              ("C-n" . company-select-next)
              ("C-p" . company-select-previous))
  :config
  (setq company-idle-delay 0.0)
  (global-company-mode t))

;; yasnippet
(use-package yasnippet
  :ensure t
  :straight t
  :diminish yas-minor-mode
  :config
  (setq
   yas-verbosity 1
   yas-wrap-around-region t)
  (yas-global-mode))

(use-package yasnippet-snippets
  :straight t
  :ensure t)

;; multiple cursors
(use-package multiple-cursors
  :ensure t
  :straight t
  :bind (("C-c m c" . mc/edit-lines)
		 ("C-c m n" . mc/mark-next-like-this)
		 ("C-c m p" . mc/mark-previous-like-this)
		 ("C-c m a" . mc/mark-all-like-this)))

;;treesitter
;; (use-package tree-sitter
;;   :ensure t
;;   :straight t
;;   :diminish
;;   :config
;;   (global-tree-sitter-mode)
;;   (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))
;; (use-package tree-sitter-langs
;;   :ensure t
;;   :straight t
;;   :after tree-sitter
;;   :config
;;   (require 'tree-sitter-langs))

;; copilot
(use-package copilot
  :ensure t
  :init
  (add-hook 'prog-mode-hook 'copilot-mode)
  :diminish
  :config
  (define-key copilot-completion-map (kbd "<tab>") 'copilot-accept-completion)
  (define-key copilot-completion-map (kbd "TAB") 'copilot-accept-completion)
  :straight (:host github :repo "zerolfx/copilot.el"
                   :files ("dist" "*.el")))

;; ellama
(use-package ellama
  :straight t
  :config
  (global-set-key (kbd "M-0") 'ellama-chat))

;; ;; chatgpt
;; (use-package shell-maker
;;   :ensure t
;;   :straight (:host github :repo "xenodium/chatgpt-shell" :files ("shell-maker.el")))

;; ripgrep
(use-package rg
  :ensure t
  :straight t
  :config
  (setq rg-command-line-flags
   '("--hidden" "--glob" "!.git"))
  (rg-enable-default-bindings))

;; elcord
(use-package elcord
  :ensure t
  :straight t
  :config
  (when (not (string= (getenv "ATWORK") "true"))
	(elcord-mode)))

;; treemacs
(use-package treemacs
  :ensure t
  :straight t
  :custom
  (treemacs--icon-size 16)
  :bind ("C-c t" . treemacs-select-window))

;; projectile
(use-package projectile
  :ensure t
  :straight t
  :diminish projectile-mode
  :config
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (projectile-mode t))
(use-package treemacs-projectile
  :ensure t
  :straight t)
;; (use-package counsel-projectile
;;   :ensure t
;;   :straight t
;;   :config
;;   (counsel-projectile-mode))
;; chatgpt
;; (use-package chatgpt-shell
;;   :requires shell-maker
;;   :ensure t
;;   :straight (:host github :repo "xenodium/chatgpt-shell" :files ("chatgpt-shell.el"))
;;   :config
;;   (let ((file-path "~/Documents/ssssh/chat-gpt-api-key"))
;; 	(if (file-exists-p file-path)
;; 		(setq chatgpt-shell-openai-key (trim-string (with-temp-buffer
;; 													  (insert-file-contents file-path)
;; 													  (buffer-string)))))))

;; lsp-mode
(use-package lsp-mode
  :ensure t
  :straight t
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  (setq lsp-prefer-flymake nil)
  :commands (lsp lsp-mode lsp-deferred))

(use-package lsp-ui
  :ensure t
  :straight t
  :commands lsp-ui-mode)

(use-package lsp-ivy
  :ensure t
  :straight t)

;; lisp / slime
(use-package slime
  :ensure t
  :straight t
  :config
  (setq inferior-lisp-program "/usr/bin/sbcl")
  (setq slime-contribs '(slime-fancy)))

;; haskell
(use-package lsp-haskell :ensure t :straight t)
(use-package haskell-mode
  :ensure t
  :straight t
  :mode "\\.hs\\'"
  :bind (:map haskell-mode-map
			  ("M-j" . lsp-ui-imenu)
			  ("M-?" . lsp-find-references)
			  ("M-g l" . flycheck-list-errors)
			  ("M-g a" . lsp-execute-code-action)
			  ("M-g r" . lsp-rename)
			  ("M-g q" . lsp-workspace-restart)
			  ("M-g Q" . lsp-workspace-shutdown))
  :hook ((haskell-mode . lsp-deferred)
		 (haskell-mode . my/haskell-config-hooks)
		 (haskell-mode . my/haskell-save-hooks))
  :config
  (defun my/haskell-config-hooks ())
  (defun my/haskell-save-hooks ()
	"save hooks"
	(add-hook 'before-save-hook #'lsp-format-buffer t t)))

;; svelte
(use-package svelte-mode
  :ensure t
  :straight t
  :mode "\\.svelte\\'"
  :bind (:map svelte-mode-map
			  ("M-j" . lsp-ui-imenu)
			  ("M-?" . lsp-find-references)
			  ("M-g l" . flycheck-list-errors)
			  ("M-g a" . lsp-execute-code-action)
			  ("M-g r" . lsp-rename)
			  ("M-g q" . lsp-workspace-restart)
			  ("M-g Q" . lsp-workspace-shutdown))
  :hook ((svelte-mode . lsp-deferred)
		 (svelte-mode . my/svelte-config-hooks)
		 (svelte-mode . my/svelte-save-hooks))
  :config
  (defun my/svelte-config-hooks ())
  (defun my/svelte-save-hooks ()
    "save hooks"
    (add-hook 'before-save-hook #'lsp-format-buffer t t)))

;; Go
(use-package gotest :ensure t :straight t)
(use-package go-mode
  :ensure t
  :straight t
  :mode "\\.go\\'"
  :bind (:map go-mode-map
			  ("M-j" . lsp-ui-imenu)
			  ("M-?" . lsp-find-references)
			  ("M-g f" . go-test-current-file)
			  ("M-g b" . go-test-current-benchmark)
			  ("M-g p" . go-test-current-project)
			  ("M-g t" . go-test-current-test)
			  ("M-g R" . go-run)
			  ("M-g l" . flycheck-list-errors)
			  ("M-g a" . lsp-execute-code-action)
			  ("M-g r" . lsp-rename)
			  ("M-g q" . lsp-workspace-restart)
			  ("M-g Q" . lsp-workspace-shutdown))
  :hook ((go-mode . lsp-deferred)
		 (go-mode . my/go-config-hooks)
		 (go-mode . my/go-save-hooks))
  :config
  (defun my/go-config-hooks ()
    (setq tab-width 4)
    )
  (defun my/go-save-hooks ()
    "save hooks"
    (add-hook 'before-save-hook #'lsp-format-buffer t t)
    (add-hook 'before-save-hook #'lsp-organize-imports t t)))

;; Rust
(use-package rustic
  :ensure t
  :straight t
  :hook ((rustic-mode . lsp-deferred)
		 (rustic-mode . my/rustic-mode-hook))
  :bind (:map rustic-mode-map
			  ("M-j" . lsp-ui-imenu)
			  ("M-?" . lsp-find-references)
			  ("M-g b" . rustic-cargo-build)
			  ("M-g t" . rustic-cargo-test)
			  ("M-g A" . rustic-cargo-add)
			  ("M-g f" . leptos-format-buffer)
			  ("M-g l" . flycheck-list-errors)
			  ("M-g a" . lsp-execute-code-action)
			  ("M-g r" . lsp-rename)
			  ("M-g q" . lsp-workspace-restart)
			  ("M-g Q" . lsp-workspace-shutdown)
			  ("M-g s" . lsp-rust-analyzer-status))
  :config
  (setq lsp-rust-analyzer-cargo-watch-command "clippy")
  (defun leptos-format-buffer ()
	(let ((temp-point (point))
		  (temp-start (window-start)))
	  (shell-command-on-region
	   (point-min)
	   (point-max)
	   "fish -c leptosfmt_helper"
	   nil
	   t)
	  (goto-char (point-min))
	  (set-window-start (selected-window) temp-start)
	  (goto-char temp-point)))
  (defun my/rustic-mode-hook ()
	(when buffer-file-name
      (setq-local buffer-save-without-query t))
	(add-hook 'before-save-hook 'leptos-format-buffer t t)
	(add-hook 'before-save-hook 'lsp-format-buffer t t)))

;; Python
(use-package pyvenv
  :ensure t
  :straight t
  :config
  (setq pyvenv-workon ".venv")
  (pyvenv-tracking-mode 1))
(use-package python-black
  :ensure t
  :straight t
  :diminish python-black-on-save-mode
  :after python
  :hook (python-mode . python-black-on-save-mode))
(use-package python-pytest :ensure t :straight t)
(use-package python-mode
  :hook ((python-mode . lsp-deferred))
  :bind (:map python-mode-map
			  ("M-j" . lsp-ui-imenu)
			  ("M-?" . lsp-find-references)
			  ("M-g t" . python-pytest)
			  ("M-g f" . python-pytest-file)
			  ("M-g p" . python-pytest)
			  ("M-g F" . python-pytest-function)
			  ("M-g l" . flycheck-list-errors)
			  ("M-g a" . lsp-execute-code-action)
			  ("M-g r" . lsp-rename)
			  ("M-g q" . lsp-workspace-restart)
			  ("M-g Q" . lsp-workspace-shutdown)
			  ("M-g s" . lsp-rust-analyzer-status)))

;; Fish
(use-package fish-mode
  :ensure t
  :straight t)

;; Terraform
(use-package terraform-mode
  :ensure t
  :straight t
  :hook ((terraform-mode . lsp-deferred)
		 (terraform-mode . my/terraform-save-hooks))
  :config
  (defun my/terraform-save-hooks ()
    "save hooks"
    (add-hook 'before-save-hook #'lsp-format-buffer t t)))


;; markdown
(use-package markdown-mode
  :ensure t
  :straight t)

;; chatgpt
(use-package shell-maker
  :ensure t
  :straight (:host github :repo "xenodium/chatgpt-shell" :files ("shell-maker.el")))

;; mdlp
(use-package mdlp-mode
  :ensure t
;;  :hook (markdown-mode . mdlp-mode)
  :straight (:host github :repo "icub3d/mdlp" :files ("mdlp-mode.el"))
  :config
  (setq mdlp-github-token (string-trim (f-read-text "~/Documents/ssssh/github-pat"))))

;; grip (for makrdown preview)
;; (use-package grip-mode
;;   :ensure t
;;   :straight t
;;   :hook ((markdown-mode . grip-mode))
;;   :config
;;   (setq grip-github-user "icub3d")
;;   (setq grip-github-password (f-read-text "~/Documents/ssssh/github-pat"))
;;   (setq grip-preview-use-webkit t)
;;   (setq grip-update-after-change nil))


;; docker-compose
(use-package docker-compose-mode
  :ensure t
  :straight t)

;; dockerfile
(use-package dockerfile-mode
  :ensure t
  :straight t)

;; yaml
(use-package yaml-mode
  :ensure t
  :straight t
  :mode "\\.yaml\\'"
  :mode "\\.yml\\'"
  :config
  (defun my/yaml-config-hooks ()
    (setq tab-width 4))
  (defun my/yaml-save-hooks ()
    "save hooks"
    (add-hook 'before-save-hook #'lsp-format-buffer t t))
  :hook
  ((yaml-mode . my/yaml-config-hooks)
   (yaml-mode . my/yaml-save-hooks)
   (yaml-mode . lsp-deferred)))

;; Jenkinsfile
(use-package jenkinsfile-mode
  :ensure t
  :straight t)

;; js-mode
(use-package js
  :ensure nil
  :straight nil
  :bind (:map js-mode-map
			  ("M-j" . lsp-ui-imenu)
			  ("M-?" . lsp-find-references)
			  ("M-g l" . flycheck-list-errors)
			  ("M-g a" . lsp-execute-code-action)
			  ("M-g r" . lsp-rename)
			  ("M-g q" . lsp-workspace-restart)
			  ("M-g Q" . lsp-workspace-shutdown))
  :hook ((js-mode . lsp-deferred)
		 (js-mode . my/js-config-hooks)
		 (js-mode . my/js-save-hooks))
  :config
  (defun my/js-config-hooks ()
	(setq js-jsx-syntax t))
  (defun my/js-save-hooks ()
    "save hooks"
    (add-hook 'before-save-hook #'lsp-format-buffer t t)))

;; emmet-mode
(use-package emmet-mode
  :ensure t
  :straight t
  :hook ((mhtml-mode . emmet-mode)
		 (css-mode . emmet-mode)
		 (js-mode . emmet-mode)
		 (typescript-mode . emmet-mode)
		 (web-mode . emmet-mode)))

;; css
(use-package css-mode
  :ensure nil
  :straight (:type built-in)
  :bind (:map css-mode-map
			  ("M-j" . lsp-ui-imenu)
			  ("M-?" . lsp-find-references)
			  ("M-g l" . flycheck-list-errors)
			  ("M-g a" . lsp-execute-code-action)
			  ("M-g r" . lsp-rename)
			  ("M-g q" . lsp-workspace-restart)
			  ("M-g Q" . lsp-workspace-shutdown))
  :hook ((css-mode . lsp-deferred)
		 (css-mode . my/css-config-hooks)
		 (css-mode . my/css-save-hooks))
  :config
  (setq lsp-css-lint-unknown-at-rules "ignore")
  (defun my/css-config-hooks ())
  (defun my/css-save-hooks ()
	"save hooks"
	(add-hook 'before-save-hook #'lsp-format-buffer t t)))

;; tailwind
(use-package lsp-tailwindcss
  :ensure t
  :straight (:host github :repo "merrickluo/lsp-tailwindcss"))

;; html
(use-package mhtml-mode
  :ensure nil
  :straight (:type built-in)
  :bind (:map html-mode-map
			  ("M-j" . lsp-ui-imenu)
			  ("M-?" . lsp-find-references)
			  ("M-g l" . flycheck-list-errors)
			  ("M-g a" . lsp-execute-code-action)
			  ("M-g r" . lsp-rename)
			  ("M-g q" . lsp-workspace-restart)
			  ("M-g Q" . lsp-workspace-shutdown))
  :hook ((html-mode . lsp-deferred)
		 (html-mode . my/html-config-hooks)
		 (html-mode . my/html-save-hooks))
  :config
  (defun my/html-config-hooks ())
  (defun my/html-save-hooks ()
	(add-hook 'before-save-hook #'lsp-format-buffer t t)))

;; prettier
(use-package prettier-js
  :ensure t
  :straight t
  :hook ((js-mode . prettier-js-mode)
		 (typescript-mode . prettier-js-mode)
		 (css-mode . prettier-js-mode)
		 (html-mode . prettier-js-mode)
		 (mhtml-mode . prettier-js-mode)))

;; typescript
(use-package typescript-mode
  :ensure t
  :straight t
  :mode "\\.ts\\'"
  :mode "\\.tsx\\'"
  :bind (:map typescript-mode-map
			  ("M-j" . lsp-ui-imenu)
			  ("M-?" . lsp-find-references)
			  ("M-g l" . flycheck-list-errors)
			  ("M-g a" . lsp-execute-code-action)
			  ("M-g r" . lsp-rename)
			  ("M-g q" . lsp-workspace-restart)
			  ("M-g Q" . lsp-workspace-shutdown))
  :hook ((typescript-mode . lsp-deferred)
		 (typescript-mode . my/typescript-config-hooks)
		 (typescript-mode . my/typescript-save-hooks))
  :config
  (defun my/typescript-config-hooks ())
  (defun my/typescript-save-hooks ()))

;; json
(use-package json-mode
  :ensure t
  :straight t
  :mode "\\.json\\'"
  :config
  (defun my/json-config-hooks ()
    (setq tab-width 4))
  (defun my/json-save-hooks ()
    "save hooks"
    (add-hook 'before-save-hook #'lsp-format-buffer t t))
  :hook
  ((json-mode . my/json-config-hooks)
   (json-mode . my/json-save-hooks)
   (json-mode . lsp-deferred)))

;; dap-mode
(use-package dap-mode
  :ensure t
  :straight t
  :demand t
  :bind
  :bind (:map lsp-mode-map
			  ("M-g d" . dap-debug)
			  ("M-g h" . dap-hydra))
  :bind (:map dap-mode-map
			  ("<left>" . dap-continue)
			  ("<right>" . dap-next)
			  ("<down>" . dap-step-in)
			  ("<up>" . dap-step-out))
  :custom
  (dap-auto-configure-mode t)
  :config
  (dap-ui-mode 1)
  (dap-tooltip-mode 1)
  (dap-ui-controls-mode 1)
  
  ;; chrome
  (require 'dap-chrome)
  (setq dap-chrome-debug-program  `("node"
                                    ,"/home/jmarsh/dev/vscode-chrome-debug/out/src/chromeDebug.js"))
  ;; firefox
  (require 'dap-firefox)
  (dap-firefox-setup)
  (setq dap-firefox-debug-program  `("node"
                                     ,"/home/jmarsh/dev/vscode-firefox-debug/dist/adapter.bundle.js"))
  (defun dap-firefox--populate-start-file-args (conf)
	"Populate CONF with the required arguments."
	(-> conf
		(dap--put-if-absent :dap-server-path dap-firefox-debug-program)
		(dap--put-if-absent :type "Firefox")
		(dap--put-if-absent :cwd default-directory)
		(dap--put-if-absent :name "Firefox Debug")))
  
  ;; go
  (require 'dap-dlv-go)
  ;; gdb // rust
  (require 'dap-lldb)
  (require 'dap-gdb-lldb)
  (dap-gdb-lldb-setup)
  ;; python
  (require 'dap-python)
  (setq dap-python-debugger 'debugpy))

;; mermaid-mode
(use-package mermaid-mode
  :ensure t
  :straight t
  :mode "\\.mmd\\'"
  :mode "\\.mermaid\\'")

;; vim equivalent of ci
(defun seek-backward-to-char (chr)
  "Seek backwards to a character"
  (interactive "cSeek back to char: ")
  (while (not (= (char-after) chr))
	(forward-char -1)))
(defun delete-between-pair (char)
  "Delete in between a pair of characters"
  (interactive "cDelete between char: ")
  (seek-backward-to-char char)
  (forward-char 1)
  (zap-to-char 1 char)
  (insert char)
  (forward-char -1))
(global-set-key (kbd "M-C-z") 'delete-between-pair)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(telephone-line-mode t)
 '(warning-suppress-types '((emacs))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(mode-line ((t (:background "#403e41" :foreground "#fcfcfa"))))
 '(swiper-background-match-face-1 ((t (:background "#5b595c" :foreground "#fcfcfa"))))
 '(swiper-background-match-face-2 ((t (:background "#5b595c" :foreground "#fcfcfa"))))
 '(swiper-background-match-face-3 ((t (:background "#5b595c" :foreground "#fcfcfa" :weight bold))))
 '(swiper-background-match-face-4 ((t (:background "#5b595c" :foreground "#fcfcfa" :weight bold))))
 '(swiper-line-face ((t (:background "#403e41" :foreground "#a9dc76"))))
 '(swiper-match-face-1 ((t (:background "#5b595c" :foreground "#fcfcfa"))))
 '(swiper-match-face-2 ((t (:background "#5b595c" :foreground "#fcfcfa"))))
 '(swiper-match-face-3 ((t (:background "#5b595c" :foreground "#fcfcfa" :weight bold))))
 '(swiper-match-face-4 ((t (:background "#5b595c" :foreground "#fcfcfa" :weight bold))))
 '(telephone-line-accent-active ((t (:inherit mode-line :weight bold :background "#221f22" :foreground "#a9dc76"))))
 '(telephone-line-accent-inactive ((t (:inherit mode-line-inactive :background "#221f22" :foreground "#78dce8"))))
 '(telephone-line-evil ((t (:inherit mode-line :foreground "white" :weight bold))))
 '(telephone-line-projectile ((t (:foreground "#a9dc76" :weight bold))))
 '(telephone-line-unimportant ((t (:inherit mode-line :foreground "#c1c0c0")))))
(put 'downcase-region 'disabled nil)
