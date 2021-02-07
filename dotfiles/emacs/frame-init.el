(defun dm/terminal-setup (term)
  ;; keyboard-translate does not accept terminal argument, so check
  ;; that the selected terminal is the one that is supposed to be
  ;; configured
  (when (equal (terminal-name nil) (terminal-name term))
    (keyboard-translate ?\C-q ?\C-x)
    (keyboard-translate ?\C-x ?\C-q)
    (keyboard-translate ?\C-Q ?\C-X)
    (keyboard-translate ?\C-X ?\C-Q)))

(defun dm/frame-setup (frame)
  ;; text frames should have no menu even on macOS
  (if (eq (framep frame) 't)
      (set-frame-parameter nil 'menu-bar-lines 0))
  (dm/terminal-setup-once (get-device-terminal frame)))

(defun dm/frame-focused ()
  (dm/terminal-setup-once (get-device-terminal (selected-frame))))

(setq dm/terminal-setup-applied (make-hash-table :test 'equal))

(defun dm/terminal-setup-once (term)
  (unless (gethash (terminal-name term) dm/terminal-setup-applied)
    (dm/terminal-setup term)
    (puthash (terminal-name term) t dm/terminal-setup-applied)))

(defun dm/forget-terminal (term)
  (remhash (terminal-name term) dm/terminal-setup-applied))

(add-hook 'delete-terminal-functions 'dm/forget-terminal)
(add-hook 'focus-in-hook 'dm/frame-focused)
(add-hook 'after-make-frame-functions 'dm/frame-setup t)
(dm/frame-setup (selected-frame))
