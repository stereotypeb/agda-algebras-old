---
layout: default
title : Subalgebras.Univalent module (The Agda Universal Algebra Library)
date : 2021-02-20
author: William DeMeo
---

### <a id="univalent-subalgebras">Univalent Subalgebras*</a>

This section presents the [Subalgebras.Univalent][] module of the [Agda Universal Algebra Library][].

In his Type Topology library, Martín Escardó gives a nice formalization of the notion of subgroup and its properties.  In this module we merely do for algebras what Martin did for groups.


This is our first foray into univalent foundations, and our first chance to put Voevodsky's univalence axiom to work.

As one can see from the import statement that starts with `open import Overture.Preliminaries`, there are many new definitions and theorems imported from Escardó's [Type Topology][] library.  Most of these will not be discussed here.

This module can be safely skipped, or even left out of the Agda Universal Algebra Library, as it plays no role in other modules.


\begin{code}

{-# OPTIONS --without-K --exact-split --safe #-}

open import MGS-Subsingleton-Theorems using (global-dfunext)

module Subalgebras.Univalent {gfe : global-dfunext} where


open import Subalgebras.Subalgebras public
open import MGS-Subsingleton-Theorems using (Univalence)
open import MGS-Subsingleton-Theorems using (Π-is-subsingleton)

open import MGS-Embeddings using (embedding-gives-ap-is-equiv; pr₁-embedding;
 lr-implication; rl-implication; inverse; ×-is-subsingleton; _≃_; _●_;
 logically-equivalent-subsingletons-are-equivalent)



module mhe_subgroup_general {𝓦 : Level}{𝑆 : Signature 𝓞 𝓥}{𝑨 : Algebra 𝓦 𝑆}(ua : Univalence) where

 open subalgebras {𝑆 = 𝑆} public

 open import MGS-Powerset renaming (_∈_ to _∈₀_; _⊆_ to _⊆₀_; ∈-is-subsingleton to ∈₀-is-subsingleton)
  using (𝓟; equiv-to-subsingleton; powersets-are-sets'; subset-extensionality'; propext; _holds; Ω)

 op-closed : (∣ 𝑨 ∣ → Set 𝓦) → Set(𝓞 ⊔ 𝓥 ⊔ 𝓦)
 op-closed B = (f : ∣ 𝑆 ∣)(a : ∥ 𝑆 ∥ f → ∣ 𝑨 ∣) → ((i : ∥ 𝑆 ∥ f) → B (a i)) → B ((f ̂ 𝑨) a)

 subuniverse : Set(ov 𝓦)
 subuniverse = Σ B ꞉ (𝓟 ∣ 𝑨 ∣) , op-closed ( _∈₀ B)


 being-op-closed-is-subsingleton : (B : 𝓟 ∣ 𝑨 ∣) → is-subsingleton (op-closed ( _∈₀ B ))

 being-op-closed-is-subsingleton B = Π-is-subsingleton gfe
  (λ f → Π-is-subsingleton gfe
   (λ a → Π-is-subsingleton gfe
    (λ _ → ∈₀-is-subsingleton B ((f ̂ 𝑨) a))))


 pr₁-is-embedding : is-embedding ∣_∣
 pr₁-is-embedding = pr₁-embedding being-op-closed-is-subsingleton


 --so equality of subalgebras is equality of their underlying subsets in the powerset:
 ap-pr₁ : (B C : subuniverse) → B ≡ C → ∣ B ∣ ≡ ∣ C ∣
 ap-pr₁ B C = ap ∣_∣

 ap-pr₁-is-equiv : (B C : subuniverse) → is-equiv (ap-pr₁ B C)
 ap-pr₁-is-equiv = embedding-gives-ap-is-equiv ∣_∣ pr₁-is-embedding

 subuniverse-is-a-set : is-set subuniverse
 subuniverse-is-a-set B C = equiv-to-subsingleton
                            (ap-pr₁ B C , ap-pr₁-is-equiv B C)
                            (powersets-are-sets' ua ∣ B ∣ ∣ C ∣)


 subuniverse-equal-gives-membership-equiv : (B C : subuniverse)
  →                                         B ≡ C
                                            ---------------------
  →                                         (∀ x → x ∈₀ ∣ B ∣ ⇔ x ∈₀ ∣ C ∣)

 subuniverse-equal-gives-membership-equiv B C B≡C x =
  transport (λ - → x ∈₀ ∣ - ∣) B≡C , transport (λ - → x ∈₀ ∣ - ∣ ) ( B≡C ⁻¹ )


 membership-equiv-gives-carrier-equal : (B C : subuniverse)
  →                                     (∀ x →  x ∈₀ ∣ B ∣  ⇔  x ∈₀ ∣ C ∣)
                                        --------------------------------
  →                                     ∣ B ∣ ≡ ∣ C ∣

 membership-equiv-gives-carrier-equal B C φ = subset-extensionality' ua α β
  where
   α :  ∣ B ∣ ⊆₀ ∣ C ∣
   α x = lr-implication (φ x)

   β : ∣ C ∣ ⊆₀ ∣ B ∣
   β x = rl-implication (φ x)


 membership-equiv-gives-subuniverse-equality : (B C : subuniverse)
  →                                            (∀ x → x ∈₀ ∣ B ∣ ⇔ x ∈₀ ∣ C ∣)
                                               -----------------------------
  →                                            B ≡ C

 membership-equiv-gives-subuniverse-equality B C = inverse (ap-pr₁ B C)
  (ap-pr₁-is-equiv B C) ∘ (membership-equiv-gives-carrier-equal B C)


 membership-equiv-is-subsingleton : (B C : subuniverse) → is-subsingleton (∀ x → x ∈₀ ∣ B ∣ ⇔ x ∈₀ ∣ C ∣)

 membership-equiv-is-subsingleton B C = Π-is-subsingleton gfe
  (λ x → ×-is-subsingleton
   (Π-is-subsingleton gfe (λ _ → ∈₀-is-subsingleton ∣ C ∣ x ))
    (Π-is-subsingleton gfe (λ _ → ∈₀-is-subsingleton ∣ B ∣ x )))


 subuniverse-equality : (B C : subuniverse) → (B ≡ C) ≃ (∀ x → (x ∈₀ ∣ B ∣) ⇔ (x ∈₀ ∣ C ∣))

 subuniverse-equality B C = logically-equivalent-subsingletons-are-equivalent _ _
  (subuniverse-is-a-set B C) (membership-equiv-is-subsingleton B C)
   (subuniverse-equal-gives-membership-equiv B C , membership-equiv-gives-subuniverse-equality B C)


 carrier-equality-gives-membership-equiv : (B C : subuniverse)
  →                                        ∣ B ∣ ≡ ∣ C ∣
                                           -------------------------------
  →                                        (∀ x → x ∈₀ ∣ B ∣  ⇔  x ∈₀ ∣ C ∣)

 carrier-equality-gives-membership-equiv B C refl x = id , id


 --so we have...
 carrier-equiv : (B C : subuniverse) → (∀ x → x ∈₀ ∣ B ∣ ⇔ x ∈₀ ∣ C ∣) ≃ (∣ B ∣ ≡ ∣ C ∣)

 carrier-equiv B C = logically-equivalent-subsingletons-are-equivalent _ _
  (membership-equiv-is-subsingleton B C)(powersets-are-sets' ua ∣ B ∣ ∣ C ∣)
   (membership-equiv-gives-carrier-equal B C , carrier-equality-gives-membership-equiv B C)

 -- ...which yields an alternative subuniverse equality lemma.
 subuniverse-equality' : (B C : subuniverse) → (B ≡ C) ≃ (∣ B ∣ ≡ ∣ C ∣)

 subuniverse-equality' B C = (subuniverse-equality B C) ● (carrier-equiv B C)

\end{code}

---------------------------------

[← Subalgebras.Subalgebras](Subalgebras.Subalgebras.html)
<span style="float:right;">[Varieties →](Varieties.html)</span>

{% include UALib.Links.md %}

