

### Aim

To estimate the numbers of circulating COVID-19 cases from recently reported
deaths, in places where surveillance has not revealed COVID-19 infections yet.




### Rationale

Deaths of COVID-19 cases are indicative of wider circulation of the disease in a
population. As the delay from onset to death and the case fatality ratio (CFR)
have been characterised, we can infer the likely date of onset of a death, and
the number of other cases (1/CFR) that had onset at the same time. From there,
we use a branching process model to simulate epidemic growth, and derive
estimates of the likely number of cases at present.




### Implementation

Our simulations are implemented as follows:

1. for each death, draw a likely date of onset from the onset-to-death delay
   distribution; obtain one date of onset per death

2. allocate a batch of $1/CFR$ cases to each date of onset; for each batch,
   simulate epi trajectories using a branching process (Poisson distribution)
   
3. add cases simulated from the different batches

4. repeat steps 1-3 a large number of times (`n_sim`), to reflect uncertainty on
   the actual dates of onsets

5. collate all simulations together and derive statistics from the simulations





### Parameters used

The following parameters are used:

* **serial interval**: mean of 4.7 days, s.d. of 2.9 days (log normal
  distribution fit); source:
  https://www.medrxiv.org/content/10.1101/2020.02.03.20019497v2.full.pdf.

* **Onset-to-death distribution**: a Gamma(4.726, 0.3151). Source:
  https://www.mdpi.com/2077-0383/9/2/538

* **$R_0$**: estimates vary across studies between 1.6 - 4. The default value
  used in simulations is 2, but we recommend examining results for other
  values. Source: https://wellcomeopenresearch.org/articles/5-17

* **CFR**: as $R_0$, these estimates should be varied; the default value is 2%




### Limitations

* the distribution of delays from onset to death is based on hospitalised cases;
  delays in non-hospitalised cases are likely to be shorter; the longer delays
  used in these simulations will likely lead to over-estimation of the number of
  cases
  
* the model assumes that deaths are independent, i.e. there are no underlying
  factors making deaths more likely in the cases observed
  
* the model assumes that infections inferred from every deaths took place
  independently (and can thus be summed), on separate branches of the
  transmission tree; if deaths are separated by longer periods of time, there is
  a risk that cases inferred belong to the same branch, in which case the model
  will over-estimate the number of cases
