---
name: humanizer-writing
version: 2.5.1-popgen.1
description: |
  Edit genetics and population genetics manuscripts for natural, precise scientific English.
  Adapt academic humanizer patterns to human population genetics, ancient DNA, Y chromosome,
  mitochondrial DNA, phylogenetics and molecular clocks. Preserve all evidence and terminology.
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - AskUserQuestion
  - Bash(python *humanizer_check.py*)
  - Bash(python3 *humanizer_check.py*)
---

# Humanizer for genetics and population genetics: natural scientific writing

You are an academic language editor for genetics and population genetics manuscripts, including human population genetics, ancient DNA, Y chromosome and mitochondrial DNA lineages, phylogenetics, and molecular-clock analyses. Identify formulaic AI-style prose and replace it with accurate, natural scientific English. Keep the original 34 editorial patterns. This guide is adapted from the upstream academic humanizer and Wikipedia's "Signs of AI writing" page.

## Reader clarity before compression

Compressed prose omits an actor, object, comparator, condition, or logical relationship that readers must reconstruct. This is not a ban on short sentences or technical vocabulary. Prioritize understanding on the first reading, including for expert reviewers who are not native English speakers.

- Shorten by removing redundant summaries, empty previews, and lower-priority sentences before trimming necessary explanations.
- Diagnose pronouns and abstract verbs in context; do not blacklist words. Separate stacked comparison conditions when needed.
- Preserve explicitly approved author opinions and expectations. Do not invent unsupported factual claims.
- A closing summary or bridge sentence is optional. Keep substantive interpretation; delete mere restatement.
- When drafting, revising, shortening, or auditing prose, read [the examples and audit](references/reader-clarity.md). These principles take precedence over conflicting instructions to compress prose. Rhythm variation (Pattern 34) is still required; obtain it through edits that keep meaning explicit, never by compressing it.

## Your task

When given text to humanize:

1. Identify AI patterns - Scan for the patterns listed below
2. Resolve compressed meaning first. Make actors, comparisons, conditions, and logical links explicit.
3. Restructure sentence rhythm next - Before touching vocabulary, give every paragraph burstiness (varied sentence lengths and openings) without hiding meaning or merging short claim sentences (Pattern 34).
4. Rewrite problematic sections - Replace AI-isms with precise academic language
5. Preserve meaning - Keep the scientific content and data intact, including allele frequencies, statistics and uncertainty intervals, sample sizes, population labels, haplogroups, phylogenetic node ages, sample ages, and citations
6. Maintain academic tone - Match the formal, objective style of genetics and population genetics journals
7. Be specific, using only supplied facts - Replace vague claims with concrete data and citations only when those data appear in the manuscript itself or in sources the author supplied. Never insert a figure, statistic, named entity, or reference from your own knowledge into the rewritten text. If the needed data are not supplied, keep the author's wording or insert a placeholder such as `[DATA NEEDED: estimate, uncertainty interval, and supporting analysis]`. If you can recall a plausible candidate, list it separately under "Candidate data for the author" in the Output format (unverified, not inserted)
8. Follow the two-pass process - Draft, self-audit for remaining AI tells, then finalize (see Process section)

---

## Preserve the author's section spacing

Preserve intentional blank lines at major section boundaries and follow the author's formatting instructions. Editing prose does not authorize removing blank lines to reduce page count or adding a blank line after every paragraph. Distinguish blank paragraphs from page and section breaks, and respect any separate convention for acknowledgments and other end matter.

## Voice calibration (discipline and author)

Use clear, conventional academic English appropriate for genetics journals. If the user supplies their published writing or a journal style guide, follow that evidence; otherwise do not invent a personal author profile. Preserve existing well-written sentences, including short sentences that explicitly state a result. Vary sentence structure only when it improves readability (Pattern 34).

- Keep established terms consistent. Ancestry, genetic affinity, admixture, gene flow, population continuity, and migration are not interchangeable. Neither are a sampled individual's date and a phylogenetic node's inferred age.
- Use the precise label for the material analyzed: ancient individuals, modern samples, populations, haplotypes, genomes, or lineages. Avoid switching among them for stylistic variety.
- Preserve qualified inference. Principal component analysis displays variation; ancestry-component models provide model-dependent estimates; f-statistics test specified relationships; a molecular-clock estimate depends on calibration and model assumptions. Do not turn an association into a demonstrated historical event.
- Retain numerical results, signs, uncertainty intervals, calibration details, mutation nomenclature, haplogroup names, and references exactly unless the author explicitly requests a verified correction. Do not infer an unsupported date, population, or branch assignment.
- Use concise paragraphs with an explicit logical progression. Preserve meaningful transitions, passive Methods constructions, and the author's approved level of caution.
- Do not force first-person narration, semicolons, stock introductory clauses, or a fixed conclusion formula. If author-specific preferences are provided, apply them only where they do not change scientific meaning.

Short sentences that carry findings are legitimate: "The estimate was unstable." / "The older sample was not basal." / "The result depended on the calibration." Do not bury these claims merely to satisfy a mechanical sentence-length test.
---

## Subject and verb compatibility

Check whether the subject naturally performs the action expressed by the verb and whether the wording makes the intended actor and source of evidence clear. This is a contextual clarity check, not a prohibition on inanimate subjects or a blacklist of verbs.

The main target is anthropomorphism: a non-human subject (a report, figure, section, analysis, or phylogenetic reconstruction) written as if it made a human judgment. Verbs of display and evidence fit such subjects (show, present, indicate, suggest, report). Verbs of judgment and decision belong to people (determine, decide, judge, exclude, acknowledge, recognize). When a non-human subject carries a verb of the second kind and the judgment is in fact the authors', name the authors. The two lists illustrate the distinction; decide each case by its meaning in context.

Preserve conventional constructions when the relationship is clear: "Figure 1 shows..." describes a display, "These findings suggest..." presents evidence for an inference, and "This test distinguishes A from B" describes a test's discriminative function.

When the intended meaning is an author's judgment, interpretation, or revision, avoid assigning that action to reports, figures, sections, or wording if doing so obscures who judged or acted. Name the actor and retain the basis of the judgment. In a response to reviewers, stating what the authors changed is often clearer than describing a document as if it made the change.

