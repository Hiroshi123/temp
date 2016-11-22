;; http://www.mahalito.net/~harley/elisp/undo-group.el
;(require 'undo-group)

(defvar term-paste-mode-map
  (let ((map (make-keymap))
	(i ? ))
    (while (< i ?~) ;; 取りあえずスペース ～ ~までself-insert-commandをセットして上書く
      (define-key map (char-to-string i) 'self-insert-command)
      (setq i (1+ i)))
    (define-key map "\C-m" 'newline)
    map))

(defcustom term-paste-mode-on-hook nil
  "Hook to run when term-paste-mode is activated."
  :group 'term-paste-mode  :type 'hook)

(defcustom term-paste-mode-off-hook nil  "Hook to run when term-paste-mode is deactivated."
  :group 'term-paste-mode  :type 'hook)

(define-minor-mode term-paste-mode  "Minor mode for pasting from any terminal applications."
  :lighter " Paste"
  :group 'term-paste-mode  (cond (term-paste-mode         ;; minor-mode-mapの優先順位を上げる
				  (setq minor-mode-map-alist
					(cons (cons 'term-paste-mode term-paste-mode-map)
					      (delete (assq 'term-paste-mode minor-mode-map-alist) minor-mode-map-alist)))
				  (undo-group-boundary)
				  (run-hooks 'term-paste-mode-on-hook))
				 (term-paste-mode-on-hook         (run-hooks 'term-paste-mode-off-hook)
								  )))

(provide 'term-paste-mode)

