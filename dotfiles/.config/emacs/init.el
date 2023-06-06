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

;; general settings
(tool-bar-mode -1)                   ; hide tool bar
(menu-bar-mode -1)                   ; hide menu bar
(scroll-bar-mode -1)                 ; hide scroll bar
(xterm-mouse-mode 1)                 ; mouse in terminal
(setq inhibit-startup-screen t)      ; startup screen
(setq-default tab-width 4)           ; tab size
(global-display-line-numbers-mode 1) ; line numbers
(electric-pair-mode 1)               ; autopairs
(setq ring-bell-function 'ignore)    ; no bell
(setq vc-follow-symlinks t)          ; follow symlinks

;; backup stuff
(setq
   backup-by-copying t      ; don't clobber symlinks
   backup-directory-alist
    '(("." . "~/.saves/"))    ; don't litter my fs tree
   delete-old-versions t
   kept-new-versions 6
   kept-old-versions 2
   version-control t)       ; use versioned backups

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
  (("C-x C-f" . counsel-find-file)
   ("C-x f" . counsel-git))
  :config (counsel-mode))

(use-package ivy
  :ensure t
  :straight t
  :defer 0.0
  :diminish
  :bind (("C-c C-r" . ivy-resume)
         ("C-x B" . ivy-switch-buffer-other-window))
  :custom
  (ivy-count-format "(%d/%d) ")
  (ivy-use-virtual-buffers t)
  :config (ivy-mode))

(use-package ivy-rich
  :ensure t
  :straight t
  :after ivy
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
			  ("M-g Q" . lsp-workspace-shutdown)
			  ("M-g s" . lsp-rust-analyzer-status))
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
  (defun my/rustic-mode-hook ()
	(when buffer-file-name
      (setq-local buffer-save-without-query t))
	(require 'dap-dlv-go)
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
  :straight t)

;; dap-mode
(use-package dap-mode
  :ensure t
  :straight t
  :custom
  (dap-auto-configure-mode t)
  :config
  ;; go
  (require 'dap-dlv-go)
  ;; gdb // rust
  (require 'dap-gdb-lldb)
  (dap-register-debug-template "Rust::GDB Run Configuration"
                               (list :type "gdb"
									 :request "launch"
									 :name "GDB::Run"
									 :gdbpath "rust-gdb"
									 :target nil
									 :cwd nil))
  ;; python
  (require 'dap-python)
  (setq dap-python-debugger 'debugpy))

;; perspective
;; (use-package perspective
;;   :ensure t
;;   :straight t
;;   :custom
;;   (persp-mode-prefix-key (kbd "C-x x"))
;;   :init
;;   (persp-mode))

;; (custom-set-variables
;;  ;; custom-set-variables was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(persp-mode t)
;;  '(persp-mode-prefix-key [3 134217840]))
;; (custom-set-faces
;;  ;; custom-set-faces was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(persp-selected-face ((t (:foreground "#a9dc76" :weight bold)))))
