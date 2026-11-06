;;;
;;; /path/to/lispworks-7-1-0-x86-win32.exe -siteinit - -init lw-build-image.lisp -
;;;
(require "describe")
(require "asdf")

(load (merge-pathnames ".vim/bundle/slimv/slime/swank-loader.lisp"
                       #+(or windows mswindows os-windows win32) #P"Z:/hmj/"
                       #+unix (user-homedir-pathname)
                       ))

;; Equivalent to (swank-loader::loadup)
(swank-loader:init :load-contribs t :setup nil)

(setf swank-loader:*source-directory* nil)

(defun start-swank-server ()
  (swank:create-server
    :interface "0.0.0.0"
    :port 4005
    :dont-close t))

(defun main ()
  (let ((args system:*line-arguments-list*))
    (if (member "-w" args :test #'string=)
        (start-swank-server)
        (loop (sleep 60))
    )))

(push '("Main" nil main)
      mp:*initial-processes*)    

(load-all-patches)

(save-image "lw-dev"
            :console t
            :multiprocessing t
            :environment nil
            )

(lw:quit)
