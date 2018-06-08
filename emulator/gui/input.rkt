#lang racket/base

(provide
  (except-out (struct-out input) input)
  (rename-out [make-input input]))

(require
  racket/list
  racket/match
  racket/contract/base
  charterm
  "private/base.rkt"
  "../../utils.rkt")

(define input-mode/c (symbols 'str 'dec 'hex 'bin))

(struct input element (label mode length [value #:mutable])
  #:methods gen:displayable
  [(define (display area displayable)
     (apply charterm-cursor (map add1 (area-top-left area)))
     (charterm-display (or (input-label displayable) ""))
     (when (input-value displayable)
       (define len (input-length displayable))
       (define value (format-input-value (input-mode displayable)
                                         (input-value displayable)
                                         len))
       (charterm-underline)
       (apply charterm-cursor (match (area-top-right area)
                                [(list x y)
                                 (list (+ 2 (- x (string-length value)))
                                       (+ 1 y))]))
       (charterm-display value)
       (charterm-normal)))])

(define (make-input #:name [name #f]
                    #:show? [show? #t]
                    #:label [label #f]
                    #:mode [mode 'str]
                    #:length [length 8]
                    [value #f])
  (input name show? label mode length value))

(define (format-input-value mode value len)
  (cond
    [(eq? mode 'str) (substring value 0 (min (string-length value) len))]
    [(eq? mode 'dec) (format-dec value #:min-width len)]
    [(eq? mode 'hex) (format-hex value #:min-width len)]
    [(eq? mode 'bin) (format-bin value #:min-width len)]
    [else ""]))