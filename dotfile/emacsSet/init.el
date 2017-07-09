
(require 'saveplace)

(require 'linum)

(setq-default saive-place t)

(set-language-environment 'Japanese)
(prefer-coding-system 'utf-8)

;(line-number-mode t)
(global-linum-mode t)

;(electric-indent-mode 0)

;(global-hl-line-mode)

(column-number-mode t)

(set-locale-environment nil)

(auto-image-file-mode t)

(blink-cursor-mode 0)

(show-paren-mode 1)

(setq show-paren-style 'mixed)

;; Clozure CLをデフォルトのCommon Lisp処理系に設定
(setq inferior-lisp-program "clisp")
;; ~/.emacs.d/slimeをload-pathに追加

(add-to-list 'load-path (expand-file-name "~/.emacs.d/load-path-dir"))
(add-to-list 'load-path (expand-file-name "~/.emacs.d/slime"))
(add-to-list 'load-path (expand-file-name "/usr/share/emacs/site-lisp"))

;; SLIMEのロード
;;
;(require 'slime)
;(slime-setup '(slime-repl slime-fancy slime-banner))

;(require 'ac-slime)
;(add-hook 'slime-mode-hook 'set-up-slime-ac)
;(add-hook 'slime-repl-mode-hook 'set-up-slime-ac)

(package-initialize)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)

(add-to-list 'load-path (expand-file-name "~/.emacs.d/auto-install/"))
(require 'auto-install)

(auto-install-update-emacswiki-package-name t)
(auto-install-compatibility-setup) 

(setq split-width-threshold nil)

(require 'auto-complete)
;(require 'auto-complete-config)
(global-auto-complete-mode t)


;(create-fontset-from-ascii-font "Menlo-14:weight=normal:slant=normal" nil "menlokakugo")
;(set-fontset-font "fontset-menlokakugo"
;                  'unicode
;                  (font-spec :family "Hiragino Kaku Gothic ProN" :size 16)
;                  nil
;                  'append)
(add-to-list 'default-frame-alist '(font . "fontset-menlokakugo"))

(setq inferior-lisp-program "sbcl")

(set-frame-parameter (selected-frame) 'alpha '(85 50))

;(global-font-lock-mode t)
;(require 'font-lock)



;(require 'web-mode)
;(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
;(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
;(add-to-list 'auto-mode-alist '("\\.[gj]sp\\'" . web-mode))
;(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
;(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
;(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
;(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
;(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
;(setq web-mode-engines-alist
;'(("php"    . "\\.phtml\\'")
;  ("blade"  . "\\.blade\\.")))



;(load-library "php-mode")
;(require 'php-mode)

(put 'upcase-region 'disabled nil)

;paste mode					

;(require 'term-paste-mode)

;(add-hook 'term-paste-mode-on-hook
;	  (lambda ()
;	    (key-chord-mode 0)
;	    ))
;(add-hook 'term-paste-mode-off-hook
;	  (lambda ()
;	    (key-chord-mode 1)
;	    ))

;(defalias 'p 'term-paste-mode)

;copy & paste

;(defun copy-from-osx ()
;  (shell-command-to-string "pbpaste"))

;(defun paste-to-osx (text &optional push)
;  (let ((process-connection-type nil))
;    (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
;      (process-send-string proc text)
;      (process-send-eof proc))))

;(setq interprogram-cut-function 'paste-to-osx)
;(setq interprogram-paste-function 'copy-from-osx)

;(require 'scala-mode)


