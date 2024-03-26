Selection of feature vector

We considered various types of feature vectors that are broadly divided into two groups: amino acid descriptors and TAPE Transformer. Amino acid descriptors are feature vectors defined for each type of amino acid. We constituted a feature vector x of the PHBH protein by concatenating the feature vectors of the amino acids at the four mutated residues (i.e., V47, W185, L199 and L210).
  
Feature Vectors Based on Amino Acid Descriptors. 
 
  For a feature vector of each amino acid, we considered amino acid descriptors including ST-scale, Z-scale, T-scale, FASGAI, MS-WHIM, ProtFP, VHSE and BLOSUM-based features. On top of that, position-specific score matrix (PSSM) was used as a feature vector to incorporate the evolutionary information from PHBH homologues. Specifically, we constructed PSSM by PSI-BLAST iterative homology search using the wild-type PHBH sequence as a query against the nr database. The homology search was iterated five times, with 200 homologues used to update the PSSM per iteration. This produced a PSSM {s_ij} for each residue i and amino acid j. The PSSM-based feature vector of the PHBH protein was constructed by concatenating the PSSM values of the four mutated residues and their amino acids.
To select the optimal feature vector, we performed a feature selection procedure using the initial library as a benchmark dataset. For each feature vector, we conducted 5-fold nested cross validation where the hyperparameters of SVM and RBF kernel were optimized in the inner 5-fold cross validation, and the model performance was evaluated in the outer 5-fold cross validation by Spearman’s rank correlation. In this experiment, the combination of BLOSUM with PSSM (denoted as BLOSUM × PSSM) achieved the best performance (Figure S9a).

 Feature Vectors Based on TAPE Transformer

 In addition to the amino acid descriptors, we considered the feature vectors based on TAPE Transformer which is a representation learning model pre-trained on the Pfam database (denoted as BERT). In addition, we fine-tuned the pre-trained TAPE Transformer using PHBH homologues via a method proposed previously to incorporate the evolutionary information of PHBH (denoted as Evotuned-BERT). The performance of BERT and Evotuned-BERT were evaluated using the same benchmark experiment as that of amino acid descriptors. The prediction accuracy of Evotuned-BERT was better than that of BERT, and was comparable to BLOSUM x PSSM.

 

