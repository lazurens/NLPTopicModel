# discursus_io_analysis
# Topic Modeling (Supervised vs Unsupervised):
There is two LDAs for both types of learning, yet they are totally different.
- Supervised (LDA) stands for: Linear Discriminant Analysis
- UnSupervised (LDA) stands for: Latent Dirichlet Allocation
So in our case inorder to extract the topics without any humain intervention, we need the Unsupervised learning version of topic modeling "Latent Dirichlet Allocation".

## Overview : Topic modeling with LDA(Latent Dirichlet Allocation)
In LDA, each document may be viewed as a mixture of various topics where each document is considered to have a set of topics that are assigned to it via LDA. This is identical to probabilistic latent semantic analysis (pLSA), except that in LDA the topic distribution is assumed to have a sparse Dirichlet prior. The sparse Dirichlet priors encode the intuition that documents cover only a small set of topics and that topics use only a small set of words frequently. In practice, this results in a better disambiguation of words and a more precise assignment of documents to topics. LDA is a generalisation of the pLSA model, which is equivalent to LDA under a uniform Dirichlet prior distribution.

For example, an LDA model might have topics that can be classified as Developement_related and freedom_related. A topic has probabilities of generating various words, such as growth, evolution, and increase, which can be classified and interpreted by the viewer as "Development_related".

Each tweets is assumed to be characterized by a particular set of topics. This is makes it part of the standard bag of words model assumption, and makes the individual words exchangeable.

# Packages:

  - topicmodels : An R Package for Fitting Topic Models.
  - LDAvis : R package for interactive topic model visualization.

# Steps of implementation: 

  - Tweets Collection/aqcuizition
  - Preprocessing : Tokenization and Stopwords
  - Vector Space : (Corpus Bag of words)
  - Model : LDA (R packages: gensim, topicmodels ...)
  - Evaluation
  - Visualization

# Progress of implementation: 

  - Tweets Collection/aqcuizition : Done :)
  - Preprocessing : Done (Can be improved)
  - Vector Space : Done
  - Model : Done
  - Evaluation : Manually done with no measures
  - Visualization : Inprogress
    - State: Trying to apply the visualization on an example that works with correct parameters and apply the code on our tweets.
# Main tasks 18/05 :

| Vis Variables | Description | Processing |
| ------ | ------ | ------ |
| phi | a matrix with the topic-term distributions | Okay
| theta | a matrix with the document-topic distributions | Okay
| doc.length | a numeric vector with token counts for each document | Not Okay
| vocab | a character vector containing the terms | Not Okay
| term.frequency | a numeric vector of observed term frequencies | Okay
    ## Issues: Error in LDAvis::createJSON(phi = phi, theta = theta, vocab = vocab, doc.length = doc_length,  :   Number of rows of phi does not match 
      number of columns of theta; both should be equal to the number of topics       in the model.
#### Solutions:
- http://stackoverflow.com/questions/36342754/convert-topicmodels-output-to-json
- https://www.r-bloggers.com/ldavis-show-case-on-r-bloggers/
## Issues : 
Error in LDAvis::createJSON(phi = phi, theta = theta, vocab = vocab, doc.length = doc_length,  : 
  Length of term.frequency 
      not equal to the number of terms in the vocabulary.

# Last Solution
We use the english stop words from the [SMART information retrieval system](http://en.wikipedia.org/wiki/SMART_Information_Retrieval_System), available in the R package **tm**.

### Using the R package 'lda' for model fitting

The object `documents` is a list where each element represents one document, according to the specifications of the **lda** package. After creating this list, we compute a few statistics about the corpus.

Next, we set up a topic model with 20 topics, relatively diffuse priors for the topic-term distributions ($\eta$ = 0.02) and document-topic distributions ($\alpha$  = 0.02), and we set the collapsed Gibbs sampler to run for 5,000 iterations (slightly conservative to ensure convergence). A visual inspection of `fit$log.likelihood` shows that the MCMC algorithm has converged after 5,000 iterations. This block of code takes about 4 minutes to run on a laptop using a single core 2.0Ghz processor (and 8GB RAM).

### Visualizing the fitted model with LDAvis

To visualize the result using [LDAvis](https://github.com/cpsievert/LDAvis/), we'll need estimates of the document-topic distributions, which we denote by the $D \times K$ matrix $\theta$, and the set of topic-term distributions, which we denote by the $K \times W$ matrix $\phi$. We estimate the "smoothed" versions of these distributions ("smoothed" means that we've incorporated the effects of the priors into the estimates) by cross-tabulating the latent topic assignments from the last iteration of the collapsed Gibbs sampler with the documents and the terms, respectively, and then adding pseudocounts according to the priors. A better estimator might average over multiple iterations of the Gibbs sampler (after convergence, assuming that the MCMC is sampling within a local mode and there is no label switching occurring).

We've already computed the number of tokens per document and the frequency of the terms across the entire corpus. We save these, along with $\phi$, $\theta$, and `vocab`, in a list as the data object `posttweets`.

Now we call the `createJSON()` function in **LDAvis**. This function will return a character string representing a JSON object used to populate the visualization. The `createJSON()` function computes topic frequencies, inter-topic distances, and projects topics onto a two-dimensional plane to represent their similarity to each other. It also loops through a grid of values of a tuning parameter, $0 \leq \lambda \leq 1$, that controls how the terms are ranked for each topic, where terms are listed in decreasing of *relevance*, where the relevance of term $w$ to topic $t$ is defined as $\lambda \times p(w \mid t) + (1 - \lambda) \times p(w \mid t)/p(w)$. Values of $\lambda$ near 1 give high relevance rankings to *frequent* terms within a given topic, whereas values of $\lambda$ near zero give high relevance rankings to *exclusive* terms within a topic. The set of all terms which are ranked among the top-`R` most relevant terms for each topic are pre-computed by the `createJSON()` function and sent to the browser to be interactively visualized utilizing D3 as part of the JSON object.

