;;; rk-org-jira-url.el --- Utilities for creating JIRA URLs.  -*- lexical-binding: t; -*-

;; Copyright (C) 2018 Raghuvir Kasturi

;; Author: Raghuvir Kasturi <raghuvir.kasturi@gmail.com>

;;; Commentary:

;;; Code:

(autoload 'org-insert-link "org")
(autoload 'ivy-read "ivy")

(defconst rk-org--jira-base-url-template
  "https://moviohq.atlassian.net/browse/%s"
  "Base URL for work JIRA.")

(defconst rk-org--jira-project-alist
  '(("Green" . "GREEN")
    ("Support" . "MCSUP")
    ("Blue" . "BLUE")
    ("Yellow" . "YE")
    ("Cinema" . "MC"))
  "Map of project names to abbreviated tags.")

(defun rk-org--create-jira-url (ticket project)
  "Create a URL for TICKET, scoped to the Green project by default, unless PROJECT is specified."
  (interactive (let ((ticket (read-string "Ticket number: " nil))
                     (project (ivy-read "Project: " '("Green" "Support" "Red" "Blue" "Yellow" "Cinema")
                                        :predicate nil
                                        :require-match t)))
                 (list ticket project)))
  (let* ((project-tag (cdr (assoc project rk-org--jira-project-alist)))
         (ticket-and-project (format "%s-%s" project-tag ticket)))
    (org-insert-link nil (format rk-org--jira-base-url-template ticket-and-project) nil)))

(provide 'rk-org-jira-url)

;;; rk-org-jira-url.el ends here