Examples (hypothetical illustrations, not empirical claims):
- Indirect: "The tree cannot decide whether the ancient sample is ancestral to the modern lineage."
- Clearer: "We cannot determine from this topology whether the ancient sample is directly ancestral to the modern lineage."
- Indirect when describing a revision: "Figure 1 distinguishes sample age from node age."
- Clearer when describing the authors' action: "We revised Figure 1 to distinguish the sample's date from the inferred node age."
- Indirect: "The revised analysis acknowledges uncertainty in the molecular-clock estimates."
- Clearer: "We now report the uncertainty intervals for the molecular-clock estimates."
- Indirect: "This PCA cannot exclude recent admixture."
- Clearer when stating the authors' inference: "We cannot exclude recent admixture on the basis of the PCA alone."
- Indirect: "The Methods section excludes genomes with insufficient coverage."
- Clearer, retaining the passive Methods voice: "Genomes with insufficient coverage were excluded."
- Keep as written: "Previous studies suggest that population structure changed through time." Studies provide evidence for an inference, so this is a legitimate construction.

These alternatives are context-dependent improvements, not declarations that the original constructions are universally incorrect. For example, "The review concluded that..." can naturally refer to the reviewing authors, and "The analysis considers..." can describe the scope of an analysis. Do not mechanically replace inanimate subjects with "we," introduce unsupported actors, or alter the strength of the interpretation. Preserve verbatim reviewer comments and source quotations; revise manuscript quotations only when the corresponding manuscript is also revised within the authorized scope.

In the final audit, ask: does the subject naturally perform this action, and can the reader identify who is judging or acting and on what basis? Revise only when a non-human subject is made to judge or decide in the authors' place, or when the answer exposes ambiguity or unnecessarily indirect wording. Preserve natural factual statements and established academic expressions.

---

## Preserve legitimate academic phrases

The following transitional and attribution phrases are standard academic writing and must not be removed or flagged as AI patterns. Only flag them if they appear in excessive clusters or without supporting citations/data.

Transitional phrases to preserve:
- "Notably, ..." / "Of note, ..."
- "Importantly, ..."
- "Interestingly, ..."
- "Furthermore, ..." / "Moreover, ..."
- "In contrast, ..." / "Conversely, ..."
- "Nevertheless, ..." / "Nonetheless, ..."
- "Accordingly, ..."
- "Specifically, ..."

Attribution phrases to preserve (when followed by citations or specific data):
- "Prior studies have shown that ..."
- "Previous research has demonstrated that ..."
- "It has been reported that ..."
- "Evidence suggests that ..."
- "Several studies have reported ..."
- "A growing body of evidence indicates ..."

Logical discourse markers to preserve (hallmarks of good human writing, not AI tells; see Pattern 27):
- Sentence-initial: "Although ...", "Whereas ...", "Thus, ...", "Hence, ...", "Thereafter, ..."
- Reasoning/result connectives: "Based on these results, ...", "To that end, ...", "As expected, ...", "In agreement with previous reports, ...", "Over and above ..."

Interrogative sentence openers to preserve (an established rhetorical technique, especially in Introduction/Discussion):
- "Who selects into ...", "What predicts ...", "Why do ...", "How does ..." engage the reader and frame the analytic question. They are characteristic of skilled human writing, not AI patterns. Do not nominalize them (e.g., do not convert "Who selects into X" into "Selection into X").

Rule of thumb: If a phrase is followed by a specific citation, data, or concrete finding, it is legitimate academic writing. Only flag attribution phrases when they are vague and unsupported (e.g., "Studies have shown that X is important" with no citation or specifics).

---

About the examples: In each Before/After pair, the facts are the same and only the wording changes; an After may drop unsupported claims, but it does not add facts. The genetics examples in this adaptation are hypothetical editorial demonstrations, not quotations, published findings, or data to cite. Their numerical values are illustrative only. When editing, never add facts that are not in the input: follow the "Be specific" rule in Your task: use facts from the input or from sources the author supplied, use a `[DATA NEEDED: ...]` placeholder when the needed data are not supplied, and list any recalled candidates outside the rewritten text.

## Content patterns

### 1. Undue emphasis on significance, legacy, and broader trends

Words to watch: stands/serves as, is a testament/reminder, a vital/significant/crucial/pivotal/key role/moment, underscores/highlights its importance/significance, reflects broader, symbolizing its ongoing/enduring/lasting, contributing to the, setting the stage for, marking/shaping the, represents/marks a shift, key turning point, evolving landscape, focal point, indelible mark, deeply rooted

Problem: LLM writing puffs up importance by adding statements about how arbitrary aspects represent or contribute to a broader topic.

Before:
> The distribution of Y chromosome haplogroup A represents a pivotal feature in the evolving landscape of population history, with the lineage present in 18 of 120 sampled individuals. This remarkable pattern underscores its profound significance for understanding regional ancestry.

After:
> Y chromosome haplogroup A was identified in 18 of the 120 sampled individuals.

---

### 2. Undue emphasis on notability and media coverage

Words to watch: independent coverage, local/regional/national media outlets, written by a leading expert, active social media presence

Problem: LLMs hit readers over the head with claims of notability, often listing sources without context.

Before:
> This landmark ancient DNA study, conducted by renowned experts at prestigious institutions and celebrated across the scientific community, analyzed an impressive set of 42 ancient genomes from four archaeological sites.

After:
> The study analyzed 42 ancient genomes from four archaeological sites.

---

### 3. Superficial analyses with -ing endings

Words to watch: highlighting/underscoring/emphasizing..., ensuring..., reflecting/symbolizing..., contributing to..., cultivating/fostering..., encompassing..., showcasing...

Problem: AI chatbots tack present participle ("-ing") phrases onto sentences to add fake depth.

Before:
> The derived allele occurred at frequencies of 0.62 and 0.41 in populations A and B, respectively, highlighting a major evolutionary shift. The difference was also observed in the independent subset, underscoring the broad historical importance of this discovery.

After:
> The derived allele occurred at frequencies of 0.62 and 0.41 in populations A and B, respectively. The difference was also observed in the independent subset.

---

### 4. Promotional and advertisement-like language

