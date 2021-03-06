(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(custom-safe-themes
   '("bd7b7c5df1174796deefce5debc2d976b264585d51852c962362be83932873d9" default))
 '(global-linum-mode 1)
 '(go-gen-test-default-functions "-all")
 '(indicate-empty-lines t)
 '(inhibit-startup-screen t)
 '(org-agenda-files '("~/Downloads/orgmode-coursefiles/sec-2.4-end-mylife.org"))
 '(package-selected-packages
   '(edit-indirect markdown-mode company-capf vterm git-link adaptive-wrap org pkgbuild-mode rjsx-mode monokai-pro-theme jupyter company-jedi lsp-jedi lua-mode groovy-mode rainbow-mode lsp-ui prettier-js flycheck lsp-mode rust-mode flycheck-rust racer cargo auto-package-update flycheck-golangci-lint go-gen-test go-dlv company-go slime-company slime company-terraform terraform-mode flycheck-haskell company-c-headers php-mode toml-mode yaml-mode web-mode json-mode js2-mode protobuf-mode markdown-preview-mode markdown-mode fish-mode dockerfile-mode company counsel company-shell company-tabnine swiper ivy use-package))
 '(pkgbuild-update-sums-on-save nil)
 '(save-place t nil (saveplace))
 '(scroll-bar-mode 'right)
 '(show-paren-mode t)
 '(size-indication-mode t)
 '(tooltip-mode nil)
 '(vc-follow-symlinks t))

;; save-copies, etc.
(if (not (file-exists-p "~/.emacs.d/backups/"))
        (make-directory "~/.emacs.d/backups/" t))
(setq backup-directory-alist `(("." . ,"~/.emacs.d/backups/")))
(setq auto-save-file-name-transforms
	  `((".*" "~/.emacs.d/backups/" t)))

;; general configuration
(setq-default tab-width 4)
(put 'upcase-region 'disabled nil)
(if window-system
    (tool-bar-mode -1))
(menu-bar-mode -1)
(setq exec-path (cons "/home/jmarsh/.cargo/bin" exec-path))
(setq exec-path (cons "/home/jmarsh/go/bin" exec-path))
(setq exec-path (cons "/home/jmarsh/bin" exec-path))

