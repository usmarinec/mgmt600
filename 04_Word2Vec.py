import pandas as pd
pd.options.mode.chained_assignment = None
import numpy as np
import re
import nltk

from gensim.models import word2vec

from sklearn.manifold import TSNE
import matplotlib.pyplot as plt
#%matplotlib inline

## dataset import. We will compare two brands: apple & chanel
df = pd.read_csv("./script_inputs/apple.csv", encoding ="utf-8" )
df2 = pd.read_csv("./script_inputs/chanel.csv", encoding ="utf-8" )

col_list = ["text"]

## text preprocessing
STOP_WORDS = nltk.corpus.stopwords.words()

def clean_sentence(val):
    "remove chars that are not letters or numbers, downcase, then remove stop words"
    regex = re.compile('([^\s\w]|_)+')
    sentence = regex.sub('', val).lower()
    sentence = sentence.split(" ")
    
    for word in list(sentence):
        if word in STOP_WORDS:
            sentence.remove(word)  
            
    sentence = " ".join(sentence)
    return sentence

def clean_dataframe(df):
    "drop nans, then apply 'clean_sentence' function to question1 and 2"
    df = df.dropna(how="any")
    
    for col in ['text']:
        df[col] = df[col].apply(clean_sentence)
    
    return df

df = clean_dataframe(df)
df2 = clean_dataframe(df2)

## build corpus based on the Text column in df
def build_corpus(df):
    "Creates a list of lists containing words from each sentence"
    corpus = []
    for col in ['text']:
        for sentence in df[col].iteritems():
            word_list = sentence[1].split(" ")
            corpus.append(word_list)
            
    return corpus

corpus = build_corpus(df)
corpus2 = build_corpus(df2)

model = word2vec.Word2Vec(corpus, vector_size=100, window=20, min_count=100, workers=4)
model.wv['apple']
model2 = word2vec.Word2Vec(corpus2, vector_size=100, window=20, min_count=150, workers=4)
model2.wv['chanel']

def tsne_plot(model):
    "Creates and TSNE model and plots it"
    labels = []
    tokens = []

    for word in model.wv.key_to_index:
        tokens.append(model.wv[word])
        labels.append(word)
    
    tsne_model = TSNE(perplexity=40, n_components=2, init='pca', n_iter=2500, random_state=23)
    new_values = tsne_model.fit_transform(tokens)

    x = []
    y = []
    for value in new_values:
        x.append(value[0])
        y.append(value[1])
        
    plt.figure(figsize=(15, 15)) 
    for i in range(len(x)):
        plt.scatter(x[i],y[i])
        plt.annotate(labels[i],
                     xy=(x[i], y[i]),
                     xytext=(5, 2),
                     textcoords='offset points',
                     ha='right',
                     va='bottom')
    plt.show()

print(df)
print(df2)

print(corpus[0:2])
print(corpus2[0:2])

print(model.wv['apple'])
print(model2.wv['chanel'])

tsne_plot(model)
model.wv.most_similar("apple") 

tsne_plot(model2)
model2.wv.most_similar("chanel") 
