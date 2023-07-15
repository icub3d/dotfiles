;; straight and use-package setup
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
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

;; theming
(use-package monokai-pro-theme
  :ensure t
  :straight t
  :config
  (load-theme 'monokai-pro t))
(set-face-attribute 'default nil :font "JetBrains Mono" :height 120)

;; diminish
(use-package diminish
  :ensure t
  :straight t)

;; Ivy, Counsel, Swiper
(use-package counsel
  :ensure t
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


;; flycheck
(use-package flycheck
  :diminish
  :ensure t
  :straight t)

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
			  ("M-g l" . flycheck-list-errors)
			  ("M-g a" . lsp-execute-code-action)
			  ("M-g r" . lsp-rename)
			  ("M-g q" . lsp-workspace-restart)
			  ("M-g Q" . lsp-workspace-shutdown)
			  ("M-g s" . lsp-rust-analyzer-status))
  :config
  (setq lsp-rust-analyzer-cargo-watch-command "clippy")
  (defun my/rustic-mode-hook ()
	(when buffer-file-name
      (setq-local buffer-save-without-query t))
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

;; treesitter
(use-package tree-sitter
  :ensure t
  :straight t
  :diminish
  :config
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))
(use-package tree-sitter-langs
  :ensure t
  :straight t
  :after tree-sitter
  :config
  (require 'tree-sitter-langs))


;; Fish
(use-package fish-mode
  :ensure t
  :straight t)

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

;; dap-mode
(use-package dap-mode
  :ensure t
  :straight t
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

;; multiple cursors
(use-package multiple-cursors
  :ensure t
  :straight t
  :bind (("C-c m c" . mc/edit-lines)
		 ("C-c m n" . mc/mark-next-like-this)
		 ("C-c m p" . mc/mark-previous-like-this)
		 ("C-c m a" . mc/mark-all-like-this)))

;; markdown
(use-package markdown-mode
  :ensure t
  :straight t)

;; chatgpt
(use-package shell-maker
  :ensure t
  :straight (:host github :repo "xenodium/chatgpt-shell" :files ("shell-maker.el")))

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


;; ripgrep
(use-package rg
  :ensure t
  :straight t
  :config
  (rg-enable-default-bindings))

;; elcord
(use-package elcord
  :ensure t
  :straight t
  :config
  (elcord-mode))

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
		 (web-mode . emmet-mode)))

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
  (defun my/typescript-config-hooks ()
	(setq tab-width 2))
  (defun my/typescript-save-hooks ()
	"save hooks"
	(add-hook 'before-save-hook #'lsp-format-buffer t t)))

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

;; chatgpt
(use-package chatgpt-shell
  :requires shell-maker
  :ensure t
  :straight (:host github :repo "xenodium/chatgpt-shell" :files ("chatgpt-shell.el"))
  :config
  (let ((file-path "~/Documents/ssssh/chat-gpt-api-key"))
	(if (file-exists-p file-path)
		(setq chatgpt-shell-openai-key (trim-string (with-temp-buffer
							(insert-file-contents file-path)
							(buffer-string)))))))

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