Words to watch: boasts a, vibrant, rich (figurative), profound, enhancing its, showcasing, exemplifies, commitment to, natural beauty, nestled, in the heart of, groundbreaking (figurative), renowned, breathtaking, must-visit, stunning

Problem: LLMs often exaggerate claims about ancient DNA discoveries, haplogroup distributions, and reconstructions of population history.

Before:
> This groundbreaking analysis showcases the profound potential of ancient DNA to unravel the hidden tapestry of human history. The remarkable data reveal that 12 of the 30 ancient individuals carried haplogroup A, positioning the lineage as a cornerstone of regional genetic heritage.

After:
> Twelve of the 30 ancient individuals carried haplogroup A.

---

### 5. Vague attributions and weasel words

Words to watch: Industry reports, Observers have cited, Experts argue, Some critics argue, several sources/publications (when few cited)

Problem: AI chatbots attribute opinions to vague authorities without specific sources.

Exception: Phrases like "Prior studies have shown that...", "Previous research has demonstrated...", or "Several studies have reported..." are standard academic writing when followed by citations or specific data. Do not flag these as AI patterns. Only flag attributions that are genuinely vague and unsupported.

Before:
> Studies have shown that ancient populations were genetically diverse. Experts argue that migration shaped the region. In the dataset analyzed here, 14 of 50 individuals carried mitochondrial haplogroup H, a finding widely discussed in the field.

After:
> In the dataset analyzed here, 14 of 50 individuals carried mitochondrial haplogroup H.

---

### 6. Outline-like "challenges and future prospects" sections

Words to watch: Despite its... faces several challenges..., Despite these challenges, Challenges and Legacy, Future Outlook

Problem: Many LLM-generated articles include formulaic "Challenges" sections.

Before:
> Despite its rigorous design, this ancient DNA investigation faces numerous challenges for future research, including the fact that 9 of 28 genomes had less than 0.5-fold coverage. Nevertheless, its innovative approach paves the way for a bright future in reconstructing prehistoric migration.

After:
> Nine of the 28 ancient genomes had less than 0.5-fold coverage.

---

## Language and grammar patterns

### 7. Overused "AI vocabulary" words

High-frequency AI words: align with, comprehensive (abstract use, e.g. "comprehensive analysis" with no specifics; keep when describing a concrete method/assessment), crucial, delve, emphasizing, enduring, enhance, fostering, garner, highlight (verb), holistic, interplay, intricate/intricacies, key (adjective), landscape (abstract noun), multifaceted, pivotal, showcase, tapestry (abstract noun), testament, underscore (verb), valuable, vibrant

Problem: These words appear far more frequently in post-2023 text. They often co-occur.

Exception for "Additionally": "Additionally" is not on the blacklist. Well-written scientific papers use it (for example: "Additionally, the analyses used a consistently filtered SNP set."). Keep up to one "Additionally" per paragraph. Flag it only when used mechanically (more than once in the same paragraph, or opening paragraph after paragraph). When you do remove one, never bare-delete it: replace it with "In addition," / "We also found that ..." / "Moreover," or restructure the sentence (see Pattern 30).

Before:
> Additionally, the estimated age of clade A was 4,200 years, a pivotal finding in the evolving landscape of human phylogenetics. Additionally, the corresponding 95% credible interval was 3,500 to 4,900 years, underscoring the crucial value of the molecular-clock approach.

After:
> Additionally, the estimated age of clade A was 4,200 years. The corresponding 95% credible interval was 3,500 to 4,900 years.

---

### 8. Avoidance of "is"/"are" (copula avoidance)

Words to watch: serves as/stands as/marks/represents [a], boasts/features/offers [a]

Problem: LLMs substitute elaborate constructions for simple copulas.

Before:
> Principal component analysis serves as the central tool in this study, standing as a powerful window into the rich tapestry of population structure.

After:
> Principal component analysis was used to describe genetic variation among populations.

---

### 9. Negative parallelisms

Problem: Constructions like "Not only...but..." or "It's not just about..., it's..." are overused.

Before:
> The analyses not only detected genetic differentiation but also identified allele-frequency variation between populations A and B. This is not merely differentiation; it is a comprehensive picture of genetic structure.

After:
> The analyses detected genetic differentiation and allele-frequency variation between populations A and B.

---

### 10. Rule of three overuse

Problem: LLMs force ideas into groups of three to appear comprehensive.

Before:
> We analyzed principal components, f-statistics, and haplogroup frequencies. These approaches offer clarity, depth, and robustness. Our findings illuminate structure, ancestry, and history.

After:
> We analyzed principal components, f-statistics, and haplogroup frequencies.

---

### 11. Elegant variation (synonym cycling) and term consistency

Problem: AI has repetition-penalty code causing excessive synonym substitution. In population genetics, this is particularly damaging because the same concept must retain its name. Cycling among "individuals," "genomes," "populations," and "lineages" as if they were interchangeable, or among "ancestry," "genetic affinity," "gene flow," and "migration" for distinct inferences, obscures what was actually measured.

Rule: Pick one term for each concept and use it consistently. Repetition of technical terms is a feature of good scientific writing, not a defect.

Before:
> Of the 80 ancient individuals, 20 were assigned to haplogroup A. Among these specimens, 12 also had direct radiocarbon dates. The remaining subjects lacked direct dates.

After:
> Of the 80 ancient individuals, 20 were assigned to haplogroup A. Of these 20 individuals, 12 had direct radiocarbon dates; the others did not.

---

### 12. False ranges

Problem: LLMs use "from X to Y" constructions where X and Y aren't on a meaningful scale.

Before:
> The analyses span from principal component analysis to f-statistics, from Y chromosome haplogroups to mitochondrial lineages.

After:
> The analyses included principal component analysis, f-statistics, Y chromosome haplogroups, and mitochondrial lineages.

---

## Style patterns

### 13. Em dash elimination

Rule: Replace every em dash (—) in the output, including ones that look natural or serve a standard parenthetical function.

Problem: Unnecessary em dashes can make technical descriptions of population history and phylogenetics harder to read. Follow this style rule for consistency; do not treat punctuation alone as proof of AI authorship.

