# Food orders – speech to text to JSON – get a food order, use Azure AI Speech Cognitive service to transform 
# speech to text and then using Azure OpenAI GPT3.5 to extract a JSON object that represents the order and can be used to search in a Database
# In this case we are extracting restaurant order entities.
# try saying:  I would like to order a large burger which French fries and a large coke.

import azure.cognitiveservices.speech as speechsdk
from dotenv import load_dotenv
import pandas as pd
from openai import AzureOpenAI
import os


load_dotenv()

AZURE_OPENAI_KEY = os.getenv("AZURE_OPENAI_KEY") 
AZURE_OPENAI_ENDPOINT = os.getenv("AZURE_OPENAI_ENDPOINT")
AZURE_OPENAI_MODEL = os.getenv("AZURE_OPENAI_MODEL")

client = AzureOpenAI(
  azure_endpoint = AZURE_OPENAI_ENDPOINT, 
  api_key=AZURE_OPENAI_KEY,  
  api_version="2024-10-21"
)
SPEECH_KEY = os.getenv("SPEECH_KEY")
SPEECH_REGION = os.getenv("SPEECH_REGION")

def voice_to_text():
    speech_config = speechsdk.SpeechConfig(subscription=SPEECH_KEY, region=SPEECH_REGION)
    speech_config.speech_recognition_language="en-US"

    audio_config = speechsdk.audio.AudioConfig(use_default_microphone=True)
    speech_recognizer = speechsdk.SpeechRecognizer(speech_config=speech_config, audio_config=audio_config)

    print("Can I have your order please?")
    speech_recognition_result = speech_recognizer.recognize_once_async().get()

    if speech_recognition_result.reason == speechsdk.ResultReason.RecognizedSpeech:
        print("Text: {}".format(speech_recognition_result.text))
    return speech_recognition_result.text

def call_openAI(text):

    system_message = """
You are an assistant designed to extract entities from a food order transcript. 
Users will enter in a string of text and you will respond with entities you've extracted from the text as a JSON object. 
Here's an example of your output format:
[  
    {    
        main: {      
            type: "vegan burger",
            size: "large",
            cooking_degree: "medium",
            toppings: [        
                {
                    type: "lettuce",
                    quantity: 1,
                    size: "small"
                },        
                {
                    type: "tomato",
                    quantity: 1,
                    size: ""        
                },        
                {
                    type: "onion",
                    quantity: 2,
                    size: ""
                }      
            ]
        },
        drinks: {
            type: "pepsi cola",
            size: "large",
            additionals: [
                {
                    type: "ice",
                    quantity: 1,
                    size: "small"
                },
                {
                    type: "lemon",
                    quantity: 1,
                    size: ""
                }  
            ]
        }  
    }
]
"""

    message_text = [
        {"role":"system","content":system_message},
        {"role":"user","content":text}]
    response = client.chat.completions.create(
        model=AZURE_OPENAI_MODEL,
        messages = message_text,
        max_tokens=800,
       
    )

    return response.choices[0].message.content

#I would like to order two hamburgers with French fries, tomato, lettuce and mayonnaise and two large cokes and two ice creams
if __name__ == "__main__":
    text = voice_to_text()
    response = call_openAI(text)
    print(response)
