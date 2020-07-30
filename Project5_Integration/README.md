# Part 5 - Integration

## 5.1 Addition of NLP heat recovery models (Part 4)

TBC

## 5.2 Scenario analysis

1. `$ ampl scenario.run`
2. log output is saved in files `scenarioX.log` (for X = 1–6)

## 5.3 Multi-objective optimisation

1. `$ ampl multiobjective.run`
    - set the objective function by uncommenting the relevant line of this section

        ```ampl
        # set objective (otherwise takes the first objective defined -- which is in the model)
        objective multiobj1;
        # objective multiobj2;
        # objective multiobj3;
        ```

        and don't forget to uncomment the corresponding line here

        ```ampl
        # initialise outputs
        # TO EDIT: change the first 2 elements of this set to the terms of your objective function (this is for MATLAB--it will use them as plot axes)
        #   You can also include other stuff that could be interesting to note on the plot here
        set multi_vars := {'CO2', 'InvCost', 'OpCost', 'TotalCost'}; # for multiobj1
        # set multi_vars := {'OpCost', 'InvCost', 'CO2', 'TotalCost'}; # for multiobj2
        # set multi_vars := {'CO2', 'TotalCost', 'OpCost', 'InvCost'}; # for multiobj3
        ```

2. useful output is printed to `multiobjective.dat` (no log file here)
    - you may wish to rename this file if you want to avoid it being overwritten at the next repeat
3. from MATLAB, run `paretoFront('multiobjective.dat')` to get a plot of the Pareto frontier
    - pass the optional second argument `dims` (`[width height]` in cm) to `paretoFront` to have the figure exported as .pdf and .fig
    - files will be named e.g. `pareto-front-CO2-InvCost` for the CO2/InvCost frontier
4. repeat

## 5.4 Sensitivity analysis

1. `$ ampl sensitivity.run`
    - this automatically runs through `c_spec{Grids}` (specific grid price) and `c_CO2{Layers}` (CO2 emissions factor)
    - note objective function is unchanged from main model (so still total cost)
2. useful output is printed to `sensitivity_TC_c_spec.dat` and `sensitivity_TC_c_CO2.dat`
3. from MATLAB, run `sensitivityPlot(file,dims)` where `file` is either of the two outputs, and `dims` (optional) is as defined above

### 5.4.2 Combined sensitivity & multiobjective analysis

1. return to `multiobjective.run` — except this time, uncomment one of the following lines to change the value of a specific parameter

    ```ampl
    # hack hacky hack -- Pareto frontiers for different grid prices
    # let c_spec['ElecGridBuy'] := 2 * 0.2514;
    # let c_spec['NatGasGrid'] := 2 * 0.111;
    # let c_CO2['Natgas'] := 2 * 0.27;
    ```

    - in this example values are multiplied by 2 — we used factors of 0.5 and 2 (alongside the original plot, which was for factor 1)
2. as before, useful output is printed to `multiobjective.dat`
3. from MATLAB, run `paretoFront('multiobjective.dat',dims)` to get a plot of the Pareto frontier
    - rename the output files — our convention is e.g. `pareto-front-CO2-InvCost-c_CO2-Natgas-200` for the CO2/InvCost frontier when the value of `c_CO2['Natgas']` was set to 2x (200%) its normal value
4. repeat from step 1 (for each parameter, for each multiplying factor on that parameter, for each objective)
    - this is a lot of (very sad) manual work, but I didn't get round to writing a master MATLAB script to automate everything 😭
5. in MATLAB, run `combine_figs.m` to superimpose the Pareto frontiers for different parameter values
    - the lines
    
        ```matlab
        for front = {'CO2-InvCost' 'CO2-TotalCost' 'OpCost-InvCost'}
        ```

        ```matlab
        for var = {'c_spec-ElecGridBuy' 'c_spec-NatGasGrid' 'c_CO2-Natgas'}
        ```
        
        determine for which frontiers a combined plot will be made showing the variation of a parameter (here there will be 9 plots)
    - the line `files = {[filePrefix '-' var '-50.fig'] [filePrefix '.fig'] [filePrefix '-' var '-200.fig']};` determines which multiplier values of the paramters will be used: here 50%, 100% (file has no suffix), 200%
        - remember to rename the legend accordingly if you change this! `legend('50%','100%','200%')`
    - obviously, for all this to work you need to have produced the relevant files from steps 1–4 above first
    - MATLAB spits out the combined plot as e.g. `pareto-front-CO2-InvCost-c_CO2-Natgas-overview`
