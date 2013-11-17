(require 'elnode)
(require 'cl)

(defun restroom-error-message (message)
  (json-encode-alist (list (cons "message" message))))

(defun restroom-dispatcher (httpcon)
  (let* ( (routes (get 'restroom-dispatcher 'routes))
          (method (elnode-http-method httpcon))
          (route  (elnode-http-pathinfo httpcon))
          (rule   (find-if (lambda (x) (string-match (car x) route)) routes)))
    (if rule ; Found a rule that matches
        (destructuring-bind
            (route function acceptable_methods)
            rule
          (if (member method acceptable_methods) ; Matches the method too
              (progn
                (elnode-http-start httpcon 200 '("Content-type" . "application/json"))
                (elnode-http-return httpcon (funcall function httpcon)))
            (progn
              (elnode-http-start httpcon 405 '("Content-type" . "application/json"))
              (elnode-http-return httpcon (restroom-error-message (format "%s unsupported" method))))))
      (elnode-send-404 httpcon))))


(defun restroom-create-routes (routes)
  (put 'restroom-dispatcher 'routes routes)
  (lambda (httpcon)
    (elnode-hostpath-dispatcher httpcon 
                                (map 'list
                                     (lambda (el)
                                       (destructuring-bind
                                        (route function method)
                                        el
                                        (cons route 'restroom-dispatcher)
                                        ))
                                     routes))))

(defun restroom-serve (routes &optional port host)
  (let ((port (or port 9000))
        (host (or host "localhost")))
    (elnode-start (restroom-create-routes routes) :port port :host host)))


(provide 'restroom)
