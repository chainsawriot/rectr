import torch
from transformers import *

model_class, tokenizer_class = (BertModel, BertTokenizer)

model = model_class.from_pretrained("bert-base-multilingual-cased")
tokenizer = tokenizer_class.from_pretrained("bert-base-multilingual-cased")

def bert_word(text, model = BertModel.from_pretrained("bert-base-multilingual-cased"), tokenizer = BertTokenizer.from_pretrained("bert-base-multilingual-cased")):
    return(pipeline("feature-extraction", model = model, tokenizer = tokenizer)(text))

def bert_sentence(text, model = BertModel.from_pretrained("bert-base-multilingual-cased"), tokenizer = BertTokenizer.from_pretrained("bert-base-multilingual-cased"), max_length = 512):
    input_ids = tokenizer.encode(text, add_special_tokens = True, max_length = max_length, return_tensors = 'pt')		
    with torch.no_grad():
        output_tuple = model(input_ids)
    output = output_tuple[0].squeeze()
    output = output.mean(dim = 0)
    output = output.numpy()
    return(output)


def bert_tokenize(text, tokenizer = BertTokenizer.from_pretrained("bert-base-multilingual-cased")):
    return tokenizer.encode(text, add_special_tokens = False)

# def masked(text, model = BertModel.from_pretrained("bert-base-multilingual-cased"), tokenizer = BertTokenizer.from_pretrained("bert-base-multilingual-cased")):
#     return(pipeline("fill-mask", model = model, tokenizer = tokenizer)(text))
