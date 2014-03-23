;; Export listed symbols from this module
(def export
 (func (symbols)
   (fold (func (acc s)
           (assoc acc s (eval s)))
         (hashmap)
         symbols)))

;; Import exported symbols from module to this namespace
(def import
 (macro (file)
   (let ((symbols (require file))
         (defns (list)))
     (cons (quote progn)
           (fold (func (acc kv)
                   (cons (list (quote def) (head kv) (head (tail kv)))
                         defns))
           defns
           symbols)))))

(export '(export import))
