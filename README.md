# README 

Paper title: **Beyond Monolithic Perturbation: Heterogeneous Mechanism Design for Multi-Attribute Metric Differential Privacy**

Submission Id: **6**

## Description
This repository contains the source code related to the methodologies and experiments presented in the paper titled **"Beyond Monolithic Perturbation: Heterogeneous Mechanism Design for Multi-Attribute Metric Differential Privacy"**. 

The file **`main_fe.m`** implements the **DepHDP-m** and **DepHDP-r** algorithm (*Dependency-aware Heterogeneous Data Perturbation*) proposed in the paper. DepHDP is a framework for multi-attribute mDP that combines dependency-aware grouping with heterogeneous perturbation design.

### Directory Structure
* MATLAB Code/Frequency Estimation/
* README.md

### Security/Privacy Issues and Ethical Concerns
There are no security or ethical concerns.

## Basic Requirements
### **Recommended Hardware Requirements**
- **Processor**: Dual-core CPU or higher
- **Memory**: 64 GB RAM (16 GB recommended for larger datasets)
- **Disk Space**: 2 GB of free space for MATLAB installation and artifact files

### **Supported Operating Systems**
- **Windows 10/11**
- **macOS Monterey/Ventura**
- **Ubuntu Linux 20.04/22.04**

## Environment 

### Set up the environment
The code was developed and tested using **MATLAB R2025b** with the **Optimization Toolbox**, **Symbolic Math Toolbox**, and **Statistics and Machine Learning Toolbox** installed. The toolboxes include the [**`linprog`**](https://www.mathworks.com/help/optim/ug/linprog.html) function for linear programming and the [**`randsample`**](https://www.mathworks.com/help/stats/randsample.html) function for random sample.

## Artifact Evaluation
### Main Results(displayed in Table 1) demo
#### Utility loss across different perturbation methods(Case I: Frequency Estimation)
It reports the utility loss of different perturbation methods under varying privacy budgets 𝜖. As expected, the utility loss consistently decreases as 𝜖 increases for all methods.
Overall, DepHDP (our method) achieves the lowest utility loss across all privacy budgets, clearly outperforming approaches based on SPL (uniform budget allocation) and ALLOC (optimized budget allocation across attributes). 

### Experiments 
The file **`main_fe.m`** is the driver script for the Frequency Estimation case. It contains the entire experimental workflow by sequentially invoking all major modules, from data and budget preparation to perturbation, utility loss evaluation, and final result analysis, ensuring a complete and reproducible experiment.
```matlab
cost_attribute3;                  % calculate cost mattrix for all groups

%%
distance_all_attribute_sets;      % calculate distance matrix for all groups
               
%% 
loss_calculation2;                % this can be done as a pre-calculate result, it takes much time in this step

%% 
epsilon_allocation;               % allocate different privacy budgets to different groups with an optimization method

%%
real_loss_r;                      % calculate the utility loss for DepHDP-r with allocated privacy budget

%%
real_loss_m;                      % calculate the utility loss for DepHDP-m with allocated privacy budget

%%
BS_SPL;                           % calculate the utility loss for SPL+DPN and SPL+RMP with splitted privacy budget

%%
OPT_PND;                          % calculate the utility loss for ALLOC+DPN with splitted privacy budget

%%
OPT_RMP;                          % calculate the utility loss for ALLOC+RMP with splitted privacy budget

%%
analyze_result;
```