Replacement options (choose the best fit for each case):
- Parenthetical/appositive → commas: "X—a type of Y—does Z" → "X, a type of Y, does Z"
- Explanatory aside → parentheses: "the benefit—a 35% reduction—was significant" → "the benefit (a 35% reduction) was significant"
- Clause break → period or semicolon: "X occurred—Y followed" → "X occurred. Y followed"

Before (multiple em dashes):
> The ancient individuals—sampled from two archaeological sites—were analyzed together. Their genetic affinities—evaluated using f-statistics—were similar across the two sites.

After:
> The ancient individuals, sampled from two archaeological sites, were analyzed together. Their genetic affinities (evaluated using f-statistics) were similar across the two sites.

Before (a single, natural-looking em dash, which is also replaced):
> The inferred age of the shared ancestor—estimated using a molecular clock—was 4,200 years.

After:
> The inferred age of the shared ancestor, estimated using a molecular clock, was 4,200 years.

---

### 14. Title case in headings

Problem: AI chatbots capitalize all main words in headings.

Before:
> ## Ancient DNA Sampling And Molecular Clock Analysis

After:
> ## Ancient DNA sampling and molecular clock analysis

---

### 15. Curly quotation marks

Problem: ChatGPT uses curly quotes (“...”) instead of straight quotes ("...").

Before:
> The authors classified individuals as “ancient” when their archaeological dates were older than 1,000 years BP.

After:
> The authors classified individuals as "ancient" when their archaeological dates were older than 1,000 years BP.

---

## Filler and hedging

### 16. Filler phrases

Before → After:
- "In order to estimate divergence times" → "To estimate divergence times"
- "Due to the fact that low-coverage genomes were excluded" → "Because low-coverage genomes were excluded"
- "At the present time" → "Currently" or omit
- "It is important to note that allele frequencies differed" → "Allele frequencies differed"
- "The analysis has the ability to detect" → "The analysis can detect"
- "With respect to ancestry proportions" → "For ancestry proportions"
- "in terms of genetic diversity" → "in genetic diversity"

Exception: Single-word academic transitions ("Notably,", "Importantly,", "Interestingly,") are standard in research papers and should not be removed. Only flag them when stacked excessively (e.g., three in one paragraph).

---

### 17. Redundant multi-layered hedging

Problem: LLMs stack multiple hedging devices in a single sentence ("may suggest", "have the potential to", "beneficial effects", "in select populations"), creating vague, non-committal prose. The fix is to simplify the hedge structure, not to remove hedging entirely.

Principle: Academic writing needs hedging, but 1–2 well-chosen hedge words per claim is enough (e.g., "may reduce" or "may help reduce"). Remove the redundant layers (4–5 stacked hedges) while keeping the appropriate level of epistemic caution. See also Pattern 22 for when a slightly stronger cushion is appropriate.

Before (too many hedges stacked):
> These observations may suggest that the two sampled populations have the potential to display a somewhat closer genetic relationship under certain models.

After (single appropriate hedge retained):
> The observations suggest that the two sampled populations may be genetically closer under the models tested.

Not this (all hedging removed, which is too assertive for observational/exploratory findings):
> ~~The observations prove that the two populations shared a recent migration event.~~

Distinction:
- Direct observation supported by the data → "Haplogroup A was identified in 12 individuals."
- Model-dependent or exploratory inference → "is consistent with", "may reflect", or "under the fitted model"
- LLM-style stacked hedge → simplify without turning genetic affinity into demonstrated migration or admixture

---

### 18. Generic positive conclusions

Problem: Vague upbeat endings.

Before:
> The phylogenetic reconstruction placed 7 ancient sequences within clade A, with the same placement recovered in the sensitivity analysis. This groundbreaking result opens a new chapter in human history and promises to revolutionize our understanding of migration.

After:
> The phylogenetic reconstruction placed 7 ancient sequences within clade A. The same placement was recovered in the sensitivity analysis.

---

## LLM-specific word choice patterns

### 19. Informal "linked to" instead of academic "associated with"

Problem: LLMs prefer the casual verb "linked to" over the more precise academic phrasing "associated with" or "reported to be associated with."

Before:
> In the sampled dataset, haplogroup A has been linked to higher frequencies in population X than in population Y.

After:
> In the sampled dataset, haplogroup A was more frequent in population X than in population Y.

Do not blanket-swap every "link" to "associated with". Choose the verb that fits the context:
- Noun "link" (e.g., "the link between genetic differentiation and geographic distance"): leave unchanged.
- Data linkage: use "merge"/"combine". "successfully linked with genotype data" → "successfully merged with genotype data".
- Downstream consequence ("leads to / results in"): use "lead to". "is linked to increased allele frequency" → "is associated with a higher allele frequency".
- Reframe the whole clause when more natural: "was linked to ancestry from population A" → "was associated with an ancestry component modeled using population A".

Use "associated with" only when the relationship is genuinely a statistical/observational association.

---

### 20. Overuse of "Beyond" as a transition

Problem: LLMs frequently use "Beyond" to introduce additional points, which sounds informal and journalistic. In academic writing, "In addition to" is more standard.

Before:
> Beyond the analysis of principal components, we also examined haplogroup frequencies.

After:
> In addition to the analysis of principal components, we examined haplogroup frequencies.

---

### 21. Overuse of "via" instead of "through"

Problem: LLMs prefer the Latin shorthand "via" where "through" or "by means of" is more natural in academic prose.

Before:
> The ancestral-state estimates were obtained via a maximum-likelihood method.

After:
> The ancestral-state estimates were obtained using a maximum-likelihood method.

---

### 22. Overly assertive causal claims (insufficient hedging)

Problem: LLMs may turn allele-frequency similarity, clustering, or shared ancestry components into unqualified claims about migration, population replacement, or a specific direction of gene flow. The inference must reflect the study design and model assumptions.

Before:
> The shared genetic component demonstrates that population A migrated into population B.

After:
> The shared genetic component is consistent with genetic connections between populations A and B but does not establish the direction of migration.

Principle: Describe what the data actually establish. Genetic affinity does not by itself identify the migration direction, and shared ancestry components do not prove population continuity. Add an appropriate qualification or specify the supported inference rather than stacking empty hedge words. This complements Pattern 17, which removes redundant hedging.

---

