# Reader clarity before compression

These editorial examples are illustrative, not research findings or sources to cite. Apply the principles across academic disciplines and adapt each revision to the actual evidence.

## What counts as compressed prose?

Compressed prose omits an actor, object, comparison, condition, or logical relationship that readers must reconstruct. The problem is not sentence length or technical vocabulary. A grammatically correct sentence can still leave an expert reader uncertain about what was compared, under which conditions, or what changed. Write for readers who know the field but may not be native English speakers.

Preserve concise sentences that are already clear. Do not expand every technical term, ban particular words, or split every long sentence. The goal is accurate understanding on the first reading, not the smallest word count.

## Eight diagnostic examples

### 1. Name what an abstract verb means

- Unclear: `The ancient genomes add information beyond the modern dataset.`
- Clearer, if the number of informative branches was measured: `Adding the ancient genomes increased the number of informative phylogenetic branches relative to the analysis of modern genomes alone.`

The word "adds" is not prohibited. The missing outcome and comparator are the problem. If the evidence does not support a specific outcome, do not invent one to complete the sentence. Treat it as a question for the author and mark it with a `[DATA NEEDED: ...]` placeholder (see "Be specific" in SKILL.md).

### 2. Give pronouns an unambiguous referent

- Unclear: `The two ancient sample groups differed in sample age and sequencing coverage. This explained the separation.`
- Clearer, if supported by the coverage-matched analysis: `The genetic separation was smaller after matching the groups by sequencing coverage.`

Identify what "this" and "the difference" refer to. Replacing a pronoun with a noun does not establish a causal explanation. Keep pronouns when their referents are clear.

### 3. Separate stacked comparison conditions

- Dense: `With matched inputs and fixed thresholds, A outperformed B under default settings at lower cost.`
- Clearer: `Both models received the same input. At the prespecified threshold, model A had higher sensitivity than model B under its default settings. Model A also cost less to run.`

Use the measured outcome instead of "outperformed." Specify which model used the threshold if this is not already clear. Do not pack input, threshold, settings, performance, and cost into one modifier structure.

### 4. Turn noun chains into actions

- Dense: `Coverage-based ancient genome selection improved data completeness.`
- Clearer, if supported by the data filtering described in the study: `Genomes were filtered by sequencing coverage before population structure analysis. The higher-coverage subset had fewer missing genotypes than the unfiltered dataset.`

Explain the filtering criterion, measured outcome, and comparator using the actual methods and results. Do not invent thresholds or read counts that the source text does not state.

### 5. Distinguish retrospective evaluation from prospective use

- Unclear claim: `The classifier enables error-free ancient-sample assignment.`
- Clearer: `Using the labeled validation dataset, we identified a threshold that correctly assigned every evaluated sample in that dataset.`

A threshold found after observing the correct labels does not show that users can select an error-free threshold for new, unlabeled data. Preserve the analysis; describe what it actually establishes. Claims of practical benefit must rely on information available during use.

### 6. State a connection instead of announcing one

- Redundant: `Performance also changed. Larger batches were faster but less sensitive.`
- Clearer: `Processing genomes in larger batches reduced runtime but also lowered assignment sensitivity.`

Remove empty preview sentences. Keep useful signposts such as "At the fixed threshold" and "In the retrospective analysis" when they distinguish comparison conditions.

### 7. Do not automatically summarize every paragraph

- Redundant: `The revised filters reduced missing genotypes and improved variant call consistency. These findings demonstrate benefits across multiple outcomes.`
- Clearer: `The revised filters reduced missing genotypes and improved variant call consistency.`

Delete a closing sentence if it merely restates concrete findings in abstract terms. Keep interpretations that connect findings to prior evidence or explain their meaning. Do not delete a substantive conclusion simply because it summarizes the paper.

### 8. Keep abstract methods and results aligned

If an abstract says that population structure, haplogroup distribution, and divergence times were analyzed but reports only population structure, either restore the relevant results or remove lower-priority objectives from the abstract's Methods. The abstract must remain consistent with the paper. Do not compress every result into shorthand merely to keep every topic.

## Shortening order

1. Identify the essential findings, comparison conditions, and interpretation.
2. Remove repetitive summaries, empty previews, and lower-priority sentences or topics. Check the role of any attached citations.
3. Remove redundant phrases without omitting actors, comparators, conditions, or outcomes.
4. Recount words and check that methods, results, and conclusions still correspond. If the limit cannot be met within the authorized scope without losing meaning, present the tradeoff to the author rather than silently exceeding it.

Do not automatically prioritize limitations and future-work sentences over the main findings in an abstract. They can be removed when lower priority, not required by the journal, and unnecessary to prevent a misleading claim. Preserve qualifications that materially change interpretation.

## Preserve the author's intended position

Do not weaken an explicitly approved opinion or expectation merely to make it sound conventionally cautious. For example, do not mechanically turn `We expect ... to clarify unresolved lineages ...` into `may potentially be useful ...`. Distinguish author opinion from an empirical finding. Flag factual claims that conflict with the evidence; preserving authorial voice does not authorize unsupported causal or superiority claims.

## Final audit

- Can the reader identify the actor, object, comparator, and conditions without guessing?
- Do pronouns, abstract verbs, and noun chains convey a specific meaning in context?
- Are related comparisons adjacent, with changes in conditions clearly signaled?
- Does each sentence add a finding, necessary condition, substantive interpretation, or useful connection?
- Does shortening preserve the correspondence between methods and results, including within the abstract?
- Have approved author opinions, technical terms, numbers, citation fields, and intentional section spacing been preserved?
- Have edits stayed within the requested scope, without inventing missing information? For example, a readability request for the Discussion does not authorize changes to the Methods or Results.

For an audit request, identify passages and explain the problem. For an authorized revision, make the changes and reread the result. Avoid substituting apologies or explanations of editorial preferences for actual manuscript improvements.
