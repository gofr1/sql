Non-SARGable Predicates:

function(column) = something.
column + column = something.
column + value = something.
column = @something or @something IS NULL.
column like ‘%something%’.
column = case when.

Bad side effects:

Increased CPU.
Index Scans (when you could have Seeks).
Implicit Conversion.
Poor Cardinality Estimates.
Inappropriate Plan Choices.
Long Running Queries.