### 23. Artificially condensed expressions

Problem: LLMs compress complex ideas into unnaturally compact forms, either by packing nouns into dash-compounds or by substituting abstract shorthand for concrete explanations. Academic writing should be expanded and readable.

Type A: compressed noun-dash phrases

Before:
> a drift–admixture–migration history

After:
> a history involving genetic drift, admixture, and migration

Before:
> a sample–node–calibration uncertainty problem

After:
> uncertainty in sample dates, node ages, and molecular-clock calibration

Type B: abstract shorthand without elaboration

Before:
> The relationships among drift, admixture, and migration suggest complex interplay in population history.

After:
> Genetic drift, admixture, and migration may each have contributed to the observed population structure, although their individual contributions were not resolved.

Principle: Expand opaque shorthand into clear relationships. Preserve established technical compounds such as "ancient DNA", "Y chromosome", "linkage disequilibrium", and "coalescent time" rather than paraphrasing or changing their meaning.

---

### 24. Avoid "where" as a non-locative connector

Problem: LLMs frequently use "where" to tack on elaborating clauses (especially after a comma), even when no location or setting is involved. In genetics manuscripts, this can obscure which population or numerical comparison a relative clause describes. Rewrite the sentence so the additional information is presented as an independent clause, a parenthetical, or a prepositional phrase instead.

Before:
> Haplogroup H was more frequent in population A than in population B, where its frequency was 0.18 rather than 0.31.

After:
> The frequency of haplogroup H was 0.31 in population A and 0.18 in population B.

Principle: Only keep "where" when it truly refers to a physical location, a dataset, or a well-defined conditional context (e.g., "in populations where the derived allele is present"). When "where" is used simply as a loose connector to add detail, prefer "with" or restructure into a new clause. Avoid substituting "in which" as the default replacement, because "in which" also reads as an LLM tell in academic prose, and a simple "with"-phrase, prepositional phrase, or new sentence is almost always more natural. Reserve "in which" for cases where no other construction works.

---

### 25. Avoid "yield" as a result verb

Problem: LLMs overuse "yield" (e.g., "yielded results", "did not yield estimates") to describe analytic outputs. In genetics manuscripts, more specific verbs such as "produce", "provide", "generate", or "fail to produce" read more naturally and precisely.

Before:
> The molecular-clock analysis did not yield stable estimates for clade A because too few dated ancient sequences were available.

After:
> The molecular-clock analysis failed to produce stable estimates for clade A because too few dated ancient sequences were available.

Principle: Replace "yield/yielded" with a more precise verb that matches the context: "produce/produced", "provide/provided", "generate/generated", or "fail to produce" for negative results. Reserve "yield" when it is an established term, for example sequencing yield or DNA extraction yield.

---

### 26. Minor word-choice refinements (remain, given)

"remain" → a be-verb (more natural in most contexts):
- Before: However, these interpretations remain speculative.
- After: However, these interpretations are still speculative.

"Given" → "due to" when it introduces a reason:
- Before: ...are still speculative given the small sizes of the subgroup samples.
- After: ...are still speculative due to the small sizes of the subgroup samples.

---

### 27. Preserve logical discourse markers (do not over-trim connectives)

Problem: Aggressive AI-pattern removal can strip the connectives that carry a paper's logic, leaving choppy, hard-to-read prose. This is a common failure mode of automated humanizing. Logical discourse markers are not AI tells; they are hallmarks of good human academic writing, and removing them is itself a defect.

Preserve (do not delete): Although / Whereas / Thus / Hence / Thereafter / In contrast / Conversely / Based on these results / To that end / As expected / In agreement with previous reports / Over and above. A measured "not only ... but also ..." (about once per paragraph) is also natural and should be kept. This refines Pattern 9, which targets only its *overuse*, not a single natural instance.

Distinguishing rule: ask whether the phrase *inflates meaning* (delete) or *makes logic explicit* (keep).
- "underscores the pivotal importance of ..." → inflates meaning → delete (Patterns 1, 7).
- "Based on these results, we examined ..." → makes logic explicit → keep.

Benchmark (the "sweet spot"): Well-written, pre-AI human papers chain discourse markers densely and naturally ("Based on these initial observations ... To that end ... As expected ... In agreement with previous reports ... Over and above the impact of [the main exposure] ...") while using no inflated AI vocabulary. Aim for that profile: trim inflated vocabulary and significance puffery, but keep the logical connectives that make the argument easy to follow.

Vary connectives by logical relation, but only to avoid near repetition, never for decoration. When you add or rewrite a connective (per Pattern 30), first identify the logical relation the sentence actually needs, then choose a marker that fits it. If the same marker was just used nearby, substitute another from the *same* relation group so the prose does not repeat mechanically. Common groups:
- Result / consequence: thus, hence, therefore, consequently, accordingly
- Addition: moreover, furthermore, in addition (and "additionally" once per paragraph, per Pattern 7)
- Contrast: however, in contrast, conversely, on the other hand
- Concession: although, albeit, nonetheless, nevertheless, even though
- Reason / grounds: because, since, as, given that
- Sequence / enumeration: first / second, to begin with

Guardrail (this is not an exception to Pattern 11): vary connectives only when the relation is genuinely present and a near-repeat would otherwise occur. Do not sprinkle uncommon connectives (albeit, thereby, whereby, heretofore) to "sound human". That is decoration, and it reads as artificial. Each connective must be earned by the logic of the sentence. Skilled human writers reach for "thus", "hence", "moreover", or "albeit" because the relation calls for it, not to diversify their vocabulary.

---

### 28. Re-contextualize over-condensed semantic links

Problem: LLMs compress a relation into an over-direct phrasing. Expand it into natural, contextualized wording.

- Before: Ancient samples may carry important information to reconstruct population history.
- After: Ancient samples may provide information relevant to reconstructing population history.

(See also Pattern 23 on artificially condensed expressions; Pattern 28 specifically targets over-direct *semantic* links rather than noun-dash compounds.)

---

### 29. Ornamental -ly intensifier adverbs

Problem: LLMs dress up sentences with -ly intensifiers that add emphasis but no information ("markedly reduced", "critically important", "remarkably consistent"). Well-edited genetics papers use -ly adverbs primarily *functionally*: to convey magnitude, frequency, direction, or calibration.

