;;; init.el -- my custom config
;;;
;;; Commentary:
;;;
;;; This is my custom init file.  As with most Emacs users, this is a
;;; work in progress.  :)

;;; Code:

;; 100 MB for garbage collector.
(setq gc-cons-threshold (* 100 1000 1000))
(defun efs/display-startup-time ()
  "Prints load information."
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                     (time-subtract after-init-time before-init-time)))
           gcs-done))
(add-hook 'emacs-startup-hook #'efs/display-startup-time)

;; Things are a bit different in macos.
(defvar notes-dir "~/Documents/notes")
(defvar fish-shell "/usr/bin/fish")
(when (eq system-type 'darwin)
  (setq fish-shell "/usr/local/bin/fish")
  (setq notes-dir "~/OneDrive - UHG/Documents/notes"))

;; fix our environment and paths from fish.
;; Get environment from fish
(defun set-fish-env (key value)
  "Set environment KEY = VALUE (from fish)."
  (setenv key value))
(mapc
 (lambda (line) (let*
                    ((parts (split-string line "="))
                     (key (car parts))
                     (value (mapconcat 'identity (cdr parts) "=")))
                  (set-fish-env key value)))
 (split-string
  (shell-command-to-string (concat fish-shell " -i -c \"env\""))
  "\n"
  t))
(let*
    ((fish-path (shell-command-to-string (concat fish-shell " -c \"echo -n $PATH\"")))
     (full-path (append exec-path (split-string fish-path ":"))))
  (setenv "PATH" fish-path)
  (setq exec-path full-path))


(defun with-home-dir (path)
  "Prepend home directory + '/' to PATH."
  (concat (getenv "HOME") "/" path))

;; save-copies, etc.
(if (not (file-exists-p (with-home-dir ".emacs.d/backups/")))
        (make-directory (with-home-dir ".emacs.d/backups/") t))
(setq backup-directory-alist `(("." . "~/.emacs.d/backups/")))
(setq auto-save-file-name-transforms
	  `((".*" "~/.emacs.d/backups/" t)))
(setq auto-save-visited-interval 30)
(auto-save-visited-mode)

;; update tmux status on save.
(defun tmux-status-tracker-save ()
  "Update the status tracker when we save a file"
  (shell-command-to-string "tmux_status_tracker_save"))

(add-hook 'after-save-hook #'tmux-status-tracker-save)

;; some additional commands to do some "vim" like things.
(autoload 'zap-up-to-char "misc" "kill up to but not including argth occurence of char")
(global-set-key "\M-z" 'zap-up-to-char)

;; general configuration
(setq-default tab-width 4)
(put 'upcase-region 'disabled nil)
(menu-bar-mode -1)
(when (display-graphic-p) (scroll-bar-mode -1))
(tool-bar-mode -1)
(setq exec-path (cons (with-home-dir ".cargo/bin") exec-path))
(setq exec-path (cons (with-home-dir "go/bin") exec-path))
(setq exec-path (cons (with-home-dir "bin") exec-path))
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; MELPA
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(when (not package-archive-contents)
    (package-refresh-contents)) ;; refresh if we don't have any.

;; install use-package
(unless (package-installed-p 'use-package) (package-install 'use-package))

;; auto-update
(use-package auto-package-update
  :ensure t
  :config
  (setq auto-package-update-delete-old-versions t)
  (setq auto-package-update-hide-results t)
  (auto-package-update-maybe))


;; Emoji: 😄, 🤦, 🏴
(use-package unicode-fonts
  :ensure t
  :config (unicode-fonts-setup))
;; doesn't work in macos
;; (when (not (eq system-type 'darwin))
;;   (set-fontset-font t nil (font-spec :name "Noto Color Emoji")))

;; theme
(use-package monokai-pro-theme
  :ensure t
  :config
  (load-theme 'monokai-pro t))

(use-package smart-mode-line
  :ensure t
  :init (add-hook 'after-init-hook 'sml/setup)
  :config
  (add-to-list 'sml/replacer-regexp-list '("^~/Documents/notes/" " 📓"))
  (add-to-list 'sml/replacer-regexp-list '("^~/OneDrive - UHG/Documents/notes/" " 📓"))
  (add-to-list 'sml/replacer-regexp-list '("^~/dev/oti-azure/" " [oti] "))
  (add-to-list 'sml/replacer-regexp-list '("^~/dev/dotfiles/" " [·] "))
  (add-to-list 'sml/replacer-regexp-list '("^~/dev/marshians/" " 👽"))
  (add-to-list 'sml/replacer-regexp-list '("^~/dev/icub3d/" " ³ ")))

(defun simple-mode-line-render (left right)
  "Return a string of `window-width' length.
Containing LEFT, and RIGHT aligned respectively."
  (let ((available-width
         (- (window-total-width)
            (+ (length (format-mode-line left))
               (length (format-mode-line right))))))
    (append left
            (list (format (format "%%%ds" available-width) ""))
            right)))

(setq-default
 mode-line-format
  '((:eval
    (simple-mode-line-render
     ;; Left.
     (quote (""
			 mode-line-front-space
			 mode-line-mule-info
			 mode-line-client
			 mode-line-modified
			 mode-line-remote
			 mode-line-frame-identification
			 mode-line-buffer-identification))
     ;; Right.
     (quote ("%e %p "
			 (vc-mode vc-mode)
			 " "
			 minions-mode-line-modes
			 mode-line-misc-info
			 ))))))


;; magit
(use-package magit
  :ensure t
  :config
  (setq magit-diff-refine-hunk 'all))

;; colors
(use-package rainbow-mode
  :ensure t
  :hook prog-mode :hook text-mode :hook conf-mode)

;; git
(use-package git-link :ensure t)

;; org
(use-package org :ensure t)

;; minions -- hide the minor mode.
(use-package minions :ensure t :config (minions-mode 1))

;; multi-cursor
(use-package multiple-cursors
  :ensure t
  :config
  (global-set-key (kbd "C-c m c") 'mc/edit-lines)
  (global-set-key (kbd "C-c m n") 'mc/mark-next-like-this)
  (global-set-key (kbd "C-c m p") 'mc/mark-previous-like-this)
  (global-set-key (kbd "C-c m a") 'mc/mark-all-like-this))

;; flyspell
(use-package flyspell
  :ensure t
  :hook (text-mode . flyspell-mode)
  :config
  (setq ispell-silently-savep t))

(electric-pair-mode 1)

(use-package elcord
  :ensure t
  :config
  (elcord-mode)
  (setq elcord-use-major-mode-as-main-icon t))

(use-package tramp
  :ensure t
  :defer t
  :config
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path)
  (setf tramp-persistency-file-name
        (concat temporary-file-directory "tramp-" (user-login-name))))

(use-package docker-tramp
  :ensure t)

(use-package docker
  :ensure t
  :bind ("C-c d" . docker))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ivy, swiper, counsel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package ivy
  :ensure t
  :config
  (ivy-mode 1)
  (global-set-key (kbd "C-x f") 'counsel-git)
  (global-set-key (kbd "C-x M-f") 'counsel-file-jump)
  (global-set-key (kbd "M-x") 'counsel-M-x)
  (global-set-key (kbd "C-x C-f") 'counsel-find-file)
  (define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history))

(use-package swiper
  :ensure t
  :config
  (global-set-key (kbd "C-r") 'swiper)
  (global-set-key (kbd "C-s") 'swiper))

(use-package counsel :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LSP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook ((go-mode . lsp-deferred)
         ((web-mode) . lsp-deferred)
		 (python-mode . lsp-deferred)
		 (ruby-mode . lsp-deferred)
		 (yaml-mode . lsp-deferred))
  :custom
  (lsp-rust-analyzer-cargo-watch-command "clippy")
  (lsp-eldoc-render-all t)
  (lsp-idle-delay 0.6)
  (lsp-rust-analyzer-server-display-inlay-hints t)
  :config
  (setq rustic-lsp-server 'rust-analyzer)
  (setq lsp-auto-configure t)
  (setq lsp-file-watch-threshold 8192))

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode)

(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)

(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

(use-package company-lsp
  :commands company-lsp)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; company, tabnine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package flycheck
  :ensure t
  :hook (prog-mode . flycheck-mode))

(use-package company
  :ensure t
  :hook (pog-mode . company-mode)
  :config
  (add-hook 'after-init-hook 'global-company-mode)
  (setq company-tooltip-align-annotations t)
  (setq company-minimum-prefix-length 1)
  (add-to-list 'company-backends #'company-tabnine)
  (setq company-idle-delay   0) ;; no delay
  (setq company-show-quick-access t)) ;; smow numbers

(use-package company-tabnine :ensure t)
(use-package company-shell :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; simple syntax modes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package dockerfile-mode :ensure t)
(use-package docker-compose-mode :ensure t)
(use-package fish-mode :ensure t)

;; markdown
(use-package markdown-mode
  :ensure markdown-mode :ensure edit-indirect :ensure pandoc
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init
  (setq markdown-fontify-code-blocks-natively t)
  (setq markdown-command "pandoc --template=GitHub.html5 --self-contained --metadata title=emacs")
  :config
  (defun my-markdown-filter (buffer)
	(princ
	 (with-temp-buffer
       (let ((tmp (buffer-name)))
		 (set-buffer buffer)
		 (set-buffer (markdown tmp))
		 (format "%s" (buffer-string))))
	 (current-buffer)))
  (defun markdown-preview ()
	"Preview markdown."
	(interactive)
	(unless (process-status "httpd")
      (httpd-start))
	(impatient-mode)
	(imp-set-user-filter 'my-markdown-filter)
	(imp-visit-buffer)))

(use-package simple-httpd
  :ensure t
  :config
  (setq httpd-port 7070)
  (setq httpd-host (system-name)))

(use-package impatient-mode
  :ensure t
  :commands impatient-mode)


;; protobuf
(use-package protobuf-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.proto$" . protobuf-mode)))

;; octave
(add-to-list 'auto-mode-alist '("\\.m$" . octave-mode))

;; lua
(use-package lua-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.lua$" . lua-mode)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ruby
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package ruby-mode :ensure t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ein
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package ein :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; python
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package lsp-python-ms
  :ensure t
  :init (setq lsp-python-ms-auto-install-server t)
  :hook (python-mode . (lambda ()
                          (require 'lsp-python-ms)
                          (lsp-deferred))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; HTML, CSS, JavaScript
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package emmet-mode
  :ensure t
  :hook sgml-mode
  :hook web-mode)

(use-package prettier-js
  :ensure t
  :config
  (add-hook 'js2-mode-hook 'prettier-js-mode)
  (add-hook 'web-mode-hook 'prettier-js-mode)
  (setq prettier-js-args '("--trailing-comma" "all")))

(use-package json-mode
  :ensure json-mode
  :ensure json-snatcher
  :config
  (setq js-indent-level 2)
  (add-to-list 'auto-mode-alist '("\\.json$" . json-mode)))

;; (use-package typescript-mode
;;   :ensure t
;;   :config
;;   (add-to-list 'auto-mode-alist '("\\.tsx$" . typescript-mode))
;;   (add-to-list 'auto-mode-alist '("\\.ts$" . typescript-mode)))

(use-package web-mode
  :ensure t
  :config
  (setq
   web-mode-markup-indent-offset 2
   web-mode-css-indent-offset 2
   web-mode-code-indent-offset 2)
  (add-hook 'web-mode-hook
			(lambda ()
			  (if (equal web-mode-content-type "javascript")
				  (web-mode-set-content-type "jsx"))))
  (add-to-list 'auto-mode-alist '("\\.html$" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.js$" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.jsx$" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.ts$" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tsx$" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.html$" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.css$" . web-mode)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Config Languages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package yaml-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.yaml$" . yaml-mode))
  (add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode)))

(use-package toml-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.toml$" . toml-mode))
  (add-to-list 'auto-mode-alist '("\\.tml$" . toml-mode)))

(use-package groovy-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("Jenkinsfile" . groovy-mode)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Other Languages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package php-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.php$" . php-mode))
  (add-to-list 'auto-mode-alist '("\\.inc$" . php-mode)))

;; C/C++
(use-package company-c-headers :ensure t)

;; Haskell
(use-package flycheck-haskell :ensure t)

;; Terraform
(use-package terraform-mode
  :ensure terraform-mode :ensure company-terraform)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DAP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package dap-mode
  :hook (dap-stopped . (lambda (arg)
						 (call-interactively #'dap-hydra)))
  :ensure dap-mode
  :commands dap-debug
  :config
  ;; Set up Node debugging
  (require 'dap-node)
  (dap-node-setup) ;; Automatically installs Node debug adapter if needed
  (require 'dap-go)
  (dap-go-setup)
  (require 'dap-firefox)
  (dap-firefox-setup)
  (require 'dap-hydra)
  (require 'dap-gdb-lldb)
  (dap-gdb-lldb-setup)
  (dap-register-debug-template "Rust::GDB Run Configuration"
                               (list :type "gdb"
									 :request "launch"
									 :name "GDB::Run"
									 :gdbpath "rust-gdb"
									 :target nil
									 :cwd nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LISP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package slime
  :ensure slime :ensure slime-company
  :config
  (setq inferior-lisp-program "sbcl"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; rust
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package rustic
  :ensure rustic :ensure cargo
  :hook (before-save . lsp-format-buffer)
  :hook (rustic-mode . flyspell-prog-mode)
  :bind (:map rustic-mode-map
              ("M-j" . lsp-ui-imenu)
              ("M-?" . lsp-find-references)
              ("C-c C-c l" . flycheck-list-errors)
              ("C-c C-c a" . lsp-execute-code-action)
              ("C-c C-c r" . lsp-rename)
              ("C-c C-c q" . lsp-workspace-restart)
              ("C-c C-c Q" . lsp-workspace-shutdown)
              ("C-c C-c s" . lsp-rust-analyzer-status))
  :config
  (setq rustic-lsp-format t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Go
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package go-mode
  :ensure company-go :ensure go-dlv :ensure go-gen-test
  :ensure flycheck-golangci-lint
  :hook (go-mode . lsp)
  :hook (go-mode . flyspell-prog-mode)
  :bind (:map go-mode-map
              ("C-c C-c a" . lsp-execute-code-action)
              ("C-c C-c r" . lsp-rename)
              ("C-c C-c q" . lsp-workspace-restart)
              ("C-c C-c Q" . lsp-workspace-shutdown))
  :config
  (defun lsp-go-install-save-hooks ()
	(add-hook 'before-save-hook #'lsp-format-buffer t t)
	(add-hook 'before-save-hook #'lsp-organize-imports t t))
  (add-hook 'go-mode-hook #'lsp-go-install-save-hooks)
  (add-hook 'go-mode-hook 'flycheck-mode)
  (eval-after-load 'flycheck
	'(add-hook 'flycheck-mode-hook #'flycheck-golangci-lint-setup))
  (add-hook 'after-init-hook #'global-flycheck-mode)
  (require 'compile)
  (add-hook 'go-mode-hook
			(lambda ()
			  (unless (file-exists-p "Makefile")
				(set (make-local-variable 'compile-command)
					 (format "go build -gcflags \"-N -l\" .")))))
  (defvar go-test-keywords)
  (setq go-test-keywords
		'(("PASS" . font-lock-type-face)
		  ("ok" . font-lock-type-face)
		  ("FAIL" . font-lock-comment-face)))

  (define-derived-mode go-test-mode fundamental-mode
	(setq font-lock-defaults '(go-test-keywords))
	(setq mode-name "go test"))

  (defun go-test-buffer ()
	(if (get-buffer "*go-test*")
		(pop-to-buffer "*go-test*")
	  (pop-to-buffer (get-buffer-create
					  (generate-new-buffer-name "*go-test*"))))
	(go-test-mode))

  (defun go-test (cmd)
	"Go test"
	(interactive (list (read-string "go test: " "go test -gcflags '-N -l' .")))
	(go-test-buffer)
	(insert (concat "test: " cmd "\n"))
	(start-process-shell-command "go-test" "*go-test*" cmd))

  (defun go-test-cover (cmd)
	"Go test cover"
	(interactive (list (read-string "go test cover: "
									"go test -gcflags '-N -l' -covermode=set -coverprofile=coverage.out .")))
	(let ((output (shell-command-to-string cmd))
		  (file (file-name-nondirectory buffer-file-name)))
	  (go-coverage "coverage.out")
	  (go-test-buffer)
	  (insert output)
	  (switch-to-buffer (concat file "<gocov>"))))

  (defun go-test-current-function ()
	"Run the test on only the current function."
	(interactive)
	(save-excursion
	  (go-goto-function-name t)
	  (let (bounds pos1 pos2 func-name)
		(setq bounds (bounds-of-thing-at-point 'word))
		(setq pos1 (car bounds))
		(setq pos2 (cdr bounds))
		(setq func-name (buffer-substring-no-properties pos1 pos2))
		(go-test-buffer)
		(insert (concat "test function: " func-name "\n"))
		(start-process-shell-command "go-test" "*go-test*" (concat "go test -gcflags '-N -l' -run '^" func-name "$' .")))))

  (defun go-test-race (cmd)
	"Go test race"
	(interactive (list (read-string "go test race: " "go test -gcflags '-N -l' -race .")))
	(go-test-buffer)
	(insert (concat "race: " cmd "\n"))
	(start-process-shell-command "go-test" "*go-test*" cmd))

  (defun go-run (cmd)
	"Go run"
	(interactive (list (read-string "go run: " "go run .")))
	(go-test-buffer)
	(insert (concat "run: " cmd "\n"))
	(start-process-shell-command "go-test" "*go-test*" cmd))

  ;; set bindings when in go-mode.
  (defun go-mode-bindings ()
	"go-mode bindings"
	(interactive)
	(local-set-key (kbd "M-g M-d") #'go-gen-test-dwim)
	(local-set-key (kbd "C-c C-c C-t") #'go-test)
	(local-set-key (kbd "M-g M-c") 'go-test-cover)
	(local-set-key (kbd "C-c C-c C-r") 'go-run)
	(local-set-key (kbd "C-c C-c C-f") 'go-test-current-function)
	(local-set-key (kbd "M-g M-r") 'go-test-race)
	(local-set-key (kbd "M-g M-b") 'gud-break))
  (add-hook 'go-mode-hook #'go-mode-bindings)
  ) ;; end of Go's use-package


;; adaptive wrapping for visual mode
(use-package adaptive-wrap :ensure t
  :config
  (setq-default adaptive-wrap-extra-indent 4)
  (add-hook 'visual-line-mode-hook #'adaptive-wrap-prefix-mode))

;; splunk highlighting for OTI logs
(defvar splunk-keywords
	  '(("time" . font-lock-type-face)
		("level" . font-lock-type-face)
		("msg" . font-lock-type-face)
		("submissionid" . font-lock-type-face)
		("info" . font-lock-warning-face)
		("debug" . font-lock-comment-face)))
(define-derived-mode splunk-highlight-mode fundamental-mode
  (setq font-lock-defaults '(splunk-keywords))
  (setq mode-name "splunk"))
(defun splunk-mode ()
  "A simple splunk mode for viewing our logs."
  (splunk-highlight-mode)
  (visual-line-mode))
(add-to-list 'auto-mode-alist '("\\.splunk$" . splunk-mode))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :extend nil :stipple nil :background "#2d2a2e" :foreground "#fcfcfa" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight bold :height 140 :width normal :foundry "ADBO" :family "JetBrains Mono Medium"))))
 '(mode-line ((t (:background "#5b595c" :foreground "#fcfcfa" :inverse-video nil))))
 '(mode-line-inactive ((t (:background "#403e41" :foreground "#fcfcfa" :inverse-video nil))))
 '(persp-selected-face ((t (:foreground "#fc9867" :weight bold))))
 '(rustic-errno-face ((t (:foreground "#ff6188"))))
 '(sml/charging ((t (:inherit sml/global :foreground "#a9dc76"))))
 '(sml/discharging ((t (:inherit sml/global :foreground "#ab9df2"))))
 '(sml/filename ((t (:inherit sml/global :foreground "#ffd866" :weight bold))))
 '(sml/global ((t (:foreground "#c1c0c0" :inverse-video nil))))
 '(sml/modes ((t (:inherit sml/global :foreground "#fcfcfa"))))
 '(sml/modified ((t (:inherit sml/not-modified :foreground "#ff6188" :weight bold))))
 '(sml/outside-modified ((t (:inherit sml/not-modified :background "#ff6188" :foreground "#fcfcfa"))))
 '(sml/prefix ((t (:inherit sml/global :foreground "#fc9867"))))
 '(sml/read-only ((t (:inherit sml/not-modified :foreground "#78dce8"))))
 '(vterm-color-black ((t (:foreground "#403E41"))))
 '(vterm-color-blue ((t (:foreground "#78DCE8"))))
 '(vterm-color-cyan ((t (:foreground "#A1EFE4"))))
 '(vterm-color-green ((t (:foreground "#A9DC76"))))
 '(vterm-color-magenta ((t (:foreground "#AB9DF2"))))
 '(vterm-color-red ((t (:foreground "#FF6188"))))
 '(vterm-color-white ((t (:foreground "#F8F8F2"))))
 '(vterm-color-yellow ((t (:foreground "#FC9867")))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(custom-safe-themes
   '("3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" "bd7b7c5df1174796deefce5debc2d976b264585d51852c962362be83932873d9" default))
 '(global-linum-mode 1)
 '(go-gen-test-default-functions "-all")
 '(grep-command "grep --color always -nH --null -e ")
 '(grep-find-command
   '("find . -type f -exec grep --color -nH --null -e  \\{\\} +" . 49))
 '(indicate-empty-lines t)
 '(inhibit-startup-screen t)
 '(mode-line-format
   '("%e" mode-line-front-space mode-line-mule-info mode-line-client mode-line-modified mode-line-remote mode-line-frame-identification mode-line-buffer-identification mode-line-position
	 (vc-mode vc-mode)
	 sml/pre-modes-separator minions-mode-line-modes mode-line-misc-info mode-line-end-spaces))
 '(package-selected-packages
   '(typescript-mode monokai-pro-theme smart-mode-line lsp-pyright pyvenv pvenv ein mmm-mode snow lsp-python-ms docker docker-compose-mode docker-tramp impatient-mode simple-httpd pandoc origami highlight-indent-guides elcord magit dap-go dap-mode emmet-mode rustic multiple-cursors minions unicode-fonts edit-indirect markdown-mode git-link adaptive-wrap org pkgbuild-mode rjsx-mode jupyter company-jedi lsp-jedi lua-mode groovy-mode rainbow-mode lsp-ui prettier-js flycheck lsp-mode flycheck-rust cargo auto-package-update flycheck-golangci-lint go-gen-test go-dlv company-go slime-company slime company-terraform terraform-mode flycheck-haskell company-c-headers php-mode toml-mode yaml-mode web-mode json-mode js2-mode protobuf-mode markdown-preview-mode markdown-mode fish-mode dockerfile-mode company counsel company-shell company-tabnine swiper ivy use-package))
 '(pkgbuild-update-sums-on-save nil)
 '(rustic-ansi-faces
   ["#19181a" "#ff6188" "#a9dc76" "#ffd866" "#78dce8" "#ab9df2" "#78dce8" "#fcfcfa"])
 '(rustic-lsp-format t)
 '(save-place-mode t nil (saveplace))
 '(show-paren-mode t)
 '(size-indication-mode t)
 '(tooltip-mode nil)
 '(vc-follow-symlinks t))

;;; init.el ends here

