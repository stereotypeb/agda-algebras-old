---
layout: default
title : Algebras.Basic module (Agda Universal Algebra Library)
date : 2021-04-23
author: [agda-algebras development team][]
---

### <a id="algebras">Basic Definitions</a>

This is the [Algebras.Basic][] module of the [Agda Universal Algebra Library][].

\begin{code}

{-# OPTIONS --without-K --exact-split --safe #-}

open import Algebras.Basic using (𝓞 ; 𝓥 ; Signature )

module Algebras.Setoid {𝑆 : Signature 𝓞 𝓥} where

-- Imports from the Agda (Builtin) and the Agda Standard Library
open import Agda.Builtin.Equality  using    ( _≡_    ;  refl          )
open import Agda.Primitive         using    ( _⊔_    ;  lsuc          )
                                   renaming ( Set    to Type          )
open import Data.Product           using    ( _,_    ;  _×_
                                            ; Σ      ;  Σ-syntax      )
open import Function               using    ( _∘_                     )
open import Function.Base          using    ( flip                    )
open import Function.Bundles       using    ( Func                    )
open import Level                  using    ( Level  ;  Lift          )
open import Relation.Binary        using    ( Setoid ;  IsEquivalence )
open import Relation.Unary         using    ( Pred  ; _∈_             )

-- -- Imports from the Agda Universal Algebra Library
open import Overture.Preliminaries using ( ∥_∥ ; ∣_∣ )

private variable
 α ρ ι : Level

\end{code}

#### Models (again)

Here we define algebras over a setoid, instead of a mere type with no equivalence on it.

(This approach is inspired by the one taken, e.g., by Andreas Abel in his formalization Birkhoff's completeness theorem; see http://www.cse.chalmers.se/~abela/agda/MultiSortedAlgebra.pdf.)

First we define an operator that translates an ordinary signature into a signature over a setoid domain.

\begin{code}

open Setoid using    (_≈_ ; Carrier )
            renaming ( refl  to reflS
                     ; sym   to symS
                     ; trans to transS
                     ; isEquivalence to isEqv )
open Func renaming   ( f to _<$>_ )

⟦_⟧s : Signature 𝓞 𝓥 → Setoid α ρ → Setoid _ _

Carrier (⟦ 𝑆 ⟧s ξ) = Σ[ f ∈ ∣ 𝑆 ∣ ] ((∥ 𝑆 ∥ f) → ξ .Carrier)
_≈_ (⟦ 𝑆 ⟧s ξ) (f , u) (g , v) = Σ[ eqv ∈ f ≡ g ] EqArgs eqv u v
 where
 EqArgs : f ≡ g → (∥ 𝑆 ∥ f → Carrier ξ) → (∥ 𝑆 ∥ g → Carrier ξ) → Type _
 EqArgs refl u v = ∀ i → (_≈_ ξ) (u i) (v i)

IsEquivalence.refl  (isEqv (⟦ 𝑆 ⟧s ξ))                     = refl , λ _ → reflS  ξ
IsEquivalence.sym   (isEqv (⟦ 𝑆 ⟧s ξ))(refl , g)           = refl , λ i → symS   ξ (g i)
IsEquivalence.trans (isEqv (⟦ 𝑆 ⟧s ξ))(refl , g)(refl , h) = refl , λ i → transS ξ (g i) (h i)

\end{code}


##### Setoid Algebras

A setoid algebra is just like an algebra but we require that all basic operations of the algebra respect the underlying setoid equality.
The `Func` record packs a function (f, aka apply, aka _<$>_) with a proof (cong) that the function respects equality.

\begin{code}

Algebroid : (α ρ : Level) → Type (𝓞 ⊔ 𝓥 ⊔ lsuc (α ⊔ ρ))
Algebroid α ρ = Σ[ A ∈ Setoid α ρ ]      -- the domain (a setoid)
                 Func (⟦ 𝑆 ⟧s A) A       -- the basic operations,
                                         -- along with congruence proofs that
                                         -- each operation espects setoid equality

record SetoidAlgebra α ρ : Type (𝓞 ⊔ 𝓥 ⊔ lsuc (α ⊔ ρ)) where
  field
    Domain : Setoid α ρ
    Interp : Func (⟦ 𝑆 ⟧s Domain) Domain
     --      ^^^^^^^^^^^^^^^^^^^^^^^ is a record type with two fields:
     --       1. a function  f : Carrier (⟦ 𝑆 ⟧s Domain)  → Carrier Domain
     --       2. a proof cong : f Preserves _≈₁_ ⟶ _≈₂_ (that f preserves the setoid equalities)


open SetoidAlgebra

-- Forgetful Functor
𝕌[_] : SetoidAlgebra α ρ →  Type α
𝕌[ 𝑨 ] = Carrier (Domain 𝑨)

𝔻[_] : SetoidAlgebra α ρ →  Setoid α ρ
𝔻[ 𝑨 ] = Domain 𝑨


-- Easier notation for application of an (interpreted) operation symbol.

_∙_ : (f : ∣ 𝑆 ∣)(𝑨 : Algebroid α ρ) → (∥ 𝑆 ∥ f  →  Carrier ∣ 𝑨 ∣) → Carrier ∣ 𝑨 ∣

f ∙ 𝑨 = λ a → ∥ 𝑨 ∥ <$> (f , a)

open SetoidAlgebra

_̂_ : (f : ∣ 𝑆 ∣)(𝑨 : SetoidAlgebra α ρ) → (∥ 𝑆 ∥ f  →  𝕌[ 𝑨 ]) → 𝕌[ 𝑨 ]

f ̂ 𝑨 = λ a → (Interp 𝑨) <$> (f , a)

\end{code}

\end{code}

#### Level lifting setoid algebra types

\begin{code}

open Level
Lift-SetoidAlg : SetoidAlgebra α ρ → (β : Level) → SetoidAlgebra (α ⊔ β) ρ
Domain (Lift-SetoidAlg 𝑨 β) =
 record { Carrier = Lift β 𝕌[ 𝑨 ]
        ; _≈_ = λ x y → (Domain 𝑨 ≈ (lower x))(lower y)
        ; isEquivalence =
           record { refl = reflS (Domain 𝑨)
                  ; sym = symS (Domain 𝑨)
                  ; trans = transS (Domain 𝑨)
                  }
        }
(Interp (Lift-SetoidAlg 𝑨 β)) <$> (f , la) = lift ((f ̂ 𝑨) (lower ∘ la))
cong (Interp (Lift-SetoidAlg 𝑨 β)) {(f , la)} {(.f , lb)} (refl , la=lb) = cong (Interp 𝑨) ((refl , la=lb))


\end{code}

What makes the `Lift-Alg` type so useful for resolving type level errors
involving algebras is the nice properties it possesses.  Indeed, the
[UniversalAlgebra][] library contains formal proofs of the following facts.

+ [`Lift-Alg` is a homomorphism](Homomorphisms.Basic.html#exmples-of-homomorphisms)
 (see [Homomorphisms.Basic][]) 

+ [`Lift-Alg` is an algebraic invariant](Homomorphisms.Isomorphisms.html#lift-is-an-algebraic-invariant")
  (see [Homomorphisms.Isomorphisms][])

+ [`Lift-Alg` of a subalgebra is a subalgebra](Subalgebras.Subalgebras.html#lifts-of-subalgebras)
  (see [Subalgebras.Subalgebras][])

+ [`Lift-Alg` preserves identities](Varieties.EquationalLogic.html#lift-invariance))
  (see [Varieties.EquationalLogic][])





--------------------------------

[agda-algebras development team]: https://github.com/ualib/agda-algebras#the-agda-algebras-development-team