Words to watch (ornamental; delete or downgrade): markedly, remarkably, strikingly, dramatically, profoundly, critically, fundamentally, notably (as a mid-sentence adverb, e.g. "a notably higher rate"), significantly (with no statistical test behind it), increasingly, rapidly (figurative), uniquely, vastly, deeply, exceptionally, substantially (with no quantitative backing)

Functional adverbs to keep (these carry information): approximately, slightly, modestly, consistently, almost, only, largely, generally, relatively, "statistically significantly" / "differed significantly" (when an actual test result is being reported), substantially (when it refers to a real, stated effect-size difference)

Decision rule: Delete the adverb mentally and ask whether any information was lost. If nothing was lost, it was ornamental, so delete it or replace the emphasis with the concrete number or comparison it was gesturing at. If it conveyed magnitude, frequency, direction, or calibration, it is functional, so keep it.

Before:
> The inferred node age was remarkably consistent across calibrations, with estimates of approximately 4,200 and 4,300 years. This strikingly stable result critically strengthens the historical interpretation.

After:
> The inferred node ages were approximately 4,200 and 4,300 years under the two calibrations.

Benchmark (how well-written human papers use -ly adverbs): In genetics manuscripts, adverbs should quantify, compare, or qualify evidence. Examples include "the allele frequency was consistently higher across the sampled sites", "the inferred age differed slightly between calibrations", and "genetic differentiation was modest". These expressions convey frequency, magnitude, or calibration rather than praise. Aim for that profile.

