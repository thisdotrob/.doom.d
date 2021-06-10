;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Bobby Stevenson"
      user-mail-address "this.rob@protonmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Set flycheck to run eslint checker after lsp checker
;; https://github.com/hlissner/doom-emacs/issues/1530#issuecomment-725588733
(add-hook! 'lsp-after-initialize-hook
  (run-hooks (intern (format "%s-lsp-hook" major-mode))))
(defun js-flycheck-setup ()
  (flycheck-add-next-checker 'lsp 'javascript-eslint))
(add-hook 'typescript-mode-lsp-hook
          #'js-flycheck-setup)
(add-hook 'rjsx-mode-lsp-hook
          #'js-flycheck-setup)

;; Disable lsp formatting, so it uses eslint/prettier instead
;; https://github.com/hlissner/doom-emacs/issues/4158#issuecomment-731573313
(setq-hook! 'typescript-mode-hook +format-with-lsp nil)
(setq-hook! 'rjsx-mode-hook +format-with-lsp nil)

;; Disable lsp warnings about converting CommonJS imports to ES6
;; https://discord.com/channels/406534637242810369/406554085794381833/839797232038445056
(after! lsp-mode
  (lsp-defun my/filter-typescript ((params &as &PublishDiagnosticsParams :diagnostics)
                                 _workspace)
  (lsp:set-publish-diagnostics-params-diagnostics
   params
   (or (seq-filter (-lambda ((&Diagnostic :message))
                     (not (s-contains? "File is a CommonJS module" message)))

                   diagnostics)
       []))
    params)

  (setq lsp-diagnostic-filter 'my/filter-typescript))
