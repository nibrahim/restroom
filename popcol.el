(defun api-response (data)
  (json-encode-alist 
   (list (cons "params" data))))

(defun extract-param (key alist)
  (and (assoc key alist)
       (cdr (assoc key alist))))

(defun verify-params (params)
  (let ((userhash (extract-param "userhash" params))
        (package (extract-param "package" params))
        (rating (extract-param "rating" params)))
    (if (and (and userhash (string-match "^[a-f0-9]\\\{40\\\}$"  userhash))
             (and package (string-match "^[0-9a-z_-]+$" package))
             (and rating (string-match "^[0-9]\\\{1,2\\\}$" rating)))
        (list userhash package rating))))


(defun save-stats (userhash package rating)
  
  (json-encode-alist (list (cons "userhash" userhash)
                           (cons "package" package)
                           (cons "rating" rating))))


(defun ratings-upload (httpcon)
  (let ((params (elnode-http-params httpcon)))
    (let (
          (args (verify-params params))
          )
      (if args
          (destructuring-bind
              (userhash package rating)
              args
            (save-stats userhash package rating))
        (json-encode-alist (list (cons "message" "Parameter error")))))))


(defun ratings-display (httpcon) 
  (json-encode-alist '(("elnode" . 10) ("restroom" . 5))))
  
;; List of the form (url function methods)
(require 'restroom)
(restroom-serve
 '(("^.*/ratings/?$" ratings-display ("GET"))
   ("^.*/ratings/\\(.*\\)" ratings-upload ("POST"))))





