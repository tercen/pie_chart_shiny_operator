# Pie chart Shiny operator

##### Description

The `Pie chart Shiny operator` is a Shiny operator which allows you to plot a Pie chart
inside Tercen.

##### Usage

Input projection|.
---|---
`y-axis`        | count, number of occurrences of a specific label (see count operator)
`labels`        | label, the label for the corresponding count values

Output relations|.
---|---
`Operator view`        | view of the Shiny application

##### Details

Creates a Pie Chart based on the counts of a count operator and labels the counts according
to the label of the crosstab view.

##### See Also

[GitHub](https://github.com/tercen/pie_chart_shiny_operator)
[count](https://github.com/tercen/count_operator)