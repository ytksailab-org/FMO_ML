Feature Vectors Based on Amino Acid Descriptors. 
 We considered various types of feature vectors that are broadly divided into two groups: amino acid descriptors and TAPE Transformer. Amino acid descriptors are feature vectors defined for each type of amino acid. We constituted a feature vector x of the PHBH protein by concatenating the feature vectors of the amino acids at the four mutated residues (i.e., V47, W185, L199 and L210). For a feature vector of each amino acid, we considered amino acid descriptors including ST-scale, Z-scale, T-scale, FASGAI, MS-WHIM, ProtFP, VHSE and BLOSUM-based features. On top of that, position-specific score matrix (PSSM) was used as a feature vector to incorporate the evolutionary information from PHBH homologues. Specifically, we constructed PSSM by PSI-BLAST iterative homology search using the wild-type PHBH sequence as a query against the nr database. The homology search was iterated five times, with 200 homologues used to update the PSSM per iteration. This produced a PSSM {s_ij} for each residue i and amino acid j. The PSSM-based feature vector of the PHBH protein was constructed by concatenating the PSSM values of the four mutated residues and their amino acids.

Connection of experimental data with amino acid descriptors
Matsushita_PHBH_20230501_22hplc.csv.unix is the experimental data of PHBH assay against 6. The amounts of 6-product were measured with HPLC. First, to connect this experimental data with amino acid descriptors, Matsushita_PHBH_ssf.pl was used as described below.

> for feat in BLOSUM FASGAI MS-WHIM T-scale ST-scale Z-scale VHSE ProtFP ; do
> perl Matsushita_PHBH_ssf.pl Matsushita_PHBH_20230501_22hplc.csv.unix ${feat} 4 > Matsushita_PHBH_20230501_PSSM_6hplc_${feat}.csv
> done

Next, to incorporate the evolutionary information from PHBH homologues, PSSM was used together with amino acids descriptors, as described below.

> for feat in BLOSUM FASGAI MS-WHIM T-scale ST-scale Z-scale VHSE ProtFP ; do
> perl Matsushita_PHBH_ssf.pl Matsushita_PHBH_20230501_6hplc.csv.unix ${feat} PSI-BLAST-200-5 4 > Matsushita_PHBH_20230501_PSSM_6hplc_${feat}.csv
> done

To select the optimal feature vector, we performed a feature selection procedure using the initial library as a benchmark dataset. For each feature vector, we conducted 5-fold nested cross validation where the hyperparameters of SVM and RBF kernel were optimized in the inner 5-fold cross validation, and the model performance was evaluated in the outer 5-fold cross validation by Spearman’s rank correlation. 

> for feat in BLOSUM FASGAI MS-WHIM T-scale ST-scale Z-scale VHSE ProtFP ; do
> python3 model_selection_svr.py spearman Matsushita_PHBH_20230501_6hplc_${feat}.csv 2>&1 > Matsushita_PHBH_20230501_svr_spearman_6hplc_${feat}.log
> done

> for feat in BLOSUM FASGAI MS-WHIM T-scale ST-scale Z-scale VHSE ProtFP ; do
> python3 model_selection_svr.py spearman Matsushita_PHBH_20230501_PSSM_6hplc_${feat}.csv 2>&1 > Matsushita_PHBH_20230501_svr_spearman_PSSM_6hplc_${feat}.log
> done

In this experiment, the combination of BLOSUM with PSSM (denoted as BLOSUM × PSSM) achieved the best performance. 

Feature Vectors Based on TAPE Transformer

In addition to the amino acid descriptors, we considered the feature vectors based on TAPE Transformer which is a representation learning model pre-trained on the Pfam database (denoted as BERT). In addition, we fine-tuned the pre-trained TAPE Transformer using PHBH homologues via a method proposed previously to incorporate the evolutionary information of PHBH (denoted as Evotuned-BERT). 

Connection of experimental data with amino acid descriptors
Matsushita_PHBH_20230501_6hplc.csv was used to connect the experimental data. Matsushita_PHBH_ssf.pl was used in an essentially same procedure.

> for feat in BERT Evotuned-BERT ; do
> perl Matsushita_PHBH_ssf.pl Matsushita_PHBH_20230501_6hplc.csv ${feat} 4 > Matsushita_PHBH_20230501_6hplc_${feat}.csv
> done

To evaluate the BERT and Evotuned-BERT, 5-fold nested cross validation were conducted in an essentially same procedure. 

> for feat in BERT Evotuned-BERT ; do
> python3 model_selection_svr.py spearman Matsushita_PHBH_20230501_22hplc_${feat}.csv 2>&1 > Matsushita_PHBH_20230501_svr_spearman_6hplc_${feat}.log
> done

The performance of BERT and Evotuned-BERT were evaluated using the same benchmark experiment as that of amino acid descriptors. The prediction accuracy of Evotuned-BERT was better than that of BERT, and was comparable to BLOSUM x PSSM. 

Construction of machine learning model

By considering the result of benchmark experiment, we decided to construct the machine learning model based on BLOSUM x PSSM. model_construction_svr.py was used for the construction of machine learning model as described below. The information and the accuracy of machine learning model are written in Matsushita_PHBH_20230501_model_con_svr_spearman_6hplc_BLOSUM_PSSM and Matsushita_PHBH_20230501_model_con_svr_spearman_6hplc_BLOSUM_PSSM.log, respectively.

> python3 model_construction_svr.py spearman Matsushita_PHBH_20230501_6hplc_BLOSUM_PSSM.csv Matsushita_PHBH_20230501_model_con_svr_spearman_6hplc_BLOSUM_PSSM 2>&1 > Matsushita_PHBH_20230501_model_con_svr_spearman_6hplc_BLOSUM_PSSM.log

Machine learning model based on Evotuned-BERT was constructed in an essentially the same procedure.

> python3 model_construction_svr.py spearman Matsushita_PHBH_20230501_6hplc_Evotuned-BERT.csv Matsushita_PHBH_20230501_model_con_svr_spearman_6hplc_Evotuned-BERT 2>&1 > Matsushita_PHBH_20230501_model_con_svr_spearman_6hplc_Evotuned-BERT.log

Prediction of the whole sequence pattern

By using the model constructed above, machine learning models for the prediction of whole sequence pattern were developed, separately.

A pair of seqence and feature vector was calculated by using Matsushita_PHBH_ssf_pred_split.pl as described below. 

> perl Matsushita_PHBH_ssf_pred_split.pl BLOSUM PSI-BLAST-200-5 4 Matsushita_PHBH_BLOSUM_PSSM_pred 1

model_prediction_svr.py was used for the prediction of the whole sequence pattern using BLOSUM_PSSM as described below. 

> python3 model_prediction_svr.py Matsushita_PHBH_BLOSUM_PSSM_pred_1.csv Matsushita_PHBH_20230501_model_con_svr_spearman_6hplc_BLOSUM_PSSM 2>&1 > Matsushita_PHBH_20230501_model_pred_svr_spearman_6hplc_BLOSUM_PSSM_rank

The prediction of the whole sequence pattern using Evotued-BERT was conducted in an essentially the same procedure.



