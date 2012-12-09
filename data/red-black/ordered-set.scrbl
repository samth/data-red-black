#lang scribble/manual
@(require scribble/manual
          scribble/eval
          (for-label data/red-black/ordered-set
                     racket/base
                     racket/string))

@(define my-eval (make-base-eval))
@(my-eval '(require data/red-black/ordered-set racket/string))


@title{Ordered set}
@author+email["Danny Yoo" "dyoo@hashcollision.org"]


@defmodule[data/red-black/ordered-set]

This module provides a mutable, set-like container of totally-ordered elements.

As a quick example:

@interaction[#:eval my-eval
(require data/red-black/ordered-set)
(define s1 (new-ordered-set))
(for ([w (string-split 
          (string-append "this is a test of the emergency broadcast"
                         " system this is only a test"))])
  (ordered-set-add! s1 w))
@code:comment{Let's query for membership:}
(ordered-set-member? s1 "broadcast")
(ordered-set-member? s1 "radio")
@code:comment{The ordered set acts as a sequence:}
(for/list ([w s1]) w)
(ordered-set-remove! s1 "broadcast")
(ordered-set-member? s1 "broadcast")
]


For convenience, these ordered sets use the notion of the total-order defined
by the @racket[datum-order] function in @racketmodname[data/order].  The
@racket[new-ordered-set] constructor can take an optional @racket[#:order]
comparision function to customize how its elements compare:
@interaction[#:eval my-eval
@code:comment{order-strings-by-length: string string -> (or/c '< '= '>)}
(define (order-strings-by-length x y)
  (define xs (string-length x))
  (define ys (string-length y))
  (cond [(< xs ys) '<]
        [(= xs ys) '=]
        [(> xs ys) '>]))
(define a-set (new-ordered-set #:order order-strings-by-length))
(for ([word (string-split "we few we happy few we band of brothers")])
  (ordered-set-add! a-set word))
(ordered-set->list a-set)
]


On the implementation side: an ordered set hold onto its elements with a
red-black tree, so that most operations work in time logarithmic to the set's
@racket[ordered-set-count].


@section{API}

@defproc[(new-ordered-set [#:order order 
                                    (any/c any/c . -> . (or/c '< '= '>))
                                    datum-order])
         ordered-set/c]{
Constructs a new ordered set.  By default, this uses @racket[datum-order]
to compare its elements.
}


@defproc[(ordered-set? [x any/c]) boolean?]{
Returns true if @racket[x] is an ordered set.
}


@defthing[ordered-set/c flat-contract?]{
A flat contract for ordered sets.
}


@defproc[(ordered-set-order [a-set ordered-set/c]) (any/c any/c . -> . (or/c '< '= '>))]{
Returns the total-ordering function used by ordered set @racket[a-set].
}


@defproc[(ordered-set-empty? [a-set ordered-set/c]) boolean?]{
Returns true if the ordered set @racket[a-set] is empty.
}


@defproc[(ordered-set-count [a-set ordered-set/c]) natural-number/c]{
Returns the number of elements in the ordered set @racket[a-set].
}


@defproc[(ordered-set-member? [a-set ordered-set/c] [x any/c]) boolean?]{
Returns true if @racket[x] is an elements in ordered set @racket[a-set].
}


@defproc[(ordered-set-add! [a-set ordered-set/c] [x any/c]) void?]{
Adds @racket[x] into ordered set @racket[a-set].  If @racket[x] is already
an element, this has no effect.
}


@defproc[(ordered-set-remove! [a-set ordered-set/c] [x any/c]) void?]{
Removes @racket[x] from ordered set @racket[a-set].  If @racket[x] is not
an element of @racket[a-set], this has no effect.
}

@defproc[(ordered-set->list [a-set ordered-set/c]) list?]{
Returns the elements of ordered set @racket[a-set] as a list, where
the elements are sorted according to @racket[a-set]'s total-order.
}