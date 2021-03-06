% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/model_validation.R
\name{run_validation}
\alias{run_validation}
\title{Run EPIDEMIA model validation statistics}
\usage{
run_validation(
  date_start = NULL,
  total_timesteps = 26,
  timesteps_ahead = 2,
  reporting_lag = 0,
  per_timesteps = 12,
  skill_test = TRUE,
  epi_data = NULL,
  env_data = NULL,
  env_ref_data = NULL,
  env_info = NULL,
  casefield = NULL,
  groupfield = NULL,
  populationfield = NULL,
  obsfield = NULL,
  valuefield = NULL,
  fc_model_family = NULL,
  report_settings = NULL,
  ...
)
}
\arguments{
\item{date_start}{Date to start testing for model validation.}

\item{total_timesteps}{Number of weeks from (but including) `week_start` to
run validation tests.}

\item{timesteps_ahead}{Number of weeks for testing the n-week ahead forecasts.
Results will be generated from 1-week ahead through `weeks_ahead` number of
weeks.}

\item{reporting_lag}{Number of timesteps to simulate reporting lag. For
instance, if you have weekly data, and a reporting_lag of 1 week, and are
working with a timesteps_ahead of 1 week, then that is functional equivalent
to reporting lag of 0, and timesteps_ahead of 2 weeks. I.e. You are
forecasting next week, but you don't know this week's data yet, you only
know last week's numbers.}

\item{per_timesteps}{When creating a timeseries of validation results, create
a moving window with per_timesteps width number of time points. Should be a
minimum of 10 timesteps. In beta-testing.}

\item{skill_test}{Logical parameter indicating whether or not to run
validations also on two naïve models for a skill test comparison. The naïve
models are "persistence": the last known value (case counts) carried
forward, and "average week" where the predicted value is the average of that
week of the year, as calculated from historical data.}

\item{epi_data}{Epidemiological data with case numbers per week, with date
field "obs_date".}

\item{env_data}{Daily environmental data for the same groupfields and date
range as the epidemiological data. It may contain extra data (other
districts or date ranges). The data must be in long format (one row for each
date and environmental variable combination), and must start at absolutel
minimum \code{report_settings$env_lag_length} days (default 180) before
epi_data for forecasting.}

\item{env_ref_data}{Historical averages by week of year for environmental
variables. Used in extended environmental data into the future for long
forecast time, to calculate anomalies in early detection period, and to
display on timeseries in reports.}

\item{env_info}{Lookup table for environmental data - reference creation
method (e.g. sum or mean), report labels, etc.}

\item{casefield}{The column name of the field that contains disease case
counts (unquoted field name).}

\item{groupfield}{The column name of the field for district or geographic area
unit division names of epidemiological AND environmental data (unquoted
field name). If there are no groupings (all one area), user should give a
field that contains the same value throughout.}

\item{populationfield}{Column name of the optional population field to give
population numbers over time (unquoted field name). Used to calculated
incidence if \code{report_settings$report_value_type} = "incidence". Also
optionally used in Farrington method for populationOffset.}

\item{obsfield}{Field name of the environmental data variables (unquoted field
name).}

\item{valuefield}{Field name of the value of the environmental data variable
observations (unquoted field name).}

\item{fc_model_family}{The \code{\link[stats]{family}} parameter passsed to
\code{\link[mgcv:bam]{mgcv::bam}}, and the extended families in
\code{\link[mgcv]{family.mgcv}} can also be used. This sets the type of
generalized additive model (GAM) to run: it specifies the distribution and
link to use in model fitting. E.g. for a Poisson regression, the user would
input "poisson()". If a cached model is being used, set the parameter to
`"cached"`.}

\item{report_settings}{This is a named list of all the report, forecasting,
 event detection and other settings. All of these have defaults, but they are
 not likely the defaults needed for your system, so each of these should be
 reviewed:

 \itemize{

 \item \code{report_period} = 26: The number of weeks that the entire report
 will cover. The \code{report_period} minus \code{fc_future_period} is the
 number of weeks of past (known) data that will be included. Default is 26
 weeks.

 \item \code{report_value_type} = "cases": How to report the results, either
 in terms of "cases" (default) or "incidence".

 \item \code{report_inc_per} = 1000: If reporting incidence, what should be
 denominator be?  Default is per 1000 persons.

 \item \code{epi_date_type} = "weekISO": String indicating the standard (WHO
 ISO-8601 or CDC epi weeks) that the weeks of the year in epidemiological and
 environmental reference data use ("weekISO" or "weekCDC"). Required:
 epidemiological observation dates listed are LAST day of week.

 \item \code{epi_interpolate} = FALSE: TRUE/FALSE flag for if the given
 epidemiological data be linearly interpolated for any explicitly missing
 values before modeling?

 \item \code{epi_transform} = "none" (default if not set): Should the case
 counts be transformed just before regression modeling and backtransformed
 directly after prediction/forecast creation? The current only supported
 transformation is "log_plus_one", where log(cases + 1) is modeled and
 back-transformed by exp(pred) - 1 (though pmax(exp(pred) - 1, 0) is used in
 case of small predicted values).

 \item \code{model_run} = FALSE: TRUE/FALSE flag for whether to only generate
 the model regression object plus metadata. This model can be cached and used
 later on its own, skipping a large portion of the slow calculations for
 future runs.

 \item \code{model_cached} = NULL: The output of a previous model_run = TRUE
 run of run_epidemia() that produces a model (regression object) and
 metadata. The metadata will be used for input checking and validation. Using
 a prebuilt model saves on processing time, but will need to be updated
 periodically. If using a cached model, also set `fc_model_family =
 "cached"`.

 \item \code{env_var}: List environmental variables to actually use in the
 modelling. (You can therefore have extra variables or data in the
 environmental dataset.) Input should be a one column tibble, header row as
 `obsfield` and each row with entries of the variables (must match what is in
 env_data, env_ref-data, and env_info). Default is to use all environmental
 variables that are present in all three of env_data, env_ref_data, and
 env_info.

 \item \code{env_lag_length} = 181: The number of days of past environmental
 data to include for the lagged effects. The distributed lags are summarized
 using a thin plate basis function. Default is 181 days.

 \item \code{env_anomalies} = FALSE: TRUE/FALSE indicating if the
 environmental variables should be replaced with their anomalies. The
 variables were transformed by taking the residuals from a GAM with
 geographic unit and cyclical cubic regression spline on day of year per
 geographic group.

 \item \code{fc_start_date}: The date to start the forecasting, also the
 start of the early warning period. Epidemiological data does not have to
 exist just before the start date, though higher accuracy will be obtained
 with more recent data. The default is the week following the last known
 observation in /code{epi_data}.

 \item \code{fc_future_period} = 8: Number of future weeks from the end of
 the \code{epi_data} to produce forecasts, or if fc_start_date is set, the
 number of weeks from and including the start date to create forecasts.
 Synonymous with early warning period. Default is 8 weeks.

 \item \code{fc_clusters}: Dataframe/tible of geographic units and a cluster
 id. This clusters, or groups, certain geographic locations together, to
 better model when spatial non-stationarity in the relationship between
 environmental variables and cases. See the overview and data & mdoeling
 vignettes for more discussion. Default is a global model, all geographic
 units in one cluster.

 \item \code{fc_cyclicals} = FALSE: TRUE/FALSE flag on whether to include a
 smooth term based on day of year in the modeling (as one way of accounting
 for seasonality).

 \item \code{fc_splines}: The type of splines that will be used to handle
 long-term trends and lagged environmental variables. If supplemental package
 `clusterapply` is not installed, the default (and only choice) uses modified
 b-splines ('modbs'). If the package is installed, then 'tp' becomes an
 option and the default which uses thin plate splines instead.

 \item \code{fc_ncores}: The number of physical CPU cores available. Will be
 used to determine the multi-threading (or not) for use in modeling and
 predicting.

 \item \code{ed_summary_period} = 4: The number of weeks that will be
 considered the "early detection period". It will count back from the week of
 last known epidemiological data. Default is 4 weeks.

 \item \code{ed_method} = 'none': Which method for early detection should be
 used ("farrington" is only current option, or "none").

 \item \code{ed_control} = Controls passed along to the event detection
 method.  E.g. for `ed_method = 'farrington'`, these are passed to
 \code{\link[surveillance:farringtonFlexible]{surveillance::farringtonFlexible()}}.
  Currently, these parameters are supported for Farrington: `b`, `w`,
 `reweight`, `weightsThreshold`, `trend`, `pThresholdTrend`,
 `populationOffset`, `noPeriods`, `pastWeeksNotIncluded`, `thresholdMethod`.
 Any control not included will use surveillance package defaults, with the
 exception of `b`, the number of past years to include: epidemiar default is
 to use as many years are available in the data.


 }}

\item{...}{Accepts other arguments that may normally part of `run_epidemia()`,
but ignored for validation runs.}
}
\value{
Returns a nested list of validation results. Statistics are calculated
 on the n-week ahead forecast and the actual observed case counts. Statistics
 returned are  Mean Absolute Error (MAE), Root Mean Squared Error (RMSE). The
 first object is `skill_scores`, which contains `skill_overall` and
 `skill_grouping`. The second list is `validations`, which contains lists per
 model run (the forecast model and then optionally the naive models). Within
 each, `validation_overall` is the results overall, `validation_grouping` is
 the results per geographic grouping, and `validation_perweek` is the raw
 stats per week. Lastly, a `metadata` list contains the important parameter
 settings used to run validation and when the results where generated.
}
\description{
This function takes a few more arguments than `epidemiar::run_epidemia()` to
generate statistics on model validation. The function will evaluate a number
of weeks (`total_timesteps`) starting from a specified week (`date_start`) and
will look at the n-week ahead forecast (1 to `timesteps_ahead` number of
weeks) and compare the values to the observed number of cases. An optional
`reporting_lag` argument will censor the last known data back that number of
weeks. The validation statistics include Root Mean Squared Error (RMSE) and
Mean Absolute Error (MAE), and an R-squared staistic both in total and per
geographic grouping (if present).
}
