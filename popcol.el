(defun api-response (data)
  (json-encode-alist 
   (list (cons "params" data))))

(defun ratings-upload (httpcon)
  (api-response (elnode-http-params httpcon)))

(defun ratings-display (httpcon) 
  (json-encode-alist '(("elnode" . 10) ("restroom" . 5))))
  
;; List of the form (url function methods)
(require 'restroom)
(restroom-serve
 '(("^.*/ratings/?$" ratings-display ("GET"))
   ("^.*/ratings/\\(.*\\)" ratings-upload ("POST"))))