;; MELPA
(require 'package)
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
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

;; General Key Bindings
(global-set-key (kbd "C-c C-c") 'comment-region)
(global-set-key (kbd "C-c C-u") 'uncomment-region)

;; theme
(use-package monokai-pro-theme
  :ensure t
  :config
  (load-theme 'monokai-pro t))

;; vterm
(use-package vterm :ensure t)

;; colors
(use-package rainbow-mode
  :ensure t
  :hook prog-mode :hook text-mode :hook conf-mode)
  
(add-to-list 'auto-mode-alist '("\\.m$" . octave-mode))

;; git
(use-package git-link :ensure t)

;; org
(use-package org :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ivy, swiper, counsel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun find-in-git ()
  "Find file in the current Git repository."
  (interactive)
  (let* ((default-directory (locate-dominating-file
                             default-directory ".git"))
         (cands (split-string
                 (shell-command-to-string
                  "git ls-files --full-name --")
                 "\n"))
         (file (ivy-read "Find file: " cands)))
    (when file
      (find-file file))))

(use-package ivy
  :ensure t
  :config
  (ivy-mode 1)
  (global-set-key (kbd "C-x f") 'find-in-git)
  ;; (setq ivy-use-virtual-buffers t)
  ;; (setq enable-recursive-minibuffers t)
  )

(use-package swiper
  :ensure t
  :config
  (global-set-key (kbd "C-s") 'swiper))

(use-package counsel
  ;; TODO more configuration
  :ensure t)

(use-package lua-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.lua$" . lua-mode)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LSP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook (go-mode . lsp-deferred)
  :hook (rust-mode . lsp-deferred)
  :config
  (setq lsp-auto-configure t)
  (setq lsp-file-watch-threshold 8192))
;;  (require 'lsp-clients))
(use-package lsp-ui :ensure t :commands lsp-ui-mode)

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
  (setq company-show-numbers t)) ;; smow numbers

(use-package company-tabnine
  :ensure t)
(use-package company-capf
  :ensure t)
(use-package company-shell
  :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; simple syntax modes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package dockerfile-mode :ensure t)
(use-package fish-mode :ensure t)
(use-package markdown-mode
  :ensure markdown-mode :ensure edit-indirect
  :commands (markdown-mode gfm-mode)
  
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "markdown_py"))
(use-package protobuf-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.proto$" . protobuf-mode)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; HTML, CSS, JavaScript
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package prettier-js
  :ensure t
  :config
  (add-hook 'js2-mode-hook 'prettier-js-mode)
  (add-hook 'web-mode-hook 'prettier-js-mode)
  (setq prettier-js-args '("--trailing-comma" "all")))

(use-package json-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.json$" . json-mode)))

(use-package web-mode
  :ensure t
  :config
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

;; Python
;; (use-package lsp-jedi
;;   :ensure t :ensure company-jedi
;;   :config
;;   (add-to-list 'company-backends #'company-jedi)
;;   (with-eval-after-load "lsp-mode"
;;     (add-to-list 'lsp-disabled-clients 'pyls)
;;     (add-to-list 'lsp-enabled-clients 'jedi)))
;; (use-package jupyter :ensure jupyter)

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
(defun rust-doc ()
  (interactive)
  (shell-command-to-string "cargo doc --open"))

(use-package rust-mode
  :ensure rust-mode :ensure flycheck-rust :ensure cargo
  :hook (rust-mode . lsp)
  :hook (rust-mode . cargo-minor-mode)
  :config
  (setq exec-path (cons "/home/jmarsh/.cargo/bin" exec-path))
  (add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))
  (setq rust-format-on-save t)
  (add-hook 'rust-mode-hook 'cargo-minor-mode)
  (add-hook 'rust-mode-hook
			(lambda () (setq indent-tabs-mode nil)))
  (add-hook 'rust-mode-hook
			(lambda ()
			  (local-set-key (kbd "M-g M-d") 'rust-doc)
			  (local-set-key (kbd "C-c <tab>") #'rust-format-buffer)))
  (add-hook 'flycheck-mode-hook #'flycheck-rust-setup)
  (define-key rust-mode-map (kbd "M-g M-r") 'rust-run)
  (define-key rust-mode-map (kbd "M-g M-t") 'rust-test))
(use-package lsp-rust
    :after lsp-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Go
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package go-mode
  :ensure company-go :ensure go-dlv :ensure go-gen-test
  :ensure flycheck-golangci-lint
  :hook (go-mode . lsp)
  :config
  (setq exec-path (cons "/home/jmarsh/go/bin" exec-path))
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
	(go-goto-function-name t)
	(let (bounds pos1 pos2 func-name)
	  (setq bounds (bounds-of-thing-at-point 'word))
	  (setq pos1 (car bounds))
	  (setq pos2 (cdr bounds))
	  (setq func-name (buffer-substring-no-properties pos1 pos2))
	  (go-test-buffer)
	  (insert (concat "test function: " func-name "\n"))
	  (start-process-shell-command "go-test" "*go-test*" (concat "go test -gcflags '-N -l' -run '^" func-name "$' ."))))

  (defun go-test-race (cmd)
	"Go test race"
	(interactive (list (read-string "go test race: " "go test -gcflags '-N -l' -race .")))
	(go-test-buffer)
	(insert (concat "race: " cmd "\n"))
	(start-process-shell-command "go-test" "*go-test*" cmd))

  (defun go-vet-lint (cmd)
	"Go vet and lint"
	(interactive (list (read-string "go build: " "go vet -shadow .; golint .")))
	(go-test-buffer)
	(insert (concat "vet and lint: " cmd "\n"))
	(start-process-shell-command "go-test" "*go-test*" cmd))

  (defun go-meta-linter (cmd)
	"Go linter"
	(interactive (list (read-string "go build: " "golangci-lint .")))
	(go-test-buffer)
	(insert (concat "golangci-lint: " cmd "\n"))
	(start-process-shell-command "go-test" "*go-test*" cmd))

  ;; set bindings when in go-mode.
  (defun go-mode-bindings ()
	"go-mode bindings"
	(interactive)
	(local-set-key (kbd "M-g M-d") #'go-gen-test-dwim)
	(local-set-key (kbd "M-g M-t") #'go-test)
	(local-set-key (kbd "M-g M-c") 'go-test-cover)
	(local-set-key (kbd "M-g M-f") 'go-test-current-function)
	(local-set-key (kbd "M-g M-r") 'go-test-race)
	(local-set-key (kbd "M-g M-b") 'gud-break)
	(local-set-key (kbd "M-g M-l") 'go-vet-lint)
	(local-set-key (kbd "M-g M-m") 'go-meta-linter))
  (add-hook 'go-mode-hook #'go-mode-bindings)
  ) ;; end of use-package


;; adaptive wrapping for visual mode
(use-package adaptive-wrap :ensure t
  :config
  (setq-default adaptive-wrap-extra-indent 4)
  (add-hook 'visual-line-mode-hook #'adaptive-wrap-prefix-mode))

;; splunk highlighting
(setq splunk-keywords
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
  (splunk-highlight-mode)
  (visual-line-mode))
(add-to-list 'auto-mode-alist '("\\.splunk$" . splunk-mode))


;; (custom-set-faces
;;  ;; custom-set-faces was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(company-tooltip ((t (:background "magenta" :foreground "black"))))
;;  '(go-coverage-0 ((t (:foreground "red"))))
;;  '(go-coverage-1 ((t (:foreground "green"))))
;;  '(go-coverage-10 ((t (:foreground "green"))))
;;  '(go-coverage-2 ((t (:foreground "green"))))
;;  '(go-coverage-3 ((t (:foreground "green"))))
;;  '(go-coverage-4 ((t (:foreground "green"))))
;;  '(go-coverage-5 ((t (:foreground "green"))))
;;  '(go-coverage-6 ((t (:foreground "green"))))
;;  '(go-coverage-7 ((t (:foreground "green"))))
;;  '(go-coverage-8 ((t (:foreground "green"))))
;;  '(go-coverage-9 ((t (:foreground "green"))))
;;  '(go-coverage-covered ((t (:foreground "green"))))
;;  '(go-coverage-untracked ((t (:foreground "white"))))
;;  '(lsp-ui-doc-background ((t (:background "#060606")))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
