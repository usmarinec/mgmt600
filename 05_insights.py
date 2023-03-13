import pandas as pd
import numpy as np
import re, os, json
from csv import writer, reader
from os import listdir, walk
from os.path import isfile, join
from time import gmtime, strftime
from nltk.corpus import stopwords, wordnet
import nltk
from nltk.corpus import stopwords
import os
from os import listdir
## new libraries: sklearn and gensim: you need to install using analconda prompt or terminal as you installed instaloader.from sklearn.decomposition import LatentDirichletAllocation, TruncatedSVD
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
from sklearn.model_selection import GridSearchCV
## gensim
import gensim
import gensim.corpora as corpora
from gensim.utils import simple_preprocess
from gensim.models import CoherenceModel
import csv

from spacy.lang.en import English
import en_core_web_sm

from pprint import pprint
import pyLDAvis
import pyLDAvis.gensim_models as gensimvis

import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

from sklearn.manifold import TSNE
from bokeh.plotting import figure, output_file, show
from bokeh.models import Label
from bokeh.io import output_notebook

##sentiment analytsis
import nltk
from nltk.sentiment.vader import SentimentIntensityAnalyzer

## make a list for all text file on folder
new_list = []
file = open("./script_output/stocknews.csv", "r", encoding="utf8")
new_list= list(csv.reader(file, delimiter=","))

## make df from text list
import pandas as pd
from pandas import DataFrame
df = DataFrame(new_list[1:], columns=new_list[0])
##Text Preprocessing##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# remove http or https
df["link"] = df["text"].apply(lambda s: " ".join(w for w in s.split() if w.startswith("http")))
df["AnalyzedTextWithoutHttp"] = df["text"].apply(lambda s: " ".join(w for w in s.split() if not w.startswith("http")))

# Remove hashtag
df["hashtag"] = df["AnalyzedTextWithoutHttp"].apply(lambda s: " ".join(w for w in s.split() if w.startswith("#")))
df["AnalyzedTextWithoutHttpHashtag"] = df["AnalyzedTextWithoutHttp"].apply(lambda s: " ".join(w for w in s.split() if not w.startswith("#")))

# Remove username
df["user_mentioned"] = df["AnalyzedTextWithoutHttpHashtag"].apply(lambda s: " ".join(w for w in s.split() if w.startswith("@")))
df["AnalyzedTextWithoutHttpHashtagUserName"] = df["AnalyzedTextWithoutHttpHashtag"].apply(lambda s: " ".join(w for w in s.split() if not w.startswith("@")))

# Remove non-alphabatic
df["AnalyzedTextWithoutHttpHashtagUserNameNonAlpha"] = df["AnalyzedTextWithoutHttpHashtagUserName"].apply(lambda s: " ".join(w for w in s.split() if w.isalpha()))

nltk.download('stopwords')
stop_words = set(stopwords.words('english'))
df["AnalyzedText"] = df["AnalyzedTextWithoutHttpHashtagUserNameNonAlpha"].apply(lambda s: " ".join(w for w in s.split() if w.lower() not in stop_words))

# print(df.head(10))

data = df.AnalyzedText.values.tolist()
data = [re.sub('\S*@\S*\s?', '', sent) for sent in data]
# Remove  new line characters
data = [re.sub('\s+', ' ', sent) for sent in data]
# Remove distracting single quotes
data = [re.sub("\'", "", sent) for sent in data]
##END Text Preprocess~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

##Text Analysis~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## up to this point, we finished the data preprocessing. Now let's do the actual text analysis
def sent_to_words(sentences):
    for sentence in sentences:
        yield(gensim.utils.simple_preprocess(str(sentence), deacc=True)) 

data_words = list(sent_to_words(data))

## remember bigram and trigram? Let's check whether there is a differnce between usage of bigram vs trigram for text mining
# Build the bigram and trigram models
bigram = gensim.models.Phrases(data_words, min_count=5, threshold=100) # higher threshold fewer phrases.
trigram = gensim.models.Phrases(bigram[data_words], threshold=100)  
# Phrases: Automatically detect common phrases – multi-word expressions / word n-grams – from a stream of sentences

# get a sentence clubbed as a trigram/bigram
bigram_mod = gensim.models.phrases.Phraser(bigram)
trigram_mod = gensim.models.phrases.Phraser(trigram)

# See bigram and trigram example
# print(bigram_mod[bigram_mod[data_words[5]]])
# print(trigram_mod[bigram_mod[data_words[5]]])

## you can do additional analysis

def remove_stopwords(texts):
    return [[word for word in simple_preprocess(str(doc)) if word not in stop_words] for doc in texts]

def make_bigrams(texts):
    return [bigram_mod[doc] for doc in texts]

def make_trigrams(texts):
    return [trigram_mod[bigram_mod[doc]] for doc in texts]

# lemmatization: achieve the root forms
def lemmatization(texts, allowed_postags=['NOUN', 'ADJ', 'VERB', 'ADV']):
    """https://spacy.io/api/annotation"""
    texts_out = []
    for sent in texts:
        doc = nlp(" ".join(sent)) 
        texts_out.append([token.lemma_ for token in doc if token.pos_ in allowed_postags]) #token.lemma_: root of token; token.pos_: The simple part-of-speech tag ('NOUN', 'ADJ', 'VERB', 'ADV')
    return texts_out

# Remove Stop Words
data_words_nostops = remove_stopwords(data_words)

# Form Bigrams
data_words_bigrams = make_bigrams(data_words_nostops)

# print(data_words_bigrams[:10])

nlp = en_core_web_sm.load()
data_lemmatized = lemmatization(data_words_bigrams, allowed_postags=['NOUN', 'ADJ', 'VERB', 'ADV']) 
# print(data_lemmatized[:3])

##Create the Dictionary and Corpus needed for Topic Modeling
# Create Dictionary
id2word = corpora.Dictionary(data_lemmatized)

# Create Corpus
texts = data_lemmatized

# Term Document Frequency
corpus = [id2word.doc2bow(text) for text in texts]

# View
# print(corpus[:3])

# Build LDA model
lda_model = gensim.models.ldamodel.LdaModel(corpus=corpus,
                                           id2word=id2word,
                                           num_topics=5, 
                                           random_state=100,
                                           update_every=1,
                                           chunksize=100,
                                           passes=10,
                                           alpha='auto',
                                           per_word_topics=True)

# Print the Keyword in the 10 topics
pprint(lda_model.print_topics())
doc_lda = lda_model[corpus]

lda_viz = gensimvis.prepare(topic_model= lda_model, corpus = corpus , dictionary = id2word)
pyLDAvis.save_html(lda_viz, './script_output/insights_lda_viz.html')

## dominant topic
def format_topics_sentences(ldamodel=None, corpus=corpus, texts=data):
    # Init output
    sent_topics_df = pd.DataFrame()

    # Get main topic in each document
    for i, row_list in enumerate(ldamodel[corpus]):
        row = row_list[0] if ldamodel.per_word_topics else row_list            
        # print(row)
        row = sorted(row, key=lambda x: (x[1]), reverse=True)
        # Get the Dominant topic, Perc Contribution and Keywords for each document
        for j, (topic_num, prop_topic) in enumerate(row):
            if j == 0:  # => dominant topic
                wp = ldamodel.show_topic(topic_num)
                topic_keywords = ", ".join([word for word, prop in wp])
                sent_topics_df = sent_topics_df.append(pd.Series([int(topic_num), round(prop_topic,4), topic_keywords]), ignore_index=True)
            else:
                break
    sent_topics_df.columns = ['Dominant_Topic', 'Perc_Contribution', 'Topic_Keywords']
    # Add original text to the end of the output
    contents = pd.Series(texts)
    sent_topics_df = pd.concat([sent_topics_df, contents], axis=1)
    return(sent_topics_df)

df_topic_sents_keywords = format_topics_sentences(ldamodel=lda_model, corpus=corpus, texts=data_lemmatized)

# Format
df_dominant_topic = df_topic_sents_keywords.reset_index()
df_dominant_topic.columns = ['Document_No', 'Dominant_Topic', 'Topic_Perc_Contrib', 'Keywords', 'Text']
print(df_dominant_topic.head(10))
##document count
print(df_dominant_topic['Dominant_Topic'].value_counts())

#Get topic weights and dominant topics.........
# Get topic weights
topic_weights = []
for i, row_list in enumerate(lda_model[corpus]):
    topic_weights.append([w for i, w in row_list[0]])

# Array of topic weights    
arr = pd.DataFrame(topic_weights).fillna(0).values

