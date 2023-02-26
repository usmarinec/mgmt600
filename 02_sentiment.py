import pandas as pd
import csv
import nltk
from nltk.sentiment.vader import SentimentIntensityAnalyzer

nltk.download('vader_lexicon')

# import previously preprocessed dataset
df = pd.read_csv('./script_output/text_preprocessing.csv')
df["text"] = df["text"].apply(lambda s: str(s))

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

df["positive"] = df['text'].apply(nltk_sentiment_pos)
df['negative'] = df['text'].apply(nltk_sentiment_neg)
df['neutral'] = df['text'].apply(nltk_sentiment_neu)

print(df[['positive', 'neutral', 'negative']])

df.to_csv('./script_output/text_sentiment.csv')