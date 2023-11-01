;;; config.el --- summary -*- lexical-binding: t -*-

;; Maintainer: Colin Mclear
;; This file is not part of GNU Emacs

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Personal config file
;; This file contains all user-specific settings

;;; Code:
;;;; Personal Information

;; Give Emacs some personal info
;; (setq user-full-name "Junghan Kim"
;;       user-mail-address "")

;;;;; Private File
;; where to store private or "secret" info
(let ((private (expand-file-name "private.el" lem-user-dir)))
  (if (file-exists-p private)
	  (load-file private)))

;;;; User Vars

;;;;; Set Fonts
;; Set fonts
;; Uncomment and set below variables for fonts other than the defaults
(custom-set-variables
 '(lem-ui-default-font
   '(:font "Sarasa Mono K" :height 136)))

(custom-set-variables
 '(lem-ui-variable-width-font
   '(:font "Pretendard Variable" :height 136)))

;;;;; Org Directories
;; Set these if you're using org
;; (setq org-directory "~/sync/org/"
;;       org-default-notes-file (concat org-directory "inbox.org")
;;       org-agenda-files (list org-directory))

(setq org-directory user-org-directory
      org-default-notes-file (concat org-directory "roam/workflow/inbox.org")
      ;; org-agenda-files (list org-directory)
      org-agenda-files (append (file-expand-wildcards (concat org-directory "roam/workflow/*.org")))
      )

;;;; Hangul

(defvar show-keyboard-layout nil
  "If non nil, show keyboard layout in special buffer.")

(setq default-input-method "korean-hangul")
(set-language-environment "Korean")
(set-keyboard-coding-system 'utf-8)
(setq locale-coding-system  'utf-8)
(prefer-coding-system 'utf-8)
(set-charset-priority 'unicode)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(setq-default buffer-file-coding-system 'utf-8-unix)
;; (unless (spacemacs/system-is-mswindows)
;;   (set-selection-coding-system 'utf-8))

(setq coding-system-for-read 'utf-8)
(setq coding-system-for-write 'utf-8)

;; Treat clipboard input as UTF-8 string first; compound text next, etc.
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

;; terminal-mode is nil
;; (setq-default line-spacing 2) ; use fontaine

;; 날짜 표시를 영어로한다. org mode에서 time stamp 날짜에 영향을 준다.
(setq system-time-locale "C")
;; (setenv "LANG" "en_US.UTF-8")
;; (setenv "LC_ALL" "en_US.UTF-8")

(setq input-method-verbose-flag nil
      input-method-highlight-flag nil)

(defun jh-visual/emoji-set-font ()
  (when (display-graphic-p) ; gui
    ;; (set-fontset-font t 'emoji (font-spec :family "Apple Color Emoji") nil 'prepend)
    (set-fontset-font t 'emoji (font-spec :family "Noto Color Emoji") nil)
    (set-fontset-font t 'emoji (font-spec :family "Noto Emoji") nil 'prepend) ; Top
    )
  (unless (display-graphic-p) ; terminal
    (set-fontset-font "fontset-default" 'emoji (font-spec :family "Noto Emoji") nil 'prepend) ; default face
    )

  (set-fontset-font t 'symbol (font-spec :family "Symbola") nil 'prepend)
  (set-fontset-font t 'symbol (font-spec :family "Noto Sans Symbols 2") nil 'prepend)
  (set-fontset-font t 'symbol (font-spec :family "Noto Sans Symbols") nil 'prepend)

  ;; 2023-09-14 심볼에는 컬러 빼자. 터미널과 호환성 유지 차원
  ;; (set-fontset-font t 'symbol (font-spec :family "Noto Color Emoji") nil 'prepend) ; Top
  )

(add-hook 'after-init-hook #'jh-visual/emoji-set-font)

;; (global-set-key [?\C-\\] 'jh-visual//change-input-method)
(global-set-key (kbd "<S-SPC>") 'toggle-input-method)
;; (global-set-key (kbd "<Alt_R>") 'toggle-input-method)
(global-set-key (kbd "<Hangul>") 'toggle-input-method)
;; (global-unset-key (kbd "S-SPC"))

(defun my/fontaine-apply-current-preset ()
  (interactive)
  ;; (fontaine-apply-current-preset)
  ;; 한글 사용 위해서 필수!
  ;; (set-fontset-font "fontset-default" 'hangul (font-spec :family "Sarasa Mono K")) ; default face
  (set-fontset-font "fontset-default" 'hangul (font-spec :family (face-attribute 'default :family))) ; default face
  (set-fontset-font "fontset-default" 'hangul (font-spec :family (face-attribute 'variable-pitch :family)) nil 'append) ; for
  )
(add-hook 'lambda-themes-after-load-theme-hook #'my/fontaine-apply-current-preset)

;;;;; Set Splash Footer
;; Set a footer for the splash screen
(setq lem-splash-footer "📜 Don't be the best. Be the only. - Kevin Kelly")

;;;; Load Modules
;; Load modules in stages for a shorter init time. We load core modules first,
;; then more expensive modules after init, with the rest loaded after startup
;; has fully completed.

;;;;; Load base modules
(message "
;; ======================================================
;; *Loading 𝛌-Emacs Base Modules*
;; ======================================================")
(measure-time
 (cl-dolist (mod (list
                  ;; Base modules
                  'lem-setup-libraries
                  'lem-setup-settings
                  'lem-setup-functions
                  'lem-setup-macros
                  'lem-setup-scratch
                  'lem-setup-theme

                  ;; Basic UI modules
                  'lem-setup-windows
                  'lem-setup-buffers
                  'lem-setup-frames
                  'lem-setup-fonts
                  'lem-setup-faces))
   (require mod nil t)))

;;;;; Load After-Init Modules
(defun lem-user-config-after-init ()
  "Modules loaded after init."
  (message "
  ;; ======================================================
  ;; *Loading 𝛌-Emacs after-init Modules*
  ;; ======================================================")
  (measure-time (cl-dolist (mod (list
                                 ;; Splash/Dashboard
                                 'lem-setup-splash
                                 ;;'lem-setup-dashboard

                                 ;; Completion
                                 'lem-setup-completion

                                 ;; Navigation & Search modules
                                 'lem-setup-navigation
                                 'lem-setup-dired
                                 'lem-setup-search

                                 ;; Project & Tab/Workspace modules
                                 'lem-setup-vc
                                 'lem-setup-projects
                                 'lem-setup-tabs
                                 'lem-setup-workspaces))
                  (require mod nil t))))
(add-hook 'after-init-hook #'lem-user-config-after-init)

;;;;; Load After-Startup Modules
(defun lem-user-config-after-startup ()
  "Modules loaded after Emacs startup."
  (message "
  ;; ======================================================
  ;; *Loading 𝛌-Emacs after-startup Modules*
  ;; ======================================================")
  (measure-time (cl-dolist (mod (list

                                 ;; Writing modules
                                 'lem-setup-writing
                                 'lem-setup-notes
                                 'lem-setup-citation

                                 ;; Keybindings & Modal
                                 'lem-setup-keybindings
                                 'cpm-setup-meow

                                 ;; Programming modules
                                 'lem-setup-programming
                                 'lem-setup-debug
                                 'lem-setup-skeleton

                                 ;; Shell & Terminal
                                 'lem-setup-shell
                                 'lem-setup-eshell

                                 ;; Org modules
                                 'lem-setup-org-base
                                 'lem-setup-org-settings
                                 'lem-setup-org-extensions

                                 ;; Productivity
                                 'lem-setup-pdf
                                 'lem-setup-elfeed

                                 ;; OS settings
                                 ;; load only if on macos
                                 (when sys-mac
                                   'lem-setup-macos)

                                 ;; Other UI/UX
                                 'lem-setup-help
                                 'lem-setup-colors
                                 'lem-setup-modeline

                                 ;; Server
                                 ;; 'lem-setup-server
                                 ))
                  (require mod nil t))))
(add-hook 'emacs-startup-hook #'lem-user-config-after-startup)

;;;;; Scratch Directory
(customize-set-variable 'lem-scratch-default-dir lem-scratch-save-dir)

;;;; User Keybindings
;; Set this to whatever you wish. All Lambda-Emacs keybinds will be available through this prefix.
(customize-set-variable 'lem-prefix "C-c C-SPC")

;;;; User Functions
;; Put any custom user functions here.

;;; Provide
(provide 'config)
;;; config.el ends here
