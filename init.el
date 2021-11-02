;;; init.el -- My Emacs configuration

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("elpa" . "https://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure 't)

;; Opciones de rendimiento

;; -*- lexical-binding: t; -*-

;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

;; Para crear archivos de respaldo ~
(setq make-backup-files nil) 

;; Essential settings.
(setq inhibit-splash-screen t
      inhibit-startup-message t
      inhibit-startup-echo-area-message t)

(show-paren-mode 1)
(setq show-paren-delay 0)

;;Muestra solamente y or n en los mensaje de confirmacion
(fset 'yes-or-no-p 'y-or-n-p)

;; Show only one active window when opening multiple files at the same time.
;; (add-hook 'window-setup-hook 'delete-other-windows)

;; Muestra los niveles de indentacion con colores
(add-hook 'prog-mode-hook 'highlight-indent-guides-mode)

;;Use-package

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;;Resalta la posicion actual del cursor
;; (global-hl-line-mode t)

(setq visible-bell t)

;;Habilitar / Deshabilitar menu de opciones
(menu-bar-mode -1)
(setq inhibit-startup-message t)
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

;;Portapapeles global
(setq x-select-enable-clipboard t)

;; Aumentar el tamaño de data que recibe Emacs del proceso
(setq read-process-output-max (* 1024 1024)) ;; 1mb

;;Tema para emacs

;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;; (add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" default))
 '(global-tab-line-mode t)
 '(nxml-auto-insert-xml-declaration-flag t)
 '(nxml-slash-auto-complete-flag t)
 '(package-selected-packages
   '(gitignore-templates markdown-preview-mode apt-sources-list try perspective keycast evil-numbers marginalia doom-modeline spacemacs-theme smart-mode-line-powerline powerline-evil editorconfig company-box company-coq jedi-core ti highlight-indent-guides elfeed ggtags rg color-theme impatient-mode emmet-mode yaml-mode beacon git-timemachine git-gutter projectile flycheck powerline evil-collection evil treemacs-magit treemacs-icons-dired origami auto-rename-tag treemacs-evil treemacs-all-the-icons json-reformat lsp-mode magit pdf-tools django-snippets django-mode rainbow-delimiters dap-mode lsp-treemacs lsp-ivy helm-lsp lsp-ui company-wordfreq company-org-block company-phpactor company-php company-ansible T org-roam engine-mode emojify org2blog org-wc languagetool apache-mode counsel ox-publish elpy company-tabnine all-the-icons-dired all-the-icons-ivy all-the-icons fzf treemacs-projectile treemacs neotree-toggle tern-auto-complete tern js2-refactor ac-js2 web-mode multiple-cursors hungry-delete ace-window org-bullets use-package magit-popup web-search org-web-tools powerthesaurus org-alert org-review evil-args evil-commentary evil-mc evil-mc-extras evil-nerd-commenter evil-org evil-surround airline-themes pandoc-mode tss typescript-mode import-js js2-mode node-resolver npm-mode github-search magit-circleci magit-lfs magit-org-todos magit-rbr magit-reviewboard magit-todos magit-vcsh orgit org-ac org-context org-evil org-jira org-kanban org-multi-wiki org-preview-html org-sidebar org-sync weechat weechat-alert viking-mode captain seq yasnippet auto-virtualenv indent-tools lsp-jedi pony-mode pydoc pylint python-mode python-pytest 2048-game composer flycheck-phpstan flymake-phpcs php-mode php-refactor-mode php-runtime phpactor phpunit smarty-mode async-await bpr concurrent ac-emmet yasnippet-classic-snippets xclip which-key websocket web-server undo-tree transcribe svg-lib svg-clock sql-indent scanner rainbow-mode python poker phps-mode orgalist org-translate org-edna ivy-hydra gnu-elpa-keyring-update gnu-elpa flymake-proselint eldoc-eval el-search eglot dict-tree csv-mode company-statistics company-ebdb cobol-mode chess auto-correct async aggressive-indent))
 '(treemacs-git-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(aw-leading-char-face ((t (:inherit ace-jump-face-foreground :height 3.0)))))

(global-set-key (kbd "C-x C-b") 'ibuffer)
(setq ibuffer-saved-filter-groups
      (quote (("default"
               ("dired" (mode . dired-mode))
               ("org" (name . "^.*org$"))
               ("magit" (mode . magit-mode))
               ("IRC" (or (mode . circe-channel-mode) (mode . circe-server-mode)))
               ("web" (or (mode . web-mode) (mode . js2-mode)))
               ("shell" (or (mode . eshell-mode) (mode . shell-mode)))
               ("mu4e" (or

                        (mode . mu4e-compose-mode)
                        (name . "\*mu4e\*")
                        ))
               ("programming" (or
                               (mode . clojure-mode)
                               (mode . clojurescript-mode)
                               (mode . python-mode)
                               (mode . c++-mode)))
               ("emacs" (or
                         (name . "^\\*scratch\\*$")
                         (name . "^\\*Messages\\*$")))
               ))))
(add-hook 'ibuffer-mode-hook
          (lambda ()
            (ibuffer-auto-mode 1)
            (ibuffer-switch-to-saved-filter-groups "default")))

;; don't show these
;;(add-to-list 'ibuffer-never-show-predicates "zowie")
;; Don't show filter groups if there are no buffers in that group
(setq ibuffer-show-empty-filter-groups nil)

;; Don't ask for confirmation to delete marked buffers
(setq ibuffer-expert t)

(save-place-mode 1)

;; Paquetes que se instalan con use-package

;; Asincronismo para emacs

(use-package async
  :ensure t
  :config
  (dired-async-mode 1)
  (async-bytecomp-package-mode 1)
  )

;; Habilita el clipboard en Emacs
(setq select-enable-clipboard t)

;;Evil mode

(use-package evil 
  :ensure t
  :init
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1)

  ;;Evil undo-tree
  (global-undo-tree-mode)
  (evil-set-undo-system 'undo-tree)
  )

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init)
  )

;;Numeracion relativa
(setq display-line-numbers-type 'relative) 
(global-display-line-numbers-mode) 

(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode))

;;Which key 
(use-package which-key
  :ensure t 
  :defer t
  :config
  (which-key-mode t)
  )

;;Org mode
(use-package org 
  :ensure t
  :pin org)

;;Org Bullets
(use-package org-bullets
  :ensure t
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(use-package org-superstar
  :ensure t)

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

(use-package evil-numbers
  :ensure t)

(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode t))

;;Yasnippet

(use-package yasnippet
  :ensure t
  :init
  (yas-global-mode 1)
  (add-hook 'yas-minor-mode-hook
	    (lambda ()
	      (yas-activate-extra-mode 'fundamental-mode)
	      )
	    )
  :config
  (setq yas-prompt-functions '(yas-dropdown-prompt                                                                                         
			       yas-ido-prompt
			       yas-completing-prompt)
	)
  )

(use-package yasnippet-snippets
  :ensure t
  :defer t
  :after yasnippet)

;; Snippet para react
(use-package react-snippets
  :ensure t)

;;Editar multiples regiones al mismo tiempo
(use-package iedit
  :ensure t)

;;Borra todos los espacios en blanco con solo presionar la tecla backspace o suprimir
(use-package hungry-delete
  :ensure t
  :config
  (global-hungry-delete-mode))

(use-package multiple-cursors
  :ensure t
  :config
  (global-set-key (kbd "C-c >") 'mc/mark-next-like-this)
  (global-set-key (kbd "C-c <") 'mc/mark-previous-like-this)
  (global-set-key (kbd "C-c =") 'mc/mark-all-like-this)
  )

(use-package web-mode
  :ensure t
  :mode "\\(?:\\(?:\\.\\(?:html\\|twig\\)\\)\\)\\'"
  :config
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.vue?\\'" . web-mode))
  (setq web-mode-enable-auto-quoting t) 
  (setq web-mode-auto-complete t)
  (setq web-mode-engines-alist
	'(
	  ("django"    . "\\.html\\'")
	  )
	)
  (setq web-mode-ac-sources-alist
	'(("css" . (ac-source-css-property))
	  ("vue" . (ac-source-words-in-buffer ac-source-abbrev))
          ("html" . (ac-source-words-in-buffer ac-source-abbrev))
	  )
	)
  (setq web-mode-extra-auto-pairs
	'(("erb"  . (("beg" "end")))
          ("php"  . (("beg" "end")
                     ("beg" "end")))
	  ))
  (setq web-mode-enable-auto-closing t)
  (setq web-mode-enable-auto-pairing t)
  (setq web-mode-enable-css-colorization t)
  (setq web-mode-enable-part-face t)
  (add-hook 'web-mode-hook
            (lambda ()
              (setq web-mode-style-padding 2)
              (yas-minor-mode t)
              (emmet-mode)
              (flycheck-add-mode 'html-tidy 'web-mode)
              (flycheck-mode)))
  )

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
  :defer t
  :bind ("C-c p" . projectile-command-map)
  :config
  (projectile-global-mode)
  (setq projectile-completion-system 'ivy)
  (setq projectile-project-search-path
	'("/baul/Codigo" "/baul/Documentos")
	)
  (setq projectile-auto-discover t)

  ;; Permite hacer cacheo del proyecto
  (setq projectile-enable-caching t)
  (add-to-list 'projectile-globally-ignored-directories "*node_modules")
  (setq projectile-mode-line
        '(:eval
          (format " Proj[%s]"
                  (projectile-project-name)
		  )
	  )
	)
  )

(use-package counsel-projectile
  :ensure t
  ;; :config
  ;; (counsel-projectile-on)
  )

;;Sirve para poder mostrar un explorador de archivos al estilo de VsCode

(use-package treemacs
  :ensure t
  :config
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-git-mode 'extended)
  (treemacs-indent-guide-mode 'line)
  (with-eval-after-load 'treemacs
    (define-key treemacs-mode-map [mouse-1] #'treemacs-single-click-expand-action))
  :bind
  (:map global-map
	([f7] . treemacs-select-window)
	([f8] . treemacs)
	([f9] . treemacs-projectile)
	("C-c 1" . treemacs-delete-other-windows)
	)
  )

(use-package treemacs-all-the-icons
  :ensure t
  :after treemacs
  )
(use-package treemacs-icons-dired
  :ensure t
  :after treemacs)

(use-package treemacs-evil
  :ensure t
  :after treemacs
  )

(use-package treemacs-magit
  :ensure t
  :after treemacs)

(use-package treemacs-projectile
  :defer t
  :ensure t
  :config
  (setq treemacs-header-function #'treemacs-projectile-create-header)
  )


;;Para autocompletado de simbolos como parentesis, comillas, etc. Parte de las funciones de electric que vienen por defecto en emacs

(electric-pair-mode 1)
(electric-layout-mode 1)
(electric-quote-mode 1)

(show-paren-mode t)

;;Git

(use-package magit
  :ensure t
  :init
  (progn
    (bind-key "C-x g" 'magit-status)
    ))

(setq magit-status-margin
      '(t "%Y-%m-%d %H:%M " magit-log-margin-width t 18)
      )

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

(use-package all-the-icons 
  :ensure t
  :defer 0.5
  )

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

;;Entorno de desarrollo en Python
(use-package elpy
  :ensure t
  :mode "\\.py\\'"
  :config
  (elpy-enable)
  (load "elpy")
  (load "elpy-rpc")
  (load "elpy-shell")
  (load "elpy-profile")
  (load "elpy-refactor")
  (load "elpy-django")
  )

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
  (
   ("M-y" . counsel-yank-pop)
   :map ivy-minibuffer-map
   ("M-y" . ivy-next-line)
   )
  )

(use-package ivy
  :ensure t
  :diminish (ivy-mode)
  :bind (
	 ("C-x b" . ivy-switch-buffer)
	 )
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "%d/%d ")
  (setq ivy-display-style 'fancy)
  )

(use-package ivy-prescient
  :after counsel
  :config (ivy-prescient-mode 1)
  )

(use-package swiper
  :ensure t
  :bind (
	 ("C-s" . swiper-isearch)
	 ("C-r" . swiper-isearch)
	 ("C-c C-r" . ivy-resume)
	 ("M-x" . counsel-M-x)
	 ("C-x C-f" . counsel-find-file)
	 )
  :config
  (progn
    (ivy-mode 1)
    (setq ivy-use-virtual-buffers t)
    (setq ivy-display-style 'fancy)
    (define-key read-expression-map (kbd "C-r") 'counsel-expression-history)
    )
  )

;;Modo mayor para apache
(use-package apache-mode
  :ensure t
  :config
  (autoload 'apache-mode "apache-mode" t)
  (add-to-list 'auto-mode-alist '("\\.htaccess\\'"   . apache-mode))
  (add-to-list 'auto-mode-alist '("httpd\\.conf\\'"  . apache-mode))
  (add-to-list 'auto-mode-alist '("srm\\.conf\\'"    . apache-mode))
  (add-to-list 'auto-mode-alist '("access\\.conf\\'" . apache-mode))
  (add-to-list 'auto-mode-alist '("sites-\\(available\\|enabled\\)/" . apache-mode))
  )

;;Corrector gramatico
(use-package languagetool
  :ensure t
  )

;;Interfaz para composer en Emacs
(use-package composer
  :ensure t
  :config
  (composer-get-bin-dir)
  (composer-get-config "bin-dir")
  )

;;Contador de palabras para org
(use-package org-wc
  :ensure t
  )

;;Exportar de org a Wordpress directamente
(use-package org2blog
  :ensure t
  )

;; Permite hacer busquedas en cualquier motor de busquedas que se definan
(use-package engine-mode
  :ensure t
  :config (engine-mode t)

  (defengine duckduckgo
    "https://duckduckgo.com/?q=%s"
    :keybinding "d")

  (defengine google 
    "https://google.co.ve"
    :keybinding "g")

  (defengine github
    "https://github.com/search?ref=simplesearch&q=%s"
    :keybinding "G")

  (defengine google-images
    "http://www.google.com/images?hl=en&source=hp&biw=1440&bih=795&gbv=2&aq=f&aqi=&aql=&oq=&q=%s")

  (defengine google-maps
    "http://maps.google.com/maps?q=%s"
    :docstring "Mappin' it up."
    :keybinding "m")

  (defengine project-gutenberg
    "http://www.gutenberg.org/ebooks/search/?query=%s"
    :keybinding "p")

  (defengine stack-overflow
    "https://stackoverflow.com/search?q=%s"
    :keybinding "s")

  (defengine twitter
    "https://twitter.com/search?q=%s"
    :keybinding "t")

  (defengine wikipedia
    "http://www.wikipedia.org/search-redirect.php?language=en&go=Go&search=%s"
    :keybinding "w"
    :docstring "Buscar conocimiento")

  (defengine wiktionary
    "https://www.wikipedia.org/search-redirect.php?family=wiktionary&language=en&go=Go&search=%s"
    :keybinding "W"
    :docstring "Buscar definiciones"
    )

  (defengine youtube
    "http://www.youtube.com/results?aq=f&oq=&search_query=%s"
    :keybinding "y")
  )

(use-package org-roam
  :ensure t
  :init (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "~/Plantillas/RoamNotes")
  (org-roam-completion-everywhere t)
  :bind (
	 ("C-c n l" . org-roam-buffer-toggle)
	 ("C-c n f" . org-roam-node-find)
	 ("C-c n i" . org-roam-node-insert)
	 :map org-mode-map
         ("C-M-i"    . completion-at-point)
	 )
  :config (org-roam-setup)
  )

;;Autocompletado

(use-package company
  :ensure t
  :config
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 3)
  (global-company-mode t)
  :bind (:map company-active-map ("<tab>" . company-complete-selection))
  )

;; Autocompletado para ansible
(use-package company-ansible
  :ensure t
  :after company
  )

;; Autocompletado para php
(use-package company-php
  :ensure t
  :after company
  )

(use-package company-phpactor
  :ensure t
  :after company
  )

(use-package company-box
  :ensure t
  :hook (company-mode . company-box-mode))

(use-package proof-general
  :ensure t)

(use-package php-mode
  ;;
  :hook ((php-mode . (lambda () (set (make-local-variable 'company-backends)
				     '(;; list of backends
				       company-phpactor
				       company-files
				       ))))))

(use-package phpunit
  :ensure t
  ;; :config
  ;; (define-key web-mode-map (kbd "C-x t") 'phpunit-current-test)
  ;; (define-key web-mode-map (kbd "C-x c") 'phpunit-current-class)
  ;; (define-key web-mode-map (kbd "C-x p") 'phpunit-current-project)
  )

(use-package company-org-block
  :ensure t
  :after company
  )

(use-package company-wordfreq
  :ensure t
  :init
  :after company
  )

(use-package company-statistics
  :ensure t
  :config
  (add-hook 'after-init-hook 'company-statistics-mode) 
  :after company
  )

(use-package company-try-hard
  :ensure t
  :after company)

(use-package company-web
  :ensure t
  :after company
  :config
  (add-to-list 'company-backends 'company-web-html)
  (add-to-list 'company-backends 'company-web-jade)
  (add-to-list 'company-backends 'company-web-slim) 
  )

;;Probar paquetes sin instarlos
(use-package try
  :ensure t)

;;Editar archivos que necesitan permisos de administrador usando su o sudo en Emacs
(use-package su
  :ensure t)

;; Modo para yaml
(use-package yaml-mode
  :ensure t
  ;; .yaml or .yml
  :mode "\\(?:\\(?:\\.y\\(?:a?ml\\)\\)\\)\\'")

;; Mostrar todos los iconos
(use-package all-the-icons
  :ensure t
  :defer t)

(use-package rainbow-delimiters
  :ensure t
  :config (add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
  )

(use-package rainbow-mode
  :ensure t
  :commands rainbow-mode
  :config (add-hook 'css-mode 'rainbow-mode)
  )

(use-package css-mode
  :ensure t
  :mode "\\.css\\'"
  :config
  (add-hook 'css-mode-hook (lambda ()
                             (rainbow-mode))))

(use-package emmet-mode
  :hook ((html-mode sgml-mode css-mode web-mode) . emmet-preview-mode)
  :bind("C-j" . emmet-expand-line)
  :config
  (add-hook 'rjsx-mode-hook
            (lambda ()
              (setq-local emmet-expand-jsx-className? t)
	      )
	    )
  
  (setq emmet-move-cursor-between-quotes t) ;; default nil
  )

;; Language Server Protocol 
(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  (lsp-enable-which-key-integration 1)
  (add-hook 'prog-mode-hook #'lsp)
  (setq lsp-enable-symbol-highlighting t)
  (setq lsp-log-io nil) ;; if set to true can cause a performance hit
  (with-eval-after-load 'lsp-mode
    (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\.my-folder\\'")
    ;; or
    (add-to-list 'lsp-file-watch-ignored-files "[/\\\\]\\.my-files\\'"))
  )

;; Opcional
(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :config
  (setq lsp-ui-sideline-show-diagnostics 1)
  (setq lsp-ui-sideline-show-hover 1)
  (setq lsp-ui-sideline-show-code-actions 1)
  (setq lsp-ui-doc-enable 1)
  (lsp-ui-peek-jump-backward)
  (lsp-ui-peek-jump-forward)
  (setq lsp-ui-doc-show-with-cursor 1)
  )

(use-package lsp-jedi
  :ensure t
  :config
  (with-eval-after-load "lsp-mode"
    (add-to-list 'lsp-disabled-clients 'pyls)
    (add-to-list 'lsp-enabled-clients 'jedi)))

(use-package lsp-tailwindcss
  :ensure t)

;; if you are helm user
(use-package helm-lsp :commands helm-lsp-workspace-symbol)

;; if you are ivy user
(use-package lsp-ivy
  :commands lsp-ivy-workspace-symbol)

(use-package lsp-treemacs
  :commands lsp-treemacs-errors-list
  :config
  (setq lsp-treemacs-symbols t)
  (setq lsp-treemacs-errors-list t)
  (lsp-treemacs-sync-mode 1)
  )

;; optionally if you want to use debugger
(use-package dap-mode
  :ensure t
  :config
  ;; Enabling only some features
  (setq dap-auto-configure-features '(sessions locals controls tooltip))
  (dap-mode 1)

  ;; The modes below are optional

  (dap-ui-mode 1)
  ;; enables mouse hover support
  (dap-tooltip-mode 1)
  ;; use tooltips for mouse hover
  ;; if it is not enabled `dap-mode' will use the minibuffer.
  (tooltip-mode 1)
  ;; displays floating panel with debug buttons
  (dap-ui-controls-mode 1)
  (require 'dap-python)
  )
;; (use-package dap-LANGUAGE) to load the dap adapter for your language

;; optional if you want which-key integration
(use-package which-key
  :ensure t
  :config
  (which-key-mode))

;; Django mode
(use-package django-mode
  :ensure t
  )

(use-package django-snippets
  :ensure t
  :after django-mode
  )

;;Herramientas para poder ver PDF en emacs
(use-package pdf-tools
  :ensure t)

;;json reformat
(use-package json-reformat
  :ensure t
  )

(use-package sgml-mode
  :hook ((sgml-mode nxml-mode html-mode web-mode)
         . sgml-electric-tag-pair-mode)
  :config
  (setq sgml-basic-offset 4))

;;Paquete para python-mode
(use-package python-mode
  :ensure t
  :hook (python-mode . lsp-deferred)
  :mode "\\.py\\'"
  :custom
  (python-shell-interpreter "python3"))

;; Live server para desarrollo
(use-package impatient-mode
  :ensure t
  )

;; Tema para emacs
(use-package zenburn-theme
  :ensure t
  :init  
  (load-theme 'zenburn t)
  )

(use-package rg
  :ensure t)

;; Front para GNU global y generador de etiquetas para codigo fuente
(use-package ggtags
  :ensure t
  :init)

;; Lector de feeds para emacs
(use-package elfeed
  :ensure t
  :config
  (setq elfeed-feeds
	'("http://nullprogram.com/feed/"
          "https://planet.emacslife.com/atom.xml")
	)
  )

;;Autocompletado para python
(use-package jedi-core
  :ensure t)

;;Conexiones remotas desde emacs
(use-package tramp
  :ensure t)

;; Habilitado el portapapeles de la GUI a la terminal

(use-package xclip
  :ensure t
  :init
  (xclip-mode 1)
  )

(use-package origami
  :ensure t)

(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1))

(use-package marginalia
  ;; Either bind `marginalia-cycle` globally or only in the minibuffer
  :ensure t
  :bind (("M-A" . marginalia-cycle)
         :map minibuffer-local-map
         ("M-A" . marginalia-cycle))

  ;; The :init configuration is always executed (Not lazy!)
  :init

  ;; Must be in the :init section of use-package such that the mode gets
  ;; enabled right away. Note that this forces loading the package.
  (marginalia-mode)
  )

;; Permite crear distantas perspectivas pawera que no se aglomeren muchos buffers en ibuffer o en cualquier otra lista de bufferso
(use-package perspective
  :ensure t
  :bind (("C-x k" . persp-kill-buffer*))
  :init
  (persp-mode)
  )

;; Modo mayor para archivos typescript
(use-package typescript-mode
  :ensure t
  :mode "\\.ts\\’"
  :hook (typescript-mode . lsp-deferred)
  :config
  ;; (setq typescript-indent-level 4)
  ;; (dap-node-setup) ;;Instala automaticamente el depurador de node si es necesario
  )

;; Añade resaltado de sintaxis para archivos de configuracion sources.list
(use-package apt-sources-list
  :ensure t)

;; Modo para poder ejecutar npm dentro de Emacs
(use-package npm
  :ensure t)

(use-package markdown-mode
  :ensure t
  :mode "\\.md\\'"
  )

(use-package markdown-preview-mode
  :ensure t
  :config
  (add-to-list 'markdown-preview-javascript '("http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML" . async))
  )

(use-package gitignore-templates
  :ensure t
  )

;;; init.el ends here
