((org-mode
  . ((eval . (setq-local compile-command
                         (concat "make "
                                 (file-name-base buffer-file-name)
                                 ".pdf"))))))
