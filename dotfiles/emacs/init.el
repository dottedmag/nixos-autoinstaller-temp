(set-face-attribute 'default nil :family "Liberation Mono" :height 130)

(setq
 dm/config-dir user-emacs-directory
 ;; Change work directory for misc Emacs files
 user-emacs-directory (expand-file-name "~/.local/lib/emacs/")
 ;; auto-save-list-file-name uses user-emacs-directory dumped during Emacs build unless overriden
 auto-save-list-file-prefix (concat user-emacs-directory "auto-save-list/.saves-")
 ;; Increase interval between GCs
 gc-cons-threshold 402653184
 ;; Allow larger GC generations
 gc-cons-percentage 0.6
 )

;; remove GNU ads

(mapc 'global-unset-key
      '("\C-h\C-c" "\C-h\C-d" "\C-h\C-p" "\C-h\C-w" "\C-hn" "\C-h\C-n"
        "\C-hP" "\C-h\C-n" "\C-h\C-m" "\C-hF"))

(setq inhibit-startup-message t)

;; inhibit-startup-echo-area-message is a variable defined in ‘startup.el’.
;; ...
;; Setting this variable takes effect only if you do it with
;; the customization buffer or if your init file contains a line of
;; this form: (setq inhibit-startup-echo-area-message
;; "YOUR-USER-NAME")
;;
;; DAFUQ? It's easier just to kill the corresponding function.
(defun display-startup-echo-area-message ())

(tool-bar-mode -1)
(scroll-bar-mode -1)
(unless (eq system-type 'darwin)
  (menu-bar-mode -1))

;; load things

(load-file (concat dm/config-dir "/frame-init.el"))
(load-file (concat dm/config-dir "/go.el"))
(load-file (concat dm/config-dir "/navigation.el"))

;; dvorak

(global-set-key "\M-x" 'fill-paragraph)
(global-set-key "\M-q" 'execute-extended-command)
