import pandas as pd
import numpy as np
import re, os, json
import nltk
import gensim
import gensim.corpora as corpora
import spacy
from csv import writer
from os import listdir, walk
from os.path import isfile, join
from time import gmtime, strftime
from nltk.corpus import stopwords, wordnet
from sklearn.decomposition import LatentDirichletAllocation, TruncatedSVD
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
from sklearn.model_selection import GridSearchCV
from gensim.utils import simple_preprocess
from gensim.models import CoherenceModel
from spacy.lang.en import English
from pprint import pprint

nlp = spacy.load("en_core_web_sm")

## import dataset
df = pd.read_csv("./script_inputs/delta.csv")

###### Text Preprocessing ######
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

# Remove stop-words
# Declare the stopwords
nltk.download('stopwords')
stop_words = set(stopwords.words('english'))
df["AnalyzedText"] = df["AnalyzedTextWithoutHttpHashtagUserNameNonAlpha"].apply(lambda s: " ".join(w for w in s.split() if w.lower() not in stop_words))

# Convert to list
data = df.AnalyzedText.values.tolist()
data = [re.sub('\S*@\S*\s?', '', sent) for sent in data]

# Remove  new line characters
data = [re.sub('\s+', ' ', sent) for sent in data]
# Remove distracting single quotes
data = [re.sub("\'", "", sent) for sent in data]

# print(df)
# print(data)

###### Analysis ######

def sent_to_words(sentences):
    for sentence in sentences:
        yield(gensim.utils.simple_preprocess(str(sentence), deacc=True))

data_words = list(sent_to_words(data))

# Build the bigram and trigram models
bigram = gensim.models.Phrases(data_words, min_count=5, threshold=100) # higher threshold fewer phrases.
trigram = gensim.models.Phrases(bigram[data_words], threshold=100)  
# Phrases: Automatically detect common phrases – multi-word expressions / word n-grams – from a stream of sentences

# get a sentence clubbed as a trigram/bigram
bigram_mod = gensim.models.phrases.Phraser(bigram)
trigram_mod = gensim.models.phrases.Phraser(trigram)

# See bigram and trigram example
# print(bigram_mod[bigram_mod[data_words[0]]])
# print(trigram_mod[bigram_mod[data_words[0]]])

## Additional ANalysis ##

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
# pprint(lda_model.print_topics())
doc_lda = lda_model[corpus]
print("1")
print(lda_model.show_topic(topicid=0, topn=50))
print("2")
print(lda_model.show_topic(topicid=1, topn=50))
print("3")
print(lda_model.show_topic(topicid=2, topn=50))
print("4")
print(lda_model.show_topic(topicid=3, topn=50))
print("5")
print(lda_model.show_topic(topicid=4, topn=50))

np.savetxt("./script_output/TopicModeling_Topic1.csv", lda_model.show_topic(topicid=0, topn=50),delimiter=", ", fmt='% s')
np.savetxt("./script_output/TopicModeling_Topic2.csv", lda_model.show_topic(topicid=1, topn=50),delimiter=", ", fmt='% s')
np.savetxt("./script_output/TopicModeling_Topic3.csv", lda_model.show_topic(topicid=2, topn=50),delimiter=", ", fmt='% s')
np.savetxt("./script_output/TopicModeling_Topic4.csv", lda_model.show_topic(topicid=3, topn=50),delimiter=", ", fmt='% s')
np.savetxt("./script_output/TopicModeling_Topic5.csv", lda_model.show_topic(topicid=4, topn=50),delimiter=", ", fmt='% s')