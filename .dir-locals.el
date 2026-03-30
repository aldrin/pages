((org-mode
  . ((eval . (setq-local compile-command
                         (let ((base (file-name-base buffer-file-name)))
                           (concat "make " base ".pdf " base ".html")))))))
