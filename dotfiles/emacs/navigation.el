(defun dm/switch-to-prev-window ()
  (interactive)
  (other-window -1))

(defun dm/switch-to-next-window ()
  (interactive)
  (other-window 1))

(global-set-key [?\C-,] 'dm/switch-to-prev-window)
(global-set-key [?\C-.] 'dm/switch-to-next-window)
