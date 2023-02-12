import pandas as pd
from pandas import DataFrame
import nltk
from nltk import word_tokenize,pos_tag
nltk.download('punkt')
from nltk.corpus import stopwords
nltk.download('stopwords')
nltk.download('averaged_perceptron_tagger')
nltk.download('omw-1.4')
from nltk.stem import WordNetLemmatizer, PorterStemmer
nltk.download('wordnet')

# to get stocknews articles from csv file in script_output dir
df = pd.read_csv('./script_output/stocknews.csv')
df["text"] = df["text"].apply(lambda s: str(s))

# text preprocessing
# remove http or https
df["link"] = df["text"].apply(lambda s: " ".join(w for w in s.split() if w.startswith("http")))
df["AnalyzedTextWithoutHttp"] = df["text"].apply(lambda s: " ".join(w for w in s.split() if not w.startswith("http")))

## Lowercasing
df["AnalyzedTextWithoutHttpLowercase"] = df["AnalyzedTextWithoutHttp"].str.lower()

#Remove Extra Whitespaces
def remove_whitespace(text):
    return " ".join(text.split())

df["AnalyzedTextWithoutHttpLowercaseWithoutWhiteSpace"] = df["AnalyzedTextWithoutHttpLowercase"].apply(remove_whitespace)

# Tokenization
df["tokenization"] = df["AnalyzedTextWithoutHttpLowercaseWithoutWhiteSpace"].apply(lambda x: word_tokenize(x))

#Remove Stopwords
en_stopwords = stopwords.words('english')

def remove_stopwords(text):
    result = []
    for token in text:
        if token not in en_stopwords:
            result.append(token)
    return result

df["tokenizationStopword"] = df["tokenization"].apply(remove_stopwords)

##lematization
def lemmatization(text):
    
    result=[]
    wordnet = WordNetLemmatizer()
    for token,tag in pos_tag(text):
        pos=tag[0].lower()
        
        if pos not in ['a', 'r', 'n', 'v']:
            pos='n'
            
        result.append(wordnet.lemmatize(token,pos))
    
    return result

df['tokenizationStopwordLemmatization'] = df["tokenizationStopword"].apply(lemmatization)

##stemming
def stemming(text):
    porter = PorterStemmer()
    
    result=[]
    for word in text:
        result.append(porter.stem(word))
    return result

df['tokenizationStopwordLemmatizationStemming'] = df["tokenizationStopwordLemmatization"].apply(stemming)

## export final results to CSV
df.to_csv("./script_output/text_preprocessing.csv")