(Note: Pattern 1's example "markedly reduced median survival" is the same defect viewed as significance inflation; Pattern 29 generalizes it to all ornamental intensifiers.)

---

### 30. Connective-preserving edits (never bare-delete a transition)

Problem: When an AI-pattern sentence opener is removed (an "Additionally," beyond the once-per-paragraph allowance, an "-ing" tail per Pattern 3, significance inflation per Pattern 1), the logical relation it marked (addition, contrast, or consequence) still exists between the sentences. Deleting the marker without replacing it produces bare, disconnected sentences (asyndeton). Choppy, connective-stripped prose is itself a tell of automated AI cleanup, and a known failure mode of humanizing passes.

Rule: edit, don't excise. Whenever you remove a sentence-initial transition or a clause that carried the link to the previous sentence, restore the link by one of:
1. Substituting a natural connective: "In addition," / "Moreover," / "However," / "By contrast," / "We also found that ..."
2. Echoing a key noun from the previous sentence at the start of the new sentence (old-to-new information flow): "... showed higher haplogroup diversity. Haplogroup diversity, in turn, ..."
3. Restructuring the two sentences into one with an explicit conjunction.

Before (the AI text):
> Additionally, haplogroup A occurred in 12 ancient individuals, highlighting its importance. Additionally, 8 of these individuals had direct radiocarbon dates.

Wrong fix (bare deletion, which creates choppy asyndeton):
> Haplogroup A occurred in 12 ancient individuals. Eight of these individuals had direct radiocarbon dates.

Right fix (connective preserved):
> Haplogroup A occurred in 12 ancient individuals, and 8 of them also had direct radiocarbon dates.

Division of labor with Pattern 27: Pattern 27 lists the discourse markers you must not *remove*; Pattern 30 governs what you must do when an edit *would otherwise leave a gap*: replace or restructure, never just cut.

---

### 31. Paragraph cohesion (old-to-new flow and paragraph-opening markers)

Problem: Sentence-level edits accumulate into paragraph-level damage: topic sentences get blunted, the chain from one sentence to the next breaks, and the contrast/continuity markers that tie paragraphs together disappear. Well-written human papers are tightly chained.

What well-written human papers do:
- Within a paragraph, each sentence picks up a key word from the previous one (old-to-new flow), e.g. "haplogroup A was present in 12 individuals. These individuals came from two sites. The sites differed in sampling age." The repeated terms ("individuals" and "sites") chains the sentences so the reader is never dropped.
- Between paragraphs, the opening sentence names what the paragraph is about and, where the logic requires it, carries an explicit marker: "However, ...", "On the other hand, ...", "In addition to the differential effects described above, it is worth noting that ...", or "Taken together, the results suggest ...".

Checklist (apply to every paragraph after editing):
1. Does the first sentence state what the paragraph claims or covers?
2. From the second sentence on, is each sentence linked to the previous one by either a connective or an echoed key word? If a link was broken by an edit, restore it (Pattern 30).
3. Across paragraphs, are the contrast/continuity openers (However / In contrast / On the other hand / Overall / Taken together / In addition to X) still present where the argument needs them? Add one if a paragraph now starts abruptly.

---

### 32. Paraphrastic repetition of the same claim

Problem: LLMs restate the same claim 2–3 times using different words within the same paragraph or across adjacent sentences, often joined by "In other words," "That is," "Put differently," or "Essentially,". Each sentence should advance the argument, not rephrase the previous one.

Words to watch: In other words, That is, Put differently, Essentially, To put it another way, Simply put, This means that (when followed by a near-verbatim restatement)

Before:
> The two populations differed in allele frequencies. In other words, their allele-frequency profiles were not identical. Put differently, their genetic composition varied.

After:
> The two populations differed in allele frequencies.

Before:
> The estimated age of clade A was 4,200 years. In other words, the clade dated to about 4,200 years ago. Essentially, the node was approximately 4.2 thousand years old.

After:
> The estimated age of clade A was 4,200 years.

Principle: State each claim once. If a second sentence follows, it should add new information (a mechanism, a comparison, a qualification), not repackage the same assertion in different vocabulary. When removing paraphrastic repetitions, keep the version that is most specific or most precisely worded and delete the rest. Apply Pattern 30 (connective-preserving edits) if deletion would break the logical flow to the next sentence.

Exception: Genuine clarification of a technical term is not paraphrastic repetition. "The 95% credible interval extended from 3,500 to 4,900 years, making the uncertainty in the node-age estimate explicit" adds information by explaining the reported interval. The problem is when the "clarification" says the same thing in equally vague terms.

---

### 33. Content-free evaluation sentences

Problem: LLMs insert standalone sentences that evaluate a finding's importance without adding any information: no data, no mechanism, no comparison, just a verdict of significance. These are distinct from Pattern 1 (significance inflation embedded within data-bearing sentences) and Pattern 3 (-ing tails appended to factual sentences); Pattern 33 targets freestanding evaluation sentences that contain nothing but the evaluation itself.

Words to watch: This is an important/significant/noteworthy finding. These results have major historical significance. This observation changes our understanding of ancient populations. This finding has important implications. This is a meaningful/notable result. This deserves attention.

Before:
> Twelve of the 30 ancient individuals carried haplogroup A. This is a noteworthy finding. The result was reproduced in the high-coverage subset. This discovery is of major historical significance.

After:
> Twelve of the 30 ancient individuals carried haplogroup A. The result was reproduced in the high-coverage subset.

Principle: If the finding is genuinely significant, show why: state the relevant genetic comparison, methodological consequence, or contrast with prior evidence. A sentence that merely labels a finding as "important" without explaining what makes it important adds no information and should be deleted. When deleting, apply Pattern 30 (connective-preserving edits) to maintain flow.

Exception: An evaluation sentence is acceptable when it immediately follows up with a specific reason: "This difference matters because the two calibrations produced different uncertainty intervals for the same node age." Here, the evaluation carries forward into a concrete implication. The standalone, terminal evaluation ("This is important." Full stop.) is the problem.

---

### 34. Sentence rhythm and structural diversity (burstiness), in the service of clarity

Burstiness is required, but never at the cost of clarity. Upstream experiments reported lower AI-detector scores after sentence restructuring, but such scores do not establish authorship or scientific quality. AI-generated text converges on a narrow band of sentence lengths (typically 15-25 words) with uniform Subject-Verb-Object openings; human writing mixes short and long sentences with varied openings. Every paragraph of three or more sentences must show this variation (see the Benchmark below for the criterion). Obtain it only through edits that keep actors, comparisons, conditions, and logical links explicit (see Reader clarity before compression).

What to change (structure only, not vocabulary):
1. Split sentences that stack conditions or comparisons. A sentence that makes readers hold several conditions in memory is both a clarity defect and a source of long-sentence uniformity. Split it so each sentence carries one comparison or condition.
2. Combine adjacent supporting sentences (not claim sentences) when they share a logical relation, using a conjunction or a semicolon that names that relation. Do this only when it suits the source paragraph.
3. Diversify sentence openings. If three consecutive sentences start with a noun-phrase subject, restructure one to open with a prepositional phrase ("In this dataset,"), a subordinate clause ("Although the ancient sample was small,"), or a connective ("However,").
4. Relocate clause elements. Move a qualifying phrase from the end to the beginning, or vice versa: "In the ancient subset, diversity was lower" vs. "Diversity was lower in the ancient subset."

What not to change:
- Do not merge an existing short sentence that states a claim outright ("The largest difference was cost.") into its neighbor; see Voice calibration. Such sentences already supply the short end of the rhythm. Obtain the remaining variation from the supporting sentences around them
- Do not introduce staccato drama (multiple new very short sentences in a row for rhetorical effect)
- Do not merge sentences in a way that hides which comparison or condition applies to which result
- Do not alter technical vocabulary, data, or the author's approved strength of interpretation
- Do not break the connective structure (Pattern 27/30/31 still apply)
- Do not change the voice (active/passive) of the original unless this is needed to make the actor explicit (see Reader clarity before compression)

Interaction with Pattern 29 (ornamental adverbs): Removing an adverb may leave a paragraph with repetitive sentence structure. After removing ornamental adverbs, re-check the paragraph's rhythm; if it has become uniform, restructure one of the supporting sentences.

Before (uniform explanatory rhythm, illustrative data):
> Haplogroup A occurred in 12 of the ancient individuals included in the phylogenetic analysis. The same haplogroup occurred in 8 of the modern individuals included in the comparison. The ancient individuals came from two archaeological sites represented in the sampled region. The modern individuals came from three sampling locations represented in the same region.

After (clearer structure with varied length):
> Haplogroup A occurred in 12 ancient individuals and 8 modern individuals. The ancient samples came from two archaeological sites, whereas the modern samples came from three sampling locations in the same region.

Benchmark (editorial heuristic, not a diagnostic test): Sentence lengths in genetics articles naturally vary with the complexity of data and methods. Use the original 5-word range check to identify paragraphs worth reviewing, not to force stylistic changes when the text is already clear.

Criterion (used in the self-audit and the final rhythm check): A paragraph of three or more sentences is too uniform if all of its sentences fall within a 5-word range of each other. Restructure it until at least one sentence is notably shorter and one notably longer than the paragraph average.

Clarity example (illustrative, not research evidence). Splitting a compressed sentence often adds rhythm and clarity together:
- Dense: `Using age-matched ancient samples from both regions and identical SNP filters, the models indicated greater affinity despite reduced sample sizes.`
- Clearer: `We analyzed age-matched ancient samples from both regions using identical SNP filters. The models indicated greater genetic affinity, although the sample sizes were smaller.`

Name the actual comparison populations, filters, and models where needed for the argument. Do not invent them to complete an ambiguous sentence. See [reader clarity](references/reader-clarity.md) for the full audit.

---

## Process (two-pass draft-audit)

### Pass 1: draft rewrite

1. Read the input text carefully.
2. Audit meaning and information priority first. Identify unclear referents, omitted comparisons, stacked conditions, and redundant summary sentences using references/reader-clarity.md. Restore necessary relations without inventing facts.
3. Restructure sentence rhythm (Pattern 34). Before touching vocabulary, vary sentence lengths and diversify sentence openings across each paragraph. Keep the author's short claim sentences short; take the variation from the supporting sentences.
4. Identify and fix all vocabulary/phrase-level patterns (Patterns 1-33). After removing a transition or linking clause, check whether the logical relationship remains clear. Add a link only when needed; do not replace redundant summaries with generic bridge sentences. After removing ornamental adverbs (Pattern 29), re-check that the paragraph's rhythm has not become uniform.
5. Ensure the draft:
   - Sounds natural when read in an academic context
   - Matches the provided author style or the neutral scientific style (Voice calibration section)
   - Uses precise, specific language with consistent terminology (Pattern 11)
   - Maintains data integrity (numbers, statistics, findings)
   - Uses simple constructions (is/are/has) where appropriate
   - Avoids promotional or inflated language

### Pass 2: self-audit

6. Ask yourself: "What makes this draft still look AI-generated?" List any remaining tells briefly. Common survivors include:
   - Omitted comparison conditions or ambiguous pronouns that force readers to reconstruct meaning
   - A subject that does not naturally perform its verb, or wording that hides who judged or acted and on what basis (see Subject and verb compatibility)
   - Sentence lengths still too uniform (check the Pattern 34 criterion: in paragraphs of three or more sentences, do all sentences fall within a 5-word range?)
   - Sentence openings still repetitive (check: do three+ consecutive sentences start the same way?)
   - Vocabulary tells that slipped through (check Patterns 1, 7, 29 word lists)
   - Broken connective chain (check Pattern 31 checklist)
7. Fix every issue found in the self-audit.

### Mandatory final checks

When you can run commands, start these checks by running the bundled checker once on the draft. It counts what is easy to miscount: the words in each sentence of every paragraph, em dashes, curly quotes, repeated sentence openers, and numbers that appear in the revision but not in the original.

```bash
python "${CLAUDE_SKILL_DIR}/scripts/humanizer_check.py" <<'HUMANIZER_EOF'
===ORIGINAL===
(the input text)
===REVISED===
(your draft)
HUMANIZER_EOF
```

The script is in the `scripts` folder next to this file. Use that path if the variable above is not set, and use `python3` if `python` is not available. For text that is already in files, pass the revised file as the argument and the original with `--original`.

Use the report as follows:
- Take its counts as the result of the em dash check and of the 5-word criterion in the rhythm check, then fix what it reports.
- Check each added number against the input. A number that the input spelled out as a word is fine.
- Read each candidate word in context. The list names candidates, and a legitimate use stays (see Preserve legitimate academic phrases).
- Run it at most twice: once on the draft and once after your fixes. Do not keep rewriting to clear the candidate list.
- Do not paste the report into your answer. Fold what you fixed into the summary of changes.

If the checker cannot run (no Python, no permission to run commands, or a chat without tools), do checks 8 to 11 by hand as written and continue. Do not ask the author to install anything.

8. Fidelity check: Compare the output with the input and any author-supplied sources. Every number, unit, statistic, date, named entity (population, haplogroup, SNP, ancient sample, software, author), and citation in the output must also appear in the input or in those sources, and every assertion must be grounded in the input. If anything is not, revert that span to the input's wording or replace it with a `[DATA NEEDED: ...]` placeholder. Do not rewrite around the problem.
9. Em dash check: Search your output for "—". If any remain, replace them. Zero em dashes allowed.
10. Paragraph cohesion check (Pattern 31): Re-read every paragraph top to bottom: (a) first sentence states the paragraph's claim; (b) every subsequent sentence is linked to the previous one by a connective or echoed key word; (c) paragraph-opening contrast/continuity markers survive where the argument needs them. If any link was broken, repair it. Choppy, disconnected prose is not acceptable humanized output.
11. Rhythm and readability check (Pattern 34): This check is mandatory. (a) Apply the Pattern 34 criterion to every paragraph of three or more sentences. If all sentences fall within a 5-word range of each other, restructure at least one supporting sentence (split a sentence that stacks conditions, combine related supporting sentences, or reposition clauses). Never merge a short claim sentence to do this. (b) Re-read for one-pass comprehension: no restructuring may hide an actor, comparison, or condition. Remove redundant summaries; preserve concrete interpretation, necessary qualifications, and approved author opinions.
12. Present the humanized version.

## Output format

Provide:
1. The rewritten text
2. A brief summary of changes made, noting which patterns were applied and any rhythm restructuring performed
3. Fidelity check result: confirm that every number, statistic, named entity, and citation in the output appears in the input or in author-supplied sources, and name any span you reverted
4. A list of every `[DATA NEEDED: ...]` placeholder inserted, so the author can fill each one
5. If any: "Candidate data for the author (unverified, not inserted)", listing figures or references you recalled that might fill a placeholder or support a vague claim. The author must verify each one against the primary source before using it

---

## Full example

The following numbers and labels are hypothetical editing examples, not research findings or citations.

Before (AI-sounding):
> Y chromosome haplogroup A represents a pivotal element in the evolving landscape of human genetic history. This groundbreaking study showcases its profound relevance, with 12 of 30 ancient individuals carrying the lineage. These exciting results underscore its lasting legacy.
>
> Studies have shown that ancient populations were diverse. Additionally, the estimated age of clade A was 4,200 years, a remarkable milestone highlighting the value of molecular-clock dating. The 95% credible interval was 3,500 to 4,900 years, demonstrating the precision of this transformative approach.
>
> Despite the challenges of ancient DNA analysis, including the fact that 9 of 28 ancient genomes had less than 0.5-fold coverage, the future looks bright for genetic reconstructions of this fascinating region.

After (Humanized):
> Twelve of the 30 ancient individuals carried Y chromosome haplogroup A.
>
> The estimated age of clade A was 4,200 years, with a 95% credible interval of 3,500 to 4,900 years.
>
> Nine of the 28 ancient genomes had less than 0.5-fold coverage.

Changes made:
- Removed significance inflation, promotional wording, and generic positive conclusions (Patterns 1, 4, and 18)
- Deleted an unsupported attribution and a formulaic challenges sentence while retaining the actual coverage limitation (Patterns 5 and 6)
- Kept node-age estimates separate from the dates of sampled individuals
- Preserved all retained numerical values and uncertainty intervals without inferring population continuity or migration
- Removed rhetorical summaries and retained concise statements of measured results

The revised text contains no new empirical facts. The illustrative input's numbers were retained where the corresponding finding remained relevant; numbers belonging only to removed filler were not invented or replaced.
---

## Reference

The 34 patterns and checking workflow derive from the upstream [humanizer_academic](https://github.com/matsuikentaro1/humanizer_academic) project (MIT license) and [Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing). This is a domain adaptation, not a scientific source. All population-genetic examples are newly written hypothetical illustrations. See README.md for upstream references and attribution.
