;;;
;;; /path/to/lispworks-7-1-0-x86-win32.exe -init lw-build-image.lisp -
;;;
(require "asdf")

(load (merge-pathnames ".vim/bundle/slimv/slime/swank-loader.lisp"
                       #+(or windows mswindows os-windows win32)
                       #P"Z:/hmj/"
                       #+unix
                       (user-homedir-pathname)
                       ))

;; Equivalent to (swank-loader::loadup)
(swank-loader:init :load-contribs t :setup nil)

(defun start-swank-server ()

  (setf swank-loader:*source-directory* nil)

  (mp:process-run-function
    "Start Swank Server"
    nil
    #'(lambda ()
        (swank:create-server
          :interface "0.0.0.0"
          :port 4005
          :dont-close t))))
(push '("Start Swank Server" nil start-swank-server)
      mp:*initial-processes*)

(load-all-patches)

(save-image "lw-dev"
            :console t
            :multiprocessing t
            :environment nil
            )

(lw:quit)
