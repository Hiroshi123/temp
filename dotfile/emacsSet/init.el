
(require 'saveplace)

(require 'linum)

(setq-default saive-place t)

(electric-indent-mode -1)

(set-language-environment 'Japanese)
(prefer-coding-system 'utf-8)

;No backup-files
(setq make-backup-files nil)
(setq auto-save-default nil)

;(line-number-mode t)
(global-linum-mode t)

;(electric-indent-mode 0)

;(global-hl-line-mode)

(setq-default indent-tabs-mode nil)

(column-number-mode t)

(set-locale-environment nil)

(auto-image-file-mode t)

(blink-cursor-mode 0)

(show-paren-mode 1)

(setq show-paren-style 'mixed)

;(setq split-width-threshold 1)
(split-window-right)


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

;(setq split-width-threshold nil)

(require 'auto-complete)
;(require 'auto-complete-config)

(global-auto-complete-mode t)

(require 'package)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-archives   (quote
		       (("gnu" . "http://elpa.gnu.org/packages/")
			("melpa-stable" . "http://stable.melpa.org/packages/")))))


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

(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.[gj]sp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(setq web-mode-engines-alist
'(("php"    . "\\.phtml\\'")
 ("blade"  . "\\.blade\\.")))

;(load-library "php-mode")
;(require 'php-mode)

(put 'upcase-region 'disabled nil)

;window move
(global-set-key (kbd "C-c <left>")  'windmove-left)
(global-set-key (kbd "C-c <down>")  'windmove-down)
(global-set-key (kbd "C-c <up>")    'windmove-up)
(global-set-key (kbd "C-c <right>") 'windmove-right)

(defun window-split-vertical-to-horizontal ()
  (interactive)
  (let ((nw (window-buffer (next-window))))
    (delete-other-windows)
    (split-window-horizontally)
    (set-window-buffer (next-window) nw)))


(defun win-resize-minimize-vert ()
  (interactive)
  (cond
   ((equal "left" (win-resize-left-or-right)) (enlarge-window-horizontally 1))
   ((equal "right" (win-resize-left-or-right)) (enlarge-window-horizontally -1))
   ((equal "mid" (win-resize-left-or-right)) (enlarge-window-horizontally 1))))

(defun enlarge ()
  (interactive)
  (cond
   (window-resize 3 1)
   )
  )

(global-set-key (kbd "C-c pika") 'enlarge)

;; (defun pika 
;;   (interactive)
;;   ;'enlarge-window-horizontally
;;   )



(defun hello ()
  "Sample command."
  (interactive)
  (setq foo "pi!!!")
  (message foo))

(defun halve-other-window-height ()
  "Expand current window to use half of the other window's lines."
  (interactive)
  (enlarge-window (/ (window-height (next-window)) 2)))

(global-set-key (kbd "C-c v") 'halve-other-window-height)




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


