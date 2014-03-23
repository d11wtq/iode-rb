;; Recursive let binding support.
(def let
 (macro (bindings body)
   (def body*
    (func (bindings body)
     (if (empty? bindings)
       body
       (body* (tail bindings)
             (cons
              (cons (quote def)
                    (head bindings))
              body)))))
   (list
    (quote apply)
    (list (quote func)
          (list)
          (cons (quote progn)
                (body* bindings (list body))))
    (list))))

;; This is the one place we can't depend on things like `export`, since just
;; about everything depends on `let`.
{'let let}