# Keep the well separated points (optional)
arr = arr[np.amax(arr, axis=1) > 0.35]

# Dominant topic number in each doc
topic_num = np.argmax(arr, axis=1)

# tSNE Dimension Reduction
tsne_model = TSNE(n_components=2, verbose=1, random_state=0, angle=.99, init='pca')
tsne_lda = tsne_model.fit_transform(arr)

# Plot the Topic Clusters using Bokeh
# output_notebook()
n_topics = 5
mycolors = np.array([color for name, color in mcolors.TABLEAU_COLORS.items()])
plot = figure(title="t-SNE Clustering of {} LDA Topics".format(n_topics), 
              plot_width=900, plot_height=700)
plot.scatter(x=tsne_lda[:,0], y=tsne_lda[:,1], color=mycolors[topic_num])
show(plot)

# Sentence Coloring of N Sentences
from matplotlib.patches import Rectangle

def sentences_chart(lda_model=lda_model, corpus=corpus, start = 0, end = 13):
    corp = corpus[start:end]
    mycolors = [color for name, color in mcolors.TABLEAU_COLORS.items()]

    fig, axes = plt.subplots(end-start, 1, figsize=(20, (end-start)*0.95), dpi=160)       
    axes[0].axis('off')
    for i, ax in enumerate(axes):
        if i > 0:
            corp_cur = corp[i-1] 
            topic_percs, wordid_topics, wordid_phivalues = lda_model[corp_cur]
            word_dominanttopic = [(lda_model.id2word[wd], topic[0]) for wd, topic in wordid_topics]    
            ax.text(0.01, 0.5, "Doc " + str(i-1) + ": ", verticalalignment='center',
                    fontsize=16, color='black', transform=ax.transAxes, fontweight=700)

            # Draw Rectange
            topic_percs_sorted = sorted(topic_percs, key=lambda x: (x[1]), reverse=True)
            ax.add_patch(Rectangle((0.0, 0.05), 0.99, 0.90, fill=None, alpha=1, 
                                   color=mycolors[topic_percs_sorted[0][0]], linewidth=2))

            word_pos = 0.06
            for j, (word, topics) in enumerate(word_dominanttopic):
                if j < 14:
                    ax.text(word_pos, 0.5, word,
                            horizontalalignment='left',
                            verticalalignment='center',
                            fontsize=16, color=mycolors[topics],
                            transform=ax.transAxes, fontweight=700)
                    word_pos += .009 * len(word)  # to move the word for the next iter
                    ax.axis('off')
            ax.text(word_pos, 0.5, '. . .',
                    horizontalalignment='left',
                    verticalalignment='center',
                    fontsize=16, color='black',
                    transform=ax.transAxes)       

    plt.subplots_adjust(wspace=0, hspace=0)
    plt.suptitle('Sentence Topic Coloring for Documents: ' + str(start) + ' to ' + str(end-2), fontsize=22, y=0.95, fontweight=700)
    plt.tight_layout()
    plt.show()

sentences_chart()   

##sentiment analytics

def nltk_sentiment_pos(str):
    sid = SentimentIntensityAnalyzer()
    ss = sid.polarity_scores(str)
    return ss['pos']

def nltk_sentiment_neg(str):
    sid = SentimentIntensityAnalyzer()
    ss = sid.polarity_scores(str)
    return ss['neg']

def nltk_sentiment_neu(str):
    sid = SentimentIntensityAnalyzer()
    ss = sid.polarity_scores(str)
    return ss['neu']

def nltk_sentiment_compound(str):
    sid = SentimentIntensityAnalyzer()
    ss = sid.polarity_scores(str)
    return ss['compound']

df["positive"] = df["AnalyzedText"].apply(nltk_sentiment_pos)
df["negative"] = df["AnalyzedText"].apply(nltk_sentiment_neg)
df["neutral"] = df["AnalyzedText"].apply(nltk_sentiment_neu)
df["compound"] = df["AnalyzedText"].apply(nltk_sentiment_compound)

## merge df and dominant topics
dffinal = pd.concat([df, df_dominant_topic], axis=1, join = 'inner')

dffinal.to_csv("./script_output/insights_finalresult.csv", index = False)

## see each topic's sentiment
dffinal.groupby("Dominant_Topic")["positive"].mean()
dffinal.groupby("Dominant_Topic")["negative"].mean()
