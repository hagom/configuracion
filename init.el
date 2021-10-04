(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("elpa" . "https://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)

;; (package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Opciones de rendimiento

;; -*- lexical-binding: t; -*-

;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

;;Deja el buffer scratch vacio
(setq initial-scratch-message "")

;; Elimina *scratch* del buffer despues de que el modo se ha elegido
(defun remove-scratch-buffer ()
  (if (get-buffer "*scratch*")
      (kill-buffer "*scratch*")))
(add-hook 'after-change-major-mode-hook 'remove-scratch-buffer)

;; Elimina los mensajes del buffer
(setq-default message-log-max nil)
(kill-buffer "*Messages*")

;;Elimina *Completions* del buffer despues de que se abre el archivo
(add-hook 'minibuffer-exit-hook
	  '(lambda ()
             (let ((buffer "*Completions*"))
               (and (get-buffer buffer)
                    (kill-buffer buffer)))))

;; Don't show *Buffer list* when opening multiple files at the same time.
(setq inhibit-startup-buffer-menu t)

;;Muestra solamente y or n en los mensaje de confirmacion
(fset 'yes-or-no-p 'y-or-n-p)

;; Show only one active window when opening multiple files at the same time.
(add-hook 'window-setup-hook 'delete-other-windows)

;;Use-package

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;;No mostrar el mensaje de bienvenida en el editor
(setq inhibit-startup-message t)

;;Resalta la posicion actual del cursor
(global-hl-line-mode t)

(setq visible-bell t)

;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;; (add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(aggressive-completion-mode t)
 '(package-selected-packages
   '(org2blog org-wc languagetool apache-mode counsel ox-publish elpy company-tabnine all-the-icons-dired all-the-icons-ivy all-the-icons fzf treemacs-projectile treemacs neotree-toggle smartparens tern-auto-complete tern js2-refactor ac-js2 web-mode multiple-cursors hungry-delete ace-window org-bullets use-package magit-popup web-search org-web-tools powerthesaurus org-alert org-review evil-args evil-commentary evil-mc evil-mc-extras evil-nerd-commenter evil-org evil-surround airline-themes powerline-evil pandoc-mode tss typescript-mode import-js js2-mode node-resolver npm-mode github-search magit-circleci magit-lfs magit-org-todos magit-rbr magit-reviewboard magit-todos magit-vcsh orgit org-ac org-context org-evil org-jira org-kanban org-multi-wiki org-preview-html org-sidebar org-sync weechat weechat-alert viking-mode captain seq yasnippet auto-virtualenv indent-tools lsp-jedi pony-mode pydoc pylint python-mode python-pytest 2048-game composer flycheck-phpstan flymake-phpcs php-mode php-refactor-mode php-runtime phpactor phpunit smarty-mode async-await bpr concurrent ac-emmet yasnippet-classic-snippets xclip which-key websocket web-server undo-tree transcribe svg-lib svg-clock sql-indent scanner rainbow-mode python poker phps-mode orgalist org-translate org-edna ivy-hydra gnu-elpa-keyring-update gnu-elpa flymake-proselint eldoc-eval el-search eglot dict-tree csv-mode company-statistics company-ebdb cobol-mode chess auto-correct async aggressive-indent aggressive-completion)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(aw-leading-char-face ((t (:inherit ace-jump-face-foreground :height 3.0)))))

;;Asincronismo en Emacs
(async-bytecomp-package-mode 1)

;; Habilita el clipboard en Emacs
(setq x-select-enable-clipboard t)

;;Evil mode

(use-package evil 
  :ensure t
  :config
  (evil-mode 1)
  
  ;;Evil undo-tree
  (global-undo-tree-mode)
  (evil-set-undo-system 'undo-tree)
  )

;;Evil undo-tree
;; (global-undo-tree-mode)
;; (evil-set-undo-system 'undo-tree)

;;Numeracion relativa
(setq display-line-numbers-type 'relative) 
(global-display-line-numbers-mode) 

;;Powerline
(use-package powerline
  :ensure t
  :init
  :config
  (powerline-evil-vim-color-theme)
  )

;;Habilitar / Deshabilitar menu de opciones
(menu-bar-mode -1)

;;Portapapeles global
(setq x-select-enable-clipboard t)

;;Tema para emacs
(load-theme 'wombat)

;;Which key 
(use-package which-key
  :ensure t 
  :config
  (which-key-mode))

;;Org mode
(use-package org 
  :ensure t
  :pin org)

;;Org Bullets
(use-package org-bullets
  :ensure t
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

;;Ace Window sirve para cambiar mas facil de ventanas
(use-package ace-window
  :ensure t
  :init
  (progn
    (setq aw-scope 'global) ;; was frame
    (global-set-key (kbd "C-x O") 'other-frame)
    (global-set-key [remap other-window] 'ace-window)
    (custom-set-faces
     '(aw-leading-char-face
       ((t (:inherit ace-jump-face-foreground :height 3.0))))) 
    ))

(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1))

(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode t))

(use-package yasnippet
  :ensure t
  :init (yas-global-mode 1)
  :config

;;; use popup menu for yas-choose-value

  (require 'popup)

  ;; add some shotcuts in popup menu mode
  (define-key popup-menu-keymap (kbd "M-n") 'popup-next)
  (define-key popup-menu-keymap (kbd "TAB") 'popup-next)
  (define-key popup-menu-keymap (kbd "<tab>") 'popup-next)
  (define-key popup-menu-keymap (kbd "<backtab>") 'popup-previous)
  (define-key popup-menu-keymap (kbd "M-p") 'popup-previous)

  (defun yas-popup-isearch-prompt (prompt choices &optional display-fn)
    (when (featurep 'popup)
      (popup-menu*
       (mapcar
	(lambda (choice)
          (popup-make-item
           (or (and display-fn (funcall display-fn choice))
               choice)
           :value choice))
	choices)
       :prompt prompt
       ;; start isearch mode immediately
       :isearch t
       )))

  (setq yas-prompt-functions '(yas-popup-isearch-prompt yas-maybe-ido-prompt yas-completing-prompt yas-no-prompt))

  )

;;Borra todos los espacios en blanco con solo presionar la tecla backspace o suprimir
(use-package hungry-delete
  :ensure t
  :config
  (global-hungry-delete-mode))

(use-package multiple-cursors
  :ensure t
  :config
  (global-set-key (kbd "C->") 'mc/mark-next-like-this)
  (global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
  (global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)
  )

(use-package web-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.vue?\\'" . web-mode))
  (setq web-mode-engines-alist
	'(("django"    . "\\.html\\'")))
  (setq web-mode-ac-sources-alist
	'(("css" . (ac-source-css-property))
	  ("vue" . (ac-source-words-in-buffer ac-source-abbrev))
          ("html" . (ac-source-words-in-buffer ac-source-abbrev))))
  (setq web-mode-enable-auto-closing t))
(setq web-mode-enable-auto-quoting t) 

;;Javascript

(use-package js2-mode
  :ensure t
  :ensure ac-js2
  :init
  (progn
    (add-hook 'js-mode-hook 'js2-minor-mode)
    (add-hook 'js2-mode-hook 'ac-js2-mode)
    ))

;;Refactorizar para javascript
(use-package js2-refactor
  :ensure t
  :config 
  (progn
    (js2r-add-keybindings-with-prefix "C-c C-m")
    ;; eg. extract function with `C-c C-m ef`.
    (add-hook 'js2-mode-hook #'js2-refactor-mode)))

(use-package tern
  :ensure tern
  :ensure tern-auto-complete
  :config
  (progn
    (add-hook 'js-mode-hook (lambda () (tern-mode t)))
    (add-hook 'js2-mode-hook (lambda () (tern-mode t)))
    (add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
    ;;(tern-ac-setup)
    ))

;; use web-mode for .jsx files
(add-to-list 'auto-mode-alist '("\\.jsx$" . web-mode))

;; turn on flychecking globally
(add-hook 'after-init-hook #'global-flycheck-mode)

;; disable jshint since we prefer eslint checking
(setq-default flycheck-disabled-checkers
	      (append flycheck-disabled-checkers
		      '(javascript-jshint)))

;; use eslint with web-mode for jsx files
(flycheck-add-mode 'javascript-eslint 'web-mode)

;; customize flycheck temp file prefix
(setq-default flycheck-temp-prefix ".flycheck")

;; disable json-jsonlist checking for json files
(setq-default flycheck-disabled-checkers
	      (append flycheck-disabled-checkers
		      '(json-jsonlist)))

;; adjust indents for web-mode to 2 spaces
(defun my-web-mode-hook ()
  "Hooks for Web mode. Adjust indents"
  ;;; http://web-mode.org/
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2))
(add-hook 'web-mode-hook  'my-web-mode-hook)

;;Sirve para saltar entre distintos proyectos

(use-package projectile
  :ensure t
  :bind ("C-c p" . projectile-command-map)
  :config
  (projectile-global-mode)
  (setq projectile-completion-system 'ivy))

;;Sirve para poder mostrar un explorador de archivos al estilo de VsCode

(use-package treemacs
  :ensure t
  :defer t
  :config
  )
(use-package treemacs-projectile
  :defer t
  :ensure t
  :config
  (setq treemacs-header-function #'treemacs-projectile-create-header)
  )

(use-package smartparens
  :ensure t
  :hook (prog-mode . smartparens-mode)
  :custom
  (sp-escape-quotes-after-insert t)
  :config
  (require 'smartparens-config))

(show-paren-mode t)

;;Git

(use-package magit
  :ensure t
  :init
  (progn
    (bind-key "C-x g" 'magit-status)
    ))

(setq magit-status-margin
      '(t "%Y-%m-%d %H:%M " magit-log-margin-width t 18))

(use-package git-gutter
  :ensure t
  :init
  (global-git-gutter-mode +1))
(global-set-key (kbd "M-g M-g") 'hydra-git-gutter/body)


(use-package git-timemachine :ensure t)

(defhydra hydra-git-gutter (:body-pre (git-gutter-mode 1)
				      :hint nil)
  "
Git gutter:
_j_: next hunk        _s_tage hunk     _q_uit
_k_: previous hunk    _r_evert hunk    _Q_uit and deactivate git-gutter
^ ^                   _p_opup hunk
_h_: first hunk
_l_: last hunk        set start _R_evision
"
  ("j" git-gutter:next-hunk)
  ("k" git-gutter:previous-hunk)
  ("h" (progn (goto-char (point-min))
              (git-gutter:next-hunk 1)))
  ("l" (progn (goto-char (point-min))
              (git-gutter:previous-hunk 1)))
  ("s" git-gutter:stage-hunk)
  ("r" git-gutter:revert-hunk)
  ("p" git-gutter:popup-hunk)
  ("R" git-gutter:set-start-revision)
  ("q" nil :color blue)
  ("Q" (progn (git-gutter-mode -1)
              ;; git-gutter-fringe doesn't seem to
              ;; clear the markup right away
              (sit-for 0.1)
              (git-gutter:clear))
   :color blue))

;;Port de nerd-tree-commenter para emacs del mismo plugin de vim que permite comentar lineas o bloques de codigo mas facil
(use-package evil-nerd-commenter
  :ensure t
  :init
  :config
  (global-set-key (kbd "M-;") 'evilnc-comment-or-uncomment-lines)
)

;; Permite indentar el codigo mientras se escribe 
(use-package aggressive-indent
  :ensure t
  :config
  (global-aggressive-indent-mode 1)
  )

(use-package fzf :ensure t)

(use-package all-the-icons 
  :ensure t
  :defer 0.5)

(use-package all-the-icons-ivy
  :ensure t
  :after (all-the-icons ivy)
  :custom (all-the-icons-ivy-buffer-commands '(ivy-switch-buffer-other-window ivy-switch-buffer))
  :config
  (add-to-list 'all-the-icons-ivy-file-commands 'counsel-dired-jump)
  (add-to-list 'all-the-icons-ivy-file-commands 'counsel-find-library)
  (all-the-icons-ivy-setup))

;; Iconos para dired
(use-package all-the-icons-dired
  :ensure t
  )

(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)

(use-package pandoc-mode
  :ensure t
  :init
  )

(use-package company-tabnine
  :ensure t
  :config
  (require 'company-tabnine)
  (add-to-list 'company-backends #'company-tabnine)
  ;; Trigger completion immediately.
  (setq company-idle-delay 0)

  ;; Number the candidates (use M-1, M-2 etc to select completions).
  (setq company-show-numbers t))

(use-package web-mode
  :ensure t
  :init
  :config (require 'web-mode)
  )

;;Entorno de desarrollo en Python
(use-package elpy
  :ensure t
  :init
  (elpy-enable))

;; Muestra un arbol para poder deshacer
(use-package undo-tree
  :ensure t
  :init
  (global-undo-tree-mode 1)
  )

;;flashes the cursor's line when you scroll
(use-package beacon
  :ensure t
  :config
  (beacon-mode 1)
  )

;; Sistema de publicacion de Org

;; (use-package ox-publish
;;   :ensure t
;;   )

(use-package counsel
  :ensure t
  :bind
  (("M-y" . counsel-yank-pop)
   :map ivy-minibuffer-map
   ("M-y" . ivy-next-line)))

(use-package ivy
  :ensure t
  :diminish (ivy-mode)
  :bind (("C-x b" . ivy-switch-buffer))
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "%d/%d ")
  (setq ivy-display-style 'fancy))

(use-package swiper
  :ensure t
  :bind (("C-s" . swiper-isearch)
	 ("C-r" . swiper-isearch)
	 ("C-c C-r" . ivy-resume)
	 ("M-x" . counsel-M-x)
	 ("C-x C-f" . counsel-find-file))
  :config
  (progn
    (ivy-mode 1)
    (setq ivy-use-virtual-buffers t)
    (setq ivy-display-style 'fancy)
    (define-key read-expression-map (kbd "C-r") 'counsel-expression-history)
    ))

;;Modo mayor para apache
(use-package apache-mode :ensure t)

;;Corrector gramatico
(use-package languagetool
  :ensure t)

;;Interfaz para composer en Emacs
(use-package composer
  :ensure t)

;;Contador de palabras para org
(use-package org-wc
  :ensure t)

;;Exportar de org a Wordpress directamente
(use-package org2blog
  :ensure t)
