
(require 'saveplace)
(require 'linum)

(setq-default saive-place t)

(setq make-backup-files nil)
(setq auto-save-default nil)

(setq debug-on-error t)

;(load "tex-site")

(set-language-environment 'Japanese)
(prefer-coding-system 'utf-8)

;(line-number-mode t)
(global-linum-mode t)

(electric-indent-mode t)
					
;(global-hl-line-mode)

(column-number-mode t)

(set-locale-environment nil)

(auto-image-file-mode t)

(blink-cursor-mode 0)

(show-paren-mode 1)

(setq show-paren-style 'mixed)
(setq inferior-lisp-program "clisp")

(add-to-list 'load-path (expand-file-name "~/.emacs.d/load-path-dir"))
(add-to-list 'load-path (expand-file-name "~/.emacs.d/slime"))
(add-to-list 'load-path (expand-file-name "/usr/share/emacs/site-lisp"))

;; load SLIME
;;
;(require 'slime)
;(slime-setup '(slime-repl slime-fancy slime-banner))

;(require 'ac-slime)
;(add-hook 'slime-mode-hook 'set-up-slime-ac)
;(add-hook 'slime-repl-mode-hook 'set-up-slime-ac)

;; (package-initialize)
;; (add-to-list 'package-archives '("marmalade" . "https://marmalade-repo.org/packages/"))
;; (add-to-list 'package-archives '("melpa" . "https://melpa.milkbox.net/packages/") t)

;; (add-to-list 'load-path (expand-file-name "~/.emacs.d/auto-install/"))

;; (require 'auto-install)

;; (auto-install-update-emacswiki-package-name t)
;; (auto-install-compatibility-setup)


(setq split-width-threshold nil)

;; (require 'auto-complete)
;; ;(require 'auto-complete-config)
;; (global-auto-complete-mode t)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.milkbox.net/packages/"))
(add-to-list 'package-archives '("marmalade" . "https://marmalade-repo.org/packages/"))
(fset 'package-desc-vers 'package--ac-desc-version)
(package-initialize)  ;load and activate packages, including auto-complete


;(require 'package)
;; (custom-set-variables
;;  ;; custom-set-variables was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(gud-gdb-command-name "gdb --annotate=1")
;;  '(large-file-warning-threshold nil)
;;  '(package-archives
;;    (quote
;;     (("gnu" . "https://elpa.gnu.org/packages/")
;;      ("melpa-stable" . "https://stable.melpa.org/packages/"))))
;;  '(package-selected-packages
;;    (quote
;;     (sed-mode llvm-mode temp-buffer-browse trie cmake-mode protocols protobuf-mode purescript-mode helm auto-complete resize-window scala-mode ztree web-mode haskell-mode erlang ack)))
;;  '(purescript-mode-hook (quote (turn-on-purescript-indent))))


(add-to-list 'default-frame-alist '(font . "fontset-menlokakugo"))

(setq inferior-lisp-program "sbcl")

(set-frame-parameter (selected-frame) 'alpha '(85 50))

;(global-font-lock-mode t)
;(require 'font-lock)

;; (require 'web-mode)
;; (add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
;; (add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
;; (add-to-list 'auto-mode-alist '("\\.[gj]sp\\'" . web-mode))
;; (add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
;; (add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
;; (add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
;; (add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
;; (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
;; (setq web-mode-engines-alist
;; '(("php"    . "\\.phtml\\'")
;;   ("blade"  . "\\.blade\\.")))

;(load-library "php-mode")
;(require 'php-mode)

(put 'upcase-region 'disabled nil)

;paste mode					

;; (require 'term-paste-mode)

;; (add-hook 'term-paste-mode-on-hook
;; 	  (lambda ()
;; 	    (key-chord-mode 0)
;; 	    ))
;; (add-hook 'term-paste-mode-off-hook
;; 	  (lambda ()
;; 	    (key-chord-mode 1)
;; 	    ))
;; (defalias 'p 'term-paste-mode)

;copy & paste

(defun copy-from-osx ()
  (shell-command-to-string "pbpaste"))

(defun paste-to-osx (text &optional push)
  (let ((process-connection-type nil))
    (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
      (process-send-string proc text)
      (process-send-eof proc))))

(setq interprogram-cut-function 'paste-to-osx)
(setq interprogram-paste-function 'copy-from-osx)

(setq w (selected-window))
(setq w2 (split-window w nil t))

;(setq w3 (split-window w2 nil))

;;(require 'scala-mode)
;;window move

(global-set-key (kbd "C-c z") 'ztree-dir)
(global-set-key (kbd "C-c r") 'resize-window)
(global-set-key (kbd "C-c <left>")  'windmove-left)
(global-set-key (kbd "C-c <down>")  'windmove-down)
(global-set-key (kbd "C-c <up>")    'windmove-up)
(global-set-key (kbd "C-c <right>") 'windmove-right)
(global-set-key "\C-cl" 'goto-line)

;(setq global-auto-complete-mode t)

;(require 'package)

;; (add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)

(ac-config-default)
(global-auto-complete-mode t)

(require 'helm-config)
(helm-mode 1)

(defun open-current-dir-with-finder ()
  (interactive)
  (shell-command (concat "open " (file-name-directory (buffer-file-name)))))

;(open-current-dir-with-finder)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(gud-gdb-command-name "gdb --annotate=1")
 '(large-file-warning-threshold nil)
 '(package-selected-packages
   (quote
    (groovy-mode gradle-mode bnfc flycheck-rust rust-mode llvm-mode ztree web-mode trie temp-buffer-browse sed-mode scala-mode resize-window purescript-mode helm haskell-mode erlang auto-complete ack))))

;; Get the Groovy support for Emacs from http://svn.codehaus.org/groovy/trunk/groovy/ide/emacs
;; Symlink the downloaded Groovy support into your .emacs.d folder as "groovy"


;;; use groovy-mode when file ends in .groovy or has #!/bin/groovy at start
(add-to-list 'load-path "~/.emacs.d/groovy")
(autoload 'groovy-mode "groovy-mode" "Major mode for editing Groovy code." t)
;; For some reason, these recommendations don't seem to work with Aquamacs
(add-to-list 'auto-mode-alist '("\.groovy$" . groovy-mode))
(add-to-list 'auto-mode-alist '("\.gradle$" . groovy-mode))
;; This does work with Aquamacs
(add-to-list 'auto-mode-alist (cons "\\.gradle\\'" 'groovy-mode))
(add-to-list 'auto-mode-alist (cons "\\.groovy\\'" 'groovy-mode))
;; This _might_ not work with Aquamacs (not sure what value it offers)
(add-to-list 'interpreter-mode-alist '("groovy" . groovy-mode))
(add-to-list 'interpreter-mode-alist '("gradle" . groovy-mode))
;;; make Groovy mode electric by default.
(add-hook 'groovy-mode-hook
          '(lambda ()
             (require 'groovy-electric)
             (groovy-electric-mode)))

;; for rust mode